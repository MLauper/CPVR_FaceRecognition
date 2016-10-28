%##########################################################################
% File:       FaceDetection.m
% Purpose:    Detect faces on a group picture
% Author:     Fabian Bigler, Marco Lauper
% Date:       Nov-2016
%##########################################################################

k = 0;
for i=1:1:40    
        filename  = sprintf('.\\Images\\cpvr_classes\\2014HS\\\%02d.pgm',i);        
        image_data = imread(filename);
        k = k + 1;
        groupPictures(k) = image_data(:);     
end;

%Detect objects using Viola-Jones Algorithm
detector = vision.CascadeObjectDetector;

%Read the input image
I = imread('HarryPotter.jpg');

%Returns Bounding Box values based on number of objects
BB = step(detector,I);

figure,
imshow(I); hold on
for i = 1:size(BB,1)
    %rectangle('Position',BB(i,:),'LineWidth',5,'LineStyle','-','EdgeColor','r');
    %imsize = size(image_data);    
end
title('Face Detection');
hold off;



