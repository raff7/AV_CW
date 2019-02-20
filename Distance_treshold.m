clear
office = load('office1.mat');
office = office.pcl_train;
new_office = cell(1,1);
treshold = 4;
for i = 1:length(office)
    point = office{i}.Location;
    color = office{i}.Color;
    mask = find(point(:,3)<treshold);
    new_point = point(mask,:);
    new_color = color(mask,:);
    new_office{i}= pointCloud(new_point, 'Color', new_color);
    pcshow(office{i})
    pcshow(new_office{i})
end