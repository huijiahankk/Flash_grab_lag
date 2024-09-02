

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
    sbjname = 'fulltest';
    isEyelink = 1;
    blockNum= 1;
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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, []); %
refreshRate = FrameRate(window);
% refreshRate = 60;
commandwindow;
addpath ../function/;
% KbName('UnifyKeyNames');

eyeScreenDistence = 57;  %  57 cm
screenHeight = 30.5; % 26.8 cm   33.5 cm
% Get the number of pixels in the vertical dimension of the screen
screenHeightPixels = windowRect(4);
screenWidthPixels = windowRect(3);


%   draw the fixcross
fixCrossDimPixDva = 0.5;
fixCrossDimPix = dva2pix(fixCrossDimPixDva,eyeScreenDistence,windowRect,screenHeight);
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
LineWithPix = 6;
phaseShiftMat = [];
FixationOnBeforeStiSec = 0.5;

% Some initial parameters:
fixWinSize = 300; % pixel Width and Height of square fixation window [in pixels]
fixateTime = 0.5; % ms Duration of gaze inside fixation window required before stimulus presentation [ms]

% % Create central square fixation window
% fixationWindow = [-fixWinSize -fixWinSize fixWinSize fixWinSize];
% fixationWindow = CenterRect(fixationWindow, windowRect);

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
flash.locPhaseShiftdva = 1;
flash.locPhaseShiftPixTemp = dva2pix(flash.locPhaseShiftdva,eyeScreenDistence,windowRect,screenHeight);
flash.maxPhaseShiftPix = [gratingCenterPix - flash.locPhaseShiftPixTemp + 0.5   gratingCenterPix + flash.locPhaseShiftPixTemp + 0.5];
% flash.phaseShift = 1;  % 1  (4 * cycleWidthPix - phaseShift)    2 abs(phaseShift)


flash.MotDirec = [-1 0 1]; % repmat([-1 1],1,trialNum/2); % - 1 means illusion inward   1 mean illusion outward

flash.Image(:,:,1) = ones(flash.LengthPix,  flash.WidthPix);
flash.Image(:,:,2) = zeros(flash.LengthPix,  flash.WidthPix);
flash.Image(:,:,3) = flash.Image(:,:,2);
flash.Texture = Screen('MakeTexture', window, flash.Image);

%----------------------------------------------------------------------
%            parameters of probe line
%----------------------------------------------------------------------
probe.shiftDva = [-1 1];
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
%%%            Eyelink setting up
%----------------------------------------------------------------------
if isEyelink
    % Some initial parameters:
    eye.fixWinSizeDva = 5; % Width and Height of square fixation window
    eye.fixWinSizePix = dva2pix(eye.fixWinSizeDva,eyeScreenDistence,windowRect,screenHeight);
    eye.fixateTime = 500; % Duration of gaze inside fixation window required before stimulus presentation [ms]
    % Create central square fixation window
    eye.fixationWindow = [-eye.fixWinSizePix -eye.fixWinSizePix eye.fixWinSizePix eye.fixWinSizePix];
    eye.fixationWindow = CenterRect(eye.fixationWindow, windowRect);


    %% STEP 1: INITIALIZE EYELINK CONNECTION; OPEN EDF FILE; GET EYELINK TRACKER VERSION

    % Initialize EyeLink connection (dummymode = 0) or run in "Dummy Mode" without an EyeLink connection (dummymode = 1);
    dummymode = 0;
    EyelinkInit(dummymode); % Initialize EyeLink connection
    status = Eyelink('IsConnected');
    if status < 1 % If EyeLink not connected
        dummymode = 1;
    end

    % Open dialog box for EyeLink Data file name entry. File name up to 8 characters
    prompt = {'Enter EDF file name (up to 8 characters)'};
    dlg_title = 'Create EDF file';
    def = {'demo'}; % Create a default edf file name
    answer = inputdlg(prompt, dlg_title, 1, def); % Prompt for new EDF file name
    % Print some text in Matlab's Command Window if a file name has not been entered
    if  isempty(answer)
        fprintf('Session cancelled by user\n')
        cleanup; % Abort experiment (see cleanup function below)
        return
    end
    edfFile = answer{1}; % Save file name to a variable
    % Print some text in Matlab's Command Window if file name is longer than 8 characters
    if length(edfFile) > 8
        fprintf('Filename needs to be no more than 8 characters long (letters, numbers and underscores only)\n');
        cleanup; % Abort experiment (see cleanup function below)
        return
    end

    % Open an EDF file and name it
    failOpen = Eyelink('OpenFile', edfFile);
    if failOpen ~= 0 % Abort if it fails to open
        fprintf('Cannot create EDF file %s', edfFile); % Print some text in Matlab's Command Window
        cleanup; %see cleanup function below
        return
    end

    % Get EyeLink tracker and software version
    % <ver> returns 0 if not connected
    % <versionstring> returns 'EYELINK I', 'EYELINK II x.xx', 'EYELINK CL x.xx' where 'x.xx' is the software version
    ELsoftwareVersion = 0; % Default EyeLink version in dummy mode
    [ver, versionstring] = Eyelink('GetTrackerVersion');
    if dummymode == 0 % If connected to EyeLink
        % Extract software version number.
        [~, vnumcell] = regexp(versionstring,'.*?(\d)\.\d*?','Match','Tokens'); % Extract EL version before decimal point
        ELsoftwareVersion = str2double(vnumcell{1}{1}); % Returns 1 for EyeLink I, 2 for EyeLink II, 3/4 for EyeLink 1K, 5 for EyeLink 1KPlus, 6 for Portable Duo
        % Print some text in Matlab's Command Window
        fprintf('Running experiment on %s version %d\n', versionstring, ver );
    end
    % Add a line of text in the EDF file to identify the current experimemt name and session. This is optional.
    % If your text starts with "RECORDED BY " it will be available in DataViewer's Inspector window by clicking
    % the EDF session node in the top panel and looking for the "Recorded By:" field in the bottom panel of the Inspector.
    preambleText = sprintf('RECORDED BY Psychtoolbox demo %s session name: %s', mfilename, edfFile);
    Eyelink('Command', 'add_file_preamble_text "%s"', preambleText);


    %% STEP 2: SELECT AVAILABLE SAMPLE/EVENT DATA
    % See EyeLinkProgrammers Guide manual > Useful EyeLink Commands > File Data Control & Link Data Control

    % Select which events are saved in the EDF file. Include everything just in case
    Eyelink('Command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    % Select which events are available online for gaze-contingent experiments. Include everything just in case
    Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,FIXUPDATE,INPUT');
    % Select which sample data is saved in EDF file or available online. Include everything just in case
    if ELsoftwareVersion > 3  % Check tracker version and include 'HTARGET' to save head target sticker data for supported eye trackers
        Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,HTARGET,GAZERES,BUTTON,STATUS,INPUT');
        Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
    else
        Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,GAZERES,BUTTON,STATUS,INPUT');
        Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    end


    % Get max color value for rescaling  to RGB for Host PC & Data Viewer integration
    colorMaxVal = Screen('ColorRange', window);
    %% STEP 4: SET CALIBRATION SCREEN COLOURS; PROVIDE WINDOW SIZE TO EYELINK HOST & DATAVIEWER; SET CALIBRATION PARAMETERS; CALIBRATE

    % Provide EyeLink with some defaults, which are returned in the structure "el".
    el = EyelinkInitDefaults(window);
    % set calibration/validation/drift-check(or drift-correct) size as well as background and target colors.
    % It is important that this background colour is similar to that of the stimuli to prevent large luminance-based
    % pupil size changes (which can cause a drift in the eye movement data)
    el.calibrationtargetsize = 3;%  Outer target size as percentage of the screen
    el.calibrationtargetwidth = 0.7;% Inner target size as percentage of the screen
    %     el.backgroundcolour = repmat(GrayIndex(screenNumber),1,3);
    el.backgroundcolour = repmat(BlackIndex(screenNumber),1,3);
    el.calibrationtargetcolour = repmat(GrayIndex(screenNumber),1,3);
    % set "Camera Setup" instructions text colour so it is different from background colour
    el.msgfontcolour = repmat(GrayIndex(screenNumber),1,3);

    % Initialize PsychSound for calibration/validation audio feedback
    % EyeLink Toolbox now supports PsychPortAudio integration and interop
    % with legacy Snd() wrapping. Below we open the default audio device in
    % output mode as master, create a slave device, and pass the device
    % handle to el.ppa_pahandle.
    % el.ppa_handle supports passing either standard mode handle, or as
    % below one opened as a slave device. When el.ppa_handle is empty, for
    % legacy support EyelinkUpdateDefaults() will open the default device
    % and use that with Snd() interop, and close the device handle when
    % calling Eyelink('Shutdown') at the end of the script.
    InitializePsychSound();
    pamaster = PsychPortAudio('Open', [], 8+1);
    PsychPortAudio('Start', pamaster);
    pahandle = PsychPortAudio('OpenSlave', pamaster, 1);
    el.ppa_pahandle = pahandle;

    % You must call this function to apply the changes made to the el structure above
    EyelinkUpdateDefaults(el);

    % Set display coordinates for EyeLink data by entering left, top, right and bottom coordinates in screen pixels
    Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, screenWidthPixels-1, screenHeightPixels-1);
    % Write DISPLAY_COORDS message to EDF file: sets display coordinates in DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Pre-trial Message Commands
    Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, screenWidthPixels-1, screenHeightPixels-1);
    % Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
    Eyelink('Command', 'calibration_type = HV5'); % horizontal-vertical 9-points   HV9
    % Allow a supported EyeLink Host PC button box to accept calibration or drift-check/correction targets via button 5
    Eyelink('Command', 'button_function 5 "accept_target_fixation"');
    % Hide mouse cursor
    %     HideCursor(window);
    % Suppress keypress output to command window.
    %     ListenChar(-1);
    Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
    % Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
    EyelinkDoTrackerSetup(el);


    %     START TRIAL; SHOW TRIAL INFO ON HOST PC; SHOW BACKDROP IMAGE AND/OR DRAW FEEDBACK GRAPHICS ON HOST PC; DRIFT-CHECK/CORRECTION

    % Write TRIALID message to EDF file: marks the start of a trial for DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Defining the Start and End of a Trial
    %         Eyelink('Message', 'TRIALID %d', i);

    % Write !V CLEAR message to EDF file: creates blank backdrop for DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Simple Drawing
    Eyelink('Message', '!V CLEAR %d %d %d', round(el.backgroundcolour(1)/colorMaxVal*255), round(el.backgroundcolour(2)/colorMaxVal*255), round(el.backgroundcolour(3)/colorMaxVal*255));

    % Supply the trial number as a line of text on Host PC screen
    %     Eyelink('Command', 'record_status_message "TRIAL %d/%d"', i, length(imgList));

    % Draw graphics on the EyeLink Host PC display. See COMMANDS.INI in the Host PC's exe folder for a list of commands
    Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode before drawing Host PC graphics and before recording
    Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
    % Optional: Send an image to the Host PC to be displayed as the backdrop image over which
    % the gaze-cursor is overlayed during trial recordings.
    % See Eyelink('ImageTransfer?') for information about supported syntax and compatible image formats.
    % Below, we use the new option to pass image data from imread() as the imageArray parameter, which
    % enables the use of many image formats.
    % [status] = Eyelink('ImageTransfer', imageArray, xs, ys, width, height, xd, yd, options);
    % xs, ys: top-left corner of the region to be transferred within the source image
    % width, height: size of region to be transferred within the source image (note, values of 0 will include the entire width/height)
    % xd, yd: location (top-left) where image region to be transferred will be presented on the Host PC
    % This image transfer function works for non-resized image presentation only. If you need to resize images and use this function please resize
    % the original image files beforehand
    % Capture the window content as an image
    %     imageArray = Screen('GetImage', window, windowRect, 'backBuffer');
    %     imwrite(imageArray, 'captured_image.png');
    %     imshow('captured_image.png');


    % Transfer the captured image to the EyeLink Host PC
    %     transferStatus = Eyelink('ImageTransfer', imageArray, 0, 0, 0, 0, 0, 0);

    %     transferStatus = Eyelink('ImageTransfer', stimArray, 0, 0, 0, 0, 0, 0);
    %     if dummymode == 0 && transferStatus ~= 0 % If connected to EyeLink and image transfer fails
    %         fprintf('Image transfer Failed\n'); % Print some text in Matlab's Command Window
    %     end

    % Optional: draw feedback box and lines on Host PC interface instead of (or on top of) backdrop image.
    % See section 25.7 'Drawing Commands' in the EyeLink Programmers Guide manual
    Eyelink('Command', 'draw_box %d %d %d %d 15', eye.fixationWindow(1), eye.fixationWindow(2), eye.fixationWindow(3), eye.fixationWindow(4)); % Fixation window
    Eyelink('Command', 'draw_cross %d %d 15 ', screenWidthPixels/2, screenHeightPixels/2); % Central crosshairs

    % Perform a drift check/correction.
    % Optionally provide x y target location, otherwise target is presented on screen centre
    EyelinkDoDriftCorrection(el, round(screenWidthPixels/2), round(screenHeightPixels/2));

    %STEP 5.3: START RECORDING

    % Put tracker in idle/offline mode before recording. Eyelink('SetOfflineMode') is recommended
    % however if Eyelink('Command', 'set_idle_mode') is used allow 50ms before recording as shown in the commented code:
    % Eyelink('Command', 'set_idle_mode');% Put tracker in idle/offline mode before recording
    % WaitSecs(0.05); % Allow some time for transition
    Eyelink('SetOfflineMode');% Put tracker in idle/offline mode before recording
    Eyelink('StartRecording'); % Start tracker recording
    WaitSecs(0.1); % Allow some time to record a few samples before presenting first stimulus

    % STEP 5.4: PRESENT CROSSHAIRS; WAIT FOR GAZE INSIDE WINDOW OR FOR KEYPRESS

    % Check which eye is available online. Returns 0 (left), 1 (right) or 2 (binocular)
    eyeUsed = Eyelink('EyeAvailable');
    % Get events from right eye if binocular
    if eyeUsed == 2
        eyeUsed = 1;
    end


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

    if isEyelink
        Eyelink('Message','BLOCKID %d',block);
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
        fixDriftFrame = 0;
        isOutFixationWindowFrame = 0;

        % Add jittering to maxPhaseShift   Random pixel shift between -5 and 5 pixel
        %         jitterAmount(block,trial) = 0;   %floor(rand * 10) - 5;

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

            while i <= gratDuraFrame

                if isEyelink
                    % Write message to EDF file to mark the start time of stimulus presentation.
                    Eyelink('Message', 'STIM_ONSET');
                    Eyelink('Message','TRIALID %d',trial);

                    bufferStart = GetSecs; % Start a ~100ms counter

                    % STEP 5.4: PRESENT CROSSHAIRS; WAIT FOR GAZE INSIDE WINDOW OR FOR KEYPRESS

                    % Present central crosshairs on a grey background
                    %         Screen('DrawTexture', window, backgroundTexture); % Prepare background texture on backbuffer
                    Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
                    %         Screen('DrawLine', window, 0, round(screenWidthPixels/2-20), round(screenHeightPixels/2), round(screenWidthPixels/2+20), round(screenHeightPixels/2), 5);
                    %         Screen('DrawLine', window, 0, round(screenWidthPixels/2), round(screenHeightPixels/2-20), round(screenWidthPixels/2), round(screenHeightPixels/2+20), 5);
                    [~, gazeWinStart] = Screen('Flip', window); % Present crosshairs. Start timer for fixation window
                    % Write message to EDF file to mark the crosshairs presentation time.
                    Eyelink('Message', 'CROSSHAIRS');
                    % Write messages to EDF: prepare backdrop and draw central crosshairs in DataViewer
                    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Simple Drawing
                    Eyelink('Message', '!V CLEAR %d %d %d', round(el.backgroundcolour(1)/colorMaxVal*255), round(el.backgroundcolour(2)/colorMaxVal*255), round(el.backgroundcolour(3)/colorMaxVal*255));
                    Eyelink('Message', '!V DRAWLINE 0 0 0 %d %d %d %d', round(screenWidthPixels/2-20), round(screenHeightPixels/2), round(screenWidthPixels/2+20), round(screenHeightPixels/2));
                    Eyelink('Message', '!V DRAWLINE 0 0 0 %d %d %d %d', round(screenWidthPixels/2), round(screenHeightPixels/2-20), round(screenWidthPixels/2), round(screenHeightPixels/2+20));
                    % Write !V IAREA message to EDF file: creates fixation window interest areas in DataViewer
                    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Interest Area Commands
                    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, fixationWindow(1), fixationWindow(2), fixationWindow(3), fixationWindow(4),'FIXWINDOW_IA');
                    fixWinComplete = 'yes'; % Reset variable for gaze maintained inside fixation window successfully
                    while 1 % loop until error or space bar press
                        % Check tracker is  still recording, otherwise close and transfer copy of EDF file to Display PC
                        err = Eyelink('CheckRecording');
                        if(err ~= 0)
                            fprintf('EyeLink Recording stopped!\n');
                            % Transfer a copy of the EDF file to Display PC
                            Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode
                            Eyelink('CloseFile'); % Close EDF file on Host PC
                            Eyelink('Command', 'clear_screen 0'); % Clear trial image on Host PC at the end of the experiment
                            WaitSecs(0.1); % Allow some time for screen drawing
                            % Transfer a copy of the EDF file to Display PC
                            transferFile; % See transferFile function below
                            cleanup; % Abort experiment (see cleanup function below)
                            return
                        end
                        % Check if a new sample is available online via the link.
                        % This is equivalent to eyeLink_newest_float_sample() in C API. See EyeLink Programmers Guide manual > Function Lists > Message and Command Sending/Receiving > Functions
                        if Eyelink('NewFloatSampleAvailable') > 0
                            % Get sample data in a Matlab structure
                            % This is equivalent to eyeLink_newest_float_sample() in C API. See EyeLink Programmers Guide manual > Function Lists > Message and Command Sending/Receiving > Functions
                            evt = Eyelink('NewestFloatSample');
                            % Save sample properties as variables. See EyeLink Programmers Guide manual > Data Structures > FSAMPLE
                            x_gaze = evt.gx(eyeUsed+1); % [left eye gaze x, right eye gaze x] +1 as we're accessing an array
                            y_gaze = evt.gy(eyeUsed+1); % [left eye gaze y, right eye gaze y]


                            if isWithinFixationWindow(x_gaze, y_gaze, xCenter, yCenter, fixWinSize)
                                %                             gazeRect=[ x-9 y-9 x+10 y+10];
                                %                             %                     fixationcolour=round(rand(3,1)*255); % coloured dot
                                %                             fixationcolour = greycolor + 5;
                                %                             Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
                                % %                             Screen('FillOval', wptr, fixationcolour, gazeRect);
                                %                             Screen('Flip',wptr);
                            elseif  isOutFixationWindowFrame <= gratDuraFrame  % fixateTime * refreshRate
                                fixDriftFrame = fixDriftFrame + 1;
                                isOutFixationWindowFrame  = fixDriftFrame;
                            elseif isOutFixationWindowFrame  > gratDuraFrame  % fixateTime * refreshRate
                                isOutFixationWindowTimes = isOutFixationWindowTimes + 1;
                                isOutFixationWindowTimesMat = [isOutFixationWindowTimes;    isOutFixationWindowTimesMat];
                                sprintf('Gaze is outside fixation window during block %d  trial  %d\n',  block, trial)
                                validTrialFlag = 0;  % the whole block was abandoned
                                break;
                            end



                            %                         if inFixWindow(x_gaze,y_gaze,fixationWindow) % If gaze sample is within fixation window (see inFixWindow function below)
                            %                             if (GetSecs - gazeWinStart)*1000 >= fixateTime % If gaze duration >= minimum fixation window time (fxateTime)
                            %                                 break; % break while loop to show stimulus
                            %                             end
                            %                         elseif ~inFixWindow(x_gaze,y_gaze,fixationWindow) % If gaze sample is not within fixation window
                            %                             %                                 gazeWinStart = GetSecs; % Reset fixation window timer
                            %                             validTrialFlag = 0;
                            %                             break;
                            %
                            %                         end
                        end
                        % Wait for space bar to end crosshairs if participant is unable to maintain gaze inside window for duration 'fixateTime'
                        [~, ~, keyCode] = KbCheck;
                        if keyCode(KbName('Space'))
                            % Write message to EDF file to mark the space bar press time
                            Eyelink('Message', 'FIXATION_KEY_PRESSED');
                            fixWinComplete = 'no'; % Update variable for gaze not maintained inside window
                            break; % break while loop to show stimulus
                        end
                    end % End of gaze-checking while loop
                end

                c = 3


                flashPresentFlag = 0;
                % No motion condition, keep phaseShift constant

                % Update phaseShift based on motion direction
                phaseShift = phaseShift + flash.MotDirecMat(trial) * phaseSpeed;
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

                %             % Reset the phaseShift to create continuous motion
                %                 if phaseShift >= flash.maxPhaseShiftMat(trial) | phaseShift <= - flash.maxPhaseShiftMat(trial)
                %                     phaseSpeed = - phaseSpeed; % Reverse the direction of motion
                %                     phaseShiftCheck(trial) = phaseShift;
                %                 end

                %                 flash.maxPhaseShiftPix = [159.5000  199.5000]

                if flash.MotDirecMat(trial) == - 1  &&  flash.maxPhaseShiftMat(trial) == flash.maxPhaseShiftPix(1) && phaseShift <= - flash.maxPhaseShiftPix(1)
                    alignPhaseShift = - phaseShift;
                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * alignPhaseShift  * sind(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * alignPhaseShift * cosd(45);

                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    phaseShiftMat(block,trial) = alignPhaseShift;
                    flashPresentFlag = 1;
                    phaseSpeed = - phaseSpeed;

                elseif  flash.MotDirecMat(trial) == 1  &&  flash.maxPhaseShiftMat(trial) == flash.maxPhaseShiftPix(1) &&  phaseShift >= (4 * cycleWidthPix - flash.maxPhaseShiftPix(1))
                    % Draw the rotated red bar only when the direction changes to inward
                    alignPhaseShift = 4 * cycleWidthPix - phaseShift;
                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * alignPhaseShift  * sind(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * alignPhaseShift * cosd(45);

                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    phaseShiftMat(block,trial) = alignPhaseShift;
                    phaseSpeed = - phaseSpeed;
                    flashPresentFlag = 1;

                elseif flash.MotDirecMat(trial) == - 1  &&  flash.maxPhaseShiftMat(trial) == flash.maxPhaseShiftPix(2) && phaseShift <= - flash.maxPhaseShiftPix(2)

                    alignPhaseShift = - phaseShift;
                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * alignPhaseShift  * sind(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * alignPhaseShift * cosd(45);

                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    phaseShiftMat(block,trial) = alignPhaseShift;
                    phaseSpeed = - phaseSpeed;
                    flashPresentFlag = 1;

                elseif  flash.MotDirecMat(trial) == 1  &&  flash.maxPhaseShiftMat(trial) == flash.maxPhaseShiftPix(2) &&  phaseShift >= (4 * cycleWidthPix - flash.maxPhaseShiftPix(2))
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
        elseif flash.MotDirecMat(trial) == 0

            if flash.maxPhaseShiftMat(trial) == flash.maxPhaseShiftPix(1)
                phaseShift = - flash.maxPhaseShiftPix(1);
            elseif flash.maxPhaseShiftMat(trial) == flash.maxPhaseShiftPix(2)
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
        probe.CenterPosX(block,trial) = flash.CenterPosX(block,trial) + phaseshiftFactorX * probe.shiftPixMat(trial) * sind(45);
        probe.CenterPosY(block,trial) = flash.CenterPosY(block,trial) + phaseshiftFactorY * probe.shiftPixMat(trial) * cosd(45);

        % Find all keyboards (returns a device index for each keyboard)
        [keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
        % Start a loop to check for key presses
        respToBeMade = true;
        if validTrialFlag == 1
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
                            fprintf(['Miss flash block number: %d\n','trial number: %d\n'],block,trial);
                            respToBeMade = false;
                        elseif keyCode(KbName('Space'))
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


                Screen('DrawTexture',window,probe.Texture,[],probe.DestinationRect,target.Angle); % flash.Rect
                Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);

                Screen('Flip', window);
                % add a small pause to prevent CPU overloading
                WaitSecs(0.01);
            end
        end
        probe.PosXMat(block,trial) = probe.CenterPosX(block,trial)  + probe.TempX;
        probe.PosYMat(block,trial) = probe.CenterPosY(block,trial)  + probe.TempY;


        if validTrialFlag == 0
            trial = trial;
        elseif validTrialFlag == 1
            trial = trial + 1;
        end

    end

end

if isEyelink

    % Write message to EDF file to mark time when blank screen is presented
    Eyelink('Message', 'BLANK_SCREEN');
    % Write !V CLEAR message to EDF file: creates blank backdrop for DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Simple Drawing
    Eyelink('Message', '!V CLEAR %d %d %d', round(el.backgroundcolour(1)/colorMaxVal*255), round(el.backgroundcolour(2)/colorMaxVal*255), round(el.backgroundcolour(3)/colorMaxVal*255));

    % Stop recording eye movements at the end of each trial
    WaitSecs(0.1); % Add 100 msec of data to catch final events before stopping
    Eyelink('StopRecording'); % Stop tracker recording

    fprintf('EyeLink Recording stopped!\n');
    % Transfer a copy of the EDF file to Display PC
    Eyelink('SetOfflineMode');% Put tracker in idle/offline mode
    Eyelink('CloseFile'); % Close EDF file on Host PC
    Eyelink('Command', 'clear_screen 0'); % Clear trial image on Host PC at the end of the experiment
    WaitSecs(0.1); % Allow some time for screen drawing
    % Transfer a copy of the EDF file to Display PC
    transferFile; % See transferFile function below
    cleanup; % Abort experiment (see cleanup function below)
end

ShowCursor(window);

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

%----------------------------------------------------------------------
%                 eye tracker functions
%----------------------------------------------------------------------

% Function that determines if gaze x y coordinates are within fixation window
function fix = inFixWindow(mx,my,fixationWindow)
fix = mx > fixationWindow(1) &&  mx <  fixationWindow(3) && ...
    my > fixationWindow(2) && my < fixationWindow(4) ;
end

% Cleanup function used throughout the script above
function cleanup
sca; % PTB's wrapper for Screen('CloseAll') & related cleanup, e.g. ShowCursor
Eyelink('Shutdown'); % Close EyeLink connection
ListenChar(0); % Restore keyboard output to Matlab
if ~IsOctave; commandwindow; end % Bring Command Window to front
end

% Function for transferring copy of EDF file to the experiment folder on Display PC.
% Allows for optional destination path which is different from experiment folder
function transferFile
try
    if dummymode ==0 % If connected to EyeLink
        % Show 'Receiving data file...' text until file transfer is complete
        Screen('FillRect', window, el.backgroundcolour); % Prepare background on backbuffer
        Screen('DrawText', window, 'Receiving data file...', 5, height-35, 0); % Prepare text
        Screen('Flip', window); % Present text
        fprintf('Receiving data file ''%s.edf''\n', edfFile); % Print some text in Matlab's Command Window

        % Transfer EDF file to Host PC
        % [status =] Eyelink('ReceiveFile',['src'], ['dest'], ['dest_is_path'])
        status = Eyelink('ReceiveFile');

        % Check if EDF file has been transferred successfully and print file size in Matlab's Command Window
        if status > 0
            fprintf('EDF file size: %.1f KB\n', status/1024); % Divide file size by 1024 to convert bytes to KB
        end
        % Print transferred EDF file path in Matlab's Command Window
        fprintf('Data file ''%s.edf'' can be found in ''%s''\n', edfFile, pwd);
    else
        fprintf('No EDF file saved in Dummy mode\n');
    end
    cleanup;
catch % Catch a file-transfer error and print some text in Matlab's Command Window
    fprintf('Problem receiving data file ''%s''\n', edfFile);
    cleanup;
    psychrethrow(psychlasterror);
end
end

function isWithin = isWithinFixationWindow(x, y, fixX, fixY, fixRadius)
distance = sqrt((x-fixX)^2 + (y-fixY)^2);
isWithin = distance <= fixRadius;
end
