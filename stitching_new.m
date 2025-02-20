% Load images
left_cam_img = imread('test_images_for_stitching/set_1/left.jpg');
center_cam_img = imread('test_images_for_stitching/set_1/center.jpg');
right_cam_img = imread('test_images_for_stitching/set_1/right.jpg');

% Convert images to grayscale
left_gray = im2gray(left_cam_img);
center_gray = im2gray(center_cam_img);
right_gray = im2gray(right_cam_img);

% Detect and extract SURF features for all images
points_left = detectSURFFeatures(left_gray);
points_center = detectSURFFeatures(center_gray);
points_right = detectSURFFeatures(right_gray);

[features_left, points_left] = extractFeatures(left_gray, points_left);
[features_center, points_center] = extractFeatures(center_gray, points_center);
[features_right, points_right] = extractFeatures(right_gray, points_right);

% Match features between left and center images
indexPairs_left_center = matchFeatures(features_left, features_center, 'Unique', true);
matchedPoints_left = points_left(indexPairs_left_center(:,1), :);
matchedPoints_center_left = points_center(indexPairs_left_center(:,2), :);

% Match features between right and center images
indexPairs_right_center = matchFeatures(features_right, features_center, 'Unique', true);
matchedPoints_right = points_right(indexPairs_right_center(:,1), :);
matchedPoints_center_right = points_center(indexPairs_right_center(:,2), :);

% Estimate the transformation between left and center images
tform_left = estgeotform2d(matchedPoints_left, matchedPoints_center_left,...
    'projective', 'Confidence', 99.9, 'MaxNumTrials', 6000);

% Estimate the transformation between right and center images
tform_right = estgeotform2d(matchedPoints_right, matchedPoints_center_right,...
    'projective', 'Confidence', 99.9, 'MaxNumTrials', 6000);

% Compute the output limits for each transformation
[xlim_left, ylim_left] = outputLimits(tform_left, [1 size(left_gray,2)], [1 size(left_gray,1)]);
[xlim_right, ylim_right] = outputLimits(tform_right, [1 size(right_gray,2)], [1 size(right_gray,1)]);

% Find the minimum and maximum output limits
xMin = min([1; xlim_left(1); xlim_right(1)]);
xMax = max([size(center_gray,2); xlim_left(2); xlim_right(2)]);

yMin = min([1; ylim_left(1); ylim_right(1)]);
yMax = max([size(center_gray,1); ylim_left(2); ylim_right(2)]);

% Width and height of panorama
width = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the panorama
panorama = zeros([height width 3], 'like', left_cam_img);

% Create a 2-D spatial reference object defining the size of the panorama
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Warp and blend the images
blender = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port');

% Warp and blend left image
warpedImage_left = imwarp(left_cam_img, tform_left, 'OutputView', panoramaView);
mask_left = imwarp(true(size(left_cam_img,1),size(left_cam_img,2)), tform_left, 'OutputView', panoramaView);
panorama = step(blender, panorama, warpedImage_left, mask_left);

% Add center image (no warping needed as it's the reference)
warpedImage_center = imwarp(center_cam_img, affine2d(eye(3)), 'OutputView', panoramaView);
mask_center = imwarp(true(size(center_cam_img,1),size(center_cam_img,2)), affine2d(eye(3)), 'OutputView', panoramaView);
panorama = step(blender, panorama, warpedImage_center, mask_center);

% Warp and blend right image
warpedImage_right = imwarp(right_cam_img, tform_right, 'OutputView', panoramaView);
mask_right = imwarp(true(size(right_cam_img,1),size(right_cam_img,2)), tform_right, 'OutputView', panoramaView);
panorama = step(blender, panorama, warpedImage_right, mask_right);

% Display the result
figure;
imshow(panorama);
title('Stitched Road Image');

