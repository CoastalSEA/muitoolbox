function output_table = cleantable(~,input_table)
%
%-------function help------------------------------------------------------
% NAME
%   cleantable.m
% PURPOSE
%   clean table by checking numeric data are not cells and 
%   replacing non-standard values
% USAGE
%   input_table - table to be cleaned
% INPUT
%   output_table - table that has been checked for numeric data in cells
%                  with all non-standard values adjusted
%
% Author: Ian Townend
% CoastalSEA (c) Dec 2020
%--------------------------------------------------------------------------
%
    nvars = width(input_table);
    for i=1:nvars   %find numeric values in cells and check for empty cells
        if iscell(input_table{1,i}) && isnumeric(input_table{1,i}{1})
            temp = input_table{:,i};                    
            idx = cellfun(@isempty,temp);
            idx = find((idx));
            for j=1:length(idx)
               temp{idx(j)} = NaN; 
            end
            output_table.(i) = cell2mat(temp);
        end
    end

    %prompt user for indicators and replace with standard values
    prompt = 'Nonstandard missing-value indicator';
    title = 'Table input';
    numlines = 1;
    propdefault = {'N/A 99'};
    answer = inputdlg(prompt,title,numlines,propdefault);
    if isempty(answer), return; end
    answer = strsplit(answer{1},' ');
    for i=1:length(answer)
        if ~isletter(answer{i})
            answer{i} = str2double(answer{i});
        end
    end
    output_table = standardizeMissing(output_table,answer);
end
