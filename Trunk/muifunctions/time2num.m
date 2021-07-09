function timeout = time2num(timein)
%
%-------function help------------------------------------------------------
% NAME
%   time2num.m
% PURPOSE
%   convert datetime or duration to a numeric value (eg for plotting)   
% USAGE
%   timeout = time2num(timein)
% INPUT
%   timein - array of values to be checked
% OUTPUT
%   timeout - timein values converted to numeric values 
% SEE ALSO
% called by muiPlots
%   
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    if isdatetime(timein)
        startyear = year(timein(1));
        timeout = startyear+years(timein-datetime(startyear,1,1));
    else
        timeout = cellstr(timein);
        timeout = split(timeout);
        timeout = cellfun(@str2num,timeout(:,1));
    end
end