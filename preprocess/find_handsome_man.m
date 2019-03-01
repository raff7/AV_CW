function [mask] = find_handsome_man(office, frame_n)
% Find two plane boundaries (parallel to y axis) that cut out the man's points
% from the point cloud. Being parallel to y, we can simply find 
% two line equations instead.
mask = {};
for i = 1:length(office)
    mask{i} = ones(1, length(office{i}.Location));
end

% Line 1 eq: x < 0
% Line 2 eq: z < 2
points = office{frame_n}.Location;
mask{frame_n}(points(:,1)<0 & points(:,3)<2) = 0;

end