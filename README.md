# AnsiConsole

A PowerShell module which supports ANSI console operations. This module provides
functions for colorizing and positioning on the console using ANSI escape
sequences. The functions create formatted output using ANSI escape sequences.

The easiest way to use the module is to pipe strings through `Set-AnsiConsole`,
passing the results back to the host terminal for display. For example:

```pwsh
   "This is red" | Set-AnsiConsole -Foreground BrightRed -Bold
   "This is using an RGB value and italics" | Set-AnsiConsole -ForegroundRGB FF3355 -Italic
```

Additional functions are provided for specific functionality, including bold, dim,
italic, underline, and foreground/background color settings. The color settings can
be configured using the 16 defined ANSI colors, the 256 palette colors, or RGB values
provided in hexadecimal format (with or without the leading `#`).

By default, the included functions will automatically apply an ANSI reset to the end
of each string. This can be disabled by using `Set-AnsiAutoReset` to configure the
default behavior:

```pwsh
Set-AnsiAutoReset $false
```
