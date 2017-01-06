%##########################################################################
% File:       PCA_FaceRecognition.m
% Purpose:    Face recognition with Hue's Moments algorithm
% Author:     Fabian Bigler, Marco Lauper
% Date:       Nov-2016
%##########################################################################

% Define file locations
baseOutputDir = '.\out\FaceRecognition\PCA\';
baseInputDir = '.\out\FaceDetection\ViolaJones\';
trainingSetDir = '.\Images\cpvr_faces_160\';

% Define mask location
outputMask = floor(imcrop(imread('.\Images\mask_160.jpg'), smallestImgSize)./255);

%% Traing with Training Set

% Get input files
files = dir(trainingSetDir);
dirFlags = [files.isdir];
trainingFacePictureFolders = files(dirFlags);
trainingFacePictureFolders(1:2) = [];
smallestImgSize = [0,0, 120, 160];

k=0;
for i = 1 : length(trainingFacePictureFolders)        
    
    % List training set pictures
    trainingFacePictureFiles = dir(strcat(trainingSetDir,trainingFacePictureFolders(i).name));
    trainingFacePictureFiles(1:2) = [];    
    
    for j = 1 : length(trainingFacePictureFiles)           
        % Read training image
        filename = strcat(trainingSetDir,trainingFacePictureFolders(i).name,'\',trainingFacePictureFiles(j).name);
        image_data = imread(filename);             
        k = k + 1;
        image_data = imcrop(image_data, smallestImgSize).*outputMask;
        
        % Convert to grayscale
        image_data = rgb2gray(image_data);
        trainingFaces(:,k) = image_data(:);
    end    

end

% Get some properties and normalize training set
countTrainingImages = k;
nImages = k;
imsize = size(image_data);
nPixels = imsize(1)*imsize(2);
normalizedTrainingFaces = double(trainingFaces)/255;

% Calculate mean face of the training set
meanFace = mean(normalizedTrainingFaces, 2);

% Subtract mean face of all training set images
for i=1:nImages
    normalizedTrainingFaces(:,i) = normalizedTrainingFaces(:,i)-meanFace;
end;

% Retrieve the Eigenvalues
covarianceFaces = normalizedTrainingFaces'*normalizedTrainingFaces;
[eigvec,eigval] = eig(covarianceFaces);
clear covarianceFaces;
eigvec = normalizedTrainingFaces * eigvec;
eigvec = eigvec / (sqrt(abs(eigval)));
eigval = diag(eigval);
eigval = eigval / nImages;

% Normalize and the Eigenvalues
[eigval, indices] = sort(eigval, 'descend');
eigvec = eigvec(:, indices);

% Set the first three eigenvectors to zero to ignore them
eigvec(1:3) = 0;
rotatedTrainingFaces = eigvec' * normalizedTrainingFaces;

%% Try to identify faces 

% Get test set pictures
files = dir(baseInputDir);
dirFlags = [files.isdir];
classFolders = files(dirFlags);
classFolders(1:2) = [];

for i = 1 : length(classFolders)

    % Create output directory
    mkdir(strcat(baseOutputDir,classFolders(i).name));
    
    % Retrieve test pictures
    groupPictureDirectories = dir(strcat(baseInputDir,'\',classFolders(i).name));
    groupPictureDirectories(1:2) = [];
    
    for j = 1 : length(groupPictureDirectories)
        
        % Create output directory
        mkdir(strcat(baseOutputDir, classFolders(i).name,'\', groupPictureDirectories(j).name));
        
        % Retrieve specific test picture
        searchPictures = dir(strcat(baseInputDir,'\',classFolders(i).name, '\', groupPictureDirectories(j).name));     
        searchPictures(1:2) = [];
        
        for k = 1 : length(searchPictures)              
            
            % Read test picture
            searchPicFile = strcat(baseInputDir,'\',classFolders(i).name, '\', groupPictureDirectories(j).name, '\',searchPictures(k).name);              
            searchPicOrig = imread(searchPicFile);
            searchPicCropped = imcrop(searchPicOrig, smallestImgSize);
            
            % Convert to grayscale and normalize
            searchPicCropped = rgb2gray(searchPicCropped);
            searchPicCroppedNormalized = double(searchPicCropped)/255;              
            
            % Subtract the mean face
            search = eigvec' * (searchPicCroppedNormalized(:) - meanFace);
            
            % Extract the distances to training set entries
            for imgIndex=1:nImages                    
                  distancePrincipalComponents(imgIndex) = dot(rotatedTrainingFaces(:,imgIndex)-search, rotatedTrainingFaces(:,imgIndex)-search);                                        
            end;
            
            % Sort all distances
            [sortedPrincipalComponents, sortIndex] = sort(distancePrincipalComponents); % sort distances  
            
            % Print the result
            searchResult = figure('Color',[1 1 1], 'Visible', 'off');
            subplot(2,7,1); 
            imshow(searchPicCropped);
            title('Search Picture');
            for resultIndex=1:13     
                subplot(2,7,resultIndex+1);
                imshow(reshape(trainingFaces(:,sortIndex(resultIndex)),imsize));                         
                title(sprintf('D=%2.2f',sortedPrincipalComponents(resultIndex)));
            end;

            % Export the result
            saveas(searchResult, strcat(baseOutputDir,classFolders(i).name, '\', groupPictureDirectories(j).name, '\',searchPictures(k).name))
        end                                        
    end
end;