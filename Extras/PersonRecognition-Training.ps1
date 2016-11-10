Import-Module ps-AzureFaceAPI
Add-Type -AssemblyName System.Drawing
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

pushd
cd 'C:\Program Files\WindowsPowerShell\Modules\ps-AzureFaceAPI\1.0.1\'

$personNames = @('0023: Tschanz', '0024: Laubscher', '0025: Knoepfel', '0026: Haeni', '0027: James', '0028: Loosli', '0029: Genecand', '0030: Tuescher', '0031: Buchegger', '0032: Cardini', '0033: Zingg', '0034: Gerber', '0035: Lauper', '0036: Bigler')

$trainingFacePictureDir = 'D:\code\src\github.com\MLauper\CPVR_FaceRecognition\Images\cpvr_faces_320'
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

popd
