% Center: 7x13
% Left: 7x12
% Right: 7x14

close all; clc;

imageFolder = 'images_for_calibration/right';
filePattern = fullfile(imageFolder, '*.jpg');
imageFiles = dir(filePattern);

% Initialize a container to store the board sizes
boardSizes = cell(numel(imageFiles), 1);

for i = 1:numel(imageFiles)
    I = imread(fullfile(imageFolder, imageFiles(i).name));
    [~, currentBoardSize] = detectCheckerboardPoints(I);
    boardSizes{i} = currentBoardSize;
end

% Convert cell array to string array for easier counting
boardSizesStr = cellfun(@(x) sprintf('%dx%d', x(1), x(2)), boardSizes, 'UniformOutput', false);

% Count occurrences of each board size
[uniqueSizes, ~, idx] = unique(boardSizesStr);
counts = accumarray(idx, 1);

% Find the most common board size
[maxCount, maxIdx] = max(counts);
mostCommonSize = uniqueSizes{maxIdx};

% Display results
disp('Board size counts:');
for i = 1:length(uniqueSizes)
    fprintf('%s: %d\n', uniqueSizes{i}, counts(i));
end

fprintf('\nMost common board size: %s (occurred %d times)\n', mostCommonSize, maxCount);