I = readmatrix('BoiseSS.csv');

[L, Iseg] = regionMerging(I, 50);

figure;
imshow(I, []);

figure;
imshow(Iseg, []);

figure;
imagesc(L);
axis image;
colorbar;
title('Region Labels');
imwrite(Iseg/255,"regiongrowing_50.jpg");

%%

I = readmatrix('BoiseSS.csv');

[L,Iseg] = regionSplitMerge( ...
    I, ...       % Image
    50, ...      % Split threshold  
    20, ...      % Merge threshold
    4);          % Minimum region size

figure;
imshow(I,[]);
title('Original Image');

% figure;
% imagesc(L);
% axis image;
% colorbar;
% title('Region Labels');

figure;
imshow(Iseg,[]);
title('Region Split-and-Merge Result');

imwrite(Iseg/255,"split50merge20.jpg");