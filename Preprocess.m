classdef Preprocess < handle
    %PREPROCESSING This class contains all the pre-processing methdos
    %  to remove unwanted points
    
    properties
        pause_time = 2
        im_height = 640;%//
        im_width = 480; %Size of the input image
        distance_threshold = 3.5;%Treshold of z-distance to remove points.
        W_edge = 5;%distance from the edge (in pixels) to be removed
        remove_man = false;%Do we want to remove bob?
        man_frame = 27;
        square_dist_neig_treshold = 0.05;%minimum istance to consider 2 points "neighbours" (in meters)
        minimum_neig = 80;%minimum number of neighbours needed to stay
        removed_points% Keep track of all of the points removed for all frames
        data%the data.
        original_data%the original version of the data, masks always are to be applied to this.
    end
    
    methods
        function self = Preprocess(file_name)
            %% Read the data
            data = load(file_name);
            self.data = data.pcl_train(1:15);
            self.original_data = self.data;
            self.removed_points = cell(1,length(self.data));
            for i=1:length(self.data)
                self.removed_points{i} =  ones(1,length(self.data{1}.Location));
            end
        end
        
        function find_NaN(self)
            %find_NaN, self explinatory, find NaN and add them to the
            %masked values.
            mask = {};
            for i = 1:length(self.original_data)
                point = self.original_data{i}.Location;
                %maybe remove index_i = find(isnan(point(:,3)));%remove NaN values.
                mask{i} = ones(1,length(point));
                mask{i}(1,isnan(point(:,3))) = 0;
            end
           self.merge_masks(mask);%Merge themask to previously eliminated pixels
           self.remove_masked_points()%remove masked points from data
        end
        
        function find_distant_points(self)
            %FIND_DISTANT_POINTS Find all the points over a Z-coordinate treshold
            %   Detailed explanation goes here
            mask = {};
            for i = 1:length(self.original_data)
                point = self.original_data{i}.Location;
                index_i = find(point(:,3)>self.distance_threshold); %remove points with z value > than treshold
                mask{i} = ones(1,length(point));
                mask{i}(1,index_i) = 0;
            end
            self.merge_masks(mask);%Merge themask to previously eliminated pixels
            self.remove_masked_points()%remove mask from image
        end
       
        function find_edges(self)
            %FIND_EDGE Find the points on the edge of the image
            %  W is the distance in pixels from the edge to be considered part of the
            %  edge, office is the original cell of point clouds
            mask = {};
            for i = 1:length(self.original_data)
                points = self.original_data{i}.Location;
                mask{i} = ones(1,length(points)); 
                for j=1:length(points)
                    [x,y]=point2coord(j,self.im_height);
                    if(x<self.W_edge || y<self.W_edge || x>self.im_width-self.W_edge || y>self.im_height-self.W_edge )
                        mask{i}(j) = 0;
                    end
                end
            end
            self.merge_masks(mask);%Merge themask to previously eliminated pixels
            self.remove_masked_points()%remove masked points from data
      end
        
      function find_outliers(self)
           mask = {};
            for i = 1:length(self.original_data)
                removing_outliers_from_frame = i
                points = self.original_data{i}.Location;
                mask{i} = ones(1,length(points));%mask of removed pixels, initialized to 1(not removed) in order to use multiplication as a logical AND.
                [~,D] = knnsearch(points,points,'K',self.minimum_neig+1,'distance','euclidean');
                mask{i}(D(:,self.minimum_neig+1)>self.square_dist_neig_treshold) = 0;%set the elements of the mask for frame i to 0 in the pixels for which the nth closest neighbours is further away than treshold (meaning there are less than n neighbouts closer than the treshold)
            end
            self.merge_masks(mask)
            self.remove_masked_points()
      end
      function remove_handsome_man(self)
            % Find two plane boundaries (parallel to y axis) that cut out the man's points
            % from the point cloud. Being parallel to y, we can simply find 
            % two line equations instead.
            mask = {};
            for i = 1:length(self.original_data)
                mask{i} = ones(1, length(self.original_data{i}.Location));
            end

            % Line 1 eq: x < 0
            % Line 2 eq: z < 2
            points = self.original_data{self.man_frame}.Location;
            mask{self.man_frame}(points(:,1)<0 & points(:,3)<2) = 0;
            
            self.merge_masks(mask);
            self.remove_masked_points()
      end
        function remove_masked_points(self)
            %Function to apply a mask to office_data
            %   keeps pixels whre mask is 1, remove where is 0
            self.data = cell(1,length(self.original_data));
            for i=1:length(self.removed_points)
                rgb = self.original_data{i}.Color; % Extracting the colour data
                point = self.original_data{i}.Location; % Extracting the xyz data
                ind = find(self.removed_points{i});
                self.data{i} = pointCloud(point(ind,:), 'Color', rgb(ind,:)); % Creating a point-cloud variable
            end
        end

        function merge_masks(self,newMask)
            %MERGE_MASK, this function simply merges the input mask to the
            %previously "removed_points" mask.
            for i=1:length(newMask)
                self.removed_points{i} = self.removed_points{i}.*newMask{i};%Mask 0 means point is removed, multiplication acts as a logical AND
            end
            mask = self.removed_points;
        end
        
        function [x,y] = point2coord(self,i)
            %point2coord, get a point and return 2d coordinates
            %i is the point index
            y =  mod(i-1,self.im_height)+1;
            x =  floor((i-1)/self.im_height)+1;
        end

        
        function index = coord2point(self,x,y)
            %COORD2POINT, find the point index given the 2d coordinates.
            index = (y-1)*self.im_height+ x;
        end
        
        function show(self,i)
            if nargin>1
               close all
               figure('Position',[0 300 700 500])
               pcshow(self.data{i})
               figure('Position',[650 100 700 500])
               mask_img = bsxfun(@times, self.original_data{i}.Color(), cast(self.removed_points{i}(:), 'like', self.original_data{i}.Color()));
               imshow(imag2d(mask_img));
               pause(self.pause_time)
            else
                for i=1:length(self.original_data)
                    close all
                    figure('Position',[0 300 700 500])
                    pcshow(self.data{i})
                    figure('Position',[650 100 700 500])
                    mask_img = bsxfun(@times, self.original_data{i}.Color(), cast(self.removed_points{i}(:), 'like', self.original_data{i}.Color()));
                    imshow(imag2d(mask_img));
                    pause(self.pause_time)
                end
            end
        end
        
        function reset(self)
            self.data = self.original_data;
            self.removed_points = cell(1,length(self.data));
            for i=1:length(self.data)
                self.removed_points{i} =  ones(1,length(self.data{1}.Location));
            end
        end
        function smooth_data(self)
            for i=1:length(self.original_data)
            	data = self.original_data{i}.Location(:,3);
                data = reshape(data,[640, 480]);
                filter = fspecial('gaussian',30,5);
                filt_data = nanconv(data, filter,'edge','nanout');
                new_data = reshape(filt_data,[640*480,1]);
                subplot(2,1,1), pcshow(self.original_data{i})
                loc = [self.original_data{i}.Location(:,1:2),new_data];
                self.original_data{i}=pointCloud(loc,'Color',self.original_data{i}.Color);
                subplot(2,1,2), pcshow(self.original_data{i})
            end
        end
       
    end
end
