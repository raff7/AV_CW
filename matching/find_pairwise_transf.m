function [transformations] = find_pairwise_transf(matched_pts, dist_thresh)
n_matches = length(matched_pts);
transformations = cell(n_matches, 1);

fit_fnc = @(data) fit_affine_transf(data);
dist_fnc = @(model, data) err_affine_transf(model, data);

for i = 1:n_matches
    match = matched_pts{i};
    pts1 = match.points1;
    pts2 = match.points2;
    n_points = size(pts1, 1);
    
    ransac_input = [pts1, ones(n_points, 1), pts2, ones(n_points, 1)];
    
    [aff_mat, inlier_idx] = ransac(ransac_input,fit_fnc,dist_fnc,4,dist_thresh);
    
    inlier_count = sum(inlier_idx);
    
    if inlier_count / n_points < 0.5
        error('Less than half of the points agree on the model')
    end
    
    transformations{i} = aff_mat;
    
end

end

