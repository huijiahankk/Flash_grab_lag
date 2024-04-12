% Initialize Psychtoolbox and open a window.
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
grey = WhiteIndex(screenNumber) / 2;
black = BlackIndex(screenNumber) ;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 800 600]);
commandwindow;

% draw the fixcross
fixCrossDimPix = 15;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
LineWithPix = 6;

% Define the dimensions of the grating and the number of cycles.
centerX = windowRect(3) / 2; % Center X-coordinate
centerY = windowRect(4) / 2; % Center Y-coordinate
gratingRadius = min(centerX, centerY) - 50; % Radius of the grating
numCycles = 18; % Number of cycles
cycleWidth = gratingRadius / numCycles; % Width of each cycle

% define the size of the center grey disk
centerDiskRadius = 100; % Diameter of the grey disk in pixels, adjust as needed
centerDiskRect = [centerX - centerDiskRadius, centerY - centerDiskRadius, centerX + centerDiskRadius, centerY + centerDiskRadius];

% Define variables for the animation speed and the phase of the grating
phaseShift = 1; % Initial phase shift
phaseSpeed = 3; % Speed of phase shift, adjust as needed
maxPhaseShift = cycleWidth; % Maximum phase shift, typically one cycle width

% Define wedge angles
wedgeAngle = 40;
wedgeAnglesStart = [25, 115, 205, 295];
% wedgeRect = [centerX - radius, centerY - radius, centerX + radius, centerY + radius];

gratingRect = [centerX - gratingRadius, centerY - gratingRadius, centerX + gratingRadius, centerY + gratingRadius];
% Create a matrix to store the grating image
[X, Y] = meshgrid(linspace(-gratingRadius, gratingRadius, round(2 * gratingRadius)), linspace(-gratingRadius, gratingRadius, round(2 * gratingRadius)));
R = sqrt(X.^2 + Y.^2);
grating = zeros(size(R));

% Generate the concentric square-wave grating
grating = grating + double(rem(R, cycleWidth * 2) < cycleWidth);

maskedGrating = ones(size(R)) * grey; % Start with a grey mask
maskedGrating(R <= gratingRadius) = 0; % Set inside to transparent (0 for black in this context)
maskedGrating(R <= gratingRadius) = grating(R <= gratingRadius); % Only apply grating inside the radius
maskedGratingTexture = Screen('MakeTexture', window, maskedGrating);

respToBeMade = true;

while respToBeMade

    % Calculate the current phase shift
    phaseShift = phaseShift + phaseSpeed;

    % Reset the phaseShift to create continuous motion
    if phaseShift > maxPhaseShift || phaseShift < -maxPhaseShift
        phaseSpeed = -phaseSpeed; % Reverse the direction of motion
    end

    % Generate the dynamic concentric square-wave grating
    dynamicR = sqrt(X.^2 + Y.^2) + phaseShift; % Apply the phase shift

    dynamicGrating = dynamicGrating + double(rem(dynamicR, cycleWidth * 2) < cycleWidth);

    dynamicGrating = dynamicGrating / numCycles;  % Normalize the grating
    % Apply the circular mask: inside the grating radius, use dynamicGrating; outside, keep it grey
    maskedGrating = ones(size(R)) * grey;  % Start with a grey mask everywhere
    maskedGrating(R <= gratingRadius) = dynamicGrating(R <= gratingRadius);  % Apply updated grating inside the mask
    
    maskedGratingTexture = Screen('MakeTexture', window, maskedGrating);
    Screen('DrawTexture', window, maskedGratingTexture, [], gratingRect);


    % Draw grating wedges
    for angle = 1: length(wedgeAnglesStart)
        Screen('FillArc', window, grey, gratingRect,wedgeAnglesStart(angle), wedgeAngle);
    end


    % Draw the grey disk in the center of the screen
    Screen('FillOval', window, grey, centerDiskRect);

    Screen('DrawLines', window, allCoords, LineWithPix, black, [centerX,centerY]);

    Screen('Flip', window);
%     Screen('Close', gratingTexture); % Close the texture after displaying it to save resources


    %----------------------------------------------------------------------
    %                      Response record
    %----------------------------------------------------------------------

    [keyIsDown,secs,keyCode] = KbCheck(-1);
    %                 if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
    if keyCode(KbName('ESCAPE'))
        ShowCursor;
        sca;
        return
        % the bar was on the left of the gabor
    elseif keyCode(KbName('1')) || keyCode(KbName('1!'))
        barTiltNow = barTiltNow - barMovStep;
    elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
        barTiltNow = barTiltNow + barMovStep;
    elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
        barTiltNow = barTiltNow - 2 * barMovStep;
    elseif keyCode(KbName('5')) || keyCode(KbName('5%'))
        barTiltNow = barTiltNow + 2 * barMovStep;
    elseif keyCode(KbName('Space'))
        respToBeMade = false;
    end
end


% Wait for a key press to close the window.
KbStrokeWait;
sca;