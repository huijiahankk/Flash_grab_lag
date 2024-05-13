% Load the data from the .mat file
addpath '../data';  % Ensure data path is correctly set
load('hjh_2024_05_13_10_38.mat');


% Assuming 'flash' is a structure containing 'LocMatTemp' and 'MotDirec'
locCondition = flash.LocMatTemp == 1;  % Condition for LocMatTemp
motCondition = flash.MotDirec == 45;   % Condition for MotDirec

% Combine conditions using element-wise logical AND
combinedCondition = locCondition & motCondition;

% Find indices where both conditions are true
indices = find(combinedCondition);

% Display the indices
disp('Indices where flash.LocMatTemp == 1 and flash.MotDirec == 45:');
disp(indices);





% Extract required fields
flashLoc = flash.LocMatTemp;  % Assuming this is a 2D matrix [x, y]
probePosX = probe.PosXMat;
probePosY = probe.PosYMat;
motionDirection = flash.MotDirec;  % Motion direction (-1 inward, 1 outward)

quad1 = find(flashLoc == 45) && find(motionDirection == -1);

% Assuming flashLoc is a matrix and you're interested in comparing a specific column, e.g., the first column
indices = find((flashLoc(:,1) == 45) & (motionDirection == -1));

% If flashLoc is just a single column or a vector, then:
indices = find((flashLoc == 45) & (motionDirection == -1));



% Calculate Euclidean distances
distances = sqrt((flashLoc(:,1) - probePosX).^2 + (flashLoc(:,2) - probePosY).^2);

% Determine the number of unique quadrants
numQuadrants = numel(unique(quadrants));

% Initialize figure
figure;

% Process and plot for each motion direction and each quadrant
for md = [-1, 1]  % Explicitly handle both directions
    for quad = 1:numl(flashLoc)  % Iterate over unique quadrants
        idx = motionDirection == md & quadrants == quad;
        currentDistances = distances(idx);

        % Correct subplot index calculation
        subplotIndex = (md == 1) * numQuadrants + find(quad == unique(quadrants));
        subplot(2, numQuadrants, subplotIndex);  % Adjusted subplot indexing
        histogram(currentDistances);
        title(sprintf('Direction: %d, Quadrant: %d', md, quad));
        xlabel('Distance');
        ylabel('Frequency');
    end
end

% Enhance layout
sgtitle('Distances by Motion Direction and Quadrant');
