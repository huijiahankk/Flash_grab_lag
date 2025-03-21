function staircase = update_staircase(trial,staircase, responseCorrect, consecutiveCorrectThreshold,consecutiveinCorrectThreshold,actualOffset,nonadaptiveTrialNum)


% Log progression
staircase.progression(end + 1) = staircase.stimuluslevel; % Log the current stimulus level
staircase.actualOffsets(end + 1) = actualOffset; % New field to store offsets

% Track consecutive correct responses
if responseCorrect % && ~staircase.ignoreCorrect
    staircase.correctResponses = staircase.correctResponses + 1;
elseif ~responseCorrect
    staircase.incorrectResponses = staircase.incorrectResponses + 1;
%     staircase.ignoreCorrect = false; % Allow listening to correct responses again
end


% Check if the threshold for correct responses is meet
if staircase.correctResponses >= consecutiveCorrectThreshold
    staircase.reversals = staircase.reversals + 1;

    % Switch direction
    staircase.direction = - staircase.direction;
    staircase.reversals = staircase.reversals + 1;

    % reset correct response count numbers
    staircase.correctResponses = 0;
%     staircase.ignoreCorrect = true; % Ignore further correct responses until an incorrect response occurs
    % % Adaptive step sizing based on reversals
    if trial >= nonadaptiveTrialNum
        staircase.step = staircase.step / 1.2;
    else
        staircase.step = staircase.step
    end

elseif staircase.incorrectResponses >= consecutiveinCorrectThreshold

    % Switch direction
    staircase.direction = - staircase.direction;
    staircase.reversals = staircase.reversals + 1;

    staircase.incorrectResponses = 0;
    staircase.ignoreCorrect = false; % Reset flag to listen to correct responses again
    % % Adaptive step sizing based on reversals
    if trial >= nonadaptiveTrialNum
        staircase.step = staircase.step / 1.2;
    else
        staircase.step = staircase.step
    end
    directionReversalFlag = 0;
end


% Ensure step size does not become too small
staircase.step = max(staircase.step, staircase.minimumStepSize);
staircase.stimuluslevel = staircase.stimuluslevel + staircase.step * staircase.direction;

end
