%##########################################################################
% File:       HuesMoments_FaceRecognition.m
% Purpose:    Face recognition with Hue's Moments algorithm
% Author:     Fabian Bigler, Marco Lauper
% Date:       Nov-2016
%##########################################################################
clear;
baseOutPutDir = '.\out\FaceRecognition\HuesMoments\';

% search pictures from ViolaJones Face detection
searchDir = '.\out\FaceDetection\ViolaJones\2016HS\_DSC0372.JPG\';

trainingSetDir = '.\Images\cpvr_faces_320\';

files = dir(trainingSetDir);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
trainingFacePictureFolders = files(dirFlags);
trainingFacePictureFolders(1:2) = [];
smallestImgRectangle = [0,0, 239, 320];

k=0;

for i = 1 : length(trainingFacePictureFolders)        
    trainingFacePictureFiles = dir(strcat(trainingSetDir,trainingFacePictureFolders(i).name));
    trainingFacePictureFiles(1:2) = [];    
    imgSize = [320,240];
    for j = 1 : length(trainingFacePictureFiles)           
        filename = strcat(trainingSetDir,trainingFacePictureFolders(i).name,'\',trainingFacePictureFiles(j).name);
        image_data = imread(filename);             
        k = k + 1;         
        %im1        = abs(log10(invmoments(image_data)));
        image_data = imcrop(image_data, smallestImgRectangle); 
        %first transfer to gray scale image
        gray_image = rgb2gray(image_data);
        %then extract hue's moments
        %trainingFaceImages(:,k) = image_data(:);
        trainingFaceImages{k} = image_data;
        %trainingFaceMoments(:,k) = abs(log10(invmoments(gray_image)));            
        trainingFaceMoments{k} = abs(log10(invmoments(gray_image)));            
    end    
end

countImages = k;

searchPic = strcat(searchDir, '07.jpg');
searchPicGray = rgb2gray(imcrop(imread(searchPic), smallestImgRectangle));
searchPicMoments = abs(log10(invmoments(searchPicGray)));

%transpose so it matches trainset moments
%transposedSearchPicMoments = searchPicMoments';

for i=1:countImages   
    resultMomentsDiff = dot(trainingFaceMoments{i}-searchPicMoments, trainingFaceMoments{i}-searchPicMoments);   
    distanceMoments(i) = resultMomentsDiff;
end;

% Sort the distances and show the nearest 14 faces
[sortedDistanceMoments, sortIndex] = sort(distanceMoments); % sort distances

smallestImgRectangle = [0,0, 239, 320];

figure('Color',[1 1 1]);
imshow(searchPic);

figure('Color',[1 1 1]);
for i=1:14
    subplot(2,7,i); 
    %imshow(searchPic);
    %imshow(trainingFaceImages(:,sortIndex(i)));   
    imshow(trainingFaceImages{sortIndex(i)});
    %imshow((reshape(mn+faces(:,sortIndex(i)), imsize))); 
    title(sprintf('Dist=%2.2f',sortedDistanceMoments(i)));
end;





% nImages = k;                     %total number of images
% imsize = size(image_data);       %size of image (they all should have the same size) 
% nPixels = imsize(1)*imsize(2);   %number of pixels in image
% faceImages = double(faceImages)/255;       %convert to double and normalize



% 
% k = 0;
% for i=1:1:40
%     for j=1:1:10
%         filename  = sprintf('.\\Images\\att_faces\\s%d\\%d.pgm',i,j);
%         
%         image_data = imread(filename);
%         k = k + 1;
%         faces(:,k) = image_data(:);
%      end;
% end;
% nImages = k;                     %total number of images
% imsize = size(image_data);       %size of image (they all should have the same size) 
% nPixels = imsize(1)*imsize(2);   %number of pixels in image
% faces = double(faces)/255;       %convert to double and normalize