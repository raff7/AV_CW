classdef FeatureMatching < handle
    %FEATUREMATCHING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        prep
        SURFSensitivity = 1000
        
    end
    
    methods
        function self = FeatureMatching(file)
            %FEATUREMATCHING Construct an instance of this class
            %   In it, construct a preprocess object.
            self.prep = Preprocess(file);
            fprintf("Start Preprocessing- Find NaN\n")
            self.prep.find_NaN()
            fprintf("NaN found- Find edges\n")
            self.prep.find_edges()
            fprintf("found edges- Find distante points\n")
            self.prep.find_distant_points()
            if self.prep.remove_man
                fprintf("found Distant points- Find BOB\n")
                self.prep.remove_handsome_man()
                fprintf("found BOB- Find outliers\n")
            else
                fprintf("found Distant points- Find Outliers\n")
            end
            self.prep.find_outliers()
            fprintf("DONE")
            self.prep.show()
        end
        
        function matchSurf(self)
            %% Find features, match them
            pic1 = rgb2gray(imag2d(self.prep.original_data{1}.Color));
            i1=1;
            surf1 = detectSURFFeatures(pic1, 'MetricThreshold', self.SURFSensitivity);
            surf1_mask= self.remove_masked_surfs(surf1,1);
            %extract both all SURF points
            [feat1, pts1] = extractFeatures(pic1, surf1);
            %and just the valid SURF points (Elimiating the masked ones)
            [feat1_mask, pts1_mask] = extractFeatures(pic1, surf1_mask);
            for i = 2:length(self.prep.original_data)
               i2=i;
               pic2 = rgb2gray(imag2d(self.prep.original_data{i}.Color));
               surf2 = detectSURFFeatures(pic2, 'MetricThreshold', self.SURFSensitivity);
               surf2_mask= self.remove_masked_surfs(surf2,i);
               
               [feat2, pts2] = extractFeatures(pic2, surf2);
               [feat2_mask, pts2_mask] = extractFeatures(pic2, surf2_mask);
               
               idx_pairs_mask = matchFeatures(feat1_mask, feat2_mask);
               idx_pairs = matchFeatures(feat1, feat2);
               
               matchedPoints1_mask = pts1_mask(idx_pairs_mask(:,1));
               matchedPoints1 = pts1(idx_pairs(:,1));
               matchedPoints2_mask = pts2_mask(idx_pairs_mask(:,2  ));
               matchedPoints2 = pts2(idx_pairs(:,2  ));
               
               Match_Points{i-1}.SURF1 = pts1(idx_pairs(:,1));
               Match_Points{i-1}.SURF2 = pts2(idx_pairs(:,2));
               Match_Points{i-1}.ID1 = i1
               
               self.show(pic1,pic2,matchedPoints1_mask,matchedPoints2_mask,matchedPoints1,matchedPoints2,surf1,surf2,i1,i2)
              
               
           
               %advance loop
               pic1 = pic2;
               surf1_mask = surf2_mask;
               feat1_mask = feat2_mask;
               pts1_mask= pts2_mask;
               i1 = i2;
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
        function show(self,pic1,pic2,matchedPoints1_mask,matchedPoints2_mask,matchedPoints1,matchedPoints2,surf1,surf2,i1,i2)
             %Plot matched features and connections
             close all
             figure('Position',[400 450 700 500])
             showMatchedFeatures(pic1,pic2,matchedPoints1_mask,matchedPoints2_mask);
             legend('matched points 1','matched points 2');
             
             %plot image1, and SURF points (matched, not matched and
             %masked)
             figure('Position',[750 50 700 500])
             imshow(imag2d(self.prep.original_data{i1}.Color))
             hold on;
             scatter(surf1.Location(:,1),surf1.Location(:,2),'r')
             scatter(matchedPoints1.Location(:,1),matchedPoints1.Location(:,2),'r','filled')
             scatter(matchedPoints1_mask.Location(:,1),matchedPoints1_mask.Location(:,2),'g','filled')
             legend('Unmatched points','Masked points','Matched points');

             figure('Position',[0 50 700 500])
             imshow(imag2d(self.prep.original_data{i2}.Color))
             hold on;
             scatter(surf2.Location(:,1),surf2.Location(:,2),'r')
             scatter(matchedPoints2.Location(:,1),matchedPoints2.Location(:,2),'r','filled')
             scatter(matchedPoints2_mask.Location(:,1),matchedPoints2_mask.Location(:,2),'g','filled')
             legend('Unmatched points','Masked points','Matched points');

             pause(2)
        end
    end
end

