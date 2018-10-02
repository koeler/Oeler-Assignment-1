function [Test_Image, Disk_Rad] = Test_Im_OL(Disk_Rad,num_Disk,Disk_Int,M,N)
%Reference I used to figure out the non-overlapping of disks: Image Analyst
%on 16 Jul 2016 https://www.mathworks.com/matlabcentral/answers/291753-how-to-plot-a-number-of-circles-with-the-same-radius-but-the-position-of-the-circles-is-randomly-pu
% close all;
% clear all;
% clc; 

% Disk_Rad = 30;
% Disk_Int = [255, 100, 222, 180, 235, 100, 230, 222, 180, 235];
% num_Disk = 8;
% M = 256;
% N = 256;

theta = 0:0.001:2*pi;
Background_Image = 1 * ones(M, N, 'uint8');

x_range = [0+Disk_Rad,N - Disk_Rad];
y_range = [0+Disk_Rad,M - Disk_Rad];

for n = 1:num_Disk
    x(n) = randi([x_range(1),x_range(2)]);
    y(n) = randi([y_range(1),y_range(2)]);
    Int = Disk_Int(randi(numel(Disk_Int)));
    for r = 1:Disk_Rad
        for th = 1:length(theta)
            x_cir(th) = x(n) - r*cos(th);
            y_cir(th) = y(n) - r*sin(th);
            Background_Image(floor(y_cir(th)),floor(x_cir(th)),:) = Int;
        end
    end
end
Test_Image = Background_Image;
imshow(Test_Image);
Test_Image = Background_Image;
imshow(Test_Image);
blur = randi([0,4]);
Test_Image = imgaussfilt(Test_Image,blur);
imshow(Test_Image);
mean_gaus = 0.005*rand(1);
Test_Image = imnoise(Test_Image,'gaussian',mean_gaus);
disp('Blur sigma');
disp(blur);
disp('Noise mean');
disp(mean_gaus);
imshow(Test_Image);

