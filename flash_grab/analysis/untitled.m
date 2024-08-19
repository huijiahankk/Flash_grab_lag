% Assuming reshapedCellArray is the given 2D cell array of size 54x3

% Initialize an empty matrix to store the values (162 rows, 4 columns)
outputMatrix = NaN(54 * 3, 4);  % 54 * 3 = 162 rows

% Loop through each cell and extract the values
for i = 1:54
    for j = 1:3
        % Extract the 1x4 matrix from the cell
        tempMatrix = reshapedCellArray{i, j};
        
        % Calculate the row index for the current set of 4 values
        rowIndex = (i-1) * 3 + j;
        
        % If the cell is empty or not 1x4, fill with NaN
        if isempty(tempMatrix) || numel(tempMatrix) ~= 4
            outputMatrix(rowIndex, :) = NaN(1, 4);  % Fill with NaN
        else
            % Store the extracted values into the output matrix
            outputMatrix(rowIndex, :) = tempMatrix;
        end
    end
end

% Display the resulting matrix
disp(outputMatrix);

% Export the matrix to Excel
xlswrite('OutputData.xlsx', outputMatrix);
