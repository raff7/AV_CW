%% Configuration and params
clear
file_name = 'office1.mat';
im_height = 640;
im_width = 480;
distance_threshold = 3.5;%to remove points outside the window
W_edge = 5;%distance from the edge (in pixels) to be removed
remove_man = false;
square_dist_neig_treshold = 0.05^2;%distance to consider 2 points "neighbours"
minimum_neig = 80;%minimum number of neighbours needed to stay
%% Read the data
office_data = load(file_name);
office_data = office_data.pcl_train;

office_data = office_data(27);
pcshow(office_data{1})

%% Preprocessing
% Keep track of all of the points removed for all frames
removed_points = [];

% select all points in point with z > threshold
removed_points  = find_distant_points(office_data, distance_threshold);
new_office_data = remove_mask(office_data, removed_points);
figure()
pcshow(new_office_data{1})

%remove points on the edge of the images
edge_removed = find_edge(office_data, W_edge,im_height,im_width);
for i=1:length(removed_points)
        removed_points{i} = removed_points{i}.*edge_removed{i};
end
new_office_data = remove_mask(office_data, removed_points);
figure()
pcshow(new_office_data{1})


% select all points belonging to that handsome man in frame 27
% TODO
if remove_man
    man_removed = find_handsome_man(office_data);
    for i=1:length(removed_points)
        removed_points{i} = removed_points{i}.*man_removed{i};
    end
end

% select outling points like flying pixels, spike and data near the edges
outlier_removed = find_outliers(office_data,square_dist_neig_treshold, minimum_neig,im_height,im_width);
for i=1:length(removed_points)
    removed_points{i} = removed_points{i}.*outlier_removed{i};
end
new_office_data = remove_mask(office_data, removed_points);
figure()
pcshow(new_office_data{1})

% remove all points selected
office_data = remove_mask(office_data, removed_points);