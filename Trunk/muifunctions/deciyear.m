function dyr = deciyear(date)
%
%-------function help------------------------------------------------------
% NAME
%   deciyear.m
% PURPOSE
%   convert datetimes or date strings to decimal years
% USAGE
%   dyr = deciyear(date)
% INPUT
%   date - datetime vector, or dates as cell array, string array or charachter vector 
% OUTPUT
%   dyr - dates as an array of decimal years
% NOTES
%   Based on code by Walter Robinson in the Matlab Forum
%   https://uk.mathworks.com/matlabcentral/answers/825540-conversion-of-gregorian-date-to-decimal-years?s_tid=srchtitle
% EXAMPLE
%     DT = datetime('2016-07-29 10:05:24') + calmonths(0:10:30);
%     CT = cellstr(DT);
%     ST = string(CT);
% 
%     dyr1 = deciyear(DT);
%     dyr2 = deciyear(CT);
%     dyr3 = deciyear(ST);
%
% Author: Ian Townend
% CoastalSEA (c)Oct 2021
%--------------------------------------------------------------------------
%
    if isdatetime(date)
        t1 = date;
    elseif iscell(date) || ischar(date) || isstring(date)
        try
            t1 = datetime(date);
        catch
            warndlg('Unable to convert input to a datetime');
            dyr = [];
            return
        end
    end

    t2 = dateshift(t1, 'start', 'year');
    t3 = dateshift(t1, 'end', 'year');
    dyr = year(t1) + (t1-t2)./(t3-t2);
end
