%% COMP 775 Assignment 1: Circular Hough Transform
%By Kelsey Oeler  9.15.2018
%-----------------------------------------------------------------
%% Method to produce a 2D accumulator (feature space) array indexed by (x,y) center values as
% well as a list of voting pixel locations together with the feature space positions they voted for.
%
%1.)Deliver the accumulator position with the most votes and display
%
%2.)Superimposed the disk chosen over the image data.
%
%3.)Upon a command from the user the method removes the votes to the accumulator 
%arrays from voters who voted the winning position, thus producing new
%accumulator array values from which the disk with the most votes will be selected. 
%
%-----------------------------------------------------------------
%% Load in Image & Manipulation
clc;
clear all;
close all;

Img_Type = input('Generated Test Image (1) or Real Image (2) Test Image OverLap(3)?\n');

%% GTI Set-Up
if Img_Type(1) == 2
    r = 123; %Input radius, or radii range, of disk in pixels
    [fname,path] = uigetfile('*.jpg', 'Select an Image');
    fname = strcat(path,fname);
    im = imread(fname);
    im = imresize(im,[256 256]);
    im = im2double(im);
    im_gs = rgb2gray(im);
elseif Img_Type(1) == 3  
    numDisk= 3;
    [Test_Image, Radius]= Test_Im_OL(30,numDisk,[255, 100, 222, 180, 235, 100, 230, 222, 180, 235],256,256);
    Test_Image = im2double(Test_Image);
    im_gs = (Test_Image);
    r = Radius;
else
    numDisk= 3;
    [Test_Image, Radius]= Test_Im(30,numDisk,[255, 100, 222, 180, 235, 100, 230, 222, 180, 235],256,256);
    Test_Image = im2double(Test_Image);
    im_gs = (Test_Image);
    r = Radius;
end
%-----------------------------------------------------------------

%% Parameters
param.Gau_sigma = 0.4; % Scale (Gaussian Deviation)
param.u_sigmoid = 2;%Mean Sigmoid
param.stdev_sigmoid = 2;%Standard Deviation Sigmoid
param.p_sig = 0.4; %Parzen sigma deviation
%-----------------------------------------------------------------
%% Method to produce votes 
%Applying your gradient of a Gaussian procedure to the image
figure;
[imgderx, imgdery] = Derivative(im_gs, param.Gau_sigma);
subplot(1,2,1);
imshow(imgderx);
subplot(1,2,2);
imshow(imgdery);
edges = sqrt(imgderx.*imgderx + imgdery.*imgdery);
figure;
imshow(edges)
direction = atan2(imgdery,imgderx);
param.Grad_mag_Thresh = max(max(edges))*0.75; %gradient magnitude Threshold

%Thresholding the magnitude of each resulting pixel
[y,x] = find(edges>param.Grad_mag_Thresh );
Edge_Points = [x,y];
hold on
plot(x,y,'*m')


%(If the threshold is passed) Vote for centers along the gradient direction according to the radius 
%value and the sense of the gradient direction relative to the desired intensity polarity. 

param.DLThresh = adaptthresh(edges,param.Grad_mag_Thresh,'ForegroundPolarity','bright');
theta_full = atan2(imgdery,imgderx);

theta_edge = [];
for i = 1:length(Edge_Points)
    theta = theta_full(Edge_Points(i,2),Edge_Points(i,1));
    theta_edge = [theta_edge;theta];
end

[numRow, numCol] = size(edges);
H = zeros(numRow, numCol); %Accumulator 
xc = [];
yc = [];
AccPos = [];
for i = 1:length(x)
    xdir = round(r*cos(theta_edge(i)));
    ydir = round(r*sin(theta_edge(i)));

    xc1 = x(i) + xdir;
    yc1 = y(i) + ydir;
    
    xc2  = x(i) - xdir;
    yc2  = y(i) - ydir;
    
    if ([xc1,yc1]) > 0 == 1
        if yc1 < numRow == 1 && xc1 < numCol == 1
            H(xc1,yc1) = H(xc1,yc1) + 1;
            xc = [xc;x(i)];
            yc = [yc;y(i)];
            AccPos = [AccPos;xc1,yc1];
        end
    end
    
    if ([xc2,yc2]) > 0 == 1
        if yc2 < numRow == 1 && xc2 < numCol == 1
            H(xc2,yc2) = H(xc2,yc2) + 1;
            xc = [xc;x(i)];
            yc = [yc;y(i)];
            AccPos = [AccPos;xc2,yc2];
        end
    end

end

Votes = [xc,yc,AccPos];

%After the votes are collected, the accumulator array should be smoothed by a Gaussian in the 
%(x,y) directions according to the Parzen standard deviation
H_GF = imgaussfilt(H,param.p_sig);

%Maximum is found. 
[maxValue, linearIndexesOfMaxes] = max(H_GF(:));
[rowsOfMaxes, colsOfMaxes] = find(H_GF == maxValue);
Full_Set = [rowsOfMaxes, colsOfMaxes];
disp('Center Positions')
disp('x_pos    y_pos')
disp(Full_Set)

%Superimpose
cir_theta = 0:0.005:2*pi;
x_cir = zeros(length(cir_theta),1);
y_cir = zeros(length(cir_theta),1);

close all;

%prompts user for input
prompt = {'Remove winning votes?'};
%Title of dialog box
dlg_title ='Input';
%number of input lines avaiable for each variable
num_lines = 1;
%Default answer for each input 
defaultans = {'Yes'};
%generate the dialog box and wait for answer
answer_pro = inputdlg(prompt,dlg_title,num_lines,defaultans);

   
figure
imshow(edges);
hold on
nd = 0;
for n = 1:length(rowsOfMaxes)
        for th = 1:length(cir_theta)
            x_cir(th) = Full_Set(n,1) - r*cos(th);
            y_cir(th) = Full_Set(n,2) - r*sin(th);
        end
        nd = nd+1
        plot(x_cir,y_cir,'*m')
        if strcmpi(answer_pro{1},'yes') == 1
            for i = 1:length(Votes)
                if isequal(Votes(i,3),Full_Set(n,1)) == 1 &&  isequal(Votes(i,4),Full_Set(n,2)) == 1 
                    H_GF(Votes(i,3),Votes(i,4)) =  H_GF(Votes(i,3),Votes(i,4)) - 1;
                end
            end       
        end
    end
[maxValue, linearIndexesOfMaxes] = max(H_GF(:));
[rowsOfMaxes, colsOfMaxes] = find(H_GF == maxValue);
Full_Set = [rowsOfMaxes, colsOfMaxes];
disp('Center Positions')
disp('x_pos    y_pos')
disp(Full_Set)

