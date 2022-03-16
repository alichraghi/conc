# conc

A ansi terminal that supports most implemented standards

## Installation

zigmod

```
zidmod aq add 1/alichraghi/conc
```

## Usage

```zig
const std = @import("std");
const conc = @import("conc");
const writer = std.io.getStdErr().writer();

pub fn main() !void {
  try conc.fgColor4(writer, .green);
  try writer.writeAll("hello");
}
```
