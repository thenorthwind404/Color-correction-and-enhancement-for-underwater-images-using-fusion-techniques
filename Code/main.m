close all;
clear all;
clc;    
%% Load the image and split channels. 

rgbImage=double(imread('./Dataset/91_img_.png'))/255;

figure, imshow(rgbImage);
grayImage = rgb2gray(rgbImage); 

Ir = rgbImage(:,:,1);
Ig = rgbImage(:,:,2);
Ib = rgbImage(:,:,3);

Ir_mean = mean(Ir, 'all');
Ig_mean = mean(Ig, 'all');
Ib_mean = mean(Ib, 'all');

%% Color compensation
alpha = 0.5;
Irc = Ir + alpha*(Ig_mean - Ir_mean);
alpha = 0.1; 

Ibc = Ib + alpha*(Ig_mean - Ib_mean);

%% White Balance

I = cat(3, Irc, Ig, Ibc);
I_lin = rgb2lin(I);
percentiles = 5;
illuminant = illumgray(I_lin,percentiles);
I_lin = chromadapt(I_lin,illuminant,'ColorSpace','linear-rgb');
Iwb = lin2rgb(I_lin);


%figure('name', 'Underwater White Balance');
%imshow([rgbImage, I, Iwb])

%%% Multi-Scale fusion. 

%% Gamma Correction
I1 = imadjust(Iwb,[],[],2);
imwrite(I1, '1.jpg', 'jpg');
%figure('name', 'Gamma Correction');
%imshow([Iwb, Igamma])


%% image sharpening
sigma = 20
Igauss = Iwb;
N = 30;
for iter=1: N
   Igauss =  imgaussfilt(Igauss,sigma);
   Igauss = min(Iwb, Igauss);
end

gain = 1;  
Norm = (Iwb-gain*Igauss);
%Norm
for n = 1:3
   Norm(:,:,n) = histeq(Norm(:,:,n)); 
end
I2 = (Iwb + Norm)/2;
imwrite(I2, '2.jpg', 'jpg');
% figure('name', 'image sharpening');
% imshow([Iwb,Igauss,Norm, Isharp])

%% load source images
 img1=double(imread('1.jpg'));
 img2=double(imread('2.jpg'));

%% Multi-Scale Guided Image Fusion
% Guided image filter parameters
r=9; 
eps=10^3;

%% apply multi-scale guided image fusion on source images
tic
F = fuse_MGF_RGB(img1, img2, r, eps);
toc
%% display source images and the fused image
%figure, imshow(uint8(I1), []);
%figure, imshow(uint8(I2),[]);
%figure, imshow((F),[]);
figure, imshow(I1);
figure, imshow(I2);
figure, imshow(F);