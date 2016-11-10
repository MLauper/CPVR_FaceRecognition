$imageToShrinkPath = "C:\Users\Marco\Desktop\4062323126531796499-account_id=1.jpg"

Import-Module ps-AzureFaceAPI
Add-Type -AssemblyName System.Drawing
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

pushd
cd 'C:\Program Files\WindowsPowerShell\Modules\ps-AzureFaceAPI\1.0.1\'

$personNames = @('0023: Tschanz', '0024: Laubscher', '0025: Knoepfel', '0026: Haeni', '0027: James', '0028: Loosli', '0029: Genecand', '0030: Tuescher', '0031: Buchegger', '0032: Cardini', '0033: Zingg', '0034: Gerber', '0035: Lauper', '0036: Bigler')
$groupName = 'class2016'

$imageToShrink = Get-Item $imageToShrinkPath
$originalBackupPath = ($imageToShrink.Directory.FullName + "\" + $imageToShrink.BaseName + ".original" + $imageToShrink.Extension)
$shrinkedImagePath = ($imageToShrink.Directory.FullName + "\" + $imageToShrink.BaseName + ".shrinked" + $imageToShrink.Extension)

Copy-Item $imageToShrink $originalBackupPath -Force
Copy-Item $imageToShrink $shrinkedImagePath -Force

$quality = 100
Do{
    $Image = [System.Drawing.Image]::FromFile($imageToShrinkPath)

    $Scale = 1.0
    [int32]$new_width = $Image.Width * $Scale
    [int32]$new_height = $Image.Height * $Scale

    $shrinkedImage = New-Object System.Drawing.Bitmap($new_width, $new_height)
    $graph = [System.Drawing.Graphics]::FromImage($shrinkedImage)
    $graph.DrawImage($Image, 0, 0, $new_width, $new_height)
    
    $quality -= 1
    $myEncoder = [System.Drawing.Imaging.Encoder]::Quality
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1) 
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myEncoder, $quality)
    $myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|where {$_.MimeType -eq 'image/jpeg'}
    
    $shrinkedImage.Save($shrinkedImagePath, $myImageCodecInfo, $($encoderParams))
}while ((Get-Item $shrinkedImagePath).Length -gt 4000000)


$detectedFaces = Invoke-FaceDetection -localImagePath $shrinkedImagePath

$identifiedFaces = @();
$detectedFaces | % {
    $identifiedFaces += Invoke-IdentifyFaces -faceIds $_.faceId -personGroupId $groupName        
}

$persons = Get-Person -personGroupId $groupName;

$bmpFile = new-object System.Drawing.Bitmap([int]($shrinkedImage.width)),([int]($shrinkedImage.height))
$graph = [System.Drawing.Graphics]::FromImage($bmpFile)
$graph.DrawImage($shrinkedImage, 0, 0, $new_width, $new_height)


$pen = new-object Drawing.Pen black;
$pen.Color = [System.Drawing.Color]::ForestGreen;
$pen.Width = 3.0;
$brush = New-Object Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 0, 0))
$font = new-object System.Drawing.Font("Tahoma", 20, "Bold","Pixel")
$format = [System.Drawing.StringFormat]::GenericDefault
$format.Alignment = [System.Drawing.StringAlignment]::Center
$format.LineAlignment = [System.Drawing.StringAlignment]::Center

$index = 0;
$personNumber = 23
$detectedFaces | % {
    $detectedFace = $_;
    $candidate = $identifiedFaces[$index].candidates | select -First 1;   
    $person = $persons | ?{$_.personId -eq $candidate.personId}
    
    $rect = new-object Drawing.Rectangle $_.faceRectangle.left, $_.faceRectangle.top, $_.faceRectangle.width, $_.faceRectangle.height
    $graph.DrawRectangle($pen, $rect);

    $rectF = [System.Drawing.RectangleF]::FromLTRB($_.faceRectangle.left, $_.faceRectangle.top,$_.faceRectangle.left+
                                                    $_.faceRectangle.width, $_.faceRectangle.top+$_.faceRectangle.height)
    $graph.DrawString($person.name+', '+$candidate.confidence +', ' + ($index+23), $font,$brush,$rectF, $format);
    $index++
    $personNumber++
}

$rect = new-object Drawing.Rectangle $_.faceRectangle.left, $_.faceRectangle.top, $_.faceRectangle.width, $_.faceRectangle.height
$graph.DrawRectangle($pen, $rect);

$identifiedImagePath = ($imageToShrink.Directory.FullName + "\" + $imageToShrink.BaseName + ".identified" + $imageToShrink.Extension)

$myEncoder = [System.Drawing.Imaging.Encoder]::Quality
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1) 
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myEncoder, 100)
$myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|where {$_.MimeType -eq 'image/jpeg'}

$bmpFile.Save($identifiedImagePath, $myImageCodecInfo, $($encoderParams))


popd
