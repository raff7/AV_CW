classdef FeatureMatching < handle
    %FEATUREMATCHING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        prep
        SURFSensitivity = 700
        HIGH_SURFSensitivity = 300
        minSURFpoints = 6
        dist_thresh = 0.3
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
        
        function transf_Match_Points= matchSurf(self)
            %% Find features, match them
            pic1 = rgb2gray(imag2d(self.prep.original_data{1}.Color));
            i1=1;
            surf1 = detectSURFFeatures(pic1, 'MetricThreshold', self.SURFSensitivity);
            surf1_mask= self.remove_masked_surfs(surf1,1);
            %extract the valid SURF points (Elimiating the masked ones)
            [feat1_mask, pts1_mask] = extractFeatures(pic1, surf1_mask);
            count = 1;%counter for succesfully matched pairs
            for i = 2:length(self.prep.original_data)
               i2=i;
               pic2 = rgb2gray(imag2d(self.prep.original_data{i}.Color));
               surf2 = detectSURFFeatures(pic2, 'MetricThreshold', self.SURFSensitivity);
               surf2_mask= self.remove_masked_surfs(surf2,i2);
               
               [feat2_mask, pts2_mask] = extractFeatures(pic2, surf2_mask);
               
               idx_pairs_mask = matchFeatures(feat1_mask, feat2_mask);
               
               matchedPoints1_mask = pts1_mask(idx_pairs_mask(:,1));
               matchedPoints2_mask = pts2_mask(idx_pairs_mask(:,2  ));
               
               if length(matchedPoints1_mask) < self.minSURFpoints %if not enough points are found, increase sensitivity
                   new_surf1 = detectSURFFeatures(pic1, 'MetricThreshold', self.HIGH_SURFSensitivity);
                   new_surf2 = detectSURFFeatures(pic2, 'MetricThreshold', self.HIGH_SURFSensitivity);
                   new_surf1_mask= self.remove_masked_surfs(new_surf1,i1);
                   new_surf2_mask= self.remove_masked_surfs(new_surf2,i2);
                   
                   [new_feat1_mask, new_pts1_mask] = extractFeatures(pic1, new_surf1_mask);
                   [new_feat2_mask, new_pts2_mask] = extractFeatures(pic2, new_surf2_mask);
               
                   new_idx_pairs_mask = matchFeatures(new_feat1_mask, new_feat2_mask);
               
                   new_matchedPoints1_mask = new_pts1_mask(new_idx_pairs_mask(:,1));
                   new_matchedPoints2_mask = new_pts2_mask(new_idx_pairs_mask(:,2 ));
               
               
                    if length(new_matchedPoints1_mask) < self.minSURFpoints%CHECK if with higher sensitivity there are enough points
                        self.show(pic1,pic2,new_matchedPoints1_mask,new_matchedPoints2_mask,new_surf1_mask,new_surf2_mask,i1,i2)
                        continue
                    else
                        Match_Points{count}.SURF1 = new_pts1_mask(new_idx_pairs_mask(:,1));
                        Match_Points{count}.SURF2 = new_pts2_mask(new_idx_pairs_mask(:,2));
                        Match_Points{count}.ID1 = i1;
                        Match_Points{count}.ID2 = i2;
                        count = count + 1;
                        self.show(pic1,pic2,new_matchedPoints1_mask,new_matchedPoints2_mask,new_surf1_mask,new_surf2_mask,i1,i2)
              
                    end
               else
                   Match_Points{count}.SURF1 = pts1_mask(idx_pairs_mask(:,1));
                   Match_Points{count}.SURF2 = pts2_mask(idx_pairs_mask(:,2));
                   Match_Points{count}.ID1 = i1;
                   Match_Points{count}.ID2 = i2;
                   count = count + 1;
                   self.show(pic1,pic2,matchedPoints1_mask,matchedPoints2_mask,surf1_mask,surf2_mask,i1,i2)
               end

               
              
               
           
               %advance loop
               pic1 = pic2;
               surf1_mask = surf2_mask;
               feat1_mask = feat2_mask;
               pts1_mask= pts2_mask;
               i1 = i2;
            end
            transf_Match_Points = self.transform_matchPoints(Match_Points);%Transform matched points in the correct data representation for the next step.
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
        function show(self,pic1,pic2,matchedPoints1_mask,matchedPoints2_mask,surf1,surf2,i1,i2)
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
             scatter(matchedPoints1_mask.Location(:,1),matchedPoints1_mask.Location(:,2),'g','filled')
             legend('Unmatched points','Matched points');

             figure('Position',[0 50 700 500])
             imshow(imag2d(self.prep.original_data{i2}.Color))
             hold on;
             scatter(surf2.Location(:,1),surf2.Location(:,2),'r')
             scatter(matchedPoints2_mask.Location(:,1),matchedPoints2_mask.Location(:,2),'g','filled')
             legend('Unmatched points','Matched points');

             pause(self.prep.pause_time)
        end
        
        function returning = transform_matchPoints(self,MP)
            %just a function to shape the point as required
            returning = {};
            for i=1:length(MP)
                pts1 = round(MP{i}.SURF1.Location);
                pts2 = round(MP{i}.SURF2.Location);
                points1 = [];
                points2 = [];
                for j=1:length(pts1)
                    idx1 = self.prep.coord2point(pts1(j,1),pts1(j,2));
                    idx2 = self.prep.coord2point(pts2(j,1),pts2(j,2));
                    p1 = self.prep.original_data{MP{i}.ID1}.Location(idx1,:);
                    p2 = self.prep.original_data{MP{i}.ID2}.Location(idx2,:);
                    points1 = [points1; p1];
                    points2 = [points2; p2];
                end
                returning{i}.points1 = points1;
                returning{i}.points2 = points2;
                returning{i}.ID1 = MP{i}.ID1;
                returning{i}.ID2 = MP{i}.ID2;

            end
        end
        
        function out_pc = merge_point_clouds(self,matches, transformations)
            % Add first point cloud
            out_pc = self.prep.data{1};
            cum_transf = eye(4);

            for i = 1:length(matches)
                match = matches{i};
                aff_transf = transformations{i};

                cum_transf = cum_transf * aff_transf;

                pc2 = self.prep.data{match.ID2};
                n_pts2 = size(pc2.Location, 1);

                new_pts = [pc2.Location, ones(n_pts2, 1)] / cum_transf;
                new_pts = new_pts(:, 1:3);

                new_pc2 = pointCloud(new_pts, 'Color', pc2.Color);

                out_pc = pcmerge(out_pc, new_pc2, 0.05);

                close all
                pcshow(out_pc)
                pause()

            end
        end
        
        function transformations = find_pairwise_transf(self,matched_pts)
            n_matches = length(matched_pts);
            transformations = cell(n_matches, 1);

            fit_fnc = @(data) fit_affine_transf(data);
            dist_fnc = @(model, data) err_affine_transf(model, data);

            for i = 1:n_matches
                match = matched_pts{i};
                pts1 = match.points1;
                pts2 = match.points2;
                fprintf("\nMatch %i, between frame %i and %i" ,i,match.ID1,match.ID2)

                n_points = size(pts1, 1);

                ransac_input = [pts1, ones(n_points, 1), pts2, ones(n_points, 1)];
                   
                [aff_mat, inlier_idx] = ransac(ransac_input,fit_fnc,dist_fnc,4,self.dist_thresh);
                fprintf("\nsuccess")
                inlier_count = sum(inlier_idx);

                if inlier_count / n_points < 0.5
                    error('Less than half of the points agree on the model')
                end

                transformations{i} = aff_mat;

            end
        end
        
    end
end

