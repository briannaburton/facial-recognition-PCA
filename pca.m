%PCA based recognition system
%This script calculates accuracy of algorithm
train_imgs_folder = './train_images/';
test_imgs_folder = './test_images/';
%number of eigenvectors to keep
n_pca = 50;
name_regex = '^normalized_(?<name>[A-za-z\s]*)[_\d]*.jpg$';

[feature_matrix, proj_matrix, labels, ~] = train(train_imgs_folder, n_pca);

%finding of algorith accuracy
%compute feature vectors for test images and find error

%read all images from training folder
test_imgs_files = dir(strcat(test_imgs_folder));

test_feature_vects = [];
%assuming that we have no other directories inside this directory
test_labels = cell(1, length(test_imgs_files) - 2);

for i = 1:length(test_imgs_files)
    entry = test_imgs_files(i);
    if (~entry.isdir)
        temp_img = rgb2gray(imread(strcat(test_imgs_folder, entry.name)));
        %concatenating rows of image
        temp_img = temp_img';
        temp_img = temp_img(:)';
        test_feature_vects = [test_feature_vects; double(temp_img)*proj_matrix];
        temp_label = regexp(entry.name, name_regex, 'names');
        %cause first two entries is directories
        test_labels{i-2} = temp_label.name;
    end
end

error = 0;
for i = 1:length(test_feature_vects)
    %find lowest
    temp_fvector = test_feature_vects(i, :);
    temp_dist = bsxfun(@minus, feature_matrix, temp_fvector);
    temp_dist = temp_dist';
    temp_dist2 = sqrt(sum(temp_dist.*temp_dist));
    [~, column] = min(temp_dist2);
    
    if ~strcmp(labels{column}, test_labels{i})
        error = error + 1;
    end
end

accuracy = (1 - error/length(test_imgs_files)) * 100;
disp(strcat('Accuracy of algorithm is:', num2str(round(accuracy, 2)), '%'));
