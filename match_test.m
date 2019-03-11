n_points = 1000;

% Generate a cloud of random 3D points
data = rand(n_points, 3);

% Add dim so can use affine transformation
aug_data = [data, ones(n_points, 1)];

x_angle = 20;
y_angle = 10;
z_angle = 170;

transl = [5, -1, 3]';

Rmat = rotx(x_angle) * roty(y_angle) * rotz(z_angle);

affine_mat = [Rmat, transl; zeros(1,3), 1];

transformed_data = (data * Rmat' + transl');

% Add noise
noise = randn(n_points, 3)*0.05;

noisy_transf_data = transformed_data + noise;

% Estimate the matrix

fit_fnc = @(data) fit_affine_transf(data);
dist_fnc = @(model, data) err_affine_transf(model, data);

ransac_input = [aug_data, noisy_transf_data];


[estimated, inlier_ids] = ransac(ransac_input,fit_fnc,dist_fnc,4,0.02);

sum(inlier_ids)
affine_mat
estimated


