$imageToShrinkPath = "D:\code\src\github.com\MLauper\CPVR_FaceRecognition\Images\cpvr_classes\2016HS\_DSC0360.JPG"

Add-Type -AssemblyName System.Drawing
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$imageToShrink = Get-Item $imageToShrinkPath
$originalBackupPath = ($imageToShrink.Directory.FullName + "\" + $imageToShrink.BaseName + ".original" + $imageToShrink.Extension)
$shrinkedImagePath = ($imageToShrink.Directory.FullName + "\" + $imageToShrink.BaseName + ".shrinked" + $imageToShrink.Extension)

Copy-Item $imageToShrink $originalBackupPath -Force
Copy-Item $imageToShrink $shrinkedImagePath -Force

while ((Get-Item $shrinkedImagePath).Length -gt 5000000){
    $Image = [System.Drawing.Image]::FromFile($imageToShrinkPath)

    $Scale = 1.0
    [int32]$new_width = $Image.Width * $Scale
    [int32]$new_height = $Image.Height * $Scale

    $shrinkedImage = New-Object System.Drawing.Bitmap($new_width, $new_height)
    $graph = [System.Drawing.Graphics]::FromImage($shrinkedImage)
    $graph.DrawImage($Image, 0, 0, $new_width, $new_height)
    
    $quality = 99
    $myEncoder = [System.Drawing.Imaging.Encoder]::Quality
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1) 
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myEncoder, $quality)
    $myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|where {$_.MimeType -eq 'image/jpeg'}
    
    $shrinkedImage.Save($shrinkedImagePath, $myImageCodecInfo, $($encoderParams))
}
