function fit_plane(pc)
%function to fit planes to the walls
    pcshow(pc)%first plot whole point cloud
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    rng(1)%set fixed random number generator
    close all
    maxDistance = 0.3;%max distance for inlaiers


    %fit plane 1
    [model1,inlierIndices,outlierIndices] = pcfitplane(pc,maxDistance);%,referenceVector,maxAngularDistance);
    plane1 = select(pc,inlierIndices);
    remainpc = select(pc,outlierIndices);

    figure()
    pcshow(plane1)
    
    %fit plane 2
    [model2,inlierIndices,outlierIndices] = pcfitplane(remainpc,maxDistance);%,referenceVector,maxAngularDistance);
    plane2 = select(remainpc,inlierIndices);
    remainpc = select(remainpc,outlierIndices);

    figure()
    pcshow(plane2)

     %fit plane 3
    [model3,inlierIndices,outlierIndices] = pcfitplane(remainpc,maxDistance);%,referenceVector,maxAngularDistance);
    plane3 = select(remainpc,inlierIndices);
    remainpc = select(remainpc,outlierIndices);

    figure()
    pcshow(plane3)

    %extract normals
    P1 = model1.Normal;
    P2 = model2.Normal;
    P3 = model3.Normal;

    %compute and display angles in degrees.
    a12 = atan2d(norm(cross(P1,P2)),dot(P1,P2))
    a13 = atan2d(norm(cross(P1,P3)),dot(P1,P3))
    a23 = atan2d(norm(cross(P2,P3)),dot(P2,P3))
    
    centreW1 = mean(plane1.Location);
    centreW2 = mean(plane2.Location);
    X = [centreW1; centreW2]
    d = pdist(X,'euclidean')
end



