function staircase = update_by_response_switch(staircase, currentResponse, lastResponse)
    if currentResponse ~= lastResponse
        staircase.direction = -staircase.direction;
        staircase.reversals = staircase.reversals + 1;
%         staircase.step = max(staircase.step / 1.3, staircase.minimumStepSize);
    end
    staircase.progression(end+1) = staircase.stimuluslevel;
    
    staircase.stimuluslevel = staircase.stimuluslevel + staircase.step * staircase.direction;
end
