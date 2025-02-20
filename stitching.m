% Set 3: 2383,2024-05-15 16:04:05,1715803445,11296019

clear;
clc;

% Load images
left_cam_img = imread('../test_images_for_stitching/set_1_undistort/left.jpg');
center_cam_img = imread('../test_images_for_stitching/set_1_undistort/center.jpg');
right_cam_img = imread('../test_images_for_stitching/set_1_undistort/right.jpg');

% Right image processing
[right_height, right_width, ~] = size(right_cam_img);
new_right_width = round(right_width * 0.80);
new_right_height = round(right_height * 0.70);
right_rows_to_remove = right_height - new_right_height;
right_cam_img = right_cam_img((right_rows_to_remove + 1):end, 1:new_right_width, :);

% Left image processing
[left_height, left_width, ~] = size(left_cam_img);
new_left_width = round(left_width * 0.80);
new_left_height = round(left_height * 0.70);
left_rows_to_remove = left_height - new_left_height;
left_cam_img = left_cam_img((left_rows_to_remove + 1):end, (left_width - new_left_width + 1):end, :);

[center_height, center_width, ~] = size(center_cam_img);
new_center_height = round(center_height * 0.70);
new_center_width = round(center_width * 1);  
center_rows_to_remove = center_height - new_center_height;
center_cols_to_remove_each_side = round((center_width - new_center_width) / 2);
center_cam_img = center_cam_img((center_rows_to_remove + 1):end, ...
                                (center_cols_to_remove_each_side + 1):(center_width - center_cols_to_remove_each_side), :);

% right_cam_img = matchHistograms(right_cam_img, center_cam_img);
% left_cam_img = matchHistograms(left_cam_img, center_cam_img);

% Convert images to grayscale
left_gray = im2gray(left_cam_img);
center_gray = im2gray(center_cam_img);
right_gray = im2gray(right_cam_img);

left_gray = histeq(left_gray);
center_gray = histeq(center_gray);
right_gray = histeq(right_gray);

points_left = detectSIFTFeatures(left_gray);
points_center = detectSIFTFeatures(center_gray);
points_right = detectSIFTFeatures(right_gray);

% Extract feature descriptors
[features_left, valid_points_left] = extractFeatures(left_gray, points_left);
[features_center, valid_points_center] = extractFeatures(center_gray, points_center);
[features_right, valid_points_right] = extractFeatures(right_gray, points_right);

% Match features between center and left
index_pairs_center_left = matchFeatures(features_center, features_left);
matched_points_center_left = valid_points_center(index_pairs_center_left(:,1));
matched_points_left = valid_points_left(index_pairs_center_left(:,2));

% Match features between center and right
index_pairs_center_right = matchFeatures(features_center, features_right);
matched_points_center_right = valid_points_center(index_pairs_center_right(:,1));
matched_points_right = valid_points_right(index_pairs_center_right(:,2));

figure('Position', [100, 100, 1200, 400]);

% Subplot for right and center images
subplot(1, 2, 1);
showMatchedFeatures(right_cam_img, center_cam_img, matched_points_right, matched_points_center_right, 'montage');
title('Matches between Right and Center Images');
xlabel('Right Image                                Center Image');

% Subplot for center and left images
subplot(1, 2, 2);
showMatchedFeatures(center_cam_img, left_cam_img, matched_points_center_left, matched_points_left, 'montage');
title('Matches between Center and Left Images');
xlabel('Center Image                                Left Image');

% Adjust subplot spacing
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);


% Apply custom RANSAC to both pairs of matches
[filtered_matched_points_center_right, filtered_matched_points_right] = customRANSAC(matched_points_center_right, matched_points_right);
[filtered_matched_points_center_left, filtered_matched_points_left] = customRANSAC(matched_points_center_left, matched_points_left);

% Visualize the filtered matches
figure('Position', [100, 100, 1200, 400]);

% Subplot for right and center images
subplot(1, 2, 1);
showMatchedFeatures(right_cam_img, center_cam_img, filtered_matched_points_right, filtered_matched_points_center_right, 'montage');
title('Filtered Matches between Right and Center Images');
xlabel('Right Image                                Center Image');

% Subplot for center and left images
subplot(1, 2, 2);
showMatchedFeatures(center_cam_img, left_cam_img, filtered_matched_points_center_left, filtered_matched_points_left, 'montage');
title('Filtered Matches between Center and Left Images');
xlabel('Center Image                                Left Image');

% Adjust subplot spacing
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

% Compute homography matrices
tform_right_to_center = estimateGeometricTransform2D(filtered_matched_points_right, filtered_matched_points_center_right, 'projective');
tform_left_to_center = estimateGeometricTransform2D(filtered_matched_points_left, filtered_matched_points_center_left, 'projective');

% Determine the output panorama size
[height, width, ~] = size(center_cam_img);
panorama_width = width * 1.5;  
panorama_height = height;

panoramaView = imref2d([panorama_height, panorama_width]);

% Initialize the panorama
panorama = zeros([panorama_height, panorama_width, 3], 'like', center_cam_img);

% Create an alpha blender
blender = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port');



% Add center image (no warping needed as it's the reference)
warpedImage_center = imwarp(center_cam_img, affine2d(eye(3)), 'OutputView', panoramaView);
mask_center = imwarp(true(size(center_cam_img,1),size(center_cam_img,2)), affine2d(eye(3)), 'OutputView', panoramaView);
panorama = step(blender, panorama, warpedImage_center, mask_center);

% Warp and blend left image
warpedImage_left = imwarp(left_cam_img, tform_left_to_center, 'OutputView', panoramaView);
mask_left = imwarp(true(size(left_cam_img,1),size(left_cam_img,2)), tform_left_to_center, 'OutputView', panoramaView);
panorama = step(blender, panorama, warpedImage_left, mask_left);

% Warp and blend right image
warpedImage_right = imwarp(right_cam_img, tform_right_to_center, 'OutputView', panoramaView);
mask_right = imwarp(true(size(right_cam_img,1),size(right_cam_img,2)), tform_right_to_center, 'OutputView', panoramaView);
panorama = step(blender, panorama, warpedImage_right, mask_right);

% Display the final panorama
figure;
imshow(panorama);
title('Stitched Panorama');

% imwrite(panorama, 'stitched_panorama.jpg');