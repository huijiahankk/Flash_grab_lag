
% For flash grab illusion test.It's a concentric grating.
% Testting the Flash grab illusion size in 4 quadrant * 2 flash location *
% 2 probe location * 3 motion direction  so totally
% flash.QuadDegree = [45 135 225 315];
% flash.maxPhaseShiftPix
% flash.MotDirec = [-1 0 1];
% probe.shiftDva = [-1 1];
%flash.MotDirec  1 means illusion outward grating moving inward at the beginning
%flash.MotDirec -1 mean illusion inward grating moving ourward at the beginning
% phaseShiftMat in flash grab experiment is [148 176 184 212]
% grating between gratingMaskRadiusPix 274 centerDiskRadiusPix 54  the
% width of the grading is 220 pixel



clear all;close all;

if 1
    sbjname = '6trial3block';
    isEyelink = 0;
    blockNum= 3;
    trialNum = 48; % 32 48
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
% refreshRate = 60;
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
cycleWidthPix = dva2pix(cycleWidthDva,eyeScreenDistence,windowRect,screenHeight) + 1;

% maxPhaseShiftdva = pix2dva(ceil(maxPhaseShift),eyeScreenDistence,windowRect,screenHeight);
gratDurationInSec = 1.5; % grating show duration in seconds
gratDuraFrame= refreshRate * gratDurationInSec;
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

flash.PresFrame = 60; % frame

% Maximum phase shift, the grading moving length
% flash.maxPhaseShift = 2 * cycleWidthPix; % dva2pix(maxPhaseShiftDva,eyeScreenDistence,windowRect,screenHeight);
gratingCenterPix = (gratingMaskRadiusPix + centerDiskRadiusPix)/2;
% locPhaseShift means flash shift from the end of the moving onset and offset
flash.locPhaseShiftdva = 1;
flash.locPhaseShiftPixTemp = dva2pix(flash.locPhaseShiftdva,eyeScreenDistence,windowRect,screenHeight);
flash.maxPhaseShiftPix = [gratingCenterPix - flash.locPhaseShiftPixTemp   gratingCenterPix + flash.locPhaseShiftPixTemp];


flash.MotDirec = [-1 0 1]; % repmat([-1 1],1,trialNum/2); % - 1 means illusion inward   1 mean illusion outward

flash.Image(:,:,1) = ones(flash.LengthPix,  flash.WidthPix);
flash.Image(:,:,2) = zeros(flash.LengthPix,  flash.WidthPix);
flash.Image(:,:,3) = flash.Image(:,:,2);
flash.Texture = Screen('MakeTexture', window, flash.Image);

%----------------------------------------------------------------------
%            parameters of probe line
%----------------------------------------------------------------------
probe.shiftDva = [-2 2];
probe.shiftPix = dva2pix(probe.shiftDva,eyeScreenDistence,windowRect,screenHeight);

probe.MoveStep = 0.3; % pixel
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
% Create all possible combinations
combinations = combvec(flash.QuadDegree, flash.MotDirec, probe.shiftPix, flash.maxPhaseShiftPix)';
numCombinations = size(combinations, 1);

% Number of repetitions to ensure at least 40 trials for each combination
numRepetitions = ceil(trialNum / numCombinations);

% Repeat the combinations to ensure we have enough trials
combinationsRepeated = repmat(combinations, numRepetitions, 1);

% Shuffle the repeated combinations
shuffledCombinations = combinationsRepeated(randperm(size(combinationsRepeated, 1)), :);

% Assign the combinations to the parameters for the current block
flash.QuadMat = shuffledCombinations(:, 1)';
flash.MotDirecMat = shuffledCombinations(:, 2)';
probe.shiftPixMat  = shuffledCombinations(:, 3)';
flash.maxPhaseShiftMat = shuffledCombinations(:, 4)';

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

%     % Assign the combinations to the parameters for the current block
%     flash.QuadMat = shuffledCombinations(:, 1)';
%     flash.MotDirecMat = shuffledCombinations(:, 2)';
%     probe.shiftPixMat  = shuffledCombinations(:, 3)';
%     flash.maxPhaseShiftMat = shuffledCombinations(:, 4)';


    %----------------------------------------------------------------------
    %                 Experiment loop
    %----------------------------------------------------------------------
    extraTrialNum = 0;
    extraConditionMat = [];
    trial = 1;

    while trial <=  trialNum + extraTrialNum
        validTrialFlag = 1;   % validTrialFlag 1 valid trial     0 abandoned trial
        if trial > trialNum
            flash.QuadMat(trial) = extraConditionMat(trial - trialNum,1);
            flash.MotDirecMat(trial) = extraConditionMat(trial - trialNum,2);
            probe.shiftPixMat(trial) = extraConditionMat(trial - trialNum,3);
            flash.maxPhaseShiftMat(trial) = extraConditionMat(trial - trialNum,4);
        end

        Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
        Screen('Flip', window);
        WaitSecs(FixationOnBeforeStiSec);
        phaseShift = 0; %flash.MotDirecMat(trial) * (maxPhaseShift); % Initial phase shift (frame)
        prekeyIsDown = 0;
        phaseSpeed = abs(phaseSpeed);

        % Add jittering to maxPhaseShift   Random pixel shift between -5 and 5 pixel
        jitterAmount(block,trial) = 0;   %floor(rand * 10) - 5;

        if  flash.QuadMat(trial) == 135 | flash.QuadMat(trial) == 315
            flash.Angle = 45;
        else  flash.QuadMat(trial) == 45 | flash.QuadMat(trial) == 225
            flash.Angle = 135;
        end

        %         Draw grating wedges
        if flash.QuadMat(trial) == 45
            wedgeStart = wedgeStartMat(1);
            phaseshiftFactorX = 1;
            phaseshiftFactorY = -1;
            target.Angle = 135;
        elseif flash.QuadMat(trial) == 135
            wedgeStart = wedgeStartMat(2);
            phaseshiftFactorX = 1;
            phaseshiftFactorY = 1;
            target.Angle = 45;
        elseif flash.QuadMat(trial) == 225
            wedgeStart = wedgeStartMat(3);
            phaseshiftFactorX = -1;
            phaseshiftFactorY = 1;
            target.Angle = 135;
        elseif flash.QuadMat(trial) == 315
            wedgeStart = wedgeStartMat(4);
            phaseshiftFactorX = -1;
            phaseshiftFactorY = -1;
            target.Angle = 45;
        end


        probe.TempX = 0;
        probe.TempY = 0;

        if flash.MotDirecMat(trial) ~= 0

            for i = 1:gratDuraFrame

                flashPresentFlag = 0;
                % No motion condition, keep phaseShift constant

                % Update phaseShift based on motion direction
                phaseShift = phaseShift + flash.MotDirecMat(trial) * phaseSpeed;

                % Update R directly using speed  if phaseShift is increasing,
                % the grating moving inward, phaseShift decreasing, grating
                % moving outward

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

                %             % Reset the phaseShift to create continuous motion
                if phaseShift >= flash.maxPhaseShiftMat(trial) + jitterAmount | phaseShift <= - flash.maxPhaseShiftMat(trial) -  jitterAmount(block,trial)
                    phaseSpeed = -phaseSpeed; % Reverse the direction of motion
                    phaseShiftCheck(trial) = phaseShift;
                end

                phaseShiftFrame(trial,i) = phaseShift;

                % Check if the phaseShift is greater than maxPhaseShift and the direction has changed to inward
                %  1 means illusion outward   grating moving inward at the beginning
                % -1 mean illusion inward grating moving ourward at the beginning
                if flash.MotDirecMat(trial) == 1  &&  phaseShift >= (flash.maxPhaseShiftMat(trial) + jitterAmount(block,trial))
                    %                 if flash.MotDirecMat(trial) == 1  &&  phaseShift <= (- flash.maxPhaseShiftMat(trial) - jitterAmount(block,trial))

                    % Draw the rotated red bar only when the direction changes to inward

                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * (4 * cycleWidthPix - phaseShift)  * sind(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * (4 * cycleWidthPix - phaseShift)  * cosd(45);

                    %                     flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * (phaseShift)  * cosd(45);
                    %                     flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * (phaseShift)  * sind(45);

                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    phaseShiftMat(block,trial) = (4 * cycleWidthPix - phaseShift);
                    flashFrame(block,trial) = i;
                    flashPresentFlag = 1; % Set flag to indicate the flash was presented

                elseif  flash.MotDirecMat(trial) == -1  &&   phaseShift <= - flash.maxPhaseShiftMat(trial) - jitterAmount(block,trial)
                    % Draw the rotated red bar only when the direction changes to inward
                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * abs(phaseShift)  * cosd(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * abs(phaseShift)  * sind(45);
                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial) , flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    phaseShiftMat(block,trial) = abs(phaseShift);
                    flashFrame(block,trial) = i;
                    flashPresentFlag = 1; % Set flag to indicate the flash was presented
                    %                 elseif  flash.MotDirecMat(trial) == 0  &&  i == flashFrame  && flash.maxPhaseShiftMat(trial) == 182 % when meet the phaseShift requirements, the value of i
                    %
                    %                     % Draw the rotated red bar only when the direction changes to inward
                    %                     flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * abs(phaseShift)  * sind(45);
                    %                     flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * abs(phaseShift)  * cosd(45);
                    %                     flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial) , flash.CenterPosY(block,trial) );
                    %                     Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    %                     %                 phaseShiftMat(trial) = phaseShift;
                    %                     flashFrame(block,trial) = i;
                    %                     flashPresentFlag = 1; % Set flag to indicate the flash was presented

                end

                %       Draw the grey disk and fixtion in the center of the screen
                Screen('FillOval', window, black, centerDiskRect);
                Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
                Screen('Flip', window);
                % define the present frame of the flash
                if flashPresentFlag
                    WaitSecs((1/refreshRate) * flash.PresFrame);
                end

            end

        elseif flash.MotDirecMat(trial) == 0

            if flash.maxPhaseShiftMat(trial) == flash.maxPhaseShiftPix(1)
                phaseShift = -160;
            elseif flash.maxPhaseShiftMat(trial) == flash.maxPhaseShiftPix(2)
                phaseShift = -236;
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
            phaseShiftMat(trial) = abs(phaseShift);
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
            WaitSecs(0.5);

        end


        % -------------------------------------------------------
        %             Draw  response picture
        % --------------------------------------------------------
        probe.CenterPosX(block,trial) = flash.CenterPosX(block,trial) + phaseshiftFactorX * probe.shiftPixMat(trial) * sind(45);
        probe.CenterPosY(block,trial) = flash.CenterPosY(block,trial) + phaseshiftFactorY * probe.shiftPixMat(trial) * cosd(45);

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
                        if  flash.QuadMat(trial) == 135 || flash.QuadMat(trial) == 315
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY - probe.MoveStep;
                        else  flash.QuadMat(trial) == 45 | flash.QuadMat(trial) == 225;
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        end
                    elseif keyCode(KbName('RightArrow'))
                        if  flash.QuadMat(trial) == 135 || flash.QuadMat(trial) == 315
                            probe.TempX = probe.TempX + probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        else  flash.QuadMat(trial) == 45 | flash.QuadMat(trial) == 225
                            probe.TempX = probe.TempX + probe.MoveStep;
                            probe.TempY = probe.TempY - probe.MoveStep;
                        end
                    elseif keyCode(KbName('UpArrow'))
                        validTrialFlag = 0;
                        extraTrialNum = extraTrialNum + 1;
                        extraConditionMat(extraTrialNum,:) = [flash.QuadMat(trial), flash.MotDirecMat(trial), probe.shiftPixMat(trial), flash.maxPhaseShiftMat(trial)];
                        fprintf(['Miss flash block number: %d\n','trial number: %d\n'],block,trial);
                        respToBeMade = false;
                    elseif keyCode(KbName('Space'))|| keyCode(KbName('Space!'))
                        OriginConditionMat{trial,:,block} = [flash.QuadMat(trial), flash.MotDirecMat(trial), probe.shiftPixMat(trial), flash.maxPhaseShiftMat(trial)];
                        respToBeMade = false;
                    end
                    prekeyIsDown = keyIsDown;
                end
                %                 end
            end
            % draw reference line
            probe.DestinationRect = CenterRectOnPoint(probe.Size,probe.CenterPosX(block,trial) + probe.TempX, probe.CenterPosY(block,trial) + probe.TempY);
            Screen('DrawTexture',window,probe.Texture,[],probe.DestinationRect,flash.Angle); % flash.Rect
            %             Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
            %             strResponse = 'Please adjust the probe' ;
            %             Screen ('TextSize',window,30);
            %             Screen('TextFont',window,'Courier');
            %             CenterQuadRect = [xCenter/2 yCenter  xCenter*3/2 yCenter];
            %             DrawFormattedText(window, strResponse, 'center', 'center', grey,[],[],[],[],[],CenterQuadRect);

            Screen('DrawTexture',window,probe.Texture,[],probe.DestinationRect,target.Angle); % flash.Rect
            Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);

            Screen('Flip', window);
            % add a small pause to prevent CPU overloading
            WaitSecs(0.01);
        end
        probe.PosXMat(block,trial) = probe.CenterPosX(block,trial)  + probe.TempX;
        probe.PosYMat(block,trial) = probe.CenterPosY(block,trial)  + probe.TempY;

        % valid trial  1   % abandon trial  0
        validTrialMat(block,trial) = validTrialFlag;

        trial = trial + 1;



    end

    extraTrialNumMat(block) = extraTrialNum;
    extraConditionMatAll{:,:,block} = extraConditionMat;

    if ~isempty(extraConditionMat)
        % After the block, append the extra trials to the end of each matrix
        flash.QuadMatUpdate{block,:} = [shuffledCombinations(:, 1)', extraConditionMat(:, 1)'];
        flash.MotDirecMatUpdate{block,:}  = [shuffledCombinations(:, 2)', extraConditionMat(:, 2)'];
        probe.shiftPixMatUpdate{block,:}  = [shuffledCombinations(:, 3)', extraConditionMat(:, 3)'];
        flash.maxPhaseShiftMatUpdate{block,:}  = [shuffledCombinations(:, 4)', extraConditionMat(:, 4)'];
    else
        flash.QuadMatUpdate{block,:} = [shuffledCombinations(:, 1)'];
        flash.MotDirecMatUpdate{block,:}  = [shuffledCombinations(:, 2)'];
        probe.shiftPixMatUpdate{block,:}  = [shuffledCombinations(:, 3)'];
        flash.maxPhaseShiftMatUpdate{block,:}  = [shuffledCombinations(:, 4)'];
    end
    
end



% % Check if conditions are still balanced
% conditionCounts = [sum(flash.QuadMat == 1), sum(flash.QuadMat == 2), sum(probe.shiftPixMat == 3),]; % Extend this for all condition values
% 
% if ~isequal(conditionCounts)
%     % Conditions are not balanced; you may need to adjust or log a warning
%     warning('Conditions are not balanced at the end of the block.');
% end


%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

savePath = '../data/';
time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'flash','probe');
save(filename2);

sca;