function tint = ts_interval(time,units,method)
%
%-------function help------------------------------------------------------
% NAME
%   ts_interval.m
% PURPOSE
%   find the time interval of a time vector based on selected method
% USAGE
%   tint = ts_interval(time,units,method)
% INPUT
%   time - time as a datetime vector
%   units - units to use for definition of duration
%   method - 'First inteval', 'Mean', or 'Mode'
% OUTPUT
%   dtint - time interval of time vector
% SEE ALSO
%   used in ct_data_cleanup.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    %get the interval using time                  
    switch method
        case 'First interval'
            tint = time(2)-time(1);
        case 'Mean'
            tint = mean(diff(time));
        case 'Mode'
            tint = mode(diff(time));
        otherwise
            tint = [];
    end
    
    %adjust value to a duration based on ts units
    if isnumeric(tint)
        tint = num2duration(tint,units);
    end
end