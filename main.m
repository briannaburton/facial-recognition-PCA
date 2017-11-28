clear variables;
close all;
clc;

%Normalization using an iterative scheme based on affine transformations
%Define a 64x64 window which determines the face locations
N = 64;

%Define an average vector F to store the average locations of the facial
%features
av_F = zeros([5,2]);

%Import the feature data and compute the average locations
dname = '/Users/briannaburton/Documents/Masters/Applied Maths/Facial_Recognition_Using_PCA/brianna';
files = dir(cat(2,dname,'/*.txt'));
for i=1:length(files)
    F1 = importdata(cat(2,dname,'/',files(i).name));
    av_F = av_F + F1;
end
av_F = av_F/(length(files))

%Extract the 5 features into their own vectors
trans_F = av_F.';
f1 = trans_F(:,1);
f2 = trans_F(:,2);
f3 = trans_F(:,3);
f4 = trans_F(:,4);
f5 = trans_F(:,5);


A = zeros([2,2]);
b = zeros([2,1]);

lsqlin(A, av_F, 0, b)