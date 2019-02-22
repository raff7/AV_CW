function [x,y] = point2coord(i,height)
%point2coord get a point and return 2d coordinates
%i is the point, height is the height of the 2d image in pixels

y =  mod(i-1,height)+1;
x =  floor((i-1)/height)+1;
end



