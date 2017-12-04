clear variables;
close all;
clc;

%Normalization using an iterative scheme based on affine transformations
%Define a 64x64 window which determines the face locations
N = 64;

%Define the location of the faces_features folder and the file format
dname = '/Users/briannaburton/Documents/Masters/facial-recognition-PCA/faces_features';
files = dir(cat(2,dname,'/*.txt'));

%Define an average vector F to store the average locations of the facial
%features and initialize it to the values of the first image
f1 = importdata(cat(2,dname,'/',files(1).name));
f1 = cat(2, f1, ones(size (f1, 1), 1));
av_F = f1;

%For a transformation fiP = Afi + b, where A and b are unknown: 
%fi*A = fiP where A = [a11, a12, 0; a21, a22, 0; b1, b2, 1], fi is the
%original fi padded by a column of ones in column 3, and fiP is defined
%below. A is found using SVD (least squares)

fiP = [13, 20, 1; 50, 20, 1; 34, 34, 1; 16, 50, 1; 48, 50, 1]; %predetermined location
A = av_F \ fiP; %Find transformation matrix


%Once the transformation A is found, apply it on every face image
new_av_F = zeros([5,3]);
for i=1:length(files)
    cfile = files(i).name;
    f1 = importdata(cat(2,dname,'/',cfile));
    f1 = cat(2, f1, ones(size (f1, 1), 1));
    fiP = f1 * A;
    new_av_F = new_av_F + fiP;
end
new_av_F = new_av_F/(length(files));

iterations = 0;

%In the loop, determine new_av_F and compare it to the previous av_F. Stop
%if less than a threshold.
stop_cond = (0.01 * ones([5,2]));
stop_cond = cat(2, stop_cond, zeros(size (stop_cond, 1), 1));

while (abs(av_F-new_av_F) >= stop_cond)
    av_F = new_av_F;
    fiP = [13, 20, 1; 50, 20, 1; 34, 34, 1; 16, 50, 1; 48, 50, 1]; %predetermined location
    A = av_F \ fiP; %Find transformation matrix

    %Apply A to every image and find the mean transformation
    new_av_F = zeros([5,3]);
    for i=1:length(files)
        cfile = files(i).name;
        f1 = importdata(cat(2,dname,'/',cfile));
        f1 = cat(2, f1, ones(size (f1, 1), 1));
        fiP = f1 * A;
        new_av_F = new_av_F + fiP;
    end
    new_av_F = new_av_F/(length(files))
    iterations = iterations + 1
end
