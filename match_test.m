% Generate a cloud of random 3D points
data = rand(1000, 3);

x_angle = 20;
y_angle = 10;
z_angle = 170;

transl = [0.5, -0.1, 0.3]; 

Rmat = rotx(x_angle) * roty(y_angle) * rotz(z_angle);

transformed_data = Rmat * data + transl;


