classdef Preprocess < handle
    %PREPROCESSING This class contains all the pre-processing methdos
    %  to remove unwanted points
    
    properties
        im_height = 640;%//
        im_width = 480; %Size of the input image
        distance_threshold = 3.5;%Treshold of z-distance to remove points.
        W_edge = 5;%distance from the edge (in pixels) to be removed
        remove_man = false;%Do we want to remove bob?
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
            data = data.pcl_train;

            self.data = data(27);
            self.original_data = self.data;
            self.show()
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
                i
                points = self.original_data{i}.Location;
                mask{i} = ones(1,length(points));%mask of removed pixels, initialized to 1(not removed) in order to use multiplication as a logical AND.
                [~,D] = knnsearch(points,points,'K',self.minimum_neig+1,'distance','euclidean');
                mask{i}(D(:,self.minimum_neig+1)>self.square_dist_neig_treshold) = 0;%set the elements of the mask for frame i to 0 in the pixels for which the nth closest neighbours is further away than treshold (meaning there are less than n neighbouts closer than the treshold)
            end
            self.merge_masks(mask)
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
            index = (x-1)*self.im_height+ y;
        end
        
        function show(self,i)
            if nargin==1
                i=1;
            end
            figure()
            pcshow(self.data{i});
        end
        
        function reset(self)
            self.data = self.original_data;
            self.removed_points = cell(1,length(self.data));
            for i=1:length(self.data)
                self.removed_points{i} =  ones(1,length(self.data{1}.Location));
            end
        end
        
       
    end
end