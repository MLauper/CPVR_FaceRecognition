%##########################################################################
% File:       ViolaJones_FaceDetection.m
% Purpose:    Detect faces on group pictures and save them in the same file
%             structure.
% Author:     Fabian Bigler, Marco Lauper
% Date:       Nov-2016
%##########################################################################

baseInputDir = '.\Images\cpvr_classes\';
baseOutPutDir = '.\out\FaceDetection\ViolaJones\';
files = dir(baseInputDir);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
classFolders = files(dirFlags);
% remove first two entries (it's always '.' and '..')
classFolders(1:2) = [];

outputMask = floor(imread('.\Images\mask_320.jpg')./255);

for i = 1 : length(classFolders)    
    
    mkdir(strcat(baseOutPutDir,classFolders(i).name));
    
    groupPictureDirectory = strcat(baseInputDir,'\',classFolders(i).name);
    groupPictures = dir(groupPictureDirectory);
    groupPictures(1:2) = [];
    for j = 1 : length(groupPictures)        
        %create output directory for group picture
        mkdir(strcat(baseOutPutDir, classFolders(i).name,'\', groupPictures(j).name));
         %Detect objects using Viola-Jones Algorithm
        faceDetector = vision.CascadeObjectDetector;
        faceDetector.MinSize = [130 130];

        %Read the input image        
        inputImg = imread(strcat(groupPictureDirectory,'\', groupPictures(j).name));
        
        %Returns Bounding Box values based on number of objects
        boundingBoxes = step(faceDetector,inputImg);

        for k = 1:size(boundingBoxes,1)
            size_x = boundingBoxes(k,4);
            size_y = boundingBoxes(k,3);
            
            % x / y = 320 / 240
            % y is fixed
            desired_size_x = (320/240) * size_y; 
            delta_size_x = desired_size_x - size_x;
            delta_correction_x = floor(delta_size_x / 2);
            
            boundingBoxes(k,2) = floor(boundingBoxes(k,2) - delta_correction_x);
            boundingBoxes(k,4) = floor(boundingBoxes(k,4) + delta_size_x);
        end
        
        %export images to filesystem
        for k = 1:size(boundingBoxes,1)                  
            outputPath = strcat(baseOutPutDir,classFolders(i).name,'\', groupPictures(j).name, '\',sprintf('%02d.jpg', k));
            %outputPath = sprintf(strcat(outputFolder,'%02d.jpg'),k);
            
            %outputPath  = sprintf('.\\out\\FaceDetection\\ViolaJones\\%02d.jpg',i);            
            outputImg = imresize(imcrop(inputImg, boundingBoxes(k,:)),[320,240]).*outputMask;
            imwrite(outputImg, outputPath);    
        end

%         figure,
%         imshow(inputImg); hold on
%         for k = 1:size(boundingBoxes,1)   
%             rectangle('Position',boundingBoxes(k,:),'LineWidth',5,'LineStyle','-','EdgeColor','r');      
%         end
%         title('Face Detection');
%         hold off;
    end               
end

% classDirectories = dir('.\Images\cpvr_classes\');
% for classDirectory = classDirectories
%     if (classDirectory.isdir == 1)
%         %outputDir = classDirectory.name;                
%     end    
% end




%  IFaces = insertObjectAnnotation(I, 'rectangle', bboxes, 'Face');
%  figure, imshow(IFaces), title('Detected faces');
%  
%  for i = 1:size(bboxes,1)
%      rectangle('Position',BB(i,:),'LineWidth',5,'LineStyle','-','EdgeColor','r');
%      imsize = size(image_data);    
%  end
          
%Useful if not only the face should be detected
%  bodyDetector = vision.CascadeObjectDetector('UpperBody'); 
%  bodyDetector.MinSize = [30 30];
%  bodyDetector.MergeThreshold = 10
%  bboxBody = step(bodyDetector, I);

%IBody = insertObjectAnnotation(I, 'rectangle',bboxBody,'Upper Body');
%figure, imshow(IBody), title('Detected upper bodies');





