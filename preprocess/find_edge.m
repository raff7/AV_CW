function mask = find_edge(office,W,height,width)
%FIND_EDGE Find the points on the edge of the image
%  W is the distance in pixels from the edge to be considered part of the
%  edge, office is the original cell of point clouds
mask = {};
    for i = 1:length(office)
        points = office{i}.Location;
        mask{i} = ones(1,length(points)); 
        for j=1:length(points)
            [x,y]=point2coord(j,height);
            if(x<W || y<W || x>width-W || y>height-W )
                mask{i}(j) = 0;
            end
        end
    end
end

