function [tm,vm] = movingtime(var,tin,tdur,tstep,func)
%
%-------function help------------------------------------------------------
% NAME
%  movingtime.m
% PURPOSE
%   Computes moving averages for a window of tint duration
% USAGE
%   [tm,vm] = movingtime(var,tin,tdur,tstep,func)
% INPUTS
%   var - is the input vector to be smoothed. 
%   tin - is the datetime vector (same legnth as x)
%   tdur - is duration to average over (string or duration) e.g.'3 yr'
%   tstep - duration to advance for next calculation (string or duration) e.g.'6 m' 
%   func -  custom function (e.g. mean, std etc) passed as character 
%          string (optional - default is mean)
% OUTPUT
%   tm - time at the beginning of each stepping interval, ie every tstep from
%        time t0 to the nearest interval that is less than tdur from the
%        end of the record
%   vm - is output vector of same length as x
% EXAMPLE
%   [tm,vm] = movingtime(x,t,1 yr,1 m,'std') returns the standard deviation at
%   monthly intervals and averaged over 1 year.
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%--------------------------------------------------------------------------
%
    if size(var,1)==1
        var = var';
    end
    
    if nargin<5
        func = 'mean';
    end

    tm = []; vm = [];
    %convert text values to durations
    if ischar(tdur) || isstring(tdur)      
        tdur = str2duration(tdur);
    elseif ~isduration(tdur)
        warndlg('Averaging period, tdur, must be duration or character data type')
        return
    end
    
    if ischar(tstep) || isstring(tstep)      
        tstep= str2duration(tstep);
    elseif ~isduration(tdur)
        warndlg('Step interval, tstep, must be duration or character data type')
        return
    end

    if isempty(tdur) || isempty(tstep)
        msg = sprintf('Incorrect input\nDuration and time step should be:\ncharacter string containing ''X u''\nwhere X is a number and u is the time unit');
        warndlg(msg); return;
    end
    
    txt = sprintf('Edit durations - Cancel to use existing values\nAveraging period (y,d,h,m,s):');
    promptxt = {txt,'Time step interval (y,d,h,m,s)'};
    defaults = [cellstr(tdur),cellstr(tstep)];
    answer = inputdlg(promptxt,'MovingTime',1,defaults);
    if ~isempty(answer)
        tdur = str2duration(answer{1});
        tstep = str2duration(answer{2});
    end
    
    %create anonymous function (different format for min/max)
    if strcmpi(func,{'min','max'})
        func = str2func(['@(x)', func, '(x,[],''omitnan'')']);
    else
        func = str2func(['@(x)', func, '(x,''omitnan'')']);
    end

    startime = tin(1);
    stoptime = tin(end)-tdur;
    nint = floor((stoptime-startime)/tstep);
    
    istartime = tin(1);
    vm = zeros(nint,1); tm = NaT(nint,1);
    for i=1:nint
        tm(i) = istartime;
        iendtime = istartime+tdur;
        idx = isbetween(tin,istartime,iendtime);
        vm(i) = func(var(idx));
        istartime = istartime+tstep;        
    end
end

    