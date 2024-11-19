function isint = isallround(vals)
%
%-------function help------------------------------------------------------
% NAME
%   isallround.m
% PURPOSE
%   check whether vector of numbers or duration are are all round numbers
%   and may or may not be integer data types
% USAGE
%   isint = isallround(vals)
% INPUT
%   vals - array of values to be checked
% OUTPUT
%   isint - logical true if all values in the array are round numbers
% SEE ALSO
%   called in setslider and inputUI
%   
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    %check whether vector of numbers or duration are all integer values
    if islist(vals) || isdatetime(vals) || islogical(vals)
        isint = false;
    else
        if isduration(vals)
            vals = time2num(vals);
        end
        isint = all(mod(vals, 1) == 0);
    end
end