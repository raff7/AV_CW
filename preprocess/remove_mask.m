function [new_office] = remove_mask(office,mask)
%Function to apply a mask to office_data
%   keeps pixels whre mask is 1, remove where is 0
new_office = cell(1,length(office));
for i=1:length(mask)
    rgb = office{i}.Color; % Extracting the colour data
    point = office{i}.Location; % Extracting the xyz data
    ind = find(mask{i});
    new_office{i} = pointCloud(point(ind,:), 'Color', rgb(ind,:)); % Creating a point-cloud variable
end

