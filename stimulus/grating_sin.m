% Parameters
screenSize = [800, 800]; % Size of the screen in pixels
gratingRadius = 300; % Radius of the grating in pixels
cycleWidth = 100; % Width of each cycle in pixels

% Create a grid of coordinates
[x, y] = meshgrid(-screenSize(2)/2:screenSize(2)/2 - 1, -screenSize(1)/2:screenSize(1)/2 - 1);
r = sqrt(x.^2 + y.^2); % Compute the radius for each pixel

% Create the grating pattern
gratingPattern = sin(2 * pi * r / cycleWidth);

% Apply a circular mask
mask = r <= gratingRadius;

% Create the grating with the mask applied
gratinga = gratingPattern .* mask;

% Display the grating
figure;
imagesc(gratinga);
colormap gray;
axis equal;
axis off;
title('Concentric Sine-Wave Grating');
