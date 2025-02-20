clear;
clc;

load('camera_parameters/centerCameraParams.mat');

I = imread('images/test_images_for_stitching/set_3/center.jpg');
I = cropImageByPercentage(I, 0, 0, 21, 0);
J = undistortImage(I, cameraParams);

figure;
subplot(1,2,1); imshow(I); title('Original Image');
subplot(1,2,2); imshow(J); title('Undistorted Image');