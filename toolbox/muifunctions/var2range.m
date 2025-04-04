function rangetext = var2range(rangevar,pretext)
%
%-------function help------------------------------------------------------
% NAME
%   var2range.m
% PURPOSE
%   convert start and end variable to a range character array
% USAGE
%   rangetext = var2range(rangevar,pretext)
% INPUT
%   rangevar - cell array of values to define start and end of range. If a
%              vector of more than 2 values the first and last values used
%   pretext - text to precede the range text
% OUTPUT
%   rangetext - range character array in format From > xxx To > yyy
% SEE ALSO
%   used in muiDataUI
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    nvar = length(rangevar);
    if nvar>2           %select start and end values if a vector
        if iscell(rangevar)
            rangevar = {rangevar{1},rangevar{end}};
        else
            if isnumeric(rangevar)
                id1 = find(~isnan(rangevar),1,"first"); %check for NaN at front of vector
                id2 = find(~isnan(rangevar),1,"last");  %check for NaN at end of vector
            else
                id1 = 1; id2 = length(rangevar);
            end
            rangevar = {rangevar(id1),rangevar(id2)};
        end
    elseif nvar==2 && ~iscell(rangevar)
        rangevar = {rangevar(1),rangevar(2)};
    elseif nvar==1
        rangevar{2} = rangevar{1};   %single row or dimension
    elseif isempty(nvar)
        rangetext = []; return;      %no range set
    end
    
    var1 = rangevar{1}; var2 = rangevar{2};
    if isinteger(var1) || islogical(var1)
        rangetext = sprintf('From > %d To > %d',var1,var2);
    elseif isnumeric(var1)
        rangetext = sprintf('From > %g To > %g',var1,var2);
    elseif isdatetime(var1) || isduration(var1) || ...
           iscalendarduration(var1) || ...
           ischar(var1) || isstring(var1) || iscategorical(var1)
        rangetext = sprintf('From > %s To > %s',var1,var2);
    else
        warndlg('Unrecognised input format in var2range.m')
        rangetext = [];
        return
    end
    %add any explanatory text in front of range if included
    if nargin>1
        rangetext = sprintf('%s %s',pretext,rangetext);
    end  
end