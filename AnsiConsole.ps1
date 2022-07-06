# https://notes.burke.libbey.me/ansi-escape-codes/

$escape = [char]0x001B
$csi = "$escape["
$textColorBase = 30
$backgroundColorBase = 40

New-Variable -Name AnsiAutoReset -Value $true -Scope Script -Force   

enum AnsiColor 
{
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

enum AnsiClear
{
    CursorToEnd = 0
    CursorToStart = 1
    All = 2
}

function Set-AnsiCursorUp {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor up by some amount.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount
    )

    "${csi}${Amount}A"
}

function Move-AnsiCursorDown {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor down by some amount.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount
    )

    "${csi}${Amount}B"
}

function Move-AnsiCursorForward {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor forward by some amount.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount
    )

    "${csi}${Amount}C"
}

function Move-AnsiCursorBack {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor backward by some amount.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount
    )

    "${csi}${Amount}D"
}

function Move-AnsiCursorNextLine {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor down by a number of lines.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount
    )

    "${csi}${Amount}E"
}

function Set-AnsiCursorPreviousLine {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor up by a number of lines.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount
    )

    "${csi}${Amount}F"
}

function Move-AnsiCursorHorizontalAbsolute {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for moving the cursor horizontally to an absolute position
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount
    )

    "${csi}${Amount}G"
}

function Move-AnsiCursorPosition {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for absolutely positioning the cursor on the screen.
    #>
    [CmdletBinding()]
    param (
        [byte] $Row,
        [byte] $Column
    )

    "${csi}${row};${column}H"
}

function Move-AnsiScrollUp {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for scrolling the screen up by a number of lines.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [byte] $Amount
    )

    "${csi}${Amount}S"
}

function Move-AnsiScrollDown {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for scrolling the screen up by a number of lines.
    #>
    param (
        [Parameter(Position = 0)]
        [byte] $Amount
    )

    "${csi}${Amount}T"
}

function Save-AnsiCursor {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for saving the current cursor position.
    #>
    "${csi}s"
}

function Restore-AnsiCursor
{
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence for restoring a saved cursor position.
    #>
    "${csi}u"
}

function Clear-AnsiDisplay {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to clear the display.
    #>
    [CmdletBinding()]
    param (
        [AnsiClear] $Target
    )

    "${csi}${Target}J"
}

function Clear-AnsiLine {
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to clear a line.
    #>
    [CmdletBinding()]
    param (
        [AnsiClear] $Target
    )

    "${csi}${Target}K"
}

function Set-AnsiConsole
{
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to format the color and style of displayed text.
    #>
    [CmdletBinding(DefaultParameterSetName="AnsiColor")]
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
        [switch] $Italic = $false
    )

    process
    {
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
                [void]$commands.Add([Convert]::ToByte($ForegroundRGB.Substring(0, 2), 16))
                [void]$commands.Add([Convert]::ToByte($ForegroundRGB.Substring(2, 2), 16))
                [void]$commands.Add([Convert]::ToByte($ForegroundRGB.Substring(4, 2), 16))
            }
            if ($PSBoundParameters.ContainsKey('BackgroundRGB')) {
                [void]$commands.Add("48")
                [void]$commands.Add("2")
                [void]$commands.Add([Convert]::ToByte($BackgroundRGB.Substring(0, 2), 16))
                [void]$commands.Add([Convert]::ToByte($BackgroundRGB.Substring(2, 2), 16))
                [void]$commands.Add([Convert]::ToByte($BackgroundRGB.Substring(4, 2), 16))
            }
        }

        $content = $content + ($commands.ToArray() -Join ";") +"m"

        foreach ($item in $Text)
        {
            $content += $item
        }
        
        $content | Format-AutoReset
    }
}


function Set-AnsiTextColor
{
    <#
    .SYNOPSIS
        Generates the ANSI escape sequence to set the text to one of the eight ANSI colors
    #>
    [CmdletBinding()]
    param
    (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $Text,
        
        [parameter(Position = 0, Mandatory = $true)]
        [AnsiColor] $Color
    )

    process
    {
        $content = "${csi}$($textColorBase + $Color)m"
        foreach ($item in $Text)
        {
            $content = $content + $item
        }
        
        $content | Format-AutoReset
    }
}

function Set-AnsiBackgroundColor
{
[CmdletBinding()]
    param
    (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $Text,
        
        [parameter(Position = 0, Mandatory = $true)]
        [AnsiColor] $Color
    )

    process
    {
        $content = "${csi}$($backgroundColorBase + $Color)m"
        foreach ($item in $Text)
        {
            $content = $content + $item
        }
        
        $content | Format-AutoReset
    }
}

function Set-AnsiTextPaletteColor {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [byte] $index
    )

    "${csi}38;5;${index}m"
}

function Set-AnsiBackgroundPaletteColor {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [byte] $index
    )

    "${csi}48;5;${index}m"
}

function Set-AnsiTextRgbColor {
    [CmdletBinding()]
    param (
        [byte] $Red,
        [byte] $Green,
        [byte] $Blue
    )

    "${csi}38;2;$Red;$Green;${Blue}m"
}

function Set-AnsiBackgroundRgbColor {
    [CmdletBinding()]

    param (
        [byte] $Red,
        [byte] $Green,
        [byte] $Blue
    )

    "${csi}48;2;$Red;$Green;${Blue}m"
}

function Reset-AnsiConsole {
    process {
    "${csi}0m"
    }
}

function Set-AnsiBold {
    "${csi}1m"
}

function Set-AnsiDim {
    "${csi}2m"
}

function Set-AnsiItalic {
    "${csi}3m"
}

function Set-AnsiUnderline {
    "${csi}4m"
}


function Reset-AnsiBold {
    "${csi}22m"
}

function Reset-AnsiDim {
    "${csi}22m"
}

function Reset-AnsiItalic {
    "${csi}23m"
}

function Reset-AnsiUnderline {
    "${csi}24m"
}

function Get-AnsiAutoReset {
    [CmdletBinding()]
    
    $script:AnsiAutoReset
}

function Set-AnsiAutoReset {
    [CmdletBinding()]
    param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [bool] $Value
    )

    $script:AnsiAutoReset = $value
}

filter Format-AutoReset 
{
   if (!$script:AnsiAutoReset) { $_ } else { "${_}${csi}0m" }
}

Export-ModuleMember -Function Set-Ansi*, Get-Ansi*, Reset-Ansi*, Save-AnsiCursor, Restore-AnsiCursor, Move-Ansi*
