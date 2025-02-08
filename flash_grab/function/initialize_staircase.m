% Function to initialize staircase
function staircase = initialize_staircase(start, step, initialreversals, limit, staircasedirection,correctResponses,incorrectResponses)
%     staircase.start = start;            % Initial value    
    staircase.stimuluslevel = start;          % Current stimulus level
    staircase.minimumStepSize = 2;
    staircase.step = step;              % Step size
    staircase.correctResponses = correctResponses; % how many correct response needed to reverse the staircase
    staircase.incorrectResponses = incorrectResponses; % how many incorrect response needed to reverse the staircase
    staircase.reversals = initialreversals;    % Initial number of reversals
    staircase.reversal_limit = limit;   % Maximum allowed reversals
    staircase.direction = staircasedirection;    % Initial direction (-1: decrease, 1: increase)
    staircase.progression = [];         % To log the steps
end