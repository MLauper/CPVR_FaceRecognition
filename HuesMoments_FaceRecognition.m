%##########################################################################
% File:       HuesMoments_FaceRecognition.m
% Purpose:    Face recognition with Hue's Moments algorithm
% Author:     Fabian Bigler, Marco Lauper
% Date:       Nov-2016
%##########################################################################

% Define output and input directory
baseOutputDir = '.\out\FaceRecognition\HuesMoments\';
baseInputDir = '.\out\FaceDetection\ViolaJones\';

% Define training set directory
trainingSetDir = '.\Images\cpvr_faces_320\';

%% Train the PCA with the Training Set

% Get input files
files = dir(trainingSetDir);
dirFlags = [files.isdir];
trainingFacePictureFolders = files(dirFlags);
trainingFacePictureFolders(1:2) = [];
smallestImgRectangle = [0,0, 239, 320];

k=0;
for i = 1 : length(trainingFacePictureFolders)        
    
    % Get Training Set Pictures
    trainingFacePictureFiles = dir(strcat(trainingSetDir,trainingFacePictureFolders(i).name));
    trainingFacePictureFiles(1:2) = [];    
    
    % Loop over Training Set Pictures
    for j = 1 : length(trainingFacePictureFiles)           
        
        % Get picture
        filename = strcat(trainingSetDir,trainingFacePictureFolders(i).name,'\',trainingFacePictureFiles(j).name);
        image_data = imread(filename);             
        k = k + 1;
        image_data = imcrop(image_data, smallestImgRectangle); 
        
        % Convert Trianing Picture to Grayscale
        gray_image = rgb2gray(image_data);
        
        % Extract Hue's moments
        trainingFaceImages{k} = image_data;
        trainingFaceMoments{k} = abs(log10(invmoments(gray_image)));            
    end
end
countTrainingImages = k;

%% Try to identify Test Set pictures 

% Get input files
files = dir(baseInputDir);
dirFlags = [files.isdir];
classFolders = files(dirFlags);
classFolders(1:2) = [];

for i = 1 : length(classFolders)
    
    % Create output directory
    mkdir(strcat(baseOutputDir,classFolders(i).name));

    % Retrieve Test Set directories
    groupPictureDirectories = dir(strcat(baseInputDir,'\',classFolders(i).name));
    groupPictureDirectories(1:2) = [];
    
    for j = 1 : length(groupPictureDirectories)
        
        % Create output child directory
        mkdir(strcat(baseOutputDir, classFolders(i).name,'\', groupPictureDirectories(j).name));
        
        % List Test Set picture
        searchPictures = dir(strcat(baseInputDir,'\',classFolders(i).name, '\', groupPictureDirectories(j).name));     
        searchPictures(1:2) = [];
        
        for k = 1 : length(searchPictures)              
            
            % Get specific test picture
            searchPic = strcat(baseInputDir,'\',classFolders(i).name, '\', groupPictureDirectories(j).name, '\',searchPictures(k).name);
            searchPicOrig = imread(searchPic);
            searchPicCropped = imcrop(searchPicOrig, smallestImgRectangle);
            
            % Convert picture to grayscale
            searchPicGray = rgb2gray(searchPicCropped);
            
            % Extract Hue's Moments
            searchPicMoments = abs(log10(invmoments(searchPicGray)));
            
            % Measure distance for each entry in Training Set
            for x=1:countTrainingImages                      
                resultMomentsDiff = norm(trainingFaceMoments{x}-searchPicMoments);    
                distanceMoments(x) = resultMomentsDiff;
            end
            
            % Sort the distances
            [sortedDistanceMoments, sortIndex] = sort(distanceMoments);
            
            % Display nearest matches results
            searchResult = figure('Color',[1 1 1], 'Visible', 'off');
            subplot(2,7,1);
            imshow(searchPic);
            title('Search Picture');
            for y=1:13
                subplot(2,7,y+1); 
                imshow(trainingFaceImages{sortIndex(y)});
                title(sprintf('Dist=%2.2f',sortedDistanceMoments(y)));
            end;

            % Save result
            saveas(searchResult, strcat(baseOutputDir,classFolders(i).name, '\', groupPictureDirectories(j).name, '\',searchPictures(k).name))
        end
     end
end