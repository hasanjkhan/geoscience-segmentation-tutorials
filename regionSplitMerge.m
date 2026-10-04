function [L, Iseg] = regionSplitMerge(I, splitThreshold, mergeThreshold, minSize)
% REGION SPLIT AND MERGE SEGMENTATION
%
% [L, Iseg] = regionSplitMerge(I, splitThreshold, ...
%                              mergeThreshold, minSize)
%
% I              : grayscale input image
% splitThreshold : maximum allowed intensity range in a split region
% mergeThreshold : maximum difference between neighboring region means
% minSize        : minimum size of regions generated during splitting
%
% L              : final region-label image
% Iseg           : image reconstructed using region mean intensities

% -------------------------------------------------------------
% 1. Convert image to double
% -------------------------------------------------------------

I = double(I);

[M,N] = size(I);

% -------------------------------------------------------------
% 2. Make image square and power-of-two sized
% -------------------------------------------------------------

S = 2^nextpow2(max(M,N));

Ip = zeros(S,S);
Ip(1:M,1:N) = I;

% -------------------------------------------------------------
% 3. REGION SPLITTING
% -------------------------------------------------------------

% qtdecomp splits a block when:
%
% max(block(:)) - min(block(:)) > splitThreshold
%
% and stops splitting when the block reaches minSize.

Q = qtdecomp(Ip, splitThreshold, minSize);

% -------------------------------------------------------------
% 4. Convert quadtree blocks into initial regions
% -------------------------------------------------------------

L = zeros(S,S);

label = 0;

% Process largest blocks first
sizes = unique(Q(Q > 0));

sizes = sort(sizes,'descend');

for k = 1:length(sizes)

    blockSize = sizes(k);

    [r,c] = find(Q == blockSize);

    for n = 1:length(r)

        r1 = r(n);
        c1 = c(n);

        % Assign a new region label
        label = label + 1;

        L(r1:r1+blockSize-1, ...
          c1:c1+blockSize-1) = label;

    end
end

% -------------------------------------------------------------
% 5. Remove padding
% -------------------------------------------------------------

L = L(1:M,1:N);

% -------------------------------------------------------------
% 6. REGION MERGING
% -------------------------------------------------------------

changed = true;

while changed

    changed = false;

    labels = unique(L);
    labels(labels == 0) = [];

    % Calculate mean intensity for each region
    regionMean = zeros(length(labels),1);

    for k = 1:length(labels)

        pixels = I(L == labels(k));

        regionMean(k) = mean(pixels);

    end

    % ---------------------------------------------------------
    % Find adjacent regions
    % ---------------------------------------------------------

    adjacency = false(length(labels));

    % Horizontal adjacency
    for r = 1:M

        for c = 1:N-1

            a = L(r,c);
            b = L(r,c+1);

            if a ~= b

                ia = find(labels == a,1);
                ib = find(labels == b,1);

                adjacency(ia,ib) = true;
                adjacency(ib,ia) = true;

            end

        end

    end

    % Vertical adjacency
    for r = 1:M-1

        for c = 1:N

            a = L(r,c);
            b = L(r+1,c);

            if a ~= b

                ia = find(labels == a,1);
                ib = find(labels == b,1);

                adjacency(ia,ib) = true;
                adjacency(ib,ia) = true;

            end

        end

    end

    % ---------------------------------------------------------
    % Merge similar neighboring regions
    % ---------------------------------------------------------

    for a = 1:length(labels)

        for b = a+1:length(labels)

            if adjacency(a,b)

                difference = abs(regionMean(a) - ...
                                 regionMean(b));

                if difference <= mergeThreshold

                    oldLabel = labels(b);
                    newLabel = labels(a);

                    % Merge region b into region a
                    L(L == oldLabel) = newLabel;

                    changed = true;

                    break;

                end

            end

        end

        if changed
            break;
        end

    end

end

% -------------------------------------------------------------
% 7. Relabel regions consecutively
% -------------------------------------------------------------

[~,~,L] = unique(L);

L = reshape(L,M,N);

% -------------------------------------------------------------
% 8. Reconstruct segmented image
% -------------------------------------------------------------

Iseg = zeros(M,N);

numRegions = max(L(:));

for k = 1:numRegions

    mask = (L == k);

    Iseg(mask) = mean(I(mask));

end

end