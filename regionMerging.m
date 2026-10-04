function [L, Iseg] = regionMerging(I, threshold)

% REGIONMERGING Region merging image segmentation
%
%   [L, Iseg] = regionMerging(I, threshold)
%
%   I         - input grayscale image
%   threshold - maximum allowed difference between neighboring
%               region mean intensities
%
%   L         - labeled segmentation image
%   Iseg      - image reconstructed from region means

    % Convert to double
    I = double(I);

    % Initial segmentation:
    % Start with every pixel as an individual region
    [rows, cols] = size(I);
    L = reshape(1:rows*cols, rows, cols);

    % Region statistics
    regionMean = I(:);
    regionSize = ones(rows*cols,1);

    % Iteratively merge neighboring regions
    changed = true;

    while changed

        changed = false;

        % Examine horizontal and vertical neighbors
        for r = 1:rows
            for c = 1:cols

                current = L(r,c);

                % Right neighbor
                if c < cols
                    neighbor = L(r,c+1);

                    if current ~= neighbor

                        difference = abs(regionMean(current) - ...
                                          regionMean(neighbor));

                        if difference <= threshold

                            % Merge neighbor into current
                            n1 = regionSize(current);
                            n2 = regionSize(neighbor);

                            newMean = ...
                                (n1*regionMean(current) + ...
                                 n2*regionMean(neighbor)) / ...
                                (n1+n2);

                            L(L == neighbor) = current;

                            regionMean(current) = newMean;
                            regionSize(current) = n1+n2;

                            changed = true;
                        end
                    end
                end

                % Bottom neighbor
                if r < rows
                    neighbor = L(r+1,c);

                    if current ~= neighbor

                        difference = abs(regionMean(current) - ...
                                          regionMean(neighbor));

                        if difference <= threshold

                            n1 = regionSize(current);
                            n2 = regionSize(neighbor);

                            newMean = ...
                                (n1*regionMean(current) + ...
                                 n2*regionMean(neighbor)) / ...
                                (n1+n2);

                            L(L == neighbor) = current;

                            regionMean(current) = newMean;
                            regionSize(current) = n1+n2;

                            changed = true;
                        end
                    end
                end

            end
        end
    end

    % Relabel regions consecutively
    [~,~,L] = unique(L);

    % Reconstruct segmented image using region mean
    Iseg = zeros(size(I));

    for k = 1:max(L(:))
        pixels = (L == k);
        Iseg(pixels) = mean(I(pixels));
    end

end