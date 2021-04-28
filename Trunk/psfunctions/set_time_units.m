function [timeints,timeunits] = set_time_units(dates,offset,timeunits)
%
%-------function help------------------------------------------------------
%NAME
%   set_time_units.m
%PURPOSE
%   convert datetimes to durations with selected time units and an
%   optional offset from zero
% USAGE
%   [timeints,units] = set_time_units(dates)
% INPUT
%   dated - datetime vector to define durations
%   offset - duration offset
%   timeunits - unit of time duration to use
% OUTPUT
%   timeints - selected time unit
%   timeunits - user selected units for duration 
% NOTES
%   some stats routines pass offset=eps(0) to avoid divide by zereo
% SEE ALSO
%   used in regression_plot.m
%
% Author: Ian Townend
% CoastalSEA (c)Feb 2021
%--------------------------------------------------------------------------
%
    if nargin<2 || isempty(offset)
        offset = 0; 
        timeunits = getTimeUnits();
    elseif nargin<3
        timeunits = getTimeUnits();
    end
    %
    switch timeunits
        case 'years'
            timeints = years(dates-dates(1)+offset); 
        case 'days'
            timeints = days(dates-dates(1)+offset); 
        case 'hours'
            timeints = hours(dates-dates(1)+offset); 
        case 'minutes'
            timeints = minutes(dates-dates(1)+offset);   
        case 'seconds'
            timeints = seconds(dates-dates(1)+offset); 
        otherwise
            warndlg('Only years, days, hours, minutes or seconds handled')
            return
    end    
end
%
function timeunits = getTimeUnits()
    %prompt user to select time units
    listxt = {'years','days','hours','minutes','seconds'};
    answer = listdlg('Name','Variables', ...
                    'PromptString','Select units:', ...
                    'ListSize',[200,100],...
                    'SelectionMode','single', ...
                    'ListString',listxt);
    if isempty(answer), answer = 1; end
    timeunits = listxt{answer};
end