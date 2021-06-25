function [timeints,timeunits] = set_time_units(dates,offset,timeunits)
%
%-------function help------------------------------------------------------
%NAME
%   set_time_units.m
%PURPOSE
%   convert datetimes to durations with selected time units and an
%   optional offset from zero. prompts for units if not defined
% USAGE
%   [timeints,units] = set_time_units(dates)
% INPUT
%   dates - datetime vector to define durations
%   offset - duration offset (optional or empty)
%   timeunits - unit of time duration to use (optional)
% OUTPUT
%   timeints - durations from t0 in selected time units. If there is an
%              offset>0 the durations are from the first value of dates, 
%              otherwise they are from 1-Jan-0001.
%   timeunits - user selected units for duration 
% NOTES
%   some stats routines pass offset=eps(0) to avoid divide by zero when
%   using durations from t(1).
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
    if offset>0
        t0 = dates(1);
    else
        t0 = datetime(1,1,1);
    end
    %
    switch timeunits
        case 'years'
            timeints = years(dates-t0+offset); 
        case 'days'
            timeints = days(dates-to+offset); 
        case 'hours'
            timeints = hours(dates-t0+offset); 
        case 'minutes'
            timeints = minutes(dates-t0+offset);   
        case 'seconds'
            timeints = seconds(dates-t0+offset); 
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