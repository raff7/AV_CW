addpath('./utils/');
%prep = Preprocess("office1.mat");
%prep.find_NaN()
%prep.find_edges()
%prep.find_distant_points()
%prep.remove_/handsome_man()
%prep.show()
%prep.find_outliers()
%prep.show()
ft = FeatureMatching("office1.mat"); 
matched_pts = ft.matchSurf();
transt  = ft.find_pairwise_transf(matched_pts);
pc = ft.merge_point_clouds(matched_pts,transt);
