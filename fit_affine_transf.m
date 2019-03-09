function [model] = fit_affine_transf(data)
n_pts = length(data);
% Split the data in source points and target points
source_pts = data(:, 1:3);
target_pts = data(:, 4:6);

% Augment data so to use an affine transformation
source_pts = [source_pts; ones(n_pts,1)];
target_pts = [target_pts; ones(n_pts,1)];

% Estimate affine transf matrix
model = source_pts \ target_pts;

% Correct entries
model(4, 1:3) = 0;
model(4, 4) = 1;
end

