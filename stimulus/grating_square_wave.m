clear all; close all; clc;

% Parameters
gratingRadiusPix = 20; % Radius of the grating in pixels
cycleWidth = 50; % Width of each cycle in pixels
contrastFactor = 0.1;
grey = 0.5; % Grey level

% Generate the grid for the grating
[X, Y] = meshgrid(linspace(-gratingRadiusPix, gratingRadiusPix, round(2 * gratingRadiusPix)), ...
    linspace(-gratingRadiusPix, gratingRadiusPix, round(2 * gratingRadiusPix)));
R = sqrt(X.^2 + Y.^2);

% Define phase shifts to visualize
phaseShifts = 0:10:80; % Example phase shifts
tolerance = 1e-5; % Tolerance for numerical precision

for phaseShift = 1:length(phaseShifts)
    % Generate the dynamic concentric square-wave grating
    dynamicR = R + phaseShift; % Apply the phase shift
    dynamicGrating(:,:,phaseShift) = double(mod(dynamicR, cycleWidth * 2) < cycleWidth);
%     figure;
%     imagesc(dynamicGrating(:,:,phaseShift));
end

% figure;
imagesc(dynamicGrating(:,:,1))