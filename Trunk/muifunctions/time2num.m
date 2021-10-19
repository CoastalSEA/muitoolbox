function [timeout,format] = time2num(timein)
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
%   format - format of datatime or duration
% SEE ALSO
%   called by muiPlots and setfigslider
%   
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    if isdatetime(timein)
        startyear = year(timein(1));
        timeout = startyear+years(timein-datetime(startyear,1,1));
        format = timein.Format;
    else
        timeout = cellstr(timein);
        timeout = squeeze(split(timeout));
        if numel(timeout)==2 && iscolumn(timeout)
            %force column vector when timein is a single value
            timeout= timeout'; 
        end  
        format = timeout{1,2};
        timeout = cellfun(@str2num,timeout(:,1));
    end
end