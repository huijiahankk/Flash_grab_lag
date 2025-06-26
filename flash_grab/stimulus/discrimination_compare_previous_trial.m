
% INTRODUCTION TO THE FLASH GRAB ILLUSION EXPERIMENT CODE
%
% This MATLAB script, utilizing Psychtoolbox, is designed to investigate the
% Flash Grab Illusion by testing participants' perceived location of a flashed
% red bar relative to a moving grating. The experiment presents a flashed bar
% within a dynamic square-wave grating and uses a probe (reference) bar to
% collect participant responses. Participants report whether the probe bar
% appears closer to the fovea (center of vision) or the periphery compared to
% the flashed bar using the left/right arrow keys.
%
% The script implements an adaptive **1-up 1-down staircase** procedure based
% on **response consistency** (i.e., whether the current response matches the
% previous one), rather than accuracy. This allows measurement of the point
% where the participant switches perception from foveal to peripheral bias.
%
% The staircase tracks:
% - `stimuluslevel`: internal value used to set the probe's position relative to the flash
% - `actualOffset`: physical distance from flash to probe, signed relative to fixation
%     - Positive = probe more peripheral than flash
%     - Negative = probe more foveal than flash
%
% The illusion is tested across:
% - Four visual quadrants [45 135 225 315 degrees]
% - Three motion conditions: inward (petal), outward (fugal), and static (control)
%
% Key Controls:
% - Is the probe closer to the fixation than the flash? → PRESS LEFT ARROW
% - Is the probe closer to the periphery than the flash? → PRESS RIGHT ARROW
%
% Key Features:
% - Flexible grating and flash configuration
% - Adaptive probe adjustment based on response trend
% - Separate logging of physical (actualOffset) vs internal (stimuluslevel) progression
% - Clear convergence plots of both values
%
% INSTRUCTIONS FOR MODIFICATION:
% 1. To adjust staircase parameters:
%    - Look for 'initialize_staircase' (e.g. Lines ~198)
%      - 'start': Initial probe offset (positive value)
%      - 'step': Step size for changes
%      - 'minimumStepSize': Lower bound for step size
%      - 'reversalLimit': How many reversals to end staircase
%      - 'staircaseDirection': +1 or -1
%
% 2. To test specific locations or stimuli:
%    - 'flash.QuadDegree' sets quadrants [e.g. [45 135 225 315]]
%    - 'flash.locPhaseShiftdva' sets flash offset from center
%    - 'flash.MotDirec' sets motion direction (-1 = inward, 0 = control, 1 = outward)
%
% The experiment runs in blocks with randomized trials, saves data to file,
% and generates plots showing staircase convergence of perceptual offset.
% Ensure Psychtoolbox is installed and the 'function' folder is in the path before running.
%
% Current Date: April 7, 2025


clear all;close all;

if 1
    sbjname = 'hjh';
    blockNum= 1;
    trialNum = 32; % 32 48  have to be a multiple of 16
    isEyelink = 0;
else
    prompt = {'subject''s name','isEyelink(without eyelink 0 or use eyelink 1)','block number','trial number(multiples of 10)'};
    dlg_title = 'Set experiment parameters ';
    answer  = inputdlg(prompt,dlg_title);
    [sbjname] = answer{1};
    [isEyelink] = str2double(answer{2});
    [blockNum] = str2double(answer{3});
    [trialNum] = str2double(answer{4});
end
fprintf(['sbjname: %s\n','isEyelink: %d\n','block number: %d\n','trial number: %d\n'],sbjname,isEyelink,blockNum,trialNum);

% isEyelink = str2num(isEyelink);

%----------------------------------------------------------------------
%           Initialize Psychtoolbox and open a window
%----------------------------------------------------------------------
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
grey = WhiteIndex(screenNumber) / 2;
black = BlackIndex(screenNumber) ;
white = WhiteIndex(screenNumber) ;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, [0 0 800 600]); %
refreshRate = FrameRate(window);
refreshRate = 60;
commandwindow;
addpath ../function/;
KbName('UnifyKeyNames');

eyeScreenDistence = 57;  %  57 cm
screenHeight = 30.5; % 26.8 cm   33.5 cm
% Get the number of pixels in the vertical dimension of the screen
screenHeightPixels = windowRect(4);

%   draw the fixcross
fixCrossDimPixDva = 0.5;
fixCrossDimPix = dva2pix(fixCrossDimPixDva,eyeScreenDistence,windowRect,screenHeight);
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
LineWithPix = 6;
phaseShiftMat = [];
FixationOnBeforeStiSec = 0.5;

%----------------------------------------------------------------------
%         Grating parameters
%----------------------------------------------------------------------
% Define the dimensions of the grating and the number of cycles.
xCenter = windowRect(3) / 2; % Center X-coordinate
yCenter = windowRect(4) / 2; % Center Y-coordinate
gratingRadiusDva = 20; % degree of visual angle draw a bigger grating
gratingRadiusPix = dva2pix(gratingRadiusDva,eyeScreenDistence,windowRect,screenHeight); % Radius of the grating

gratingRect = [xCenter - gratingRadiusPix, yCenter - gratingRadiusPix, xCenter + gratingRadiusPix, yCenter + gratingRadiusPix];
contrastFactor = 0.1;
gratingMaskRadius = 15; % degree of visual angle distance between fixation and far end of the grating
gratingMaskRadiusPix = dva2pix(gratingMaskRadius,eyeScreenDistence,windowRect,screenHeight); % Radius of the grating

% Define variables for the animation speed and the phase of the grating
phaseSpeed = 4; % Speed of phase shift (pixel/frame)
% phaseSpeedDva = pix2dva(phaseSpeed,eyeScreenDistence,windowRect,screenHeight);
% phaseSpeedDvaPerSec = phaseSpeedDva * pi * 60;

cycleWidthDva = 5;  % 5.6 in flash grab patient
cycleWidthPix = dva2pix(cycleWidthDva,eyeScreenDistence,windowRect,screenHeight);  % + 1

% maxPhaseShiftdva = pix2dva(ceil(maxPhaseShift),eyeScreenDistence,windowRect,screenHeight);
gratDurationInSec = 3; % grating show duration in seconds
gratDuraFrame = refreshRate * gratDurationInSec;
% gratDurationInSec = 3 * cycleWidth /(phaseSpeed * refreshRate);

% Create a lower resolution grid for the grating image
% resolutionFactor = 0.5; % Adjust this to balance between performance and quality
% numPoints = round(2 * gratingRadiusPix * resolutionFactor);
% [X, Y] = meshgrid(linspace(-gratingRadiusPix, gratingRadiusPix, numPoints), linspace(-gratingRadiusPix, gratingRadiusPix, numPoints));
resolutionFactor = 0.5; % Lower resolution
[X, Y] = meshgrid(linspace(-gratingRadiusPix, gratingRadiusPix, round(2 * gratingRadiusPix * resolutionFactor)));
% [X, Y] = meshgrid(linspace(-gratingRadiusPix, gratingRadiusPix, round(2 * gratingRadiusPix)), linspace(-gratingRadiusPix, gratingRadiusPix, round(2 * gratingRadiusPix)));
R = sqrt(X.^2 + Y.^2);


%----------------------------------------------------------------------
%  define the size of the center grey disk and mask wedge
%----------------------------------------------------------------------
centerDiskRadiusDva = 3;
centerDiskRadiusPix = dva2pix(centerDiskRadiusDva,eyeScreenDistence,windowRect,screenHeight); % Diameter of the grey disk in pixels, adjust as needed
centerDiskRect = [xCenter - centerDiskRadiusPix, yCenter - centerDiskRadiusPix, xCenter + centerDiskRadiusPix, yCenter + centerDiskRadiusPix];

% Define mask wedge angles
wedgeCoverAngle = 315;
wedgeStartMat = [67.5 157.5 247.5 337.5];

%----------------------------------------------------------------------
%        flashed red bar parameters
%----------------------------------------------------------------------
flash.WidthDva = 0.5; % Width of the red flashed bar in visual degree angle
flash.LengthDva = 3; % Height of the red flashed bar in visual degree angle
flash.WidthPix = dva2pix(flash.WidthDva,eyeScreenDistence,windowRect,screenHeight);
flash.LengthPix = dva2pix(flash.LengthDva,eyeScreenDistence,windowRect,screenHeight);
flash.Size = [0, 0, flash.WidthPix, flash.LengthPix];  % Red bar size before rotation
flash.QuadDegree = [45 45 45 45]; % % 10 pixels [45 45 45 45]     [45 135 225 315]  upper right quadrant is 45

flash.PresFrame = 3; % frame

% Maximum phase shift, the grading moving length
% flash.maxPhaseShift = 2 * cycleWidthPix; % dva2pix(maxPhaseShiftDva,eyeScreenDistence,windowRect,screenHeight);
gratingCenterPix = (gratingMaskRadiusPix + centerDiskRadiusPix)/2;
% locPhaseShift means flash shift from the end of the moving onset and offset
flash.locPhaseShiftdva = 0; % 2 if you want the flash has different location and the distance is 2 dva to the center
flash.locPhaseShiftPixTemp = dva2pix(flash.locPhaseShiftdva,eyeScreenDistence,windowRect,screenHeight);
% flash locations   2 locations
% flash.maxPhaseShiftPix = [gratingCenterPix - flash.locPhaseShiftPixTemp - 0.5   gratingCenterPix + flash.locPhaseShiftPixTemp + 1.5];
flash.maxPhaseShiftPix = [gratingCenterPix - flash.locPhaseShiftPixTemp     gratingCenterPix + flash.locPhaseShiftPixTemp];
% flash.phaseShift = 1;  % 1  (4 * cycleWidthPix - phaseShift)    2 abs(phaseShift)


flash.MotDirec = [-1 0 1]; % repmat([-1 1],1,trialNum/2); % - 1 means illusion inward   1 mean illusion outward

flash.Image(:,:,1) = ones(flash.LengthPix,  flash.WidthPix);
flash.Image(:,:,2) = zeros(flash.LengthPix,  flash.WidthPix);
flash.Image(:,:,3) = flash.Image(:,:,2);
flash.Texture = Screen('MakeTexture', window, flash.Image);

%----------------------------------------------------------------------
%            parameters of probe line
%----------------------------------------------------------------------
% probe.shiftDva = [-2 -1 0 1 2];
% probe.shiftPix = dva2pix(probe.shiftDva,eyeScreenDistence,windowRect,screenHeight);

probe.MoveStep = 0.7; % pixel
probe.Tilt = 135;  % in degree
probe.WidthDva = 0.5;
probe.LengthDva = 3;
probe.WidthPix = dva2pix(probe.WidthDva,eyeScreenDistence,windowRect,screenHeight);
probe.LengthPix = dva2pix(probe.LengthDva,eyeScreenDistence,windowRect,screenHeight);

% Define a rectangle
probe.Image(:,:,1) = ones(probe.LengthPix,  probe.WidthPix);  % set the probe color red
probe.Image(:,:,2) = zeros(probe.LengthPix,  probe.WidthPix);
probe.Image(:,:,3) = probe.Image(:,:,2);

% Make the rectangle into a texure
probe.Texture = Screen('MakeTexture', window, probe.Image);
% probe.Rect = Screen('Rect',probe.Texture);
probe.Size = flash.Size;


%----------------------------------------------------------------------
%        Define all possible combinations of parameters
%----------------------------------------------------------------------
% Generate all possible combinations in a matrix form
[quad_vals, mot_vals, shift_vals] = ndgrid(flash.QuadDegree, flash.MotDirec, flash.maxPhaseShiftPix);
combinations = [quad_vals(:), mot_vals(:), shift_vals(:)]; % 40 unique combinations

% Experiment parameters
% trials_per_block = size(combinations, 1);
trials_per_block = trialNum; % Set the number of trials per block based on the desired trial number

% Generate truly randomized blocks
all_combinations = cell(blockNum, 1);

for block_idx = 1:blockNum
    % Randomly shuffle the order of combinations for each block
    rng('shuffle'); % Set random seed based on current time for different randomization each loop
    doubled_combinations = repmat(combinations, trialNum/16, 1); % Repeat the combinations twice to double the trials
    all_combinations{block_idx} = doubled_combinations(randperm(trials_per_block), :); % Randomized combinations for each block
end



%----------------------------------------------------------------------
%       staircase parameter for petal (fovea) and fugal (peripheral)
%----------------------------------------------------------------------

% Define shared sstaircase
% staircase = initialize_staircase(start, step, minimumStepSize,reversalLimit, staircase direction,correctResponses, incorrectResponses)
staircase.upper_fugal = initialize_staircase(1, 10, 2, 10, 1, 0, 0); % 45 & 315 fugal
staircase.upper_petal = initialize_staircase(1, 10, 2, 10, 1, 0, 0); % 45 & 315 petal
staircase.upper_control = initialize_staircase(1, 10, 2, 10, 1, 0, 0);
staircase.lower_fugal = initialize_staircase(1, 10, 2, 10, 1, 0, 0); % 135 & 225 fugal
staircase.lower_petal = initialize_staircase(1, 10, 2, 10, 1, 0, 0); % 135 & 225 petal
staircase.lower_control = initialize_staircase(1, 10, 2, 10, 1, 0, 0);


% Fieldnames of the sstaircase for easy access
fields = fieldnames(staircase);
calculateLastTrialNum = 5; % calculate threshold count last reversal numbers
% responseThisTrial = 0;
% Define how many correct responses are needed before switching direction
% consecutiveCorrectThreshold = 1;   % up
% consecutiveinCorrectThreshold = 1;  % down
nonadaptiveTrialNum = 100;

%----------------------------------------------------------------------
%       load instruction image and waiting for a key press
%----------------------------------------------------------------------
ThisDirectory = pwd;
InstructImFile = strcat(ThisDirectory,'/FGE.png');
InstructIm     = imread(InstructImFile);
InstructTex    = Screen('MakeTexture',window,InstructIm);
sizeIm         = size(InstructIm);
InstructSrc    = [0 0 sizeIm(2) sizeIm(1)];
InstructDest   = [1 1 xCenter*2 yCenter*2];

while ~any(KbCheck(-1)) % Wait for any key press
    % Draw instructions
    Screen('DrawTexture', window, InstructTex, InstructSrc, InstructDest, 0);
    Screen('Flip', window);
    WaitSecs(0.1);
end

% KbStrokeWait;


for block = 1: blockNum
    %----------------------------------------------------------------------
    %       present a start screen and wait for a key-press
    %----------------------------------------------------------------------
    formatSpec = 'This is the %dth of %d block. \n \n Press Any Key To Begin';
    A1 = block;
    A2 = blockNum;
    str = sprintf(formatSpec,A1,A2);

    Screen ('TextSize',window,30);
    Screen('TextFont',window,'Courier');

    topCenterQuadRect = [xCenter/2 0  xCenter*3/2 yCenter];
    DrawFormattedText(window, str, 'center', 'center', grey,[],[],[],[],[],topCenterQuadRect);
    Screen('Flip', window);
    %     KbStrokeWait;
    WaitSecs(0.3);

    % Find all keyboard devices
    devices = PsychHID('Devices');
    keyboardIndices = [];
    for i = 1:length(devices)
        if strcmp(devices(i).usageName, 'Keyboard')
            keyboardIndices = [keyboardIndices, devices(i).index];
        end
    end

    % Wait for any key press on any keyboard
    keyIsDown = false;
    while ~keyIsDown
        for i = 1:length(keyboardIndices)
            [keyDown, ~, keyCode] = KbCheck(keyboardIndices(i));
            if keyDown
                keyIsDown = true;
                break; % Exit the loop once a key is detected
            end
        end
        WaitSecs(0.01); % Short pause to avoid overwhelming the CPU
    end

    %     checkflag = 1;
    %
    %     while checkflag
    %         [~, ~, keyCode, ~] = KbCheck(-1);
    %         if keyCode(KbName('s'))
    %             checkflag = 0;
    %         end
    %     end

    %     KbStro
    % keWait;


    %----------------------------------------------------------------------
    %                 Experiment loop
    %----------------------------------------------------------------------

    trial = 1;


    %     while trial <= trialNum && ...
    %             (staircase_petal.reversals < staircase_petal.reversal_limit || staircase_fugal.reversals < staircase_fugal.reversal_limit)
    %    the loop stop only if all fields meet the requirement, and to continue otherwise (if any field fails the requirement)
    while trial <= trialNum && any(cellfun(@(f) staircase.(f).reversals < staircase.(f).reversal_limit, fields))
        validTrialFlag = 1;   % validTrialFlag 1 valid trial     0 abandoned trial
        i = 1;
        Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
        Screen('Flip', window);
        WaitSecs(FixationOnBeforeStiSec);
        phaseShift = 0; %flash.MotDirecMat(trial) * (maxPhaseShift); % Initial phase shift (frame)
        prekeyIsDown = 0;
        phaseSpeed = abs(phaseSpeed);

        % Access current trial's parameters
        trial_params = all_combinations{block}(trial, :);
        quad = trial_params(1);
        motionDirec = trial_params(2);
        flashLoc = trial_params(3);



        % Check stopping criteria for all sstaircase
        if all(cellfun(@(f) staircase.(f).reversals >= staircase.(f).reversal_limit, fields))
            break; % Exit if all sstaircase have completed
        end


        if  quad == 135 | quad == 315
            flash.Angle = 45;
        else  quad == 45 | quad == 225
            flash.Angle = 135;
        end

        %         Draw grating wedges
        if quad == 45
            wedgeStart = wedgeStartMat(1);
            phaseshiftFactorX = 1;
            phaseshiftFactorY = -1;
            target.Angle = 135;
        elseif quad == 135
            wedgeStart = wedgeStartMat(2);
            phaseshiftFactorX = 1;
            phaseshiftFactorY = 1;
            target.Angle = 45;
        elseif quad == 225
            wedgeStart = wedgeStartMat(3);
            phaseshiftFactorX = -1;
            phaseshiftFactorY = 1;
            target.Angle = 135;
        elseif quad == 315
            wedgeStart = wedgeStartMat(4);
            phaseshiftFactorX = -1;
            phaseshiftFactorY = -1;
            target.Angle = 45;
        end


        probe.TempX = 0;
        probe.TempY = 0;

        if motionDirec ~= 0

            while i <= gratDuraFrame

                flashPresentFlag = 0;
                % No motion condition, keep phaseShift constant

                % Update phaseShift based on motion direction
                phaseShift = phaseShift + motionDirec * phaseSpeed;
                %                 phaseShift = phaseShift + phaseSpeed;

                % Update R directly using speed  if phaseShift is increasing,
                % the grating moving inward, phaseShift decreasing, grating
                % moving outward

                % Generate the dynamic concentric square-wave grating
                dynamicR = R + phaseShift; % Apply the phase shift
                dynamicGrating = double(mod(dynamicR, cycleWidthPix * 2) < cycleWidthPix);
                %                 dynamicGrating = mod(floor(dynamicR / cycleWidthPix), 2);
                dynamicGrating = (dynamicGrating * 2 - 1) * contrastFactor + grey;

                % Apply the circular mask: inside the grating radius, use dynamicGrating; outside, keep it grey
                maskedGrating = ones(size(R)) * black;  % Start with a grey mask everywhere
                maskedGrating(R <= gratingMaskRadiusPix) = dynamicGrating(R <= gratingMaskRadiusPix);  % Apply updated grating inside the mask

                maskedGratingTexture = Screen('MakeTexture', window, maskedGrating);
                Screen('DrawTexture', window, maskedGratingTexture, [], gratingRect);

                Screen('FillArc', window, black, gratingRect,wedgeStart, wedgeCoverAngle);

                phaseShiftFrame(trial,i) = phaseShift;

                % motion towards fovea  flash location 1 which is close to fovea
                if motionDirec == - 1  &&  flashLoc == flash.maxPhaseShiftPix(1) && phaseShift <= - flash.maxPhaseShiftPix(1)
                    alignPhaseShift = - phaseShift;
                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * alignPhaseShift  * sind(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * alignPhaseShift * cosd(45);

                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    phaseShiftMat(block,trial) = alignPhaseShift;
                    flashPresentFlag = 1;
                    phaseSpeed = - phaseSpeed;

                    % motion towards peripheral   flash location 1 which is close to fovea
                elseif  motionDirec == 1  &&  flashLoc  == flash.maxPhaseShiftPix(1) &&  phaseShift >= (4 * cycleWidthPix - flash.maxPhaseShiftPix(1))
                    % Draw the rotated red bar only when the direction changes to inward
                    alignPhaseShift = 4 * cycleWidthPix - phaseShift;
                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * alignPhaseShift  * sind(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * alignPhaseShift * cosd(45);

                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    phaseShiftMat(block,trial) = alignPhaseShift;
                    phaseSpeed = - phaseSpeed;
                    flashPresentFlag = 1;
                    %                     fprintf('Shift = %.2f\n', flashLoc);

                    % motion towards fovea  flash location 2 which is close to  peripheral
                elseif motionDirec == - 1  &&  flashLoc == flash.maxPhaseShiftPix(2) && phaseShift <= - flash.maxPhaseShiftPix(2)

                    alignPhaseShift = - phaseShift;
                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * alignPhaseShift  * sind(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * alignPhaseShift * cosd(45);

                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    phaseShiftMat(block,trial) = alignPhaseShift;
                    phaseSpeed = - phaseSpeed;
                    flashPresentFlag = 1;

                    % motion towards fovea  flash location 2 which is close to  peripheral
                elseif  motionDirec == 1  &&  flashLoc == flash.maxPhaseShiftPix(2) &&  phaseShift >= (4 * cycleWidthPix - flash.maxPhaseShiftPix(2))
                    % Draw the rotated red bar only when the direction changes to inward
                    alignPhaseShift = 4 * cycleWidthPix - phaseShift;
                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * alignPhaseShift  * sind(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * alignPhaseShift * cosd(45);

                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    phaseShiftMat(block,trial) = alignPhaseShift;
                    phaseSpeed = - phaseSpeed;
                    flashPresentFlag = 1;

                end


                %       Draw the grey disk and fixtion in the center of the screen
                Screen('FillOval', window, black, centerDiskRect);
                Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
                Screen('Flip', window);
                % define the present frame of the flash
                if flashPresentFlag
                    WaitSecs((1/refreshRate) * flash.PresFrame);
                end
                i = i + 1;
            end
        elseif motionDirec == 0

            if flashLoc == flash.maxPhaseShiftPix(1)
                phaseShift = - flash.maxPhaseShiftPix(1);
            elseif flashLoc == flash.maxPhaseShiftPix(2)
                phaseShift = - flash.maxPhaseShiftPix(2);
            end
            % Generate the dynamic concentric square-wave grating
            dynamicR = R + phaseShift; % Apply the phase shift
            dynamicGrating = double(mod(dynamicR, cycleWidthPix * 2) < cycleWidthPix);
            dynamicGrating = (dynamicGrating * 2 - 1) * contrastFactor + grey;

            % Apply the circular mask: inside the grating radius, use dynamicGrating; outside, keep it grey
            maskedGrating = ones(size(R)) * black;  % Start with a grey mask everywhere
            maskedGrating(R <= gratingMaskRadiusPix) = dynamicGrating(R <= gratingMaskRadiusPix);  % Apply updated grating inside the mask

            maskedGratingTexture = Screen('MakeTexture', window, maskedGrating);
            Screen('DrawTexture', window, maskedGratingTexture, [], gratingRect);

            Screen('FillArc', window, black, gratingRect,wedgeStart, wedgeCoverAngle);
            % Draw the rotated red bar only when the direction changes to inward
            flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * abs(phaseShift)  * sind(45);
            flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * abs(phaseShift)  * cosd(45);
            flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial) , flash.CenterPosY(block,trial) );
            Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
            phaseShiftMat(block,trial) = - phaseShift;
            flashFrame(block,trial) = i;
            flashPresentFlag = 1; % Set flag to indicate the flash was presented

            %       Draw the grey disk and fixtion in the center of the screen
            Screen('FillOval', window, black, centerDiskRect);
            Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
            Screen('Flip', window);
            % define the present frame of the flash
            if flashPresentFlag
                WaitSecs((1/refreshRate) * flash.PresFrame);
            end

            %             %       Draw the grey disk and fixtion in the center of the screen
            Screen('FillOval', window, black, centerDiskRect);
            %             Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
            %             Screen('Flip', window);
        end



        Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
        Screen('Flip', window);
        WaitSecs(0.3);


        if motionDirec == -1 % Petal
            if quad == 45 || quad == 315
                current_staircase = staircase.upper_petal; % Upper petal
            elseif quad == 135 || quad == 225
                current_staircase = staircase.lower_petal; % Lower petal
            end
        elseif motionDirec == 1 % Fugal
            if quad == 45 || quad == 315
                current_staircase = staircase.upper_fugal; % Upper fugal
            elseif quad == 135 || quad == 225
                current_staircase = staircase.lower_fugal; % Lower fugal
            end
        elseif motionDirec == 0
            if quad == 45 || quad == 315
                current_staircase = staircase.upper_control  % upper control
            elseif quad == 135 || quad == 225
                current_staircase = staircase.lower_control  % lower control
            end
        end


        %  The phaseshiftFactorX had already inclued the X and Y quadrant
        %  information so the
        if motionDirec == 1 |  motionDirec == 0   % fugal  or control
            % Update probe positions using the selected staircase
            probe.CenterPosX(block, trial) = flash.CenterPosX(block, trial) + ...
                phaseshiftFactorX * current_staircase.stimuluslevel * sind(45); % Direction scales position shift
            probe.CenterPosY(block, trial) = flash.CenterPosY(block, trial) + ...
                phaseshiftFactorY * current_staircase.stimuluslevel * cosd(45);
        elseif motionDirec == -1 % petal
            probe.CenterPosX(block, trial) = flash.CenterPosX(block, trial) - ...
                phaseshiftFactorX * current_staircase.stimuluslevel * sind(45); % Direction scales position shift
            probe.CenterPosY(block, trial) = flash.CenterPosY(block, trial) - ...
                phaseshiftFactorY * current_staircase.stimuluslevel * cosd(45);
        end


        if motionDirec == -1
            fprintf('Motion Direction: Inward (negative)\n');
        elseif motionDirec == 1
            fprintf('Motion Direction: Outward (positive)\n');
        end

        % Calculate the shift from the flash for logging or further use
        shiftFromFlash(trial) = sqrt((current_staircase.stimuluslevel * sind(45))^2 + ...
            (current_staircase.stimuluslevel * cosd(45))^2);


        % draw reference line
        probe.DestinationRect = CenterRectOnPoint(probe.Size,probe.CenterPosX(block,trial) + probe.TempX, probe.CenterPosY(block,trial) + probe.TempY);
        Screen('DrawTexture',window,probe.Texture,[],probe.DestinationRect,flash.Angle); % flash.Rect

        % -------------------------------------------------------
        %             Draw  response picture
        % --------------------------------------------------------


        % Response loop
        [keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
        respToBeMade = true;

        % Calculate distances from center
        flashDistanceFromCenter = sqrt((flash.CenterPosX(block, trial) - xCenter)^2 + (flash.CenterPosY(block, trial) - yCenter)^2);
        probeDistanceFromCenter = sqrt((probe.CenterPosX(block, trial) - xCenter)^2 + (probe.CenterPosY(block, trial) - yCenter)^2);

        % Actual offset from flash (center-referenced)
        actualOffset = probeDistanceFromCenter - flashDistanceFromCenter; % Negative = fovea, Positive = periphery
        current_staircase.progression(end+1) = actualOffset;


        % Determine actual relative position
        if probeDistanceFromCenter < flashDistanceFromCenter
            actualProbeRelativeToFlash = 'fovea';
        elseif probeDistanceFromCenter > flashDistanceFromCenter
            actualProbeRelativeToFlash = 'periphery';
        else % Equal (control at flash)
            actualProbeRelativeToFlash = 'neutral';
        end

        while respToBeMade
            for i = 1:length(keyboardIndices)
                [keyIsDown, ~, keyCode] = KbCheck(keyboardIndices(i));
                if keyIsDown
                    if keyCode(KbName('ESCAPE'))
                        ShowCursor;
                        sca;
                        return;
                    elseif keyCode(KbName('LeftArrow'))
                        probeToflash = 1;  % fovea
                        validTrialFlag = 1;
                        responseLabel = 'LeftArrow';
                        respToBeMade = false;
                    elseif keyCode(KbName('RightArrow'))
                        probeToflash = 2;  % periphery
                        validTrialFlag = 1;
                        responseLabel = 'RightArrow';
                        respToBeMade = false;
                    elseif keyCode(KbName('UpArrow'))
                        validTrialFlag = 0;
                        fprintf(['Miss flash block number: %d\n', 'trial number: %d\n'], block, trial);
                        responseLabel = 'UpArrow';
                        respToBeMade = false;
                    elseif keyCode(KbName('Space'))
                        OriginConditionMat{trial,:,block} = [quad, motionDirec, flashLoc];
                        respToBeMade = false;
                    end
                end
            end
            Screen('DrawTexture', window, probe.Texture, [], probe.DestinationRect, target.Angle);
            Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter, yCenter]);
            Screen('Flip', window);
            WaitSecs(0.01);
        end

        % Store results
        responseMat(block, trial) = probeToflash;
        responseLabelCell{block, trial} = responseLabel;

        if trial > 1
            lastResponse = responseMat(block, trial - 1);
            currentResponse = probeToflash;

            % Determine which staircase to update based on quadrant and motion direction
            if quad == 45 || quad == 315
                if motionDirec == -1 % Petal
                    staircase.upper_petal = update_by_response_switch(staircase.upper_petal, probeToflash, responseMat(block, trial - 1));
                    staircase.upper_petal.actualOffsets(end+1) = actualOffset;
                    log_staircase_info_v2(block, trial, quad, motionDirec, responseLabel,staircase.upper_petal, 'staircase.upper_petal');

                elseif motionDirec == 1 % Fugal
                    staircase.upper_fugal = update_by_response_switch(staircase.upper_fugal, probeToflash, responseMat(block, trial - 1));
                    staircase.upper_fugal.actualOffsets(end+1) = actualOffset;
                    log_staircase_info_v2(block, trial, quad, motionDirec, responseLabel,staircase.upper_fugal, 'staircase.upper_fugal');

                elseif motionDirec == 0
                    staircase.upper_control = update_by_response_switch(staircase.upper_control, probeToflash, responseMat(block, trial - 1));
                    staircase.upper_control.actualOffsets(end+1) = actualOffset;
                    log_staircase_info_v2(block, trial, quad, motionDirec, responseLabel,staircase.upper_control, 'staircase.upper_control');

                end
            elseif quad == 135 || quad == 225
                if motionDirec == -1 % Petal
                    staircase.lower_petal = update_by_response_switch(staircase.lower_petal, probeToflash, responseMat(block, trial - 1));
                    staircase.lower_petal.actualOffsets(end+1) = actualOffset;
                    log_staircase_info_v2(block, trial, quad, motionDirec, responseLabel,staircase.lower_petal, 'staircase.lower_petal');

                elseif motionDirec == 1 % Fugal
                    staircase.lower_fugal = update_by_response_switch(staircase.lower_fugal, probeToflash, responseMat(block, trial - 1));
                    staircase.lower_fugal.actualOffsets(end+1) = actualOffset;
                    log_staircase_info_v2(block, trial, quad, motionDirec, responseLabel,staircase.lower_fugal, 'staircase.lower_fugal');

                elseif motionDirec == 0
                    staircase.lower_control = update_by_response_switch(staircase.lower_control, probeToflash, responseMat(block, trial - 1));
                    staircase.lower_control.actualOffsets(end+1) = actualOffset;
                    log_staircase_info_v2(block, trial, quad, motionDirec, responseLabel,staircase.lower_control, 'staircase.lower_control');

                end
            end

        end

        if validTrialFlag == 0
            trial = trial;
        elseif validTrialFlag == 1
            trial = trial + 1;
        end
    end
end

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

savePath = '../data/Psychometric_curve/';
time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'flash','probe');
save(filename2);

sca;

%----------------------------------------------------------------------
%                 Plotting the Convergence
%----------------------------------------------------------------------

fields = fieldnames(staircase);
fields_figure = {'upper-fugal', 'upper-petal', 'upper-control', ...
                 'lower-fugal', 'lower-petal', 'lower-control'};
colors = {'b', 'r', 'g', 'k', 'm', 'c'};
markers = {'-o', '-s', '-d', '-^', '-x', '-+'};

figure;
hold on;

for i = 1:length(fields)
    current = staircase.(fields{i});

    % Plot actual perceptual offset
    if isfield(current, 'actualOffsets')
        plot(current.actualOffsets, markers{i}, ...
            'DisplayName', [fields_figure{i} ' Offset'], ...
            'Color', colors{i}, 'LineWidth', 1.5);
    end

%     % Also plot progression (staircase internals)
%     if isfield(current, 'progression')
%         plot(current.progression, ':', ...
%             'DisplayName', [fields_figure{i} ' Progression'], ...
%             'Color', colors{i}, 'LineWidth', 1);
%     end

    % Plot threshold from actualOffsets
    if isfield(current, 'actualOffsets') && length(current.actualOffsets) >= calculateLastTrialNum
        threshold = mean(current.actualOffsets(end - calculateLastTrialNum + 1:end));
        yline(threshold, '--', 'Color', colors{i}, ...
            'DisplayName', [fields_figure{i} ' Threshold']);
    end
end


xlabel('Trial Number');
ylabel('Stimulus Level (pixels)');
title('Staircase offset and Thresholds');
legend('show', 'Location', 'northeastoutside');
lgd = legend('show');
set(lgd, 'FontSize', 15); % Adjust the font size as desired
grid on;
set(gcf, 'Color', 'w');
hold off;


