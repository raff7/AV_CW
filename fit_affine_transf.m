function [model] = fit_affine_transf(data)
n_pts = size(data,1);
% Split the data in source points and target points
source_pts = data(:, 1:4);
target_pts = data(:, 5:8);

% Augment data so to use an affine transformation
%source_pts = [source_pts, ones(n_pts,1)];
%target_pts = [target_pts, ones(n_pts,1)];

% Estimate affine transf matrix
model = (source_pts \ target_pts);

% Correct entries
model(4, 1:3) = 0;
model(4, 4) = 1;
end

