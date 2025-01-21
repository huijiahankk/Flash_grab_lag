clear all;
addpath '../function';

sbjnames = {'4block5probelocation'};  % Add more subject names as needed
path = '../data/Psychometric_curve';
cd(path);

for sbjnum = 1:length(sbjnames)
    s1 = sbjnames{sbjnum};
    s2 = '*.mat';
    s3 = strcat(s1, s2);
    %     Files = dir(fullfile(path, s3{1}));
    Files = dir(s3);

    if isempty(Files)
        warning('No files found for subject %s.', s1);
        continue;
    end

    load(Files.name);

    % Get the number of blocks and trials
    [numBlocks, numTrials] = size(responseMat);

    % Define possible conditions
    motDirecValues = [-1, 0, 1];
    phaseShiftValues = [flash.maxPhaseShiftPix(1), flash.maxPhaseShiftPix(2)];
    phaseShiftLabels = {'near', 'far'};

    % Get unique probe shift values
    probeShiftValues = unique(probe.shiftPixMat);

    % Initialize a structure to hold counts
    counts = struct();

    % Initialize counts for each condition and probe shift
    for md = 1:length(motDirecValues)
        for ps = 1:length(phaseShiftValues)
            for pv = 1:length(probeShiftValues)
                counts(md, ps, pv).motDirec = motDirecValues(md);
                counts(md, ps, pv).phaseShift = phaseShiftValues(ps);
                counts(md, ps, pv).phaseShiftLabel = phaseShiftLabels{ps};
                counts(md, ps, pv).probeShift = probeShiftValues(pv);
                counts(md, ps, pv).numTrials = 0;
                counts(md, ps, pv).numRightResponses = 0;
            end
        end
    end

    % Loop over all blocks and trials
    for block = 1:numBlocks
        for trial = 1:numTrials
            % Get the response
            resp = responseMat(block, trial);
            % Check if the response is valid (not NaN)
            if ~isnan(resp)
                % Get the quadrant
                quad = flash.QuadMat(trial);
                % Get the motion direction
                motDirec = flash.MotDirecMat(trial);
                % Get the max phase shift
                maxPhaseShift = flash.maxPhaseShiftMat(trial);
                % Get the probe shift
                probeShift = probe.shiftPixMat(trial);
                % Find the indices for the current condition
                mdIndex = find(motDirecValues == motDirec);
                psIndex = find(phaseShiftValues == maxPhaseShift);
                pvIndex = find(probeShiftValues == probeShift);

                % Ensure indices are found
                if isempty(mdIndex) || isempty(psIndex) || isempty(pvIndex)
                    warning('Invalid condition encountered. Skipping trial.');
                    continue;
                end

                % Update the trial count for this condition and probe shift
                counts(mdIndex, psIndex, pvIndex).numTrials = counts(mdIndex, psIndex, pvIndex).numTrials + 1;

                % Determine if the response counts as 'right' based on the quadrant
                if quad == 45 || quad == 135
                    if resp == 1
                        counts(mdIndex, psIndex, pvIndex).numRightResponses = counts(mdIndex, psIndex, pvIndex).numRightResponses + 1;
                    end
                elseif quad == 225 || quad == 315
                    if resp == 0
                        counts(mdIndex, psIndex, pvIndex).numRightResponses = counts(mdIndex, psIndex, pvIndex).numRightResponses + 1;
                    end
                end
            end
        end
    end

    % Plotting the psychometric functions with fitted curves
    figure;
    hold on;


    colors = {'r', 'g', 'b', 'k', 'm', 'c', 'y'};  % Define colors for plotting
    markers = {'o', 's', 'd', '^', 'v', '>', '<'};  % Markers for different lines



    % Loop over each condition (all motion directions and phase shifts)
    for md = 1:length(motDirecValues)
        for ps = 1:length(phaseShiftValues)
            % Prepare arrays to hold probe shifts and percentages
            probeShifts = [];
            percentages = [];

            % Extract the data for the current condition
            for pv = 1:length(probeShiftValues)
                numTrials = counts(md, ps, pv).numTrials;
                numRight = counts(md, ps, pv).numRightResponses;
                if numTrials > 0
                    percentRight = (numRight / numTrials) * 100;
                    probeShifts(end+1) = counts(md, ps, pv).probeShift;
                    percentages(end+1) = percentRight;
                end
            end

            % Fit the logistic function using lsqcurvefit with bounds
            logisticFun = @(b, x) 1 ./ (1 + exp(-(x - b(1)) / b(2)));  % Define the logistic function
            % Initial guesses for parameters [slope, threshold]
            initialGuess = [1, mean(probeShifts)];
            % Fit the data using nlinfit
            beta = nlinfit(probeShifts, percentages, logisticFun, initialGuess);

            % Plot the data points
            plot(probeShifts, percentages, 'o', 'MarkerSize', 8, ...
                'DisplayName', sprintf('Data: MotDirec=%d, PhaseShift=%s', motDirecValues(md), phaseShiftLabels{ps}));

            % Plot the fitted curve
            xFit = linspace(min(probeShifts), max(probeShifts), 100);
            yFit = logisticFun(beta, xFit);
%             plot(xFit, yFit, 'r-', 'LineWidth', 2);

        end
    end


    % Set figure properties
    xlabel('Probe Shift (pixels)');
    ylabel('Percentage of "Right" Responses (%)');
    title('Psychometric Functions with Fitted Curves for All Conditions');
    legend('Location', 'Best');
    grid on;
    hold off;


    set(gcf, 'Color', 'w');

%     % (Optional) Display Fitted Parameters
%     disp('Fitted Parameters (alpha: threshold, beta: slope):');
%     for md = 1:length(motDirecValues)
%         for ps = 1:length(phaseShiftValues)
%             if isfield(fittedParams(md, ps), 'alpha')
%                 fprintf('MotDirec = %d, PhaseShift = %s: alpha = %.2f, beta = %.2f\n', ...
%                     motDirecValues(md), phaseShiftLabels{ps}, fittedParams(md, ps).alpha, fittedParams(md, ps).beta);
%             else
%                 fprintf('MotDirec = %d, PhaseShift = %s: Fit not available.\n', ...
%                     motDirecValues(md), phaseShiftLabels{ps});
%             end
%         end
%     end
end

% Function to convert pixels to degrees of visual angle
function degrees = pix2dva(pixels, eyeScreenDistance, windowRect, screenHeight)
% Calculate pixels per centimeter
pixelsPerCm = windowRect(4) / screenHeight;

% Calculate degrees per centimeter
degreesPerCm = 2 * atand(1 / (2 * eyeScreenDistance));

% Calculate degrees per pixel
degreesPerPixel = degreesPerCm / pixelsPerCm;

% Convert pixels to degrees
degrees = pixels * degreesPerPixel;
end
