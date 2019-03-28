addpath('./utils/');

ft = FeatureMatching("office1.mat"); 
matched_pts = ft.matchSurf();
transt  = ft.find_pairwise_transf(matched_pts);
pc = ft.merge_point_clouds(matched_pts,transt);
fit_plane(pc)
