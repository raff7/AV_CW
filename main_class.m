addpath('./utils/');
%prep = Preprocess("office1.mat");
%prep.find_NaN()
%prep.find_edges()
%prep.find_distant_points()
%prep.remove_handsome_man()
%prep.show()
%prep.find_outliers()
%prep.show()
ft = FeatureMatching("office1.mat"); 
solution = ft.matchSurf();
