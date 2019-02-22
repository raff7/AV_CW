function [x,y] = point2coord(i,height)


y =  mod(i-1,height)+1;
x =  floor((i-1)/height)+1;
end



