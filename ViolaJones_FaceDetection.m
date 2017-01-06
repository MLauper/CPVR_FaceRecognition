%##########################################################################
% File:       ViolaJones_FaceDetection.m
% Purpose:    Detect faces on group pictures and save them in the same file
%             structure.
% Author:     Fabian Bigler, Marco Lauper
% Date:       Nov-2016
%##########################################################################

% Define input and ouptut directories
baseInputDir = '.\Images\cpvr_classes\';
baseOutPutDir = '.\out\FaceDetection\ViolaJones\';

% Switch to show detected face on source image
showDetectedFaces = false;

% Get input files and filter correctly
files = dir(baseInputDir);
dirFlags = [files.isdir];
classFolders = files(dirFlags);
classFolders(1:2) = [];

% Define Mask used on output files
outputMask = floor(imread('.\Images\mask_160.jpg')./255);

for i = 1 : length(classFolders)    
    
    % Create output base directory
    mkdir(strcat(baseOutPutDir,classFolders(i).name));
    
    % List pictures
    groupPictureDirectory = strcat(baseInputDir,'\',classFolders(i).name);
    groupPictures = dir(groupPictureDirectory);
    groupPictures(1:2) = [];
    
    % Loop through each group picture
    for j = 1 : length(groupPictures)        
        
        % Create output directory
        mkdir(strcat(baseOutPutDir, classFolders(i).name,'\', groupPictures(j).name));
        
        % Read the input image
        inputImg = imread(strcat(groupPictureDirectory,'\', groupPictures(j).name));

        % Setup and execute Viola Jones Face Detector
        faceDetector = vision.CascadeObjectDetector;
        faceDetector.MinSize = [130 130];
        boundingBoxes = step(faceDetector,inputImg);

        for k = 1:size(boundingBoxes,1)
            % Retrieve current size of the detected face
            size_x = boundingBoxes(k,4);
            size_y = boundingBoxes(k,3);
            
            % Calculate desired sizes to comply with the aspect ration
            desired_size_x = (160/120) * size_y; 
            delta_size_x = desired_size_x - size_x;
            delta_correction_x = floor(delta_size_x / 2);
            
            % Rewrite bounding box coordinates to comply with the aspect
            % ration
            boundingBoxes(k,2) = floor(boundingBoxes(k,2) - delta_correction_x);
            boundingBoxes(k,4) = floor(boundingBoxes(k,4) + delta_size_x);
        end
        
        % Export face images to filesystem
        for k = 1:size(boundingBoxes,1)                  
            outputPath = strcat(baseOutPutDir,classFolders(i).name,'\', groupPictures(j).name, '\',sprintf('%02d.jpg', k));
            outputImg = imresize(imcrop(inputImg, boundingBoxes(k,:)),[160,120]).*outputMask;
            imwrite(outputImg, outputPath);    
        end

        % If enabled, show detected faces on input image
        if (showDetectedFaces == true)
            figure,
            imshow(inputImg); hold on
            for k = 1:size(boundingBoxes,1)   
                rectangle('Position',boundingBoxes(k,:),'LineWidth',5,'LineStyle','-','EdgeColor','r');      
            end
            title('Face Detection');
            hold off;            
        end
    end               
end