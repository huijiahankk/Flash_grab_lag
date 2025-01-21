function staircase = update_staircase(staircase, responseCorrect, consecutiveCorrectThreshold)
    % Track consecutive correct responses
    if responseCorrect
        staircase.correctResponses = staircase.correctResponses + 1;
    else
        staircase.correctResponses = 0;  % Reset if response is incorrect
    end

    % Check if the threshold for correct responses is meet
    if staircase.correctResponses >= consecutiveCorrectThreshold
        % If direction is 1 (increasing), it means a reversal occurred
        if staircase.direction == 1
            staircase.reversals = staircase.reversals + 1;
        end
        % Switch direction to decreasing
        staircase.direction = -1; 
    elseif staircase.correctResponses == 0
        % Handle case for the first incorrect response, switch direction to increasing
        staircase.direction = 1;
    end

    % Adaptive step sizing based on reversals
    staircase.step = staircase.step / (1 + staircase.reversals * 0.5);

    % Update current stimulus level
    staircase.stimuluslevel = staircase.stimuluslevel + staircase.step * staircase.direction;

    % Log progression
    staircase.progression(end + 1) = staircase.stimuluslevel; % Log the current stimulus level
end
