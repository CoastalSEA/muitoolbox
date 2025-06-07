function [bintable,binvar,bintime] = binned_variable(var,mtime,interval,period)
%
%-------function help------------------------------------------------------
% NAME
%   binned_variable.m
% PURPOSE
%   sort the data into interval bins for each interval within a period (e.g
%   monthly bins for each year of a record)
% USAGE
%   binvar = binned_variable(var,mtime,'month','year');
% INPUTS
%   var - variable to be binned. Can be a vector or matrix
%   mtime - datetimes for variable - vector that is the same size as var,
%           or the 1st dimension of var (ie no of rows)
%   interval - bin size, e.g. day, week, month
%           interval is a character vector of any of the following:
%           second, minute, hour, day, week, month, quarter, year
%   period - recurrence duration, e.g. week, month, year - determines output
%            format by setting the '<interval>Type' property for:
%               secondofminute*, secondofday
%               dayofweek, dayofmonth*, dayofyear (* default)
%               weekofmonth, weekofyear*
%               monthofyear*
%               hour (0-23), minute (0-59), quarter (1-4) have no Type option
% OUTPUT
%   bintable - table containing cells of binnned data with rows for each
%              cycle of the interval and variables named in order for the 
%              number of intervals in a cycle (e.g. 12 monnths in a year).
%   binvar - cell array of the binned data
%   bintime - struct for the 'intervals'  as integer values (1-365, 1-53, 1-12, year, etc)
%              and 'periods' as the datetime for the start of each period,
%              formatted according to period type and 'intstart' as the
%              datetime start of each interval
% SEE ALSO
%   called in wrm_transport_plots
%
% Author: Ian Townend
% CoastalSEA (c)May 2025
%--------------------------------------------------------------------------
%
    if isvector(var)
        if isrow(var), var = var'; end    
    end
    assert(size(var,1)==length(mtime),'Variable and time not the same length.')


    [intervals,intstart] = discretize(mtime,interval);
    noType = {'year','quarter','hour','minute'};
    if any(strcmp(noType,interval)) || any(strcmp(noType,period))
        fi = str2func(interval);   
        bintime.intervals = fi(intstart(1:end-1));
    else
        timeType = sprintf('%sof%s',interval,period);
        fi = str2func(['@(t,timeType) ',[interval,'(t,timeType)']]);  
        bintime.intervals = fi(intstart(1:end-1),timeType);
    end
    
    nint = length(unique(bintime.intervals));
    nper = ceil(length(bintime.intervals)/nint);

    binvar = cell(nper,nint);
    k = 0;     
    for i=1:nper      
       bintime.periods(i) = intstart(k+1); 
        for j=1:nint            
            idv = intervals==(k+j); 
            binvar{i,j} = var(idv);
        end
        k = k+nint;            
    end
    bintime.periods(1) = mtime(1);

    switch period    
        case {'day','quarter'}
            bintime.periods.Format = 'dd-MM-yyyy';        
        case 'month'
            bintime.periods.Format = 'MM-yyyy';   
        case 'year'
            bintime.periods.Format = 'yyyy';   
        otherwise
            warndlg('Period not recognised (day, month or year)'), 
            return;
    end
    bintime.intstart = intstart;

    % checkplot(binvar,bintime,interval)

    %table output
    rowtime = string(bintime.periods);
    varnames = 'Int'+string(unique(bintime.intervals));
    % Convert each column into a nx1 cell array
    result = cell(1,nint);
    for i = 1:nint
        result{i} = binvar(:,i); % Extract the i-th row as a 1×m cell array
    end
    bintable = table(result{:},'RowNames',rowtime,'VariableNames',varnames);
end

%%
function checkplot(binvar,bintime,interval)
    %plot of variable against interval with a line for each period
    hf = figure('Tag','PlotFig');
    ax = axes(hf);

    hold on
    nper = length(bintime.periods);
    nint = length(unique(bintime.intervals));
    for i=1:nper
        for j=1:nint
            intvar(1,j) = mean(binvar{i,j},'omitnan');
        end
        plot(1:nint,intvar(1,:),'DisplayName',string(bintime.periods(i)))
    end
    xlabel(interval)
    ylabel('Mean of variable')
    legend()
end