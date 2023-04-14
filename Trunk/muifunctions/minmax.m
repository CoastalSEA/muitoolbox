function mnmx = minmax(data,nanflag)
%
%-------function help------------------------------------------------------
% NAME
%   minmax.m
% PURPOSE
%   find max and min of multidimensional numeric or ordinal array
% USAGE
%   mnmx = minmax(data,nanflag)
% INPUTS
%   data - vector or array of ordinal categorical, or numeric data
%   nanflag - optional flag to 'includenan', default is 'omitnan'
% OUTPUT
%   mnmx - [1 x 2] array of minimum and maximum values across all dimensions
% NOTES
%   Matlab max and min function now include the 'all' option from R2018b
%   Function changed from original version in ModelUI to return min and max
% SEE ALSO
%   
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    if nargin<3
        nanflag = 'omitnan';
    end

    if iscell(data)
        if ischar(data{1})
            data = categories(categorical(data));
            mnmx{1} = data{1};
            mnmx{2} = data{end};
        end
    else
        mnmx(1) = min(data,[],'all',nanflag);  %Added in Matlab 2018b
        mnmx(2) = max(data,[],'all',nanflag);
    end
end
