%%
clc;
clear all;
img = cell2mat(struct2cell(load('RawImage1.mat')));
mask = cell2mat(struct2cell(load('bayer1.mat')));
%linear
rgbl = Demosaic(img,mask,'linear');
figure, imshow(rgbl); title('bilinear interpolation');
%cubic
rgbc = Demosaic(img,mask,'cubic');
figure, imshow(rgbc); title('bicubic interpolation');
%imwrite(im2uint8(rgbc),'RawImag3rgb.png')
%%
%demosaic
rgbd = demosaic(img,'rggb');
figure, imshow(rgbd); title('matlab demosaicing');
%%
kodim = cell2mat(struct2cell(load('kodim19.mat')));
kodim_mask = cell2mat(struct2cell(load('kodim_cfa.mat')));
kodimrgb = Demosaic(kodim,kodim_mask,'cubic');
figure, imshow(kodimrgb); title('kodim demosaicing');

kodimycbcr = rgb2ycbcr(kodimrgb);
kodimycbcr(:,:,2) = medfilt2(kodimycbcr(:,:,2),[15 15],'symmetric');
kodimycbcr(:,:,3) = medfilt2(kodimycbcr(:,:,3),[15 15],'symmetric');
kodim_rgb = ycbcr2rgb(kodimycbcr);
figure, imshow(kodim_rgb); title('kodim median filtered ycbcr');