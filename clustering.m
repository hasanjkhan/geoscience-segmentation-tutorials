clear; clc; clf

img = readmatrix('BoiseSS.csv');

%% K-means clustering
% K-means clustering is performed on the micro-CT Boise SS sample using 3
% cluster sizes 2, 3, and 4.

figure(1)
subplot(2,2,1)
imshow(img,[0 255])
title('Original')
colormap gray

for ii = 2:4
    kseg = reshape(kmeans(img(:),ii),size(img));
    ax = subplot(2,2,ii);
    imshow(kseg,[0,ii])
    title(['K = ',num2str(ii)])
    colormap(ax,"parula")
end

%% Fuzzy C-means
% Fuzzy C-means clustering is performed on the micro-CT Boise SS sample 
% using three cluster sizes 2, 3, and 4.

figure(2)
subplot(2,2,1)
imshow(img,[0 255])
title('Original')

for ii = 2:4
    options = fcmOptions(NumClusters = ii, MaxNumIteration = 1000,...
    MinImprovement = 0.0001, DistanceMetric = 'euclidean', Exponent = 2);
    
    [~,U,~,~]  = fcm(img(:),options);
    [cseg,b] = ind2sub(size(U),find(U == max(U)));
    cseg = reshape(cseg,size(img));

    ax = subplot(2,2,ii);
    imshow(cseg,[0,ii])
    title(['K = ',num2str(ii)])
    colormap(ax,"parula")
end


%% Mean Shift

figure(3)
subplot(2,2,1)
imshow(img,[0 255])
title('Original')
h = [20,25,30];

for ii = 2:4
    ax = subplot(2,2,ii);
    dataPts = [img(:),img(:)]';
    [clustCent,data2cluster,clustMembsCell] = MeanShiftCluster(dataPts,h(ii-1));
    numClust = length(clustMembsCell);
    msseg = zeros(size(img));
    for kk = 1:numClust
        msseg(clustMembsCell{kk}) = kk;
    end
    imshow(msseg,[0,numClust])
    title(['Identified regions = ',num2str(numClust)])
    colormap(ax,"parula")

    writematrix(msseg,['MSseg_h',num2str(h(ii-1)),'.csv'])
end

%% Gaussian Mixture Model

figure(4)
subplot(2,2,1)
imshow(img,[0 255])
title('Original')

for ii = 2:4
    gm = fitgmdist(img(:),ii);
    gmseg = reshape(cluster(gm,img(:)),size(img));

    ax = subplot(2,2,ii);
    imshow(gmseg,[0,ii])
    title(['K = ',num2str(ii)])
    colormap(ax,"parula")

    writematrix(gmseg,['GMMseg_K',num2str(ii),'.csv'])
end

