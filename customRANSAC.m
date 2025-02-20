function [filtered_matches1, filtered_matches2] = customRANSAC(matches1, matches2)
    % Convert to inhomogeneous coordinates
    points1 = matches1.Location;
    points2 = matches2.Location;

    % Estimate homography using RANSAC with lenient parameters
    [H, inlierIdx] = estimateGeometricTransform2D(points1, points2, 'projective', ...
        'MaxNumTrials', 2000, 'Confidence', 99, 'MaxDistance', 5);

    % Calculate distances of all points from the model
    projected_points = transformPointsForward(H, points1);
    distances = sqrt(sum((projected_points - points2).^2, 2));

    % Sort distances and keep top 80% of matches
    [sorted_distances, sortIdx] = sort(distances);
    num_to_keep = round(0.9 * length(distances));
    keep_idx = sortIdx(1:num_to_keep);

    % Filter matches
    filtered_matches1 = matches1(keep_idx);
    filtered_matches2 = matches2(keep_idx);
end