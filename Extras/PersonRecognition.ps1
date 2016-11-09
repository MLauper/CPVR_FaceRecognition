
Import-Module ps-AzureFaceAPI
Add-Type -AssemblyName System.Drawing
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

pushd
cd 'C:\Program Files\WindowsPowerShell\Modules\ps-AzureFaceAPI\1.0.1\'

$personNames = @('Tschanz', 'Laubscher', 'Knoepfel', 'Haeni', 'James', 'Loosli', 'Genecand', 'Tuescher', 'Buchegger', 'Cardini', 'Zingg', 'Gerber', 'Lauper', 'Bigler')

$trainingFacePictureDir = 'C:\Users\FabianBigler\Documents\MATLAB\CPVR_FaceRecognition\Images\cpvr_faces_320'
$trainingFaceDirectories = Get-ChildItem $trainingFacePictureDir | ? {[int32]$_.Name -ge 23}

$groupName = 'class2016'
try{ Remove-PersonGroup $groupName } catch {}
New-PersonGroup $groupName
$index = 0
$trainingFaceDirectories |  % {
    New-Person $personNames[$index] -personGroupId $groupName
    $pictures = gci $_.FullName -Filter '*.jpg'   
    $pictures | % {
        New-PersonFace -personName $personNames[$index] -personGroupId $groupName -localImagePath $_.FullName
    }

    $index++
}

Start-PersonGroupTraining -PersonGroupId $groupName

while ($true)
{
    $state = Get-PersonGroupTrainingStatus -PersonGroupId $groupName;
    if($state.status -eq 'succeeded') {break}
}


$imageToShrinkPath = "C:\Users\FabianBigler\Documents\MATLAB\CPVR_FaceRecognition\Images\cpvr_classes\2016HS\_DSC0367.JPG"


$imageToShrink = Get-Item $imageToShrinkPath
$originalBackupPath = ($imageToShrink.Directory.FullName + "\" + $imageToShrink.BaseName + ".original" + $imageToShrink.Extension)
$shrinkedImagePath = ($imageToShrink.Directory.FullName + "\" + $imageToShrink.BaseName + ".shrinked" + $imageToShrink.Extension)

Copy-Item $imageToShrink $originalBackupPath -Force
Copy-Item $imageToShrink $shrinkedImagePath -Force

$quality = 100
while ((Get-Item $shrinkedImagePath).Length -gt 4000000){
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
}


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
$detectedFaces | % {
    $detectedFace = $_;
    $candidate = $identifiedFaces[$index].candidates | select -First 1;   
    $person = $persons | ?{$_.personId -eq $candidate.personId}
    
    $rect = new-object Drawing.Rectangle $_.faceRectangle.left, $_.faceRectangle.top, $_.faceRectangle.width, $_.faceRectangle.height
    $graph.DrawRectangle($pen, $rect);

    $rectF = [System.Drawing.RectangleF]::FromLTRB($_.faceRectangle.left, $_.faceRectangle.top,$_.faceRectangle.left+
                                                    $_.faceRectangle.width, $_.faceRectangle.top+$_.faceRectangle.height)
    $graph.DrawString($person.name+': '+$candidate.confidence, $font,$brush,$rectF, $format);
    $index++;
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


#New-Person person-0023 -personGroupId 'class2016'
#New-PersonFace -personName person-00





#$personNames | ? {$_ -like 'k*'}

