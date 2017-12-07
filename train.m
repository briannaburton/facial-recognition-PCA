function [feature_matrix, proj_matrix, labels, train_imgs] = train(train_imgs_folder, n_pca)
    %Function for training face detection algorithm, returns
    %feature matrix, projection matrix, labels  and images used for
    %training

    %read all images from training folder
    train_imgs_files = dir(strcat(train_imgs_folder));

    D = [];
    train_imgs = cell(1, length(train_imgs_files) - 2);
    %assuming that we have inside no other directories
    labels = cell(1, length(train_imgs_files) - 2);
    name_regex = '^normalized_(?<name>[A-za-z\s]*)[_\d]*.jpg$';

    for i = 1:length(train_imgs_files)
        entry = train_imgs_files(i);
        if (~entry.isdir)
            temp_img = imread(strcat(train_imgs_folder, '\', entry.name));
            temp_label = regexp(entry.name, name_regex, 'names');
            
            %cause first two entries is directories
            labels{i-2} = temp_label.name;
            train_imgs{i-2} = temp_img;
            
            %concatenating rows of image
            temp_img = rgb2gray(temp_img)';
            temp_img = temp_img(:)';
            D = [D; double(temp_img)];
        end
    end

    D_m = D - mean(mean(D));
    [p, d] = size(D_m);
    sigm = (1.0/(p - 1)) * D_m * (D_m');
    [eig_vects, eig_vals] = eig(sigm);

    %since we use sigma` matrix(shorter one), eigenvectors will be
    eig_vects = (D_m')*eig_vects;
    %we also need to correct number of principal compoents
    %n_pca = p;
    %selecting k largest eigenvalues
    [~, eig_max_indices] = sort(diag(eig_vals), 'descend');
    eig_max_indices = eig_max_indices(1:n_pca);
    %creating projection matrix
    proj_matrix = eig_vects(:, eig_max_indices);
    %feature vector 
    feature_matrix = [];
    for i = 1:p
        feature_matrix = [feature_matrix; D(i,:)*proj_matrix];
    end
end