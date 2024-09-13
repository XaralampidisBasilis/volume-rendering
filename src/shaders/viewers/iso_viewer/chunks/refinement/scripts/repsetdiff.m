function [output] = repsetdiff(A,B)

    output = A;
    
   % Step 1: Loop through elements of B and remove occurrences from A
    for i = 1:length(B)
        
        % Check if the current element in B exists in A
        idx = find(ismember(output, B(i)), 1);  % Find the first occurrence of B(i) in A
        
        if ~isempty(idx)
            % Remove that occurrence from A
            output(idx) = [];  % Remove that element from A
        end
    end

end

