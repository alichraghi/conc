const std = @import("std");

/// Bell Sound
pub const BELL = "\x07";
/// Backspace
pub const BS = "\x08";
/// Tab
pub const HT = "\x09";
/// Line Feed
pub const LF = "\x0A";
/// From Feed
pub const FF = "\x0C";
/// Carriage Return
pub const CR = "\x0D";
/// ANSI Escape Code
pub const ESC = "\x1B";
/// Single Shift Two
pub const SS2 = "\u{8E}";
/// Single Shift Three
pub const SS3 = "\u{8F}";
/// Device Control String
pub const DCS = "\u{90}";
/// Control Sequence Introducer
pub const CSI = "\u{9B}";
/// String Terminator
pub const ST = "\u{9C}";
/// Operating System Command
pub const OSC = "\u{9D}";
/// Start of String
pub const SOS = "\u{98}";
/// Privacy Message
pub const PM = "\u{9E}";
/// Application Program Command
pub const APC = "\u{9F}";

pub const Until = enum {
    screen_start,
    screen_end,
    line_start,
    line_end,
};

pub const GraphicRendition = enum(u7) {
    reset = 0,
    bold = 1,
    dim = 2,
    italic = 3,
    underline = 4,
    blinking = 5,
    reverse = 7,
    hidden = 8,
    strike = 9,
    font_primary = 10,
    font_alt_1 = 11,
    font_alt_2 = 12,
    font_alt_3 = 13,
    font_alt_4 = 14,
    font_alt_5 = 15,
    font_alt_6 = 16,
    font_alt_7 = 17,
    font_alt_8 = 18,
    font_alt_9 = 19,
    font_gothic = 20,
    double_underline = 21,
    no_bold_or_dim = 22,
    no_italic = 23,
    no_underline = 24,
    no_blinking = 25,
    no_reverse = 27,
    no_hidden = 28,
    no_strike = 29,
    //      ...
    //     Color4
    //      ...
    frame = 51,
    encircle = 52,
    overline = 53,
    not_frame_or_encircle = 54,
    not_overline = 55,
    underline_color = 58,
    default_underline_color = 59,
    ideogram_underline = 60,
    ideogram_double_underline = 61,
    ideogram_overline = 62,
    ideogram_double_overline = 63,
    ideogram_stress_marking = 64,
    no_ideogram = 65,
};

pub const Color4 = enum(u7) {
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,
    default = 39,
    bright_black = 90,
    bright_red = 91,
    bright_green = 92,
    bright_yellow = 93,
    bright_blue = 94,
    bright_magenta = 95,
    bright_cyan = 96,
    bright_white = 97,
};

//
// Cursor
//

pub fn cursorPosZero(writer: anytype) !void {
    try writer.writeAll(CSI ++ "H");
}

pub fn setCursorPos(writer: anytype, row: usize, col: usize) !void {
    try writer.print(CSI ++ "{d};{d}H", .{ row + 1, col + 1 });
}

pub fn setCursorRow(writer: anytype, row: usize) !void {
    try writer.print(CSI ++ "{d}H", .{row + 1});
}

pub fn setCursorColumn(writer: anytype, column: usize) !void {
    try writer.print(CSI ++ "{d}G", .{column + 1});
}

pub fn cursorUp(writer: anytype, lines: u16) !void {
    try writer.print(CSI ++ "{d}A", .{lines});
}

pub fn cursorDown(writer: anytype, lines: u16) !void {
    try writer.print(CSI ++ "{d}B", .{lines});
}

pub fn cursorForward(writer: anytype, columns: u16) !void {
    try writer.print(CSI ++ "{d}C", .{columns});
}

pub fn cursorBackward(writer: anytype, columns: u16) !void {
    try writer.print(CSI ++ "{d}D", .{columns});
}

pub fn cursorNextLine(writer: anytype, lines: usize) !void {
    try writer.print(CSI ++ "{d}E", .{lines});
}

pub fn cursorPrevLine(writer: anytype, lines: usize) !void {
    try writer.print(CSI ++ "{d}F", .{lines});
}

pub fn saveCursor(writer: anytype) !void {
    try writer.writeAll(ESC ++ "s");
}

pub fn restoreCursor(writer: anytype) !void {
    try writer.writeAll(ESC ++ "u");
}

pub fn showCursor(writer: anytype) !void {
    try writer.writeAll(CSI ++ "?25h");
}

pub fn hideCursor(writer: anytype) !void {
    try writer.writeAll(CSI ++ "?25l");
}

/// after calling this, terminal reports the cursor position (CPR) by transmitting `ESC[<Row>;<Column>R`
pub fn requestCursorPos(writer: anytype) !void {
    try writer.writeAll(CSI ++ "6n");
}

//
// Clear
//

pub fn clearScreen(writer: anytype) !void {
    try cursorPosZero(writer);
    try writer.writeAll(CSI ++ "2J" ++ CSI ++ "3J");
}

pub fn clearLine(writer: anytype) !void {
    try writer.writeAll(CSI ++ "2K");
}

/// clear from cursor to to specified position
pub fn clearUntil(writer: anytype, until: Until) !void {
    try cursorPosZero();
    try writer.print(CSI ++ "{s}", .{switch (until) {
        .screen_start => "1J",
        .screen_end => "0J",
        .line_start => "1K",
        .line_end => "0K",
    }});
}

//
// Screen
//

pub fn saveScreen(writer: anytype) !void {
    try writer.writeAll(CSI ++ "?47h");
}

pub fn restoreScreen(writer: anytype) !void {
    try writer.writeAll(CSI ++ "?47l");
}

pub fn enableAltBuffer(writer: anytype) !void {
    try writer.writeAll(CSI ++ "?1049h");
}

pub fn disableAltBuffer(writer: anytype) !void {
    try writer.writeAll(CSI ++ "?1049l");
}

/// scroll whole page up by `lines`. new lines are added at the bottom
pub fn scrollUp(writer: anytype, lines: usize) !void {
    try writer.print(CSI ++ "{d}S", .{lines});
}

/// scroll whole page down by `lines`. new lines are added at the bottom
pub fn scrollDown(writer: anytype, lines: usize) !void {
    try writer.print(CSI ++ "{d}T", .{lines});
}

//
// Color, Graphic, etc
//

/// https://en.wikipedia.org/wiki/ANSI_escape_code#SGR
pub fn sgr(writer: anytype, mode: GraphicRendition) !void {
    try writer.print(CSI ++ "{d}m", .{@enumToInt(mode)});
}

/// https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit
pub fn fgColor4(writer: anytype, mode: Color4) !void {
    try writer.print(CSI ++ "{d}m", .{@enumToInt(mode)});
}

/// https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit
pub fn bgColor4(writer: anytype, mode: Color4) !void {
    try writer.print(CSI ++ "{d}m", .{@enumToInt(mode) + 10});
}

/// https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
pub fn fgColor8(writer: anytype, code: u8) !void {
    try writer.print(CSI ++ "38;5;{d}m", .{code});
}

/// https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
pub fn bgColor8(writer: anytype, code: u8) !void {
    try writer.print(CSI ++ "48;5;{d}m", .{code});
}

/// rarely implemented (Kitty, iTerm2, VTE, etc)
/// https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
pub fn underlineColor8(writer: anytype, code: u8) !void {
    try writer.print(CSI ++ "58;5;{d}m", .{code});
}

/// https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit
pub fn fgColorRGB(writer: anytype, r: u8, g: u8, b: u8) !void {
    try writer.print(CSI ++ "38;2;{d};{d};{d}m", .{ r, g, b });
}

/// https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit
pub fn bgColorRGB(writer: anytype, r: u8, g: u8, b: u8) !void {
    try writer.print(CSI ++ "48;2;{d};{d};{d}m", .{ r, g, b });
}

/// rarely implemented (Kitty, iTerm2, VTE, etc)
/// https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit
pub fn underlineColorRGB(writer: anytype, r: u8, g: u8, b: u8) !void {
    try writer.print(CSI ++ "58;2;{d};{d};{d}m", .{ r, g, b });
}

/// reset all SGR attributes off
pub fn resetSGR(writer: anytype) !void {
    try writer.writeAll(CSI ++ "0m");
}

//
// Other
//

/// in bracketed paste mode and you paste into your terminal the content will be wrapped by the sequences `ESC[200~` and `ESC[201~`.
/// https://cirw.in/blog/bracketed-paste
pub fn enableBracketedPasteMode(writer: anytype) !void {
    try writer.writeAll(CSI ++ "?2004h");
}

pub fn disableBracketedPasteMode(writer: anytype) !void {
    try writer.writeAll(CSI ++ "?2004l");
}

pub fn setWindowTitle(writer: anytype, title: []const u8) !void {
    try writer.print(OSC ++ "0;{s}" ++ BELL, .{title});
}

pub fn resetAll(writer: anytype) !void {
    try writer.writeAll(ESC ++ "c");
}

//
// Tests
//

test {
    const stderr = std.io.getStdErr().writer();

    try setWindowTitle(stderr, "Hello");
    try clearScreen(stderr);

    inline for (std.meta.fields(GraphicRendition)) |f| {
        try sgr(stderr, @field(GraphicRendition, f.name));
        try stderr.print(" {s} ", .{f.name});
        try resetSGR(stderr);
    }

    try sgr(stderr, .underline);
    try underlineColor8(stderr, 131);
    try stderr.writeAll(" uc8bit ");

    try underlineColorRGB(stderr, 0, 131, 0);
    try stderr.writeAll(" ucRGB ");
    try resetSGR(stderr);

    try sgr(stderr, .bold);

    inline for (std.meta.fields(Color4)) |f| {
        try bgColor4(stderr, @field(Color4, f.name));
        try stderr.print(" {s} ", .{f.name});
    }

    try bgColor4(stderr, .default);

    var i: u8 = 17;
    while (i < 255) : (i += 1) {
        try bgColor8(stderr, i);
        try stderr.print(" {d} ", .{i});
    }
    try stderr.writeAll("\n");
}
