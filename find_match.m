function [index_of_match, test_feature_vect] = find_match(test_img, feature_matrix, proj_matrix)
    %Returns index of feature vector from training feature vectors set,
    %which distance from feature vector of current image is the lowest
    
    %find projection of selected image in space of principle components
    test_img = rgb2gray(test_img);
    test_img = test_img';
    test_img = test_img(:)';
    test_feature_vect = double(test_img)*proj_matrix;
    %find vector that is closest to test_img feature vector
    dist = bsxfun(@minus, feature_matrix, test_feature_vect);
    dist = dist';
    dist2 = sqrt(sum(dist.*dist));
    [~, index_of_match] = min(dist2);
end