function [mask] = find_distant_points(office,treshold)
%FIND_DISTANT_POINTS Find all the points over a Z-coordinate treshold
%   Detailed explanation goes here
mask = {};
for i = 1:length(office)
    index_i = [];
    point = office{i}.Location;
    index_i = find(point(:,3)>treshold); %remove points with z value > than treshold
    index_i = [index_i; find(isnan(point(:,3)))];%also remove NaN values.
    mask{i} = ones(1,length(point));
    mask{i}(1,index_i) = 0;
end

