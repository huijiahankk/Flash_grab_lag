% Setup Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
grey = WhiteIndex(screenNumber) / 2;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Create noise texture with Gaussian blur
noiseTextureSize = 512;
noise = randn(noiseTextureSize, noiseTextureSize) * 50 + 128; % Gaussian noise
noise = imgaussfilt(noise, 5); % Apply Gaussian blur
noise = uint8(noise); % Convert to uint8
noiseTexture = Screen('MakeTexture', window, noise);

% Parameters for the round noise
radius = 250; % in pixels
centerX = screenXpixels / 2;
centerY = screenYpixels / 2;

% Create an alpha mask for the round shape
[x, y] = meshgrid(-radius:radius, -radius:radius);
mask = (x.^2 + y.^2) <= radius^2;
alphaMask = uint8(mask * 255); % Alpha mask for the round shape

% Combine the noise texture with the alpha mask
noiseWithAlpha = cat(3, noise(1:size(mask, 1), 1:size(mask, 2)), alphaMask);
roundNoiseTexture = Screen('MakeTexture', window, noiseWithAlpha);

% Draw the round noise
Screen('DrawTexture', window, roundNoiseTexture, [], ...
    [centerX - radius, centerY - radius, centerX + radius, centerY + radius], 0);

% Flip to the screen
Screen('Flip', window);

% Wait for a key press
KbStrokeWait;

% Clear the screen
sca;
