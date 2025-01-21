clear all;
addpath '../function';

sbjnames = {'4block5probelocation'};  % Add more subject names as needed
dataPath = '../data/Psychometric_curve';
cd(dataPath);

for sbjnum = 1:length(sbjnames)
    s1 = sbjnames{sbjnum};
    s2 = '*.mat';
    s3 = strcat(s1, s2);
%     Files = dir(fullfile(dataPath, s3{1}));
     Files = dir(s3);
    
    if isempty(Files)
        warning('No files found for subject %s.', s1);
        continue;
    end
    
    load(Files.name);
    
    % Flatten the response matrix
    responseMatVecAll = responseMat(:);  % Flatten to a column vector
    
    % Identify valid trials (assuming invalid trials are marked with NaN)
    validIndices = ~isnan(responseMatVecAll);
    
    % Filter the response vector to include only valid trials
    responseMatVec = responseMatVecAll(validIndices);
    
    % Number of blocks and trials
    [numBlocks, numTrials] = size(responseMat);
    
    % Ensure condition variables are column vectors
    flashQuadMat = flash.QuadMat(:);
    flashMotDirecMat = flash.MotDirecMat(:);
    probeShiftPixMat = probe.shiftPixMat(:);
    flashMaxPhaseShiftMat = flash.maxPhaseShiftMat(:);
    
    % Replicate condition variables across blocks and flatten
    flashQuadMatVecAll = repmat(flashQuadMat, numBlocks, 1);
    flashMotDirecMatVecAll = repmat(flashMotDirecMat, numBlocks, 1);
    probeShiftPixMatVecAll = repmat(probeShiftPixMat, numBlocks, 1);
    flashMaxPhaseShiftMatVecAll = repmat(flashMaxPhaseShiftMat, numBlocks, 1);
    
    % Flatten the condition variables
    flashQuadMatVecAll = flashQuadMatVecAll(:);
    flashMotDirecMatVecAll = flashMotDirecMatVecAll(:);
    probeShiftPixMatVecAll = probeShiftPixMatVecAll(:);
    flashMaxPhaseShiftMatVecAll = flashMaxPhaseShiftMatVecAll(:);
    
    % Filter the condition variables to include only valid trials
    flashQuadMatVec = flashQuadMatVecAll(validIndices);
    flashMotDirecMatVec = flashMotDirecMatVecAll(validIndices);
    probeShiftPixMatVec = probeShiftPixMatVecAll(validIndices);
    flashMaxPhaseShiftMatVec = flashMaxPhaseShiftMatVecAll(validIndices);
    
    % Verify that all vectors are of the same length
    assert(length(responseMatVec) == length(flashQuadMatVec), 'Vector lengths are not equal.');
    
    % Convert probe.shiftPixMat to degrees of visual angle
    probeShiftDvaMatVec = pix2dva(probeShiftPixMatVec, eyeScreenDistence, windowRect, screenHeight);
    
    % Convert maxPhaseShiftMatVec to labels 'near' and 'far'
    maxPhaseShiftLabels = cell(size(flashMaxPhaseShiftMatVec));
    for i = 1:length(flashMaxPhaseShiftMatVec)
        if flashMaxPhaseShiftMatVec(i) == flash.maxPhaseShiftPix(1)
            maxPhaseShiftLabels{i} = 'near';
        elseif flashMaxPhaseShiftMatVec(i) == flash.maxPhaseShiftPix(2)
            maxPhaseShiftLabels{i} = 'far';
        else
            maxPhaseShiftLabels{i} = 'unknown';
        end
    end
    
    % Convert maxPhaseShiftLabels to categorical array
    maxPhaseShiftCategories = categorical(maxPhaseShiftLabels);
    
    % Get unique values
    shiftValues = unique(probeShiftDvaMatVec);
    motDirecValues = unique(flashMotDirecMatVec);
    maxPhaseShiftValues = categories(maxPhaseShiftCategories);
    
    % Initialize responseRight
    responseRight = zeros(size(responseMatVec));
    
    % Assign responseRight based on conditions
    quad45or135 = flashQuadMatVec == 45 | flashQuadMatVec == 135;
    quad225or315 = flashQuadMatVec == 225 | flashQuadMatVec == 315;
    
    % Assign responses
    responseRight(quad45or135) = responseMatVec(quad45or135);
    responseRight(quad225or315) = 1 - responseMatVec(quad225or315);
    
    % Initialize a figure
    figure;
    hold on;
    
    % Define colors and markers
    colors = {'r', 'b', 'g', 'k', 'm', 'c', 'y'}; % Define colors for plotting
    markers = {'o', 's', 'd', '^', 'v', '>', '<'}; % Markers for different lines
    
    legendEntries = {}; % To store legend entries
    
    % Define the logistic function
    logisticFun = @(b, x) 1 ./ (1 + exp(-(x - b(1))/b(2)));
    
    % Define parameter bounds for lsqcurvefit
    lb = [-Inf, 0.1];   % alpha can be any value, beta should be positive and not too small
    ub = [Inf, 100];    % beta upper limit to prevent extremely large slopes
    
    % Initialize storage for fitted parameters (optional)
    fittedParams = struct();
    
    % Counter for colors and markers
    colorIndex = 1;
    markerIndex = 1;
    
    % Loop over MotDirec values
    for md = 1:length(motDirecValues)
        motDirec = motDirecValues(md);
        
        % Loop over maxPhaseShift categories
        for mps = 1:length(maxPhaseShiftValues)
            maxPhaseShiftLabel = maxPhaseShiftValues{mps}; % 'near' or 'far'
            
            % Get indices of trials matching current MotDirec and maxPhaseShift
            conditionIndices = flashMotDirecMatVec == motDirec & maxPhaseShiftCategories == maxPhaseShiftLabel;
            
            % Extract the probe shifts and responses for this condition
            xData = probeShiftDvaMatVec(conditionIndices);
            yData = responseRight(conditionIndices);
            
            % Check if data is sufficient for fitting
            if sum(conditionIndices) < 5
                fprintf('Not enough data points for MotDirec = %d, PhaseShift = %s. Skipping fit.\n', ...
                    motDirec, char(maxPhaseShiftLabel));
                % Plot the data points without fitting
                uniqueShifts = unique(xData);
                percentRight = zeros(length(uniqueShifts),1);
                for sv = 1:length(uniqueShifts)
                    shift = uniqueShifts(sv);
                    shiftIndices = xData == shift;
                    percentRight(sv) = mean(yData(shiftIndices)) * 100;
                end
                plot(uniqueShifts, percentRight, 'LineStyle', 'none', 'Color', colors{colorIndex}, ...
                    'Marker', markers{markerIndex}, 'MarkerSize', 8);
                legendEntries{end+1} = sprintf('MotDirec=%d, PhaseShift=%s', motDirec, char(maxPhaseShiftLabel));
                % Update color and marker indices
                colorIndex = colorIndex + 1;
                markerIndex = markerIndex + 1;
                if colorIndex > length(colors)
                    colorIndex = 1; % Wrap around colors
                end
                if markerIndex > length(markers)
                    markerIndex = 1; % Wrap around markers
                end
                continue;
            end
            
            % Convert binary responses to proportions
            % Not necessary since glmfit handles it
            
            % Initial parameter guesses
            alpha0 = mean(xData); %median(xData); % Start with median as initial threshold
            beta0 = 1;              % Initial guess for slope
            
            % Fit using lsqcurvefit
            try
                [beta, resnorm, residual, exitflag, output] = lsqcurvefit(logisticFun, [alpha0, beta0], xData, yData, lb, ub);
                fittedParams(md, mps).alpha = beta(1);
                fittedParams(md, mps).beta = beta(2);
                
                % Generate x values for plotting the fitted curve
                xFit = linspace(min(xData), max(xData), 100);
                yFit = logisticFun(beta, xFit) * 100;  % Convert to percentage
                
                % Plot the fitted curve
                plot(xFit, yFit, 'Color', colors{colorIndex}, 'LineWidth', 2);
            catch ME
                warning('Fitting failed for MotDirec = %d, PhaseShift = %s. Error: %s', ...
                    motDirec, char(maxPhaseShiftLabel), ME.message);
            end
            
            % Calculate empirical percentages for plotting
            uniqueShifts = unique(xData);
            percentRight = zeros(length(uniqueShifts),1);
            for sv = 1:length(uniqueShifts)
                shift = uniqueShifts(sv);
                shiftIndices = xData == shift;
                percentRight(sv) = mean(yData(shiftIndices)) * 100;
            end
            
            % Plot the data points
            plot(uniqueShifts, percentRight, 'LineStyle', 'none', 'Color', colors{colorIndex}, ...
                'Marker', markers{markerIndex}, 'MarkerSize', 8);
            
            % Create legend entry
            legendEntry = sprintf('MotDirec=%d, PhaseShift=%s', motDirec, char(maxPhaseShiftLabel));
            legendEntries{end+1} = legendEntry;
            
            % Update color and marker indices
            colorIndex = colorIndex + 1;
            markerIndex = markerIndex + 1;
            if colorIndex > length(colors)
                colorIndex = 1; % Wrap around colors
            end
            if markerIndex > length(markers)
                markerIndex = 1; % Wrap around markers
            end
        end
    end
    
    xlabel('Probe Shift (deg)');
    ylabel('Percent Response Right (%)');
    title('Psychometric Curves with Fitted Logistic Functions');
    legend(legendEntries, 'Location', 'Best');
    grid on;
    hold off;
    
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
