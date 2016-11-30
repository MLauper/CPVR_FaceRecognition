%##########################################################################
% File:       PCA_FaceRecognition.m
% Purpose:    Face recognition with Hue's Moments algorithm
% Author:     Fabian Bigler, Marco Lauper
% Date:       Nov-2016
%##########################################################################
clear all;
baseOutputDir = '.\out\FaceRecognition\PCA\';

% search pictures from ViolaJones Face detection
baseInputDir = '.\out\FaceDetection\ViolaJones\';

trainingSetDir = '.\Images\cpvr_faces_160\';

files = dir(trainingSetDir);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
trainingFacePictureFolders = files(dirFlags);
trainingFacePictureFolders(1:2) = [];
smallestImgSize = [0,0, 120, 160];
outputMask = floor(imcrop(imread('.\Images\mask_160.jpg'), smallestImgSize)./255);

k=0;
%building training set
for i = 1 : length(trainingFacePictureFolders)        
    trainingFacePictureFiles = dir(strcat(trainingSetDir,trainingFacePictureFolders(i).name));
    trainingFacePictureFiles(1:2) = [];    
    
    for j = 1 : length(trainingFacePictureFiles)           
        filename = strcat(trainingSetDir,trainingFacePictureFolders(i).name,'\',trainingFacePictureFiles(j).name);
        image_data = imread(filename);             
        k = k + 1;                 
        image_data = imcrop(image_data, smallestImgSize).*outputMask;
        image_data = rgb2gray(image_data);
        trainingFaces(:,k) = image_data(:);
    end    
end


countTrainingImages = k;
nImages = k;                     %total number of images
imsize = size(image_data);       %size of image (they all should have the same size) 
nPixels = imsize(1)*imsize(2);   %number of pixels in image
normalizedTrainingFaces = double(trainingFaces)/255;       %convert to double and normalize

%% Step 2: Calculate & show the mean image and shift all faces by it
meanFace = mean(normalizedTrainingFaces, 2);
for i=1:nImages
    normalizedTrainingFaces(:,i) = normalizedTrainingFaces(:,i)-meanFace;          % substruct the mean
end;

%% Step 3: Calculate Eigenvectors & Eigenvalues 
% Method 2: Create covariance matrix faster by using 
% Turk and Pentland's trick to get the eigenvectors of faces*faces' from
% the eigenvectors of faces'*faces
covarianceFaces = normalizedTrainingFaces'*normalizedTrainingFaces;
[eigvec,eigval] = eig(covarianceFaces);
clear covarianceFaces;
eigvec = normalizedTrainingFaces * eigvec;                        % Convert eigenvectors back as if they came from A'*A
eigvec = eigvec / (sqrt(abs(eigval)));          % Normalize eigenvectors
% eigvec & eigval are in fact sorted but in the wrong order
eigval = diag(eigval);                          % Get the eigenvalue from the diagonal
eigval = eigval / nImages;                      % Normalize eigenvalues
[eigval, indices] = sort(eigval, 'descend');    % Sort the eigenvalues
eigvec = eigvec(:, indices);                    % Sort the eigenvectors accordingly
%discard first three PCs
eigvec(1:3) = 0;

rotatedTrainingFaces = eigvec' * normalizedTrainingFaces;

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
              searchPicFile = strcat(baseInputDir,'\',classFolders(i).name, '\', groupPictureDirectories(j).name, '\',searchPictures(k).name);              
              searchPicOrig = imread(searchPicFile);
              searchPicCropped = imcrop(searchPicOrig, smallestImgSize);
              searchPicCropped = rgb2gray(searchPicCropped);
              searchPicCroppedNormalized = double(searchPicCropped)/255;              
              
              search = eigvec' * (searchPicCroppedNormalized(:) - meanFace);                                           
              for imgIndex=1:nImages                    
                    distancePrincipalComponents(imgIndex) = dot(rotatedTrainingFaces(:,imgIndex)-search, rotatedTrainingFaces(:,imgIndex)-search);                                        
              end;
              
              [sortedPrincipalComponents, sortIndex] = sort(distancePrincipalComponents); % sort distances  
              
              searchResult = figure('Color',[1 1 1], 'Visible', 'off');
              subplot(2,7,1); 
              imshow(searchPicCropped);
              title('Search Picture');
              for resultIndex=1:13     
                  subplot(2,7,resultIndex+1);
                  imshow(reshape(trainingFaces(:,sortIndex(resultIndex)),imsize));                         
                  title(sprintf('D=%2.2f',sortedPrincipalComponents(resultIndex)));
              end;

              saveas(searchResult, strcat(baseOutputDir,classFolders(i).name, '\', groupPictureDirectories(j).name, '\',searchPictures(k).name))
          end                                        
     end
end;