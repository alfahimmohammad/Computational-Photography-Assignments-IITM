%3.a
clc;
clear all;
fg = imread('redcar.png');
bg = imread('background.png');
CodeSeq=double('1111111111111111111111111111111111111111111111111111')-'0';
[h, w, ch] = size(fg);
blur = zeros(h,w+51,52,ch);
blur = (blur+nan);
fg_blur = zeros(h,w+51,ch);
for i=1:ch
    b = squeeze(blur(:,:,:,i));
    for j=1:52
        if CodeSeq(j) == 1
            d = w+j-1;
            %slice = squeeze(img(:,:,i));
            b(:,j:d,j) = double(fg(:,:,i));
        end
    end
    fg_blur(:,:,i) = reshape(mean(b,3,'omitnan'),1,h,w+51);
end
fg_blur = uint8(fg_blur);
fg_mask = fg_blur == 0;
bg_resize = imresize(bg,[h,w+51]);
final_blur = double(fg_blur) + double(fg_mask).*double(bg_resize);
imshow(uint8(final_blur));title('blurred car in static background');
%%
%3.b
cameraT = cell2mat(struct2cell(load('cameraT.mat')));
bg_T = zeros(h,w+29+51,53,ch);
bg_T = (bg_T+nan);
final_bg_T = zeros(h,w+51+29,ch);
camerat = round(cameraT);
camerat(camerat==52) = 51;
camerat = camerat + 1;
for i=1:ch
    b = squeeze(bg_T(:,:,:,i));
    for j=1:53
       
        d = w+camerat(j)-1;
        %slice = squeeze(img(:,:,i));
        b(:,29+camerat(j):29+d,j) = double(bg(:,:,i));

    end
    final_bg_T(:,:,i) = reshape(mean(b,3,'omitnan'),1,h,w+29+51);
end
final_bg_t_resize = imresize(final_bg_T(:,30:end,:),[h,w+29+51]);
object_t = 0:52;
relative_t = round(cameraT) - object_t;
relative_t(relative_t==52) = 51;
relative_t = relative_t + 1;
rlt_t = zeros(h,w+29+51,53,ch);
rlt_t = (rlt_t+nan);
final_relative_blur = zeros(h,w+51+29,ch);
for i=1:ch
    b = squeeze(rlt_t(:,:,:,i));
    for j=1:53
       
        d = w+relative_t(j)-1;
        %slice = squeeze(img(:,:,i));
        b(:,29+relative_t(j):29+d,j) = double(fg(:,:,i));

    end
    final_relative_blur(:,:,i) = reshape(mean(b,3,'omitnan'),1,h,w+29+51);
end
final_relative_blur = uint8(final_relative_blur);
final_relative_mask = final_relative_blur == 0;
final_relative_t = double(final_relative_blur) + double(final_relative_mask).*double(final_bg_t_resize);
imshow(uint8(final_relative_t));title('Blurring with both camera and object motion');
%%
%3.d
x = [0.1 1:51];
a = 1/sqrt(13);
psf = 1./sqrt(a.*x);
plot(x,psf);xlabel('x');ylabel('PSF(x)');title('Parabola PSF');
parabola_blur = uint8(final_relative_t);
parabola_blur = imresize(parabola_blur,[h,w+51]);
rot_final_blur = zeros(w+51,h,ch);
rot_final_blur(:,:,1) = rot90(parabola_blur(:,:,1),1);
rot_final_blur(:,:,2) = rot90(parabola_blur(:,:,2),1);
rot_final_blur(:,:,3) = rot90(parabola_blur(:,:,3),1);
%%
%getting A matrix
InputImage = rot_final_blur;
[H,W,CH] = size(rot_final_blur);
m = 52;
k = [52]; % Assume Blur Size in pixels = 235
% Resize image height by m/k so that the effective blur is m
InputImage1 = imresize(InputImage,[ceil(H*m/k) W],'bicubic');
% Get object size, n, knowing blurredSize = n + m - 1
n = size(InputImage1,1) - m + 1;
% Foreground: Get A matrix for foreground which encodes the blurring
Af = ComposeMotionBlurMatrix(psf, n);
% Background: bk is contribution vector of bkgrnd in blurred img for all pix
bk = abs(1 - Af*ones(n,1));
% Assume constant background in first m and last m pixels (effective blur is m)
bkLeft = zeros(size(bk)); bkLeft(1:m)=bk(1:m);
bkRite = zeros(size(bk)); bkRite(end-m+1:end)=bk(end-m+1:end);
% Ready to Solve AX=B for each color channel
spy(Af);
%%
A = [Af bkLeft bkRite];
%OutColorImage = zeros(size(Af,2),h,ch);
for colorchannel = 1:CH
    B = InputImage1(:,:,colorchannel); % coded img for channel
    X = A\B; %Least square solution
    OutColorImage(:,:,colorchannel) = X(1:end-2,:);
end
% Expand/shrink the deblurred image to match blur size of k
%OutColorImage = imresize(OutColorImage,[H-k+1 W],'bicubic');
final_result = zeros(h,size(Af,2),ch);
final_result(:,:,1) = rot90(OutColorImage(:,:,1),3);
final_result(:,:,2) = rot90(OutColorImage(:,:,2),3);
final_result(:,:,3) = rot90(OutColorImage(:,:,3),3);
%final_result(:,:,1) = uint8(255*((final_result(:,:,1) - min(min(final_result(:,:,1))))/(max(max(final_result(:,:,1))) - min(min(final_result(:,:,1))))));
%final_result(:,:,2) = uint8(255*((final_result(:,:,2) - min(min(final_result(:,:,2))))/(max(max(final_result(:,:,2))) - min(min(final_result(:,:,2))))));
%final_result(:,:,3) = uint8(255*((final_result(:,:,3) - min(min(final_result(:,:,3))))/(max(max(final_result(:,:,3))) - min(min(final_result(:,:,3))))));
final_result = uint8(final_result);
imshow(final_result);