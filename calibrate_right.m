close all; clc;
imageFolder = 'images_for_calibration/right';
filePattern = fullfile(imageFolder, '*.jpg');
imageFiles = dir(filePattern);
boardSize = [7, 14];
imagePoints = {};
validImagePoints = {};
validImages = [];
imageSize = [];

for i = 1:numel(imageFiles)
    I = imread(fullfile(imageFolder, imageFiles(i).name));
    [points, currentBoardSize] = detectCheckerboardPoints(I);
    
    if isempty(imageSize)
        imageSize = size(I(:,:,1)); 
    end
    % disp(currentBoardSize);
    if isequal(currentBoardSize, boardSize)
        validImagePoints{end+1} = points;
        validImages(end+1) = i;
        
        % figure;
        % imshow(I);
        % hold on;
        % plot(points(:, 1), points(:, 2), 'ro', 'MarkerSize', 15);
        % title(['Detected corners in image ', num2str(i)]);
        % hold off;
    else
        fprintf('Skipping image %d due to incomplete checkerboard detection\n', i);
    end
end

if isempty(validImagePoints)
    error('No valid images found. Check your checkerboard detection or board size.');
end

worldPoints = generateCheckerboardPoints(boardSize, 100);

numPoints = size(validImagePoints{1}, 1);
imagePointsMatrix = zeros(numPoints, 2, numel(validImagePoints));
for i = 1:numel(validImagePoints)
    imagePointsMatrix(:,:,i) = validImagePoints{i};
end

[cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePointsMatrix, worldPoints, ...
    'ImageSize', imageSize, 'NumRadialDistortionCoefficients', 3, 'EstimateSkew', true);

% figure;
% showReprojectionErrors(cameraParams);
% figure;
% showExtrinsics(cameraParams);

% save('camera_parameters/rightCameraParams.mat', 'cameraParams');
% 
% intrinsicMatrix = cameraParams.IntrinsicMatrix;
% radialDistortion = cameraParams.RadialDistortion;
% tangentialDistortion = cameraParams.TangentialDistortion;
% 
% adjustedRadialDistortion = radialDistortion * 0.8; 
% 
% adjustedCameraParams = cameraParameters('IntrinsicMatrix', intrinsicMatrix, ...
%                                         'RadialDistortion', adjustedRadialDistortion, ...
%                                         'TangentialDistortion', tangentialDistortion, ...
%                                         'ImageSize', cameraParams.ImageSize);

I_2 = imread('test_images_for_stitching/set_3/right.jpg');
J = undistortImage(I_2, cameraParams);

figure;
subplot(1,2,1); imshow(I_2); title('Original Image');
subplot(1,2,2); imshow(J); title('Undistorted Image');

fprintf('Calibration completed using %d out of %d images.\n', numel(validImages), numel(imageFiles));