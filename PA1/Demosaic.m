function rgb = Demosaic(img,mask,key)
img = double(img);
mask = double(mask);
l = size(img,1); h = size(img,2);
r = (mask == 1);
g = (mask == 2);
b = (mask == 3);
red = r.*img;
green = g.*img;
blue = b.*img;

[xi,yi] = meshgrid(1:h,1:l);
[x,y] = meshgrid(1:h,1:l);
zs = r==0; % Zeros locations
red(zs) = [];
x(zs) = [];
y(zs) = [];
rl = floor(size(r,1)/2); rb = floor(size(r,2)/2);
xl = floor(size(xi,1)/2); xb = floor(size(xi,2)/2);
yl = floor(size(yi,1)/2); yb = floor(size(yi,2)/2);
red = reshape(red,rl,rb);
x = reshape(x,xl,xb);
y = reshape(y,yl,yb);

Red = griddata(x,y,double(red),xi,yi,key);
Red(isnan(Red)) = 0;
Red = (Red - min(min(Red)))/(max(max(Red)) - min(min(Red))) *255;
RED = Red/255;

[xi,yi] = meshgrid(1:h,1:l);
[x,y] = meshgrid(1:h,1:l);
zs = b==0; % Zeros locations
blue(zs) = [];
x(zs) = [];
y(zs) = [];
bl = floor(size(b,1)/2); bb = floor(size(b,2)/2);
xl = floor(size(xi,1)/2); xb = floor(size(xi,2)/2);
yl = floor(size(yi,1)/2); yb = floor(size(yi,2)/2);
blue = reshape(blue,bl,bb);
x = reshape(x,xl,xb);
y = reshape(y,yl,yb);

Blue = griddata(x,y,double(blue),xi,yi,key);
Blue(isnan(Blue)) = 0;
Blue = (Blue - min(min(Blue)))/(max(max(Blue)) - min(min(Blue))) *255;
BLUE = Blue/255;

[xi,yi] = meshgrid(1:h,1:l);
[x,y] = meshgrid(1:h,1:l);
zs = g==0; % Zeros locations
green(zs) = [];
x(zs) = [];
y(zs) = [];
gl = l; gb = floor(size(g,2)/2);
xl = l; xb = floor(size(xi,2)/2);
yl = l; yb = floor(size(yi,2)/2);
green = reshape(green,gl,gb);
x = reshape(x,xl,xb);
y = reshape(y,yl,yb);

Green = griddata(x,y,double(green),xi,yi,key);
Green(isnan(Green)) = 0;
GREEN = (Green - min(min(Green)))/(max(max(Green)) - min(min(Green))) *255;
GREEN = GREEN/255;

rgb = cat(3,double(RED),double(GREEN),double(BLUE));