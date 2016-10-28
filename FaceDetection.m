%##########################################################################
% File:       FaceDetection.m
% Purpose:    Detect faces on a group picture
% Author:     Fabian Bigler, Marco Lauper
% Date:       Nov-2016
%##########################################################################

% k = 0;
% for i=2014:1:2016
%     for j=1:1:10
%         try            
%             inputFileName  = sprintf('.\\Images\\cpvr_classes\\%dHS\\%02d.jpg',i,j);        
%         catch ME
%         end
%         image_data = imread(inputFileName);
%         k = k + 1;
%         groupPictures(:,k) = image_data(:);
%      end;
% end;

%Detect objects using Viola-Jones Algorithm
faceDetector = vision.CascadeObjectDetector;
faceDetector.MinSize = [100 100];

%Read the input image
inputImg = imread('.\Images\cpvr_classes\2014HS\02.JPG');

%Returns Bounding Box values based on number of objects
boundingBoxes = step(faceDetector,inputImg);

%export images to filesystem
for i = 1:size(boundingBoxes,1)       
    outputImg = imcrop(inputImg, boundingBoxes(i,:));
    outputPath  = sprintf('.\\out\\FaceDetection\\ViolaJones\\%02d.jpg',i);
    imwrite(outputImg, outputPath);    
end

figure,
imshow(inputImg); hold on
for i = 1:size(boundingBoxes,1)   
    rectangle('Position',boundingBoxes(i,:),'LineWidth',5,'LineStyle','-','EdgeColor','r');      
end
title('Face Detection');
hold off;


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





