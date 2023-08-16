%%
%Q.1
clear all;
clc;
image = zeros(1000,1500,3);
%we shall take 24 pixels per image, hence N=24=4*6 and p=16
z = zeros(24,16,3);
r = zeros(16,1000*1500);
g = zeros(16,1000*1500);
b = zeros(16,1000*1500);
for i=1:16
    filename = "exposure"+string(i)+".jpg";
    image = imread(filename);
    image = imresize(image,0.25);
    im_r = image(:,:,1);
    im_g = image(:,:,2);
    im_b = image(:,:,3);
    r(i,:) = im_r(:);
    g(i,:) = im_g(:);
    b(i,:) = im_b(:);
    for j=1:3
        img = image(:,:,j);
        zi = 1;
        for x=1:4
            for y=1:6
                z(zi,i,j) = img(floor(1000/5)*x,floor(1500/7)*y);
                zi = zi+1;
            end
        end
    end
end
clear im_r im_g im_b;

B = log(2.^(1:16)/2048);

Z_vals = 0:255;
w = w_calc(Z_vals);
l=1;

[g_r, IE_r] = gsolve(z(:,:,1),B,l,w);
[g_g, IE_g] = gsolve(z(:,:,2),B,l,w);
[g_b, IE_b] = gsolve(z(:,:,3),B,l,w);
figure,
plot(g_r,Z_vals,'r');xlabel('log exposure');ylabel('pixel intensities');title('red channel response function');
figure,
plot(g_g,Z_vals,'g');xlabel('log exposure');ylabel('pixel intensities');title('green channel response function');
figure,
plot(g_b,Z_vals,'b');xlabel('log exposure');ylabel('pixel intensities');title('blue channel response function');
figure,
plot(g_r,Z_vals,'r');xlabel('log exposure');ylabel('pixel intensities');title('camera response function');
hold on;
plot(g_g,Z_vals,'g');xlabel('log exposure');ylabel('pixel intensities');
plot(g_b,Z_vals,'b');xlabel('log exposure');ylabel('pixel intensities');
legend('Red','Green','Blue');
hold off;
%%
%Q.2
flattened_img = zeros(3,1000*1500);
split_size = 10^7;
n_splits = floor((1000*1500)/10^7);
rem = 1000*1500 - n_splits*split_size;

w_vals = w_calc(r');
g_ = g_r(int32(r' + 1));

num = sum(w_vals.*(g_ - B),2);
den = sum(w_vals,2);
flattened_img(1,:) = exp(num./den);

w_vals = w_calc(g');
g_ = g_g(int32(g' + 1));

num = sum(w_vals.*(g_ - B),2);
den = sum(w_vals,2);
flattened_img(2,:) = exp(num./den);

w_vals = w_calc(b');
g_ = g_b(int32(b' + 1));

num = sum(w_vals.*(g_ - B),2);
den = sum(w_vals,2);
flattened_img(3,:) = exp(num./den);

reshaped_img = reshape(flattened_img',1000,1500,3);
hdrwrite(reshaped_img,'HDR_radiance.hdr');
%%
%Q.3.a
% The 3 K values that I have chosen are 0.3, 0.5, 0.7
%K = 0.15;
K = 0.7;
%K = 0.5;
%K = 0.3;
B_ = 0.95;
epsilon = 10^(-12);
im1 = zeros(size(image));
im1(:,:,1) = reshape(tone_map(flattened_img(1,:),K,B_,epsilon,true),1000,1500);
im1(:,:,2) = reshape(tone_map(flattened_img(2,:),K,B_,epsilon,true),1000,1500);
im1(:,:,3) = reshape(tone_map(flattened_img(3,:),K,B_,epsilon,true),1000,1500);

figure,
imshow(uint8(255*rescale(im1)));title('K='+string(K)+' Iwhite=inf');
%%
%Q.3.b
K = 0.5;B_ = 0.5;
%K = 0.6;B_ = 0.95;
%K = 0.4;B_ = 0.4;
%B_ = 0.1;
%B_ = 0.03;

epsilon = 10^(-12);
im2 = zeros(size(image));
im2(:,:,1) = reshape(tone_map(flattened_img(1,:),K,B_,epsilon,false),1000,1500);
im2(:,:,2) = reshape(tone_map(flattened_img(2,:),K,B_,epsilon,false),1000,1500);
im2(:,:,3) = reshape(tone_map(flattened_img(3,:),K,B_,epsilon,false),1000,1500);

figure,
imshow(uint8(255*rescale(im2)));title('K='+string(K)+' B='+string(B_));
%%
%{
Increasing the K values increse the overall brightness of the image due to which the brighter regions of the image
tend to get over-exposed and saturated. It is because K and Ibar_hdr are directly proportional and directly affect 
the final intensity of the scale of the resulting image.
When setting I_white!=inf, the brightness of the darker regions of the image increses slightly, when observed 
closely with the previous case's images. Therefore, changing B varies the lower limit of the intensity scale of 
the resulting images. When B<=0.1, the overall intensity of the image drops down drastically, much lower than when 
I_white=inf. 
%}