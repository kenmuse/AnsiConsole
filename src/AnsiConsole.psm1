Set-StrictMode -Version 'Latest'
#Requires -Version 5.1

#############################################
# Constants
#############################################

New-Variable -Name escape -Value [char]0x001B -Option Constant
New-Variable -Name csi -Value "$([char]0x001B)[" -Option Constant
New-Variable -Name textColorBase -Value 30 -Option Constant
New-Variable -Name backgroundColorBase -Value 40 -Option Constant

#############################################
# State Variables
#############################################

# Global setting which determines if ANSI graphics commands should be immediately
# reset after processing. This ensures each line only has the specified formats.
New-Variable -Name AnsiAutoReset -Value $true -Scope Script -Force

#############################################
# Enumerations
#############################################

enum AnsiColor {
    Black = 0
    Red = 1
    Green = 2
    Yellow = 3
    Blue = 4
    Magenta = 5
    Cyan = 6
    White = 7
    BrightBlack = 60
    BrightRed = 61
    BrightGreen = 62
    BrightYellow = 63
    BrightBlue = 64
    BrightMagenta = 65
    BrightCyan = 66
    BrightWhite = 67
}

enum AnsiClear {
    CursorToEnd = 0
    CursorToStart = 1
    All = 2
}

#############################################
# Functions
#############################################

function Set-AnsiCursorUp {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor up by some amount.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Move cursor up $Amount")) {
        return "${csi}${Amount}A"
    }
}

function Move-AnsiCursorDown {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor down by some amount.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Move cursor down $Amount")) {
        return "${csi}${Amount}B"
    }
}

function Move-AnsiCursorForward {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor forward by some amount.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Move cursor forward $Amount")) {
        return "${csi}${Amount}C"
    }
}

function Move-AnsiCursorBack {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor backward by some amount.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Move cursor backwards $Amount")) {
        return "${csi}${Amount}D"
    }
}

function Move-AnsiCursorNextLine {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor down by a number of lines.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Move cursor forward $Amount lines")) {
        return "${csi}${Amount}E"
    }
}

function Set-AnsiCursorPreviousLine {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor up by a number of lines.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Move cursor back $Amount lines")) {
        return "${csi}${Amount}F"
    }
}

function Move-AnsiCursorHorizontalAbsolute {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor horizontally to an absolute position
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [byte] $Column,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Set cursor to horizontal position $Column")) {
        return "${csi}${Column}G"
    }
}

function Move-AnsiCursorPosition {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for absolutely positioning the cursor on the screen.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [byte] $Row,
        [byte] $Column,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Move cursor to ($Row, $Column)")) {
        return "${csi}${row};${column}H"
    }
}

function Move-AnsiScrollUp {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for scrolling the screen up by a number of lines.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Scroll up $Amount lines")) {
        return "${csi}${Amount}S"
    }
}

function Move-AnsiScrollDown {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for scrolling the screen up by a number of lines.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Scroll down $Amount lines")) {
        return "${csi}${Amount}T"
    }
}

function Save-AnsiCursor {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for saving the current cursor position.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Save cursor position")) {
        return "${csi}s"
    }
}

function Restore-AnsiCursor {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for restoring a saved cursor position.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Restore cursor position")) {
        return "${csi}u"
    }
}

function Clear-AnsiDisplay {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to clear the display.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [AnsiClear] $Target,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess($Target, "Clear console")) {
        return "${csi}${Target}J"
    }
}

function Clear-AnsiLine {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to clear a line.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [AnsiClear] $Target,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess($target, "Clear current line")) {
        return "${csi}${Target}K"
    }
}

function Set-AnsiConsole {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to format the color and style of displayed text.
    #>
    [CmdletBinding(DefaultParameterSetName = "AnsiColor", SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [parameter(ParameterSetName = "AnsiColor")]
        [parameter(ParameterSetName = "RgbColor")]
        [string[]] $Text,

        [parameter(ParameterSetName = "AnsiColor")]
        [AnsiColor] $Foreground,

        [parameter(ParameterSetName = "AnsiColor")]
        [AnsiColor] $Background,

        [parameter(ParameterSetName = "RgbColor")]
        [string] $ForegroundRGB,

        [parameter(ParameterSetName = "RgbColor")]
        [string] $BackgroundRGB,

        [parameter(ParameterSetName = "AnsiColor")]
        [parameter(ParameterSetName = "RgbColor")]
        [switch] $Bold = $false,

        [parameter(ParameterSetName = "AnsiColor")]
        [parameter(ParameterSetName = "RgbColor")]
        [switch] $Underline = $false,

        [parameter(ParameterSetName = "AnsiColor")]
        [parameter(ParameterSetName = "RgbColor")]
        [switch] $Dim = $false,

        [parameter(ParameterSetName = "AnsiColor")]
        [parameter(ParameterSetName = "RgbColor")]
        [switch] $Italic = $false,
        [switch] $Force
    )

    process {
        $content = "${csi}"
        $commands = New-Object System.Collections.ArrayList
        if ($Dim) { [void]$commands.Add("2") }
        if ($Bold) { [void]$commands.Add("1") }
        if ($Italic) { [void]$commands.Add("3") }
        if ($Underline) { [void]$commands.Add("4") }

        if ($PSCmdlet.ParameterSetName -eq 'AnsiColor') {
            if ($PSBoundParameters.ContainsKey('Foreground')) {
                $color = $textColorBase + $Foreground
                [void]$commands.Add($color)
            }

            if ($PSBoundParameters.ContainsKey('Background')) {
                $color = $backgroundColorBase + $Background
                [void]$commands.Add($color)
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'RgbColor') {
            if ($PSBoundParameters.ContainsKey('ForegroundRGB')) {
                [void]$commands.Add("38")
                [void]$commands.Add("2")
                [void]$commands.AddRange(($ForegroundRGB | Convert-ToRgbArray))
            }
            if ($PSBoundParameters.ContainsKey('BackgroundRGB')) {
                [void]$commands.Add("48")
                [void]$commands.Add("2")
                [void]$commands.AddRange(($BackgroundRGB | Convert-ToRgbArray))
            }
        }

        if ($Force -or $PSCmdlet.ShouldProcess("console", "Set output format for text")) {
            $content = $content + ($commands.ToArray() -Join ";") + "m"
            foreach ($item in $Text) {
                return ($content + $item) | Format-AutoReset
            }
        }
    }
}

function Set-AnsiTextColor {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to set the text to one of the eight ANSI colors
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $Text,

        [parameter(Position = 0, Mandatory = $true)]
        [AnsiColor] $Color,
        [switch] $Force
    )

    process {
        if ($Force -or $PSCmdlet.ShouldProcess("console", "Set foreground text color to $Color")) {
            $content = "${csi}$($textColorBase + $Color)m"
            foreach ($item in $Text) {
                return ($content + $item) | Format-AutoReset
            }
        }
    }
}

function Set-AnsiBackgroundColor {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to set the background for the text to a specific color.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $Text,

        [parameter(Position = 0, Mandatory = $true)]
        [AnsiColor] $Color,

        [switch] $Force
    )

    process {
        if ($Force -or $PSCmdlet.ShouldProcess("console", "Set background color to $Color")) {
            $content = "${csi}$($backgroundColorBase + $Color)m"
            foreach ($item in $Text) {
                return ($content + $item) | Format-AutoReset
            }
        }
    }
}

function Set-AnsiTextPaletteColor {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to set the text to one of the 256 palette colors.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $Text,
        [Parameter(Position = 0)]
        [byte] $index,
        [switch] $Force
    )

    process {
        if ($Force -or $PSCmdlet.ShouldProcess("console", "Set text to palette color $index")) {
            $content = "${csi}38;5;${index}m"
            foreach ($item in $Text) {
                return ($content + $item) | Format-AutoReset
            }
        }
    }
}

function Set-AnsiBackgroundPaletteColor {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to set the background to one of the 256 ANSI palette colors.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $Text,
        [Parameter(Position = 0)]
        [byte] $index,
        [switch] $Force
    )

    process {
        if ($Force -or $PSCmdlet.ShouldProcess("console", "Set background to palette color $index")) {
            $content = "${csi}48;5;${index}m"
            foreach ($item in $Text) {
                return ($content + $item) | Format-AutoReset
            }
        }
    }
}

function Set-AnsiTextRgbColor {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to set the text to a specific RGB color.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [byte] $Red,
        [byte] $Green,
        [byte] $Blue,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Set text tp RGB ($Red, $Green, $Blue)")) {
        return "${csi}38;2;$Red;$Green;${Blue}m"
    }
}

function Set-AnsiBackgroundRgbColor {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to set the background to a specific RGB color.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param (
        [byte] $Red,
        [byte] $Green,
        [byte] $Blue,
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Set background to RGB ($Red, $Green, $Blue)")) {
        return "${csi}48;2;$Red;$Green;${Blue}m"
    }
}

function Reset-AnsiConsole {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to reset the console formatting.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [switch] $Force
    )

    process {
        if ($Force -or $PSCmdlet.ShouldProcess("console", "Reset all ANSI graphics states")) {
            return "${csi}0m"
        }
    }
}

function Set-AnsiBold {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to format the text bold.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Enable bold")) {
        return "${csi}1m"
    }
}

function Set-AnsiDim {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to format the text dim.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Enable dim")) {
        return "${csi}2m"
    }
}

function Set-AnsiItalic {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to format the text in italics.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Enable italic")) {
        return "${csi}3m"
    }
}

function Set-AnsiUnderline {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to format the text with an underline.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [switch] $Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Enable underline")) {
        return "${csi}4m"
    }
}


function Reset-AnsiBold {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to remove the bold formatting.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [switch]$Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Disable bold")) {
        return "${csi}22m"
    }
}

function Reset-AnsiDim {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to remove the dim formatting.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [switch]$Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Disable dim")) {
        return "${csi}22m"
    }
}

function Reset-AnsiItalic {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to remove the italic formatting.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [switch]$Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Disable italics")) {
        return "${csi}23m"
    }
}

function Reset-AnsiUnderline {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to remove the underline formatting.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [switch]$Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Disable underline")) {
        return "${csi}24m"
    }
}

function Get-AnsiAutoReset {
    <#
    .SYNOPSIS
        Gets a value indicating whether piped strings automatically include
        an ANSI reset command at the end to restore the default formatting.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
    )

    $script:AnsiAutoReset
}

function Set-AnsiAutoReset {
    <#
    .SYNOPSIS
        Sets a value indicating whether piped strings automatically include
        an ANSI reset command at the end to restore the default formatting.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    [OutputType([string])]
    param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [bool] $Value,
        [switch]$Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("console", "Disable automatic ANSI reset")) {
        $script:AnsiAutoReset = $Value
    }
}

#############################################
# Private Functions
#############################################
function Convert-ToRgbArray {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(6, 7)]
        [ValidatePattern('^#?[0-9A-Fa-f]{6}$')]
        [string] $Value
    )

    process {
        $result = New-Object System.Collections.ArrayList
        $index = (0, 1)[$Value.Length -eq 7]

        [void]$result.Add([Convert]::ToByte($Value.Substring(0 + $index, 2), 16))
        [void]$result.Add([Convert]::ToByte($Value.Substring(2 + $index, 2), 16))
        [void]$result.Add([Convert]::ToByte($Value.Substring(4 + $index, 2), 16))
        return $result.ToArray();
    }
}

function Format-AutoReset {
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $Text
    )

    process {
        foreach ($item in $Text) {
            if (!$script:AnsiAutoReset) {
                return $item
            }
            else {
                return "${item}${csi}0m"
            }
        }
    }
}

#############################################
# Exports
#############################################
Export-ModuleMember -Function @(
    "Clear-AnsiDisplay",
    "Clear-AnsiLine",
    "Get-AnsiAutoReset",
    "Move-AnsiCursorBack",
    "Move-AnsiCursorDown",
    "Move-AnsiCursorForward",
    "Move-AnsiCursorHorizontalAbsolute",
    "Move-AnsiCursorNextLine",
    "Move-AnsiCursorPosition",
    "Move-AnsiScrollDown",
    "Move-AnsiScrollUp",
    "Reset-AnsiBold",
    "Reset-AnsiConsole",
    "Reset-AnsiDim",
    "Reset-AnsiItalic",
    "Reset-AnsiUnderline",
    "Restore-AnsiCursor",
    "Save-AnsiCursor",
    "Set-AnsiAutoReset",
    "Set-AnsiBackgroundColor",
    "Set-AnsiBackgroundPaletteColor",
    "Set-AnsiBackgroundRgbColor",
    "Set-AnsiBold",
    "Set-AnsiConsole",
    "Set-AnsiCursorPreviousLine",
    "Set-AnsiCursorUp",
    "Set-AnsiDim",
    "Set-AnsiItalic",
    "Set-AnsiTextColor",
    "Set-AnsiTextPaletteColor",
    "Set-AnsiTextRgbColor",
    "Set-AnsiUnderline"
)
