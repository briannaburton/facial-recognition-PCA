%% Applied Mathematics
% Homework Face recognition

%% Antoine MERLET Condorcet

clc; % Clear command window.
clear; % Delete all variables.
close all; % Close all figure windows except those created byimtool.
imtool close all; % Close all figure windows created by imtool.
workspace; % Make sure the workspace panel is showing.

xdest = 240;
ydest = 320;
dname = uigetdir('C:\');
files = dir(cat(2,dname,'\*.jpg'));
f = figure('units','normalized','outerposition',[0 0 1 1]);
destdir = cat(2,dname,'\cropped');
mkdir(destdir);
for i=1:length(files) % Select center
    img = imread(cat(2,dname,'\',files(i).name));
    if (strfind(dname,'faces2'))
    	img = imrotate(flipdim(img,2),270);
    end
    img = imresize(img,0.15,'bicubic'); % resize so that the full face fits later in the cropp
    imshow(img)
    set(get(handle(gcf),'JavaFrame'),'Maximized',1);
    [c,r,but] = ginput(1);
    c = round(c);
    r = round(r);
    x1 = c-xdest/2;
    y1 = r-ydest/2;
    newimg = imcrop(img,[x1 y1 xdest-1 ydest-1]);
    fname = strsplit(files(i).name,'.');
    imwrite(newimg,cat(2,destdir,'\',cell2mat(fname(1)),'_cropped.jpg'));
end
close(f);


