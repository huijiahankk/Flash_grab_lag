
% For flash grab illusion test.It's a concentric grating.
% Testting the Flash grab illusion size in 4 quadrant


clear all;close all;

if 1
    sbjname = 'hjh';
    isEyelink = 0;
    blockNum= 2;
    trialNum = 32;
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
red = [255, 0, 0];
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, []); %
xCenter = windowRect(3) / 2; % Center X-coordinate
yCenter = windowRect(4) / 2; % Center Y-coordinate
refreshRate = FrameRate(window);
% refreshRate = 60;
commandwindow;
addpath ../function/;

eyeScreenDistence = 57;  %  57 cm
screenHeight = 33.5; % 26.8 cm
% Get the number of pixels in the vertical dimension of the screen
screenHeightPixels = windowRect(4);

%   draw the fixcross
fixCrossDimPixDva = 0.5;
fixCrossDimPix = dva2pix(fixCrossDimPixDva,eyeScreenDistence,windowRect,screenHeight);
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
LineWithPix = 6;


%----------------------------------------------------------------------
%         moving bar parameters
%----------------------------------------------------------------------
mov.WidthDva = 0.5; % Width of the red flashed bar in visual degree angle
mov.LengthDva = 3; % Height of the red flashed bar in visual degree angle
mov.WidthPix = dva2pix(mov.WidthDva,eyeScreenDistence,windowRect,screenHeight);
mov.LengthPix = dva2pix(mov.LengthDva,eyeScreenDistence,windowRect,screenHeight);
% flash.Angle = 135;% The angle of rotation in degrees
mov.Size = [0, 0, mov.WidthPix, mov.LengthPix];  % Red bar size before rotation
mov.QuadDegree = [45 135 225 315]; % % 10 pixels [45 45 45 45]     [45 135 225 315]
mov.speed = 3; % pixel per frame
mov.lenghPix = 100;% pixel
% mov.PresFrame = mov.lenghPix/mov.speed; % frame
mov.MotDirec = [-1 1]; % - 1 means flash moves inward   1 mean flash moves outward

mov.Image(:,:,1) = ones(mov.LengthPix,  mov.WidthPix);
mov.Image(:,:,2) = zeros(mov.LengthPix,  mov.WidthPix);
mov.Image(:,:,3) = mov.Image(:,:,2);
mov.Texture = Screen('MakeTexture', window, mov.Image);

mov.StartdistanceX = 10; % pixel
mov.StartdistanceY = 100; % pixel


%----------------------------------------------------------------------
%        flashed red bar parameters
%----------------------------------------------------------------------
flash.loc = [1/3 2/3] * mov.lenghPix; % frame
flash.presentFrame = 3; % frame



%----------------------------------------------------------------------
%            parameters of response probe
%----------------------------------------------------------------------
probe.shiftDva = [-1 1];
probe.shiftPix = dva2pix(probe.shiftDva,eyeScreenDistence,windowRect,screenHeight);

probe.MoveStep = 1; % pixel
probe.Tilt = 135;  % in degree
probe.WidthDva = 0.5;
probe.LengthDva = 3;
probe.WidthPix = dva2pix(probe.WidthDva,eyeScreenDistence,windowRect,screenHeight);
probe.LengthPix = dva2pix(probe.LengthDva,eyeScreenDistence,windowRect,screenHeight);

% Define a rectangle
probe.Image(:,:,1) = zeros(probe.LengthPix,  probe.WidthPix);
probe.Image(:,:,2) = zeros(probe.LengthPix,  probe.WidthPix) * 255;
probe.Image(:,:,3) = probe.Image(:,:,2);

% Make the rectangle into a texure
probe.Texture = Screen('MakeTexture', window, probe.Image);
% probe.Rect = Screen('Rect',probe.Texture);
probe.Size = mov.Size;
probe.intervalTime = 1;

%----------------------------------------------------------------------
%        Define all possible combinations of parameters
%----------------------------------------------------------------------
% Create all possible combinations
combinations = combvec(mov.QuadDegree, mov.MotDirec, probe.shiftPix,flash.loc)';
numCombinations = size(combinations, 1);

% Number of repetitions to ensure at least 40 trials for each combination
numRepetitions = ceil(trialNum / numCombinations);

% Repeat the combinations to ensure we have enough trials
combinationsRepeated = repmat(combinations, numRepetitions, 1);

% Shuffle the repeated combinations
shuffledCombinations = combinationsRepeated(randperm(size(combinationsRepeated, 1)), :);

% Assign the combinations to the parameters for the current block
mov.QuadMat = shuffledCombinations(:, 1)';
mov.MotDirecMat = shuffledCombinations(:, 2)';
probe.shiftPixMat  = shuffledCombinations(:, 3)';
flash.locMat = shuffledCombinations(:, 4)';

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
    DrawFormattedText(window, str, 'center', 'center', black,[],[],[],[],[],topCenterQuadRect);
    Screen('Flip', window);
    KbStrokeWait;


    %----------------------------------------------------------------------
    %                 Experiment loop
    %----------------------------------------------------------------------


    for trial = 1:trialNum

        fprintf('Starting trial %d of %d\n', trial, trialNum);
        prekeyIsDown = 0;
        flashShowFlag = 0;

        mov.LocSecq = mov.QuadMat(trial);
        % - 1 means flash moves inward   1 mean flash moves outward
        if         mov.MotDirecMat(trial) == 1
            mov.shift = 0;
        elseif     mov.MotDirecMat(trial) == - 1
            mov.shift = yCenter - mov.lenghPix/2;
        end

        fprintf('mov.LocSecq = %d, mov.MotDirec = %d, probe.shiftPix = %d,flash.loc = %d\n', ...
            mov.LocSecq, mov.MotDirecMat(trial),probe.shiftPixMat(trial),flash.locMat(trial));
        %         % Add jittering to flash.start  Random pixel shift less than 5
        %         jitterAmount(block,trial) = floor(rand * 10);


        if mov.LocSecq == 45
            FactorX = 1;
            FactorY = -1;
            mov.Angle = 135;
        elseif mov.LocSecq == 135
            FactorX = 1;
            FactorY = 1;
            mov.Angle = 45;
        elseif mov.LocSecq == 225
            FactorX = -1;
            FactorY = 1;
            mov.Angle = 135;
        elseif mov.LocSecq == 315
            FactorX = -1;
            FactorY = -1;
            mov.Angle = 45;
        end


        probe.TempX = 0;
        probe.TempY = 0;

        for i = 1: mov.lenghPix
            flashShowFlag = 0;
            flashPresentFlag = 0;
            mov.shift = mov.shift + mov.MotDirecMat(trial) * mov.speed;
            mov.CenterPosX(block,trial) = xCenter + FactorX * mov.StartdistanceX + FactorX * mov.shift * sind(45);
            mov.CenterPosY(block,trial) = yCenter + FactorY * mov.StartdistanceY + FactorY * mov.shift * cosd(45);
            mov.Rect = CenterRectOnPointd(mov.Size, mov.CenterPosX(block,trial), mov.CenterPosY(block,trial) );
            Screen('DrawTexture', window, mov.Texture, [], mov.Rect, mov.Angle);
            mov.shiftMat(trial) = mov.shift;
            iMat(trial,i) = i;

%             if   i == flash.locMat(trial)
                if i >= flash.locMat(trial) - (flash.presentFrame - 1)/2 && i <= flash.locMat(trial) + (flash.presentFrame - 1)/2

                flash.CenterPosX(block,trial) = xCenter + FactorX * mov.StartdistanceY + FactorX * mov.shift * sind(45);
                flash.CenterPosY(block,trial) = yCenter + FactorY * mov.StartdistanceX + FactorY * mov.shift * cosd(45);
                mov.locWhenFlashX(block,trial) = mov.CenterPosX(block,trial);
                mov.locWhenFlashY(block,trial) = mov.CenterPosY(block,trial);
                flash.Rect = CenterRectOnPointd(mov.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                Screen('DrawTexture', window, mov.Texture, [], flash.Rect, mov.Angle);
                % Debug messages
                fprintf('Flash drawn in trial %d at frame %d\n', trial, i);
                fprintf('mov.CenterPosX: %f, mov.CenterPosY: %f\n', mov.CenterPosX(block, trial), mov.CenterPosY(block, trial));
                fprintf('flash.CenterPosX: %f, flash.CenterPosY: %f\n', flash.CenterPosX(block, trial), flash.CenterPosY(block, trial));
            end
            Screen('DrawLines', window, allCoords, LineWithPix, black, [xCenter,yCenter]);
            Screen('Flip', window);
        end

        Screen('DrawLines', window, allCoords, LineWithPix, black, [xCenter,yCenter]);
        Screen('Flip', window);
        WaitSecs(probe.intervalTime);
        % -------------------------------------------------------
        %             Draw  response picture
        % --------------------------------------------------------
%         % probe at the flashed bar location
%         probe.CenterPosX(block,trial) = flash.CenterPosX(block,trial) + FactorX * probe.shiftPixMat(trial) * sind(45);
%         probe.CenterPosY(block,trial) = flash.CenterPosY(block,trial) + FactorY * probe.shiftPixMat(trial) * cosd(45);

        % probe around the moving bar when flashed location
        probe.CenterPosX(block,trial) = mov.locWhenFlashX(block,trial) + FactorX * probe.shiftPixMat(trial) * sind(45);
        probe.CenterPosY(block,trial) =  mov.locWhenFlashY(block,trial) + FactorY * probe.shiftPixMat(trial) * cosd(45);

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
                        if  mov.LocSecq == 135 || mov.LocSecq == 315
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY - probe.MoveStep;
                        else  mov.LocSecq == 45 | mov.LocSecq == 225;
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        end
                    elseif keyCode(KbName('RightArrow'))
                        if  mov.LocSecq == 135 || mov.LocSecq == 315
                            probe.TempX = probe.TempX + probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        else  mov.LocSecq == 45 | mov.LocSecq == 225
                            probe.TempX = probe.TempX + probe.MoveStep;
                            probe.TempY = probe.TempY - probe.MoveStep;
                        end
                    elseif keyCode(KbName('Space'))
                        respToBeMade = false;
                    end
                    prekeyIsDown = keyIsDown;
                end
                %                 end
            end
            % draw reference line
            probe.DestinationRect = CenterRectOnPoint(probe.Size,probe.CenterPosX(block,trial) + probe.TempX, probe.CenterPosY(block,trial) + probe.TempY);
            Screen('DrawTexture',window,probe.Texture,[],probe.DestinationRect,mov.Angle); % flash.Rect
            Screen('DrawLines', window, allCoords, LineWithPix, black, [xCenter,yCenter]);
            Screen('Flip', window);


            % You can add a small pause to prevent CPU overloading
            WaitSecs(0.01);
        end
        probe.PosXMat(block,trial) = probe.CenterPosX(block,trial)  + probe.TempX;
        probe.PosYMat(block,trial) = probe.CenterPosY(block,trial)  + probe.TempY;

    end
end

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

savePath = '../data/flash_lag/';
time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'flash','probe');
save(filename2);

sca;