% Function to initialize staircase
function staircase = initialize_staircase(start, step, minimumStepSize,reversalLimit, staircasedirection,correctResponses,incorrectResponses)
%     staircase.start = start;            % Initial value    
    staircase.stimuluslevel = start;          % Current stimulus level
    staircase.minimumStepSize = minimumStepSize; % Ensure step size does not become too small
    staircase.step = step;              % Step size
    staircase.correctResponses = correctResponses; % how many correct response needed to reverse the staircase
    staircase.incorrectResponses = incorrectResponses; % how many incorrect response needed to reverse the staircase
%     staircase.ignoreCorrect = false; % gets activated when the correct response threshold is met
    staircase.reversals = 0;    % Initial number of reversals
    staircase.reversal_limit = reversalLimit;   % Maximum allowed reversals
    staircase.direction = staircasedirection;    % Initial direction (-1: decrease, 1: increase)
    staircase.progression = [];         % To log the steps
    staircase.actualOffsets = []; % actual offset from the flash to the probe, positive means close to peripheral and negtive means close to the fovea
end