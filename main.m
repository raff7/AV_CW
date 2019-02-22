%% Configuration and params
clear
file_name = 'office1.mat';
distance_threshold = 4;
im_height = 640;
im_width = 480;
remove_man = false;
square_dist_neig_treshold = 0.05^2;
minimum_neig = 15;
%% Read the data
office_data = load(file_name);
office_data = office_data.pcl_train;

%% Preprocessing
% Keep track of all of the points removed for all frames
removed_points = [];
% select all points in point with z > threshold
dst_removed = find_distant_points(office_data, distance_threshold);
removed_points = dst_removed;
% select all points belonging to that handsome man in frame 26
% TODO
if remove_man
    man_removed = find_handsome_man(office_data);
    removed_points = removed_points.* man_removed;
end
% select outling points like flying pixels, spike and data near the edges
% TODO
outlier_removed = find_outliers(office_data,square_dist_neig_treshold, minimum_neig,im_height,im_width);
removed_points = removed_points .* outlier_removed;

% remove all points selected
% TODO
office_data = remove_mask(office_data, removed_points);