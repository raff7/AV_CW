function [model] = fit_affine_transf(data)
n_pts = size(data,1);
% Split the data in source points and target points to be matched
source_pts = data(:, 1:3);
target_pts = data(:, 4:6);

% Following the given paper, perform SVD of the correlation matrix of the
% points to find the rotation, and then find translation on rotated data

% Find the point coords wrt to the centroids
source_cnt = source_pts - mean(source_pts);
target_cnt = target_pts - mean(target_pts);

% Find the correlation matrix
corr_mat = source_cnt' * target_cnt;

% Perform SVD
[U, S, V] = svd(corr_mat);

% Find estimated rotation mat
estimated_Rmat = V * U';

% Estimate translation comparing rotated centroids
estimated_transl = mean(target_pts) - mean(source_pts) * estimated_Rmat';

model = {};
model.Rmat = estimated_Rmat;
model.transl = estimated_transl;

end

