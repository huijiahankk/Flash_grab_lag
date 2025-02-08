function staircase = update_staircase(staircase, responseCorrect, consecutiveCorrectThreshold,consecutiveinCorrectThreshold)
% Track consecutive correct responses
if responseCorrect
    staircase.correctResponses = staircase.correctResponses + 1;
else
    staircase.incorrectResponses = staircase.incorrectResponses + 1;
end

minimumStepSize = 2; % Ensure step size does not become too small

% Check if the threshold for correct responses is meet
if staircase.correctResponses >= consecutiveCorrectThreshold
    staircase.reversals = staircase.reversals + 1;
    % Switch direction
    staircase.direction = - staircase.direction;
    % reset correct response count numbers
    staircase.correctResponses = 0;

elseif staircase.incorrectResponses >= consecutiveinCorrectThreshold
    staircase.reversals = staircase.reversals + 1;
    % Switch direction
    staircase.direction = - staircase.direction;
    staircase.incorrectResponses = 0;
end

% % Adaptive step sizing based on reversals
% staircase.step = staircase.step / (1 + staircase.reversals * 0.2);
staircase.step = staircase.step / (1 + staircase.reversals * 0.2);

% Ensure step size does not become too small
staircase.step = max(staircase.step, staircase.minimumStepSize);

% Update current stimulus level
staircase.stimuluslevel = staircase.stimuluslevel + staircase.step * staircase.direction;

% Log progression
staircase.progression(end + 1) = staircase.stimuluslevel; % Log the current stimulus level
end
