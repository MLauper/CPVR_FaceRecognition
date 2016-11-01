%##########################################################################
% File:       HuesMoments_FaceRecognition.m
% Purpose:    Face recognition with Hue's Moments algorithm
% Author:     Fabian Bigler, Marco Lauper
% Date:       Nov-2016
%##########################################################################
clear all;
baseOutputDir = '.\out\FaceRecognition\HuesMoments\';

% search pictures from ViolaJones Face detection
%searchDir = '.\out\FaceDetection\ViolaJones\2016HS\_DSC0372.JPG\';
baseInputDir = '.\out\FaceDetection\ViolaJones\';

trainingSetDir = '.\Images\cpvr_faces_320\';

files = dir(trainingSetDir);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
trainingFacePictureFolders = files(dirFlags);
trainingFacePictureFolders(1:2) = [];
smallestImgRectangle = [0,0, 239, 320];
%smallestImgRectangle = [0,0, 120, 160];

k=0;
%building training set
for i = 1 : length(trainingFacePictureFolders)        
    trainingFacePictureFiles = dir(strcat(trainingSetDir,trainingFacePictureFolders(i).name));
    trainingFacePictureFiles(1:2) = [];    
    
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
countTrainingImages = k;

files = dir(baseInputDir);
dirFlags = [files.isdir];
classFolders = files(dirFlags);
classFolders(1:2) = [];
for i = 1 : length(classFolders)
    mkdir(strcat(baseOutputDir,classFolders(i).name));
       
    groupPictureDirectories = dir(strcat(baseInputDir,'\',classFolders(i).name));
    groupPictureDirectories(1:2) = [];
    
     for j = 1 : length(groupPictureDirectories)    
          mkdir(strcat(baseOutputDir, classFolders(i).name,'\', groupPictureDirectories(j).name));
                    
          searchPictures = dir(strcat(baseInputDir,'\',classFolders(i).name, '\', groupPictureDirectories(j).name));     
          searchPictures(1:2) = [];
          for k = 1 : length(searchPictures)              
              searchPic = strcat(baseInputDir,'\',classFolders(i).name, '\', groupPictureDirectories(j).name, '\',searchPictures(k).name);
              %searchPic(1:2) = [];
              %mkdir(strcat(baseOutputDir,'\',classFolders(i).name, '\', groupPictureDirectories(j).name, '\',searchPictures(k).name));
              searchPicOrig = imread(searchPic);
              searchPicCropped = imcrop(searchPicOrig, smallestImgRectangle);
              searchPicGray = rgb2gray(searchPicCropped);
              searchPicMoments = abs(log10(invmoments(searchPicGray)));
              
              for x=1:countTrainingImages   
                    %resultMomentsDiff = dot(trainingFaceMoments{i}-searchPicMoments, trainingFaceMoments{i}-searchPicMoments);
                    resultMomentsDiff = sumsqr(trainingFaceMoments{x}-searchPicMoments);    
                    distanceMoments(x) = resultMomentsDiff;
              end
                [sortedDistanceMoments, sortIndex] = sort(distanceMoments); % sort distances                   

                %figure('Visible','off')
                searchResult = figure('Color',[1 1 1], 'Visible', 'off');
                subplot(2,7,1); 
                imshow(searchPic);
                title('Search Picture');
                for y=2:14
                    subplot(2,7,y); 
                    %imshow(searchPic);
                    %imshow(trainingFaceImages(:,sortIndex(i)));   
                    imshow(trainingFaceImages{sortIndex(y)});
                    %imshow((reshape(mn+faces(:,sortIndex(i)), imsize))); 
                    title(sprintf('Dist=%2.2f',sortedDistanceMoments(y)));
                end;

                saveas(searchResult, strcat(baseOutputDir,classFolders(i).name, '\', groupPictureDirectories(j).name, '\',searchPictures(k).name))
          end                              
          %outputPath = strcat(baseOutPutDir,classFolders(i).name,'\', groupPictures(j).name, '\',sprintf('%02d.jpg', k));
     end
end;




% searchPic = strcat(baseInputDir, '02.jpg');
% searchPicOrig = imread(searchPic);
% searchPicCropped = imcrop(searchPicOrig, smallestImgRectangle);
% searchPicGray = rgb2gray(searchPicCropped);
% searchPicMoments = abs(log10(invmoments(searchPicGray)));
% 
% %transpose so it matches trainset moments
% %transposedSearchPicMoments = searchPicMoments';
% %firstMoments = trainingFaceMoments{1};
% %firstMomentsDiff = sumsqr(firstMoments-searchPicMoments);
% 
% for i=1:countImages   
%     %resultMomentsDiff = dot(trainingFaceMoments{i}-searchPicMoments, trainingFaceMoments{i}-searchPicMoments);
%     resultMomentsDiff = sumsqr(trainingFaceMoments{i}-searchPicMoments);    
%     distanceMoments(i) = resultMomentsDiff;
% end;
% 
% % Sort the distances and show the nearest 14 faces
% [sortedDistanceMoments, sortIndex] = sort(distanceMoments); % sort distances
% 
% smallestImgRectangle = [0,0, 239, 320];
% 
% %figure('Color',[1 1 1]);
% 
% 
% searchResult = figure('Color',[1 1 1]);
% subplot(2,7,1); 
% imshow(searchPic);
% title('Search Picture');
% for i=2:15
%     subplot(2,7,i); 
%     %imshow(searchPic);
%     %imshow(trainingFaceImages(:,sortIndex(i)));   
%     imshow(trainingFaceImages{sortIndex(i)});
%     %imshow((reshape(mn+faces(:,sortIndex(i)), imsize))); 
%     title(sprintf('Dist=%2.2f',sortedDistanceMoments(i)));
% end;
% 
% saveas(searchResult,'FigureSearch.png')


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