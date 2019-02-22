function [x,y] = point2coord(i)

height = 6;
x = height - mod(i,height);
y =  floor(i/height)+1;
end

