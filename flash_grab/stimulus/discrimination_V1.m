
% Use QUEST to test the threshold of probe.shiftPix 
% Testting the Flash grab illusion size in 4 quadrant * 2 flash location *
% 2 motion direction  so totally 24 trial
% flash.QuadDegree = [45 135 225 315];
% flash.maxPhaseShiftPix
% flash.MotDirec = [-1 0 1];
% probe.shiftDva = QUEST 
%flash.MotDirec  1 means illusion outward grating moving inward at the beginning
%flash.MotDirec -1 mean illusion inward grating moving ourward at the beginning
% phaseShiftMat in flash grab experiment is [148 176 184 212]
% grating between gratingMaskRadiusPix 274 centerDiskRadiusPix 54  the
% width of the grading is 220 pixel
% left arrow is for the probe bar is to the fovea
% right arrow is the probe is towards the peripheral




clear all;close all;

if 1
    sbjname = 'kk';
    isEyelink = 0;
    blockNum= 1;
    trialNum = 120; % 32 48
else
    prompt = {'subject''s name','isEyelink(without eyelink 0 or use eyelink 1)','block number','trial number(multiples of 10)'};
    dlg_title = 'Set experiment parameters ';
    answer  = inputdlg(prompt,dlg_title);
    [sbjname] = answer{1};
    [isEyelink] = str2double(answer{2});
    [blockNum] = str2double(answer{3})
    [trialNum] = str2double(answer{4});
end
fprintf(['sbjname: %s\n','isEyelink: %d\n','block number: %d\n','trial number: %d\n'],sbjname,isEyelink,blockNum,trialNum);

%----------------------------------------------------------------------
%       load probe.shiftPix result from QUEST
%----------------------------------------------------------------------
loadPath = '../data/Psychometric_curve/';
addpath(loadPath);
s1 = sbjname;
s2 = '*.mat';
s3 = strcat(s1, s2);
% Files = dir(s3);
Files = dir(fullfile(loadPath, s3));

if isempty(Files)
    warning('No files found for subject %s.', s1);
end

loadedData = load(Files.name,'probe');
probe = loadedData.probe;

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
% KbName('UnifyKeyNames');

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
gratDurationInSec = 1.5; % grating show duration in seconds
gratDuraFrame = refreshRate * gratDurationInSec;
% gratDurationInSec = 3 * cycleWidth /(phaseSpeed * refreshRate);

% Create a lower resolution grid for the grating image
% resolutionFactor = 0.5; % Adjust this to balance between performance and quality
% numPoints = round(2 * gratingRadiusPix * resolutionFactor);
% [X, Y] = meshgrid(linspace(-gratingRadiusPix, gratingRadiusPix, numPoints), linspace(-gratingRadiusPix, gratingRadiusPix, numPoints));
[X, Y] = meshgrid(linspace(-gratingRadiusPix, gratingRadiusPix, round(2 * gratingRadiusPix)), linspace(-gratingRadiusPix, gratingRadiusPix, round(2 * gratingRadiusPix)));
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
flash.QuadDegree = [45 135 225 315]; % % 10 pixels [45 45 45 45]     [45 135 225 315]

flash.PresFrame = 3; % frame

% Maximum phase shift, the grading moving length
% flash.maxPhaseShift = 2 * cycleWidthPix; % dva2pix(maxPhaseShiftDva,eyeScreenDistence,windowRect,screenHeight);
gratingCenterPix = (gratingMaskRadiusPix + centerDiskRadiusPix)/2;
% locPhaseShift means flash shift from the end of the moving onset and offset
flash.locPhaseShiftdva = 2;
flash.locPhaseShiftPixTemp = dva2pix(flash.locPhaseShiftdva,eyeScreenDistence,windowRect,screenHeight);
flash.maxPhaseShiftPix = [gratingCenterPix - flash.locPhaseShiftPixTemp - 0.5   gratingCenterPix + flash.locPhaseShiftPixTemp + 1.5];
% flash.phaseShift = 1;  % 1  (4 * cycleWidthPix - phaseShift)    2 abs(phaseShift)


flash.MotDirec = [-1 0 1]; % repmat([-1 1],1,trialNum/2); % - 1 means illusion inward   1 mean illusion outward

flash.Image(:,:,1) = ones(flash.LengthPix,  flash.WidthPix);
flash.Image(:,:,2) = zeros(flash.LengthPix,  flash.WidthPix);
flash.Image(:,:,3) = flash.Image(:,:,2);
flash.Texture = Screen('MakeTexture', window, flash.Image);

%----------------------------------------------------------------------
%            parameters of probe line
%----------------------------------------------------------------------

probe.shiftPix = [-2*probe.shiftPixThreshold -probe.shiftPixThreshold 0 probe.shiftPixThreshold 2*probe.shiftPixThreshold];

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
[quad_vals, mot_vals, shift_vals,probe_vals] = ndgrid(flash.QuadDegree, flash.MotDirec, flash.maxPhaseShiftPix,probe.shiftPix);
combinations = [quad_vals(:), mot_vals(:), shift_vals(:),probe_vals(:)]; 

% Experiment parameters
trials_per_block = size(combinations, 1); 

% Generate truly randomized blocks
all_combinations = cell(blockNum, 1);
for block_idx = 1:blockNum
    % Randomly shuffle the order of combinations for each block
    rng('shuffle'); % Set random seed based on current time for different randomization each loop
    all_combinations{block_idx} = combinations(randperm(trials_per_block), :); % Randomized combinations for each block
end

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

%draw instructions
Screen('DrawTexture',window,InstructTex,InstructSrc,InstructDest,0); %draw fixation Gaussian
vbl=Screen('Flip', window);%, vbl + (waitframes - 0.5) * sp.ifi);

KbStrokeWait;


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

    %----------------------------------------------------------------------
    %                 Experiment loop
    %----------------------------------------------------------------------

    trial = 1;

    while trial <=  trialNum %
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
        probeLoc = trial_params(4);
        

        % Display or use the parameters
        fprintf('Block %d, Trial %d: Quad = %d, Mot = %d, FlashShift = %d, ProbeShift = %d\n', block, trial, quad, motionDirec, flashLoc,probeLoc);
%         fprintf('Trial %d: probe.shiftPix = %f\n', trial, probe.shiftPix);
%         fprintf('Trial %d: QUEST suggested tTest (log scale) = %f, stimulusIntensity = %f\n', trial, tTest, stimulusIntensity);


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


                if motionDirec == - 1  &&  flashLoc == flash.maxPhaseShiftPix(1) && phaseShift <= - flash.maxPhaseShiftPix(1)
                    alignPhaseShift = - phaseShift;
                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * alignPhaseShift  * sind(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * alignPhaseShift * cosd(45);

                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    phaseShiftMat(block,trial) = alignPhaseShift;
                    flashPresentFlag = 1;
                    phaseSpeed = - phaseSpeed;

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

                elseif motionDirec == - 1  &&  flashLoc == flash.maxPhaseShiftPix(2) && phaseShift <= - flash.maxPhaseShiftPix(2)

                    alignPhaseShift = - phaseShift;
                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * alignPhaseShift  * sind(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * alignPhaseShift * cosd(45);

                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    phaseShiftMat(block,trial) = alignPhaseShift;
                    phaseSpeed = - phaseSpeed;
                    flashPresentFlag = 1;

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
            Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
            Screen('Flip', window);
        end

        Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
        Screen('Flip', window);
        WaitSecs(0.3);

        % -------------------------------------------------------
        %             Draw  response picture
        % --------------------------------------------------------
        probe.CenterPosX(block,trial) = flash.CenterPosX(block,trial) + phaseshiftFactorX * probe.shiftPix * sind(45);
        probe.CenterPosY(block,trial) = flash.CenterPosY(block,trial) + phaseshiftFactorY * probe.shiftPix * cosd(45);

        % Find all keyboards (returns a device index for each keyboard)
        [keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
        % Start a loop to check for key presses
        respToBeMade = true;
        while respToBeMade
            % Check each connected keyboard
            for i = 1:length(keyboardIndices)
                [keyIsDown, ~, keyCode] = KbCheck(keyboardIndices(i));
                %                 if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
                if keyIsDown
                    if keyCode(KbName('ESCAPE'))
                        ShowCursor;
                        sca;
                        return;
                    elseif keyCode(KbName('LeftArrow'))
                        probeToflash = 1; % 'fovea';
                        if probe.shiftPix < 0
                            responseCorrect = 1;
                        elseif probe.shiftPix >= 0
                            responseCorrect = 0;
                        end
                        respToBeMade = false;
                    elseif keyCode(KbName('RightArrow'))
                        probeToflash = 2; % 'peripheral';
                        if probe.shiftPix > 0
                            responseCorrect = 1;
                        elseif probe.shiftPix <= 0
                            responseCorrect = 0;
                        end
                        respToBeMade = false;
                    elseif keyCode(KbName('UpArrow'))
                        validTrialFlag = 0;
                        fprintf(['Miss flash block number: %d\n','trial number: %d\n'],block,trial);
                        respToBeMade = false;
                    elseif keyCode(KbName('Space'))
                        OriginConditionMat{trial,:,block} = [quad, motionDirec, flashLoc];
                        respToBeMade = false;
                    end
                    prekeyIsDown = keyIsDown;
                end
            end
            % draw reference line
            probe.DestinationRect = CenterRectOnPoint(probe.Size,probe.CenterPosX(block,trial) + probe.TempX, probe.CenterPosY(block,trial) + probe.TempY);
            Screen('DrawTexture',window,probe.Texture,[],probe.DestinationRect,flash.Angle); % flash.Rect


            Screen('DrawTexture',window,probe.Texture,[],probe.DestinationRect,target.Angle); % flash.Rect
            Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);

            Screen('Flip', window);
            % add a small pause to prevent CPU overloading
            WaitSecs(0.01);
        end

        tTestAdjusted = log10(stimulusIntensity);
        q = QuestUpdate(q, tTestAdjusted, responseCorrect);

        correctMat(block,trial) = responseCorrect;
        responseMat(block,trial) = probeToflash;


        if validTrialFlag == 0
            trial = trial;
        elseif validTrialFlag == 1
            trial = trial + 1;
        end

    end


    finalThreshold = QuestMean(q);  % Calculate the mean estimate from QUEST
yline(10^finalThreshold, 'r--', 'DisplayName', 'Estimated Threshold', 'LineWidth', 1.5);
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
figure;
hold on;

% Plot the threshold estimates for each block
for block = 1:blockNum
    plot(1:trialNum, thresholdProgression(block, :), '-o', 'DisplayName', ['Block ' num2str(block)]);
end

% Label the axes and add a title
xlabel('Trial Number');
ylabel('Threshold Estimate (probe.shiftPix)');
title('Convergence of Threshold Estimate Across Trials');
legend('show');
grid on;

% Optional: Add a line representing the estimated final threshold
finalThreshold = QuestMean(q);  % Calculate the mean estimate from QUEST
yline(10^finalThreshold, 'r--', 'DisplayName', 'Estimated Threshold', 'LineWidth', 1.5);

hold off;
