clear;
clc;

I = imread('../test_images_for_stitching/set_2_undistort/right.jpg');

[height, width, channels] = size(I);

new_width = round(width * 0.85);

I_new = I(:, 1:new_width, :);

figure;
subplot(1,2,1); imshow(I); title('Original Image');
subplot(1,2,2); imshow(I_new); title('New Image');