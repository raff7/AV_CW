function [mask] = find_outliers(office,dist_treshold,min_neig,height,width)
%FIND_OUTLIERS Summary of this function goes here
%   Detailed explanation goes here
range = 13;
mask = {};
    for i = 1:length(office)
        i
        points = office{i}.Location;
        mask{i} = ones(1,length(points));
        for j=1:length(points)
            if(~isnan(points(j,1)))%Ignore NAN points
                p = points(j,:);
                p_neig_count=0;
                [px,py] = point2coord(j, height);%get 2d coordinates from index
                
                for x=max(px-range,1):min(px+range,width)%go only trough the 2d neigbours
                    flag_break = false;%flag used to break out of loop
                    for y=max(py-range,1):min(py+range,height)
                        p2index = coord2point(x,y,height);%get index from 2d coordinates
                        p2=points(p2index,:);
                        dist = ((p(1)-p2(1))^2 + (p(2)-p2(2))^2 + (p(3)-p2(3))^2);
                        if(dist<dist_treshold)
                            p_neig_count = p_neig_count+1;
                        end
                        if(p_neig_count >= min_neig)%stop for loop if enough neighbours are found
                            flag_break = true;%exit both loops x and y
                            break 
                        end
                    end
                    if(flag_break)
                        break%exit bot loop x and y
                    end
                end
                if(p_neig_count < min_neig)%mask it if not enough neigbours
                    mask{i}(j) = 0;
                end
            end
        end
    end
end

