
function ReplaceStringHexString($SubString)
{
    $SubString=$Substring.Replace("`n","")
    $SubString=$Substring.Replace("`r","")
    $SubString=$Substring.Trim()

    $Result =""
    Foreach ($char in $SubString.ToCharArray())
    {
        if ($Char -eq "|")
        {
            $Result = $Result + " " + [System.String]::Format("{0:X2}", 0x1B)
            #write-host $char,[System.String]::Format("{0:X2}", 0x1B),"**"
        }
        else
        {
            $Result = $Result + " " + [System.String]::Format("{0:X2}", [System.Convert]::ToUInt32($CHAR))
            #write-host $char,[System.String]::Format("{0:X2}",[System.Convert]::ToUInt32($CHAR))
        }
    }
    return $Result 
}



$speed=70
$Power=15
$filename="Convet.gco"
$mmToLUScaleFactor = 19.708


$Prefix = ("|%N" + $filename +"|IN;VS" + [string]($speed * 10) + ";FS" + $Power.ToString() +";VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;VS500;FS50;RS65535;PIAuto;IP0,0,2032,2032;SC0,500,0,500;|*t500R;|*U200R;|*U200V;|*M4300F;|*b1M;PU;")
$Suffix = "PG;"

$GCode=Get-content '\\nas\software\laserdrop\LBBoxFillpCut.gc'

$AbsoluteCoordinatesInUse=$False
$PenDown = $false 
$FirstPoint=$false

$BodyLines = ""
$GCodeCount=0
foreach ($Line in $GCode.Split("`n"))
{
    ++$GcodeCount
    $Command=$Line.Split(" ")[0].Trim()
    If ($Command -eq "G0") {$Command="G1"} #They are the same in Laser terms
    Write-Host "$GCodeCount - Looking at Line $Line, Command $Command"

    if ($command -eq ";")
    {
        Write-Host "  Ignoring Comment: $Line"
    }
    elseif ($command -eq "G21")
    {
        Write-Host "  Set to MM"
    }
    elseif ($command -eq "G90")
    {
        Write-Host "  Setting to absolute coordinates"
        $AbsoluteCoordinatesInUse = $true
    }
    elseif ($command -eq "G91")
    {
        Write-Host "  Setting to relative coordinates"
         $AbsoluteCoordinatesInUse = $false
    }
    elseif ($command -eq "M8")
    {
        Write-Host "  Turn on Air assist"
    }
    elseif ($command -eq "M9")
    {
        Write-Host "  Turn off Air assist"
    }
    elseif ($command -eq "M106")
    {
        $Supplemental  = $Line.Replace("$Command ","").Trim()
        If ($Supplemental -eq "S0")
        {
            #THis is laser off in lightburn
            If ($PenDown) 
            {
                Write-Host ("*****Pen is down, Issue: PU")
                $BodyLines+=("PU;")
                $PenDown=$false
            }
        }
        else
        {
            If ($PenDown -eq $false) 
            {
                $PenDown=$true
            }

        }
    }
    elseif ($command -eq "G1")
    {
        $YChangeLU=0;$XChangeLU=0
        Write-Host "  Traversal Move: $Line"
        $Supplemental  = $Line.Replace("$Command ","")
        $Supplemental=$Supplemental.Replace("X"," X")
        $Supplemental=$Supplemental.Replace("Y"," Y")
        $Supplemental=$Supplemental.Replace("F"," F")
        For ($i=1; $i -le $Supplemental.Split(" ").Count-1; $i++) 
        {
            $Section= $Supplemental.Split(" ")[$i]
            if ($Section[0] -eq "X")
            {
                $Amount=$Section.Replace("X","")
                $XChangeLU=[int]([float]$Amount * $mmToLUScaleFactor)
                Write-Host "  New X", $Amount, $XChangeLU
            }
            if ($Section[0] -eq "Y")
            {
                $Amount=$Section.Replace("Y","")
                $YChangeLU=[int]([float]$Amount * $mmToLUScaleFactor)
                Write-Host "  New Y", $Amount, $YChangeLU
            }
            if ($Section[0] -eq "F")
            {
                #$Amount=$Section.Replace("F","")
                Write-Host " New F $Amount - Ignored"
            }
        }
           
        if ($Pendown -eq $false)
        { 
            Write-Host ("*****Issue: PR" + $XchangeLU + "," + $YChangeLU + ";")
            $BodyLines+=("PR" + $XchangeLU + "," + $YChangeLU + ";")
            
        }
        else
        {
            Write-Host ("*****Issue: PD" + $XchangeLU + "," + $YChangeLU + ";")
            $BodyLines+=("PD" + $XchangeLU + "," + $YChangeLU + ";")
            $PenDown=$true
        }
        if ($FirstPoint -eq $false)
        {
            $FirstPoint = $true
            Write-Host "Lightburn coordinate initialize and set relative from this point on"
            Write-Host ("*****Add SP1;|%E;SP1;PR;")
            $BodyLines+="SP1;|%E;SP1;PR;"
        }

    }
    else
    {
        Write-Host "Unhandled: $Line"
    }
    Write-Host " "
}
Write-Host "Full Body:"
$BodyLines


$Final = $Prefix + $BodyLines + $Suffix
Write-Host "Final:"
$Final 

$FinalENcoded = ReplaceStringHexString $Final

$hex_string_spaced=$FinalENcoded.Replace(" ", " 0x")
$byte_array = [byte[]] -split $hex_string_spaced
Set-Content -Path '\\nas\software\laserdrop\Converted.bin' -Value $byte_array -Encoding Byte
