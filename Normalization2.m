clear variables;
close all;
clc;

%Normalization using an iterative scheme based on affine transformations

%Define the location of the faces_features folder and the file format
dname = '/Users/briannaburton/Documents/Masters/facial-recognition-PCA/faces_features';
txtfiles = dir(cat(2,dname,'/*.txt'));

%Define an average vector F to store the average locations of the facial
%features and initialize it to the values of the first image
f1 = importdata(cat(2,dname,'/',txtfiles(1).name));
f1 = cat(2, f1, ones(size (f1, 1), 1));
av_F = f1;

%For a transformation fiP = Afi + b, where A and b are unknown: 
%fi*A = fiP where A = [a11, a12, 0; a21, a22, 0; b1, b2, 1], fi is the
%original fi padded by a column of ones in column 3, and fiP is defined
%below. A is found using SVD (least squares). First find the transformation
%and apply it on the features of image 1
fiP = [13, 20, 1; 50, 20, 1; 34, 34, 1; 16, 50, 1; 48, 50, 1];
A = f1 \ fiP;
result = f1 * A; 
%Update av_F by setting it to the result of the transformation
av_F = result;

%Find the transformation that best aligns the features of image 2  with
%av_F and apply the transformation on image 2's feature locations
f2 = importdata(cat(2,dname,'/',txtfiles(2).name));
f2 = cat(2, f2, ones(size (f2, 1), 1));
A = f2 \ av_F;
result = f2 * A;
%Update new_av_F by setting it to the result of the transformation
new_av_F = result;

%For every face image, find the best transformation that aligns it with
%av_F. Update av_F by averaging new_av_F into it. Stop when the error
%between av_F and new_av_F is less than a threshold.
stop_cond = (0.1 * ones([5,2]));
stop_cond = cat(2, stop_cond, zeros(size (stop_cond, 1), 1));

iterations = 2;

for i=3:length(txtfiles)
    while (abs(av_F-new_av_F) >= stop_cond)
        av_F = (av_F*(iterations-1))/iterations + new_av_F/iterations;
        cfile = txtfiles(i).name;
        f1 = importdata(cat(2,dname,'/',cfile));
        f1 = cat(2, f1, ones(size (f1, 1), 1));
        A = f1 \ av_F; %Find transformation matrix
        new_av_F = f1 * A; %Apply transformation matrix on the original positions
        iterations = iterations + 1;
    end
end

%Now apply inverse mapping to map the new 64x64 window to the original
%image

%Define a 64x64 window which determines the face locations
N = 64;

%Import image 1
jpgfiles = dir(cat(2,dname,'/*.jpg'));
image1 = imread(cat(2,dname,'/',jpgfiles(1).name));
newim = zeros(N,N,3);
invA = inv(A);
for i=1:N
    for j=1:N
        for k=1:3
            mapped_coor = [i, j, 1] * invA;
            x = round(mapped_coor(1));
            y = round(mapped_coor(2));
            newim(i,j,k) = image1(x,y,k);
        end
    end
end

newim = uint8(newim);
imshow(newim)