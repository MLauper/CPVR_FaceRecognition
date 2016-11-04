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
                    resultMomentsDiff = norm(trainingFaceMoments{x}-searchPicMoments);    
                    distanceMoments(x) = resultMomentsDiff;
              end
                [sortedDistanceMoments, sortIndex] = sort(distanceMoments); % sort distances                   

                %figure('Visible','off')
                searchResult = figure('Color',[1 1 1], 'Visible', 'off');
                subplot(2,7,1); 
                imshow(searchPic);
                title('Search Picture');
                for y=1:13
                    subplot(2,7,y+1); 
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