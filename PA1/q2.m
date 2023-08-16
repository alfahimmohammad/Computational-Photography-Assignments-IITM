%%
clc
clear all;
rgbimg = imread('RawImage3rgb.png');
grayimg = rgb2gray(rgbimg);
red_mean = mean2(rgbimg(:,:,1));
green_mean = mean2(rgbimg(:,:,2));
blue_mean = mean2(rgbimg(:,:,3));
gray_mean = mean2(grayimg);
rgbimg(:,:,1) = uint8(double(rgbimg(:,:,1)) * gray_mean/red_mean);
rgbimg(:,:,2)= uint8(double(rgbimg(:,:,2)) * gray_mean/green_mean);
rgbimg(:,:,3) = uint8(double(rgbimg(:,:,3)) * gray_mean/blue_mean);
%imwrite(rgbimg,'RawImage3rgbwb.png')
figure, imshow(rgbimg); title('White Balancing');

%Histogram Equalization
hsv = rgb2hsv(rgbimg);
Heq = histeq(hsv(:,:,3));
%imhist(hsv(:,:,3));
hsv(:,:,3) = Heq;
rgb = hsv2rgb(hsv);
figure, imshow(rgb); title('Histogram Equalization')

%Gamma Correction
Grgb1 = imadjust(rgbimg,[],[],0.5);
Grgb2 = imadjust(rgbimg,[],[],0.7);
Grgb3 = imadjust(rgbimg,[],[],0.9);
figure, imshow(Grgb1); title('0.5 gamma correction');
figure, imshow(Grgb2); title('0.7 gamma correction');
figure, imshow(Grgb3); title('0.9 gamma correction');
%%
figure,
montage({rgbimg, rgb},'Size',[1 2])
%%
figure,
montage({rgbimg, Grgb1, Grgb2, Grgb3},'Size',[2 2])
%%
clc; clear all;
%(814,830) - 1, (280,1165) - 2, (675,175) - 3
rgbimg = imread('RawImage3rgb.png');
y = 675; x = 175;
rgbimg(:,:,1) = uint8(double(rgbimg(:,:,1)) * 255/double(rgbimg(y,x,1)));
rgbimg(:,:,2) = uint8(double(rgbimg(:,:,2)) * 255/double(rgbimg(y,x,2)));
rgbimg(:,:,3) = uint8(double(rgbimg(:,:,3)) * 255/double(rgbimg(y,x,3)));
figure, imshow(rgbimg); title('White Balancing');
%%
clc; clear all;
%(435,2000) - 1, (715,445) - 2, (565,1550) - 3
rgbimg = imread('RawImage3rgb.png');
grayimg = rgb2gray(rgbimg);
y = 565; x = 1550;
rgbimg(:,:,1) = uint8(double(rgbimg(:,:,1)) * double(grayimg(y,x))/double(rgbimg(y,x,1)));
rgbimg(:,:,2) = uint8(double(rgbimg(:,:,2)) * double(grayimg(y,x))/double(rgbimg(y,x,2)));
rgbimg(:,:,3) = uint8(double(rgbimg(:,:,3)) * double(grayimg(y,x))/double(rgbimg(y,x,3)));
figure, imshow(rgbimg); title('White Balancing');