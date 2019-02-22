function [x,y] = point2coord(i)

height = 6;
y =  mod(i-1,height)+1;
x =  floor((i-1)/height)+1;
end



