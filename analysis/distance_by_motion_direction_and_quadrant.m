% Load the data from the .mat file
addpath '../data';
data = load('hjh_2024_05_13_10_38.mat');

% Extract required fields
flashLoc = data.flash.LocMatTemp;  % Assuming this is a 2D matrix [x, y]
probePosX = data.probe.PosXMat;
probePosY = data.probe.PosYMat;
motionDirection = data.flash.MotDirec; % Motion direction (-1 inward, 1 outward)
quadrants = flashLoc;  % Assuming each position already represents a quadrant

% Calculate Euclidean distances
distances = sqrt((flashLoc(:,1) - probePosX).^2 + (flashLoc(:,2) - probePosY).^2);

% Initialize figure
figure;

% Process and plot for each motion direction and each quadrant
for md = unique(motionDirection)'
    for quad = unique(quadrants)'
        % Filter distances by current motion direction and quadrant
        idx = motionDirection == md & quadrants == quad;
        currentDistances = distances(idx);

        % Create a subplot for each combination
        subplot(2, max(quadrants), (md == 1) * max(quadrants) + quad);
        histogram(currentDistances);
        title(sprintf('Direction: %d, Quadrant: %d', md, quad));
        xlabel('Distance');
        ylabel('Frequency');
    end
end

% Enhance layout
sgtitle('Distances by Motion Direction and Quadrant');
