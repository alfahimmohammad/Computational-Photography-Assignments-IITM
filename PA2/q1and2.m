clc;
clear all;
img = imread('fish.png');
gaussNoise = cell2mat(struct2cell(load('gaussNoise.mat')));
%gaussNoise = 255*((gaussNoise - min(min(gaussNoise)))./(max(max(gaussNoise)) - min(min(gaussNoise))));
%gaussNoise = uint8(gaussNoise);
m = 52; % Coded Sequence length
%CodeSeq=double('1010000111000001010000110011110111010111001001100111')-'0';
CodeSeq=double('1010101010101010101010101010101010101010101010101010')-'0';
%CodeSeq=double('1111111111111111111111111111111111111111111111111111')-'0';%for question 1
[h, w, ch] = size(img);
blur = zeros(h,w+51,52,ch);
blur = (blur+nan);
final_blur = zeros(h,w+51,ch);
for i=1:ch
    b = squeeze(blur(:,:,:,i));
    for j=1:52
        if CodeSeq(j) == 1
            d = w+j-1;
            %slice = squeeze(img(:,:,i));
            b(:,j:d,j) = double(img(:,:,i));
        end
    end
    final_blur(:,:,i) = reshape(mean(b,3,'omitnan'),1,h,w+51);
end
final_blur = uint8(final_blur);
%final_blur = uint8(final_blur + gaussNoise);
imshow(final_blur);title('blurred image with gaussian noise');
rot_final_blur = zeros(w+51,h,ch);
rot_final_blur(:,:,1) = rot90(final_blur(:,:,1),3);
rot_final_blur(:,:,2) = rot90(final_blur(:,:,2),3);
rot_final_blur(:,:,3) = rot90(final_blur(:,:,3),3);
%%
InputImage = rot_final_blur;
[H,W,CH] = size(rot_final_blur);
k = [52]; % Assume Blur Size in pixels = 235
% Resize image height by m/k so that the effective blur is m
InputImage1 = imresize(InputImage,[ceil(H*m/k) W],'bicubic');
% Get object size, n, knowing blurredSize = n + m - 1
n = size(InputImage1,1) - m + 1;
% Foreground: Get A matrix for foreground which encodes the blurring
Af = ComposeMotionBlurMatrix(CodeSeq, n);
% Background: bk is contribution vector of bkgrnd in blurred img for all pix
bk = abs(1 - Af*ones(n,1));
% Assume constant background in first m and last m pixels (effective blur is m)
bkLeft = zeros(size(bk)); bkLeft(1:m)=bk(1:m);
bkRite = zeros(size(bk)); bkRite(end-m+1:end)=bk(end-m+1:end);
% Ready to Solve AX=B for each color channel
spy(Af);title('A matrix of size 851X800');
%%
ZeroPaddedCodeSeq = [CodeSeq(:)/sum(CodeSeq); zeros(n-1,1)];
x_axis = 1:size(ZeroPaddedCodeSeq,1);
dft = fft(ZeroPaddedCodeSeq);
m = mag2db(abs(dft));
plot(x_axis,m);xlabel('frequency');ylabel('magnitude db');title('DFT');
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
final_result(:,:,1) = rot90(OutColorImage(:,:,1),1);
final_result(:,:,2) = rot90(OutColorImage(:,:,2),1);
final_result(:,:,3) = rot90(OutColorImage(:,:,3),1);
%final_result(:,:,1) = uint8(255*((final_result(:,:,1) - min(min(final_result(:,:,1))))/(max(max(final_result(:,:,1))) - min(min(final_result(:,:,1))))));
%final_result(:,:,2) = uint8(255*((final_result(:,:,2) - min(min(final_result(:,:,2))))/(max(max(final_result(:,:,2))) - min(min(final_result(:,:,2))))));
%final_result(:,:,3) = uint8(255*((final_result(:,:,3) - min(min(final_result(:,:,3))))/(max(max(final_result(:,:,3))) - min(min(final_result(:,:,3))))));
final_result = uint8(final_result);
imshow(final_result);title('Deblurring result');
%%
rmse = sqrt(mean(final_result(:)-img(:)).^2);
disp(rmse);