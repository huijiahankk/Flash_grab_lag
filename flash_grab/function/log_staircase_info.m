function log_staircase_info(block, trial, quad, motionDirec, responseCorrect, staircase, staircase_name)
    fprintf(['Block %d, Trial %d: Quad = %d, Mot = %d, responseCorrect = %d\n' ...
        '%s.reversals = %d, %s.stimuluslevel = %.f\n ' ...
        '%s.direction = %d, %s.correctResponses = %d\n %s.step = %d\n'], ...
        block, trial, quad, motionDirec, responseCorrect, ...
        staircase_name, staircase.reversals, ...
        staircase_name, staircase.stimuluslevel, ...
        staircase_name, staircase.direction, ...
        staircase_name, staircase.correctResponses, ...
        staircase_name, staircase.step);
end
