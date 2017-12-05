clear variables;
close all;
clc;

%Normalization using an iterative scheme based on affine transformations

%Define the location of the faces_features folder and the file format
dname = 'faces_features/';
txtfiles = dir(cat(2,dname,'/*.txt'));

%Define an average vector F to store the average locations of the facial
%features and initialize it to the values of the first image
f1 = importdata(cat(2,dname,'/',txtfiles(1).name));
f1 = cat(2, f1, ones(size (f1, 1), 1));
av_F = f1;

%For a transformation fiP = Afi + b, where A and b are unknown: 
%fi*A = fiP where A = [a11, a12, 0; a21, a22, 0; b1, b2, 1], fi is the
%original fi padded by a column of ones in column 3, and fiP is defined
%below. A is found using SVD (least squares) and applied to av_F
fiP = [13, 20, 1; 50, 20, 1; 34, 34, 1; 16, 50, 1; 48, 50, 1]; %predetermined location
A = av_F \ fiP;
av_F = av_F * A;

%To find the new av_F, go through the list of images and determine the
%transformation that aligns A with the av_F. Find the average of these
%transformation results
find_av = zeros(5,3);
for i=1:length(txtfiles)
        cfile = txtfiles(i).name;
        f1 = importdata(cat(2,dname,'/',cfile));
        f1 = cat(2, f1, ones(size (f1, 1), 1));
        A = f1 \ av_F;
        fi = f1 * A;
        find_av = find_av + fi; %save results to find average after loop ends
end
new_av_F = find_av/(length(txtfiles));

%In the loop, determine a new_av_F (calculated same as above) and compare
%it to the previous av_F. Stop if less than a threshold.
threshold = (0.0001 * ones([5,2]));
threshold = cat(2, threshold, zeros(size (threshold, 1), 1));
iterations = 1;

while (abs(av_F-new_av_F) >= threshold)
    av_F = new_av_F;
    find_av = zeros(5,3);
    A = av_F \ fiP;
    new_av_F = av_F * A;
    for i=1:length(txtfiles)
        cfile = txtfiles(i).name;
        f1 = importdata(cat(2,dname,'/',cfile));
        f1 = cat(2, f1, ones(size (f1, 1), 1));
        A = f1 \ new_av_F;
        fi = f1 * A;
        find_av = find_av + fi;
    end
    new_av_F = find_av/(length(txtfiles));
    iterations = iterations + 1;
end

%Define a 64x64 window which determines the face locations
N = 64;
%For each image, find a transformation A that aligns the coordinates with
%new_av_F (determined above). Use inverse mapping with the inverse of this
%transformation in the form mapped_coordinates = 64x64_coordinates * inv(A)
%to find the normalized image. Save the files
%
for z = 1 : length(txtfiles)
    jpgfiles = dir(cat(2,dname,'/*.jpg')); %find jpeg files
    cfile = jpgfiles(z).name;
    image1 = imread(cat(2,dname,'/',cfile)); %read first jpeg files
    newim = zeros(N,N,3); %initialize normalized image
    f1 = importdata(cat(2,dname,'/',txtfiles(z).name));
    f1 = cat(2, f1, ones(size (f1, 1), 1));
    A = f1 \ new_av_F; %transformation that aligns original data with new_av_F
    invA = inv(A);
    for i=1:N
        for j=1:N
            for k=1:3
                mapped_coor = [i, j, 1] * invA; %find coordinates in original image that map to normalized image
                x = round(mapped_coor(1));
                y = round(mapped_coor(2));
                if x > 240
                    x = 240;
                end
                if x < 1
                    x = 1;
                end
                if y > 320
                    y = 320;
                end
                if y < 1
                    y = 1;
                end
                newim(j,i,k) = image1(y,x,k); %map pixel value from original to normalized image
            end
        end
    end
    newim = uint8(newim);
    filename = ['normalized_images/normalized_', cfile];
    imwrite(newim,filename); %save image as jpeg
end

