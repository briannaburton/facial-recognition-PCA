%% Applied Mathematics
% Homework Face recognition

%% Antoine MERLET Condorcet

clc; % Clear command window.
clear; % Delete all variables.
close all; % Close all figure windows except those created byimtool.
imtool close all; % Close all figure windows created by imtool.
workspace; % Make sure the workspace panel is showing.

dname = uigetdir('/Users/briannaburton/');
files = dir(cat(2,dname,'/*.jpg'));
f = figure('units','normalized','outerposition',[0 0 1 1]);
datamat = zeros(length(files),2);
destdir = cat(2,dname,'/points');
mkdir(destdir);
for i=1:length(files) % Select center
    img = imread(cat(2,dname,'/',files(i).name));
    imshow(img)
    set(get(handle(gcf),'JavaFrame'),'Maximized',1);
    [c,r,but] = ginput(5)
    datamat(:,1) = round(c(:));
    datamat(:,2) = round(r(:));
    fname = strsplit(files(i).name,'.');
    dlmwrite(cat(2,destdir,'/',cell2mat(fname(1)),'.txt'),datamat,'delimiter',' ','newline', 'pc');
end
close(f);
disp('DONE!');
