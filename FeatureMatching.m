classdef FeatureMatching < handle
    %FEATUREMATCHING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        prep
        high_pass_radius = 3
        high_pass_amount = 5
        SURFSensitivity = 500 %it's actually a treshold
        surf_match_points_sensitivity = 10 %default =1
        surf_maxRatio = 0.6
        harris_match_points_sensitivity = 100 %default = 10
        harris_maxRatio = 0.65
        minSURFpoints = 15
        dist_thresh = 0.1
        grid_parameter = 0.01
        
        plot_stuff = false
       
    end
    
    methods
        function self = FeatureMatching(file)
            %FEATUREMATCHING Construct an instance of this class
            %   In it, construct a preprocess object.
            self.prep = Preprocess(file);
            fprintf("Start Preprocessing- Smooth data\n")
            self.prep.smooth_data()
            self.prep.find_NaN()
            fprintf("smooth data done- Find edges\n")
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
            
            if self.plot_stuff
                self.prep.show()
            end
        end
        
        function transf_Match_Points= matchSurf(self)
            %% Find features, match them
            pic1 = rgb2gray(imag2d(self.prep.original_data{1}.Color));
            %pic1 = imsharpen(pic1,'Radius',self.high_pass_radius,'Amount',self.high_pass_amount);
            pic1 = histeq(pic1);
            i1=1;
            surf1 = detectSURFFeatures(pic1, 'MetricThreshold', self.SURFSensitivity);
            harris1 = detectHarrisFeatures(pic1);
   
            surf1_mask= self.remove_masked_surfs(surf1,1);
            harris1_mask= self.remove_masked_harris(harris1,1);
            %extract the valid SURF points (Elimiating the masked ones)
            [surf_feat1_mask, surf_pts1_mask] = extractFeatures(pic1, surf1_mask);
            [harris_feat1_mask, harris_pts1_mask] = extractFeatures(pic1, harris1_mask);
            count = 1;%counter for succesfully matched pairs
            for i = 2:length(self.prep.original_data)
               if(i1==24)
                   a = 1;
               end
               i2=i;
               pic2 = rgb2gray(imag2d(self.prep.original_data{i}.Color));
              %pic2 = imsharpen(pic2,'Radius',self.high_pass_radius,'Amount',self.high_pass_amount);
               pic2 = histeq(pic2);
               surf2 = detectSURFFeatures(pic2, 'MetricThreshold', self.SURFSensitivity);
               harris2 = detectHarrisFeatures(pic2);
               surf2_mask= self.remove_masked_surfs(surf2,i2);
               harris2_mask= self.remove_masked_harris(harris2,i2);

               [surf_feat2_mask, surf_pts2_mask] = extractFeatures(pic2, surf2_mask);
               [harris_feat2_mask, harris_pts2_mask] = extractFeatures(pic2, harris2_mask);

               surf_idx_pairs_mask = matchFeatures(surf_feat1_mask, surf_feat2_mask,'MatchThreshold',self.surf_match_points_sensitivity,'MaxRatio',self.surf_maxRatio,'unique',true);
               harris_idx_pairs_mask = matchFeatures(harris_feat1_mask, harris_feat2_mask,'MatchThreshold',self.harris_match_points_sensitivity,'MaxRatio',self.harris_maxRatio);

               surf_matchedPoints1_mask = surf_pts1_mask(surf_idx_pairs_mask(:,1));
               surf_matchedPoints2_mask = surf_pts2_mask(surf_idx_pairs_mask(:,2  ));
               harris_matchedPoints1_mask = harris_pts1_mask(harris_idx_pairs_mask(:,1));
               harris_matchedPoints2_mask = harris_pts2_mask(harris_idx_pairs_mask(:,2  ));
               
               if length(surf_matchedPoints1_mask) < self.minSURFpoints %if not enough points are found, increase sensitivity
                   fprintf("\nCant finde enough matces for match %i, %i: found %i matches",i1,i2,length(surf_matchedPoints1_mask))
                   if self.plot_stuff
                        self.show(pic1,pic2,surf_matchedPoints1_mask,surf_matchedPoints2_mask,harris_matchedPoints1_mask,harris_matchedPoints2_mask,surf1_mask,surf2_mask,harris1_mask,harris2_mask,i1,i2)
                   end
                   continue
               else
                   fprintf("\nfound enough matces for match %i, %i: %i matcehs",i1,i2,length(surf_matchedPoints1_mask))
                   Match_Points{count}.points1 = [surf_pts1_mask(surf_idx_pairs_mask(:,1)).Location;harris_pts1_mask(harris_idx_pairs_mask(:,1)).Location];
                   Match_Points{count}.points2 = [surf_pts2_mask(surf_idx_pairs_mask(:,2)).Location;harris_pts2_mask(harris_idx_pairs_mask(:,2)).Location];
                   Match_Points{count}.ID1 = i1;
                   Match_Points{count}.ID2 = i2;
                   count = count + 1;
                   if self.plot_stuff
                       self.show(pic1,pic2,surf_matchedPoints1_mask,surf_matchedPoints2_mask,harris_matchedPoints1_mask,harris_matchedPoints2_mask,surf1_mask,surf2_mask,harris1_mask,harris2_mask,i1,i2)
                   end
               end

               
              
               
           
               %advance loop
               pic1 = pic2;
               surf1_mask = surf2_mask;
               harris1_mask = harris2_mask;
               surf_feat1_mask = surf_feat2_mask;
               harris_feat1_mask = harris_feat2_mask;
               surf_pts1_mask= surf_pts2_mask;
               harris_pts1_mask= harris_pts2_mask;

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
        
        function new_harris = remove_masked_harris(self,harris,frameIDX)
            counter = 1;
            mask_2d = reshape(self.prep.removed_points{frameIDX},[640, 480]);
            %new_surf = SURFPoints();
            new_harris =harris(1:2);
            for i=1:length(harris)
                x = round(harris.Location(i,1));
                y = round(harris.Location(i,2));
                if(mask_2d(x,y)==1)
                    new_harris(counter) = harris(i);
                    counter = counter+1;
                end
            end
            
        end
        function show(self,pic1,pic2,surf_matchedPoints1_mask,surf_matchedPoints2_mask,harris_matchedPoints1_mask,harris_matchedPoints2_mask,surf1_mask,surf2_mask,harris1_mask,harris2_mask,i1,i2)
             %Plot matched features and connections
             close all
             figure('Position',[300 150 1000 600])
             subplot(2,2,1),showMatchedFeatures(pic1,pic2,surf_matchedPoints1_mask,surf_matchedPoints2_mask);
             title('SURF matches')
             legend('matched points 1','matched points 2');
             subplot(2,2,2),showMatchedFeatures(pic1,pic2,harris_matchedPoints1_mask,harris_matchedPoints2_mask);
             title('HARRIS matches')
             legend('matched points 1','matched points 2');
             
             %plot image1, and SURF points (matched, not matched and
             %masked)
             %imshow(imsharpen(imag2d(self.prep.original_data{i1}.Color),'Radius',self.high_pass_radius,'Amount',self.high_pass_amount))
             subplot(2,2,3),imshow(histeq(imag2d(self.prep.original_data{i1}.Color)))
             title("Image 1");
             hold on;
             scatter(surf1_mask.Location(:,1),surf1_mask.Location(:,2),'r','.')
             scatter(harris1_mask.Location(:,1),harris1_mask.Location(:,2),'y','.')

             scatter(surf_matchedPoints1_mask.Location(:,1),surf_matchedPoints1_mask.Location(:,2),'g','.')
             scatter(harris_matchedPoints1_mask.Location(:,1),harris_matchedPoints1_mask.Location(:,2),'b','.')

             legend('Unmatched SURF points','Unmatched HARRIS points','Matched SURF points','Matched HARRIS points');

             %imshow(imsharpen(imag2d(self.prep.original_data{i2}.Color),'Radius',self.high_pass_radius,'Amount',self.high_pass_amount))
             subplot(2,2,4),imshow(histeq(imag2d(self.prep.original_data{i2}.Color)))
             title("Image 2")
             hold on;
             scatter(surf2_mask.Location(:,1),surf2_mask.Location(:,2),'r','.')
             scatter(harris2_mask.Location(:,1),harris2_mask.Location(:,2),'y','.')
             scatter(surf_matchedPoints2_mask.Location(:,1),surf_matchedPoints2_mask.Location(:,2),'g','.')
             scatter(harris_matchedPoints2_mask.Location(:,1),harris_matchedPoints2_mask.Location(:,2),'b','.')
             legend('Unmatched SURF points','Unmatched HARRIS points','Matched SURF points','Matched HARRIS points');

             pause(self.prep.pause_time)
        end
        
        function returning = transform_matchPoints(self,MP)
            %just a function to shape the point as required
            returning = {};
            for i=1:length(MP)
                pts1 = round(MP{i}.points1);
                pts2 = round(MP{i}.points2);
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
            
            cum_rotation = eye(3);
            cum_translation = zeros(3,1);
            close all;

            for i = 1:length(matches)
                match = matches{i};
                mod = transformations{i};

                cum_rotation = mod.Rmat * cum_rotation;
                cum_translation = mod.Rmat * cum_translation + mod.transl;

                pc2 = self.prep.data{match.ID2};
                n_pts2 = size(pc2.Location, 1);

                new_pts = (pc2.Location - cum_translation') / cum_rotation';

                new_pc2 = pointCloud(new_pts, 'Color', pc2.Color);

                out_pc = pcmerge(out_pc, new_pc2, self.grid_parameter);
                fprintf("\nTransforming from frame %d to initial frame coordinates", match.ID2)
                if self.plot_stuff
                    close all
                    figure('Position',[300 150 1000 600])
                    self.prep.pcanimate(out_pc)
 
                end

            end
            figure('Position',[300 150 1000 600])
            self.prep.pcanimate(out_pc)
            
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

                ransac_input = [pts1, pts2];
                   
                [aff_mat, inlier_idx] = ransac(ransac_input,fit_fnc,dist_fnc,4,self.dist_thresh,'Confidence',99.5,'MaxNumTrials',3000);
                
                %data = [pts1, pts2];
                %aff_mat = fit_fnc(data);
                %inlier_idx = dist_fnc(aff_mat, data) < self.dist_thresh;
                inlier_count = sum(inlier_idx);
                
                %fprintf("\nNOT USING RANSAC ---- There are %d inliers over %d points %d", inlier_count, n_points, inlier_count * 100 / n_points)

                if inlier_count / n_points < 0.5
                    fprintf('Less than half of the points agree on the model %f',(inlier_count / n_points))
                end
                fprintf("\nsuccess")

                transformations{i} = aff_mat;

            end
        end
        
    end
end

