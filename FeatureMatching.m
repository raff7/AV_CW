classdef FeatureMatching < handle
    %FEATUREMATCHING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        prep
        
    end
    
    methods
        function self = FeatureMatching(file)
            %FEATUREMATCHING Construct an instance of this class
            %   Detailed explanation goes here
            self.prep = Preprocess(file);
            self.prep.find_NaN()
            self.prep.find_edges()
            self.prep.find_distant_points()
            self.prep.remove_handsome_man()
            self.prep.find_outliers()
        end
        
        function matchSurf(self)
            %% Find features, match them
            pic1 = rgb2gray(imag2d(self.prep.original_data{1}.Color));
            %pic1 = pic1 .* uint8(transpose(reshape(self.prep.removed_points{1},[640, 480])));
            surf1 = detectSURFFeatures(pic1, 'MetricThreshold', 500);
            surf1= self.remove_masked_surfs(surf1,1);
            [feat1, pts1] = extractFeatures(pic1, surf1);
            for i = 2:length(self.prep.original_data)
               pic2 = rgb2gray(imag2d(self.prep.original_data{i}.Color));
               surf2 = detectSURFFeatures(pic2, 'MetricThreshold', 500);
               surf2= self.remove_masked_surfs(surf2,i);
               %surf2 = surf2(imag2d(reshape(self.prep.removed_points{i},[640, 480])))
               [feat2, pts2] = extractFeatures(pic2, surf2);
               idx_pairs = matchFeatures(feat1, feat2);
               matchedPoints1 = pts1(idx_pairs(:,1));
               matchedPoints2 = pts2(idx_pairs(:,2  ));
               figure; showMatchedFeatures(pic1,pic2,matchedPoints1,matchedPoints2);
               legend('matched points 1','matched points 2');
               %figure; imshow(pic1)
               %figure; imshow(pic2)
               pic1 = pic2;
               surf1 = surf2;
               feat1 = feat2;
               pts1= pts2;
            end
        end
        function new_surf = remove_masked_surfs(self,surf,frameIDX)
            counter = 1;
            mask_2d = reshape(self.prep.removed_points{frameIDX},[640, 480]);
            new_surf = SURFPoints();
            for i=1:length(surf)
                x = round(surf.Location(i,1));
                y = round(surf.Location(i,2));
                if(mask_2d(x,y)==1)
                    new_surf(counter) = surf(i);
                    counter = counter+1;
                end
            end
        end
    end
end

