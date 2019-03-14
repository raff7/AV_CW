pc = pcread('pc.ply');
pcshow(pc)
xlabel('X')
ylabel('Y')
zlabel('Z')

maxDistance = 0.1;


[model1,inlierIndices,outlierIndices] = pcfitplane(pc,maxDistance);
plane1 = select(pc,inlierIndices);
remainpc = select(pc,outlierIndices);

figure()
pcshow(plane1)

[model2,inlierIndices,outlierIndices] = pcfitplane(remainpc,maxDistance);
plane2 = select(remainpc,inlierIndices);
remainpc = select(remainpc,outlierIndices);

figure()
pcshow(plane2)

[model3,inlierIndices,outlierIndices] = pcfitplane(remainpc,maxDistance);
plane3 = select(remainpc,inlierIndices);
remainpc = select(remainpc,outlierIndices);

figure()
pcshow(plane3)

P1 = model1.Normal;
P2 = model2.Normal;
P3 = model3.Normal;

a12 = atan2d(norm(cross(P1,P2)),dot(P1,P2))
a13 = atan2d(norm(cross(P1,P3)),dot(P1,P3))
a23 = atan2d(norm(cross(P2,P3)),dot(P2,P3))



