function [out_pc] = merge_point_clouds(data, matches, transformations)
% Add first point cloud
out_pc = data{1};
cum_transf = eye(4);

for i = 1:len(matches)
    match = matches{i};
    aff_transf = transformations{i};
    
    cum_transf = cum_transf * aff_transf;
    
    pc2 = data{match.ID2};
    n_pts2 = size(pc2.Location, 1);
    
    new_pts = [pc2.Locations, ones(n_pts2, 1)] / cum_transf;
    new_pts = new_pts(:, 1:3);

    new_pc2 = pointCloud(new_pts, 'Color', pc2.Color);
    
    out_pc = pcmerge(out_pc, new_pc2, 0.05);
    
    close all
    pcshow(out_pc)
    pause()
    
end

