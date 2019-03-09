function [dist] = err_affine_transf(model, data)
% Split the data in source points and target points
source_pts = data(:, 1:3);
target_pts = data(:, 4:6);

% Prepare data for affine transformation
source_pts = [source_pts; ones(len(data), 1)];

% Transform source data and remove last column (all ones for affine transf)
transf_source = source_pts * model;
transf_source = transf_source(:, 1:3);

% Calculate the euclidian distance between projected points and targets
residuals = transf_source-target_pts;
dist = sqrt(sum(residuals.^2, 2));
end

