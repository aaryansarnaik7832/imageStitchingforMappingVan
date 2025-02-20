close all; clc;
imageFolder = 'images_for_calibration/left';
filePattern = fullfile(imageFolder, '*.jpg');
imageFiles = dir(filePattern);
boardSize = [7, 12];
imagePoints = {};
validImagePoints = {};
validImages = [];
imageSize = [];

for i = 1:numel(imageFiles)
    I = imread(fullfile(imageFolder, imageFiles(i).name));
    [points, currentBoardSize] = detectCheckerboardPoints(I);
    
    % Store image size (we only need to do this once)
    if isempty(imageSize)
        imageSize = size(I(:,:,1)); % Use only height and width
    end
    % disp(currentBoardSize);
    % Only use images where all expected points are detected
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

% Check if we have any valid images
if isempty(validImagePoints)
    error('No valid images found. Check your checkerboard detection or board size.');
end

% Generate world points based on the board size
worldPoints = generateCheckerboardPoints(boardSize, 100);

% Convert cell array of valid image points to a 3D matrix
numPoints = size(validImagePoints{1}, 1);
imagePointsMatrix = zeros(numPoints, 2, numel(validImagePoints));
for i = 1:numel(validImagePoints)
    imagePointsMatrix(:,:,i) = validImagePoints{i};
end

% Perform camera calibration
[cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePointsMatrix, worldPoints, ...
    'ImageSize', imageSize, 'NumRadialDistortionCoefficients', 3, 'EstimateSkew', true);

% Display results
% figure;
% showReprojectionErrors(cameraParams);
% figure;
% showExtrinsics(cameraParams);

save('camera_parameters/leftCameraParams.mat', 'cameraParams');

fprintf('Calibration completed using %d out of %d images.\n', numel(validImages), numel(imageFiles));