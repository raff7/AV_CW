function [dist] = err_affine_transf(model, data)
% Split the data in source points and target points
source_pts = data(:, 1:3);
target_pts = data(:, 4:6);

% Transform source data
transf_source = source_pts * model.Rmat' + model.transl;

% Calculate the euclidian distance between projected points and targets
residuals = transf_source-target_pts;
dist = sqrt(sum(residuals.^2, 2));
end

