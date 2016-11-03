$direcotries = gci -Directory -Recurse D:\code\src\github.com\MLauper\CPVR_FaceRecognition\Images\cpvr_faces_160\ -Exclude .picasa*
$pictures = $direcotries | % {gci $_ | select -first 10}
$i = 1; foreach ($picture in $pictures) {Copy-Item $picture.FullName -Destination "C:\Users\Marco\Desktop\FLD_based Face Recognition System_v2\FLD_based Face Recognition System_v2\Train2\$i.jpg"; $i++ }