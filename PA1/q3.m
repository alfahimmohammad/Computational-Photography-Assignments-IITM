%%
%(1060:1128,1:100) - 1, (705:765,924:984) - 2, (1:200,1:200) - 3
clc; clear all;
rgb = double(imread('RawImage3rgbwb.png'))/255;
w = 11/2; sigma = zeros(1,2);
sigma(1) = 2.5; 
sigma_nr = std2(rgb(1:200,1:200,1));
sigma_ng = std2(rgb(1:200,1:200,2));
sigma_nb = std2(rgb(1:200,1:200,3));
%red filtering
sigma(2) = 1.95*sigma_nr;
rgb(:,:,1) = bfilter2(rgb(:,:,1),w,sigma);
%green filtering
sigma(2) = 1.95*sigma_ng;
rgb(:,:,2) = bfilter2(rgb(:,:,2),w,sigma);
%blue filtering
sigma(2) = 1.95*sigma_nb;
rgb(:,:,3) = bfilter2(rgb(:,:,3),w,sigma);

figure, imshow(rgb);

%if sigma_r<=sigma_n, there would be less performance of noise filtering
%if sigma_r>>sigma_n, the noise filtering would be so much that even the
%edges would get smoothened.

%If k is the size of kernel than sigma=(k-1)/6 . 
%This is because the length for 99% of gaussian pdf is 6sigma.