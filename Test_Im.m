function [Test_Image, Disk_Rad] = Test_Im(Disk_Rad,num_Disk,Disk_Int,M,N)
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

C = 1;
StopCheck = 1000 * num_Disk;
i = 1;
while  C <= num_Disk && i < StopCheck
	x_cen = randi([x_range(1),x_range(2)]);
	y_cen = randi([y_range(1),y_range(2)]);
	i = i+1;
	if C == 1
        Int = Disk_Int(randi(numel(Disk_Int)));
        for r = 1:Disk_Rad
            for th = 1:length(theta)
                x_cir(th) = x_cen - r*cos(th);
                y_cir(th) = y_cen - r*sin(th);
                Background_Image(floor(y_cir(th)),floor(x_cir(th)),:) = Int;
            end
        end
         x(C) = x_cen;
         y(C) = y_cen;
    else
		dist = sqrt((x_cen - x) .^ 2 + (y_cen - y) .^ 2);
		if min(dist) < 2 * Disk_Rad
			continue;
		end
	end
	x(C) = x_cen;
	y(C) = y_cen;
	C = C + 1;
end

for n = 2:num_Disk
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
blur = randi([0,2]);
Test_Image = imgaussfilt(Test_Image,blur);
imshow(Test_Image);
mean_gaus = 0.001*rand(1);
Test_Image = imnoise(Test_Image,'gaussian',mean_gaus);
disp('Blur sigma');
disp(blur);
disp('Noise mean');
disp(mean_gaus);
imshow(Test_Image);
