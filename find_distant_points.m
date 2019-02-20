function [mask] = find_distant_points(office,treshold)
%FIND_DISTANT_POINTS Find all the points over a Z-coordinate treshold
%   Detailed explanation goes here
mask = [];
for i = 1:length(office)
    point = office{i}.Location;
    mask(i) = find(point(:,3)<treshold);
end

