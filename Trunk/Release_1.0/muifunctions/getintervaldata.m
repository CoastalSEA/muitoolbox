function  [mnval,numts] = getintervaldata(dst1,dst2,funchandle)
%
%-------function help------------------------------------------------------
% NAME
%   getintervaldata.m
% PURPOSE
%   Compute the mean values of the property values in dst2 between the time
%   intervals for dst1
% USAGE
%   [mnval,numts] = getintervaldata(dst1,dst2)
% INPUTS
%   dst1 - dstable used to define the sampling intervals
%   dst2 - dstable to be sampled for mean values in dst1 intervals
%   funchandle - anonymous function to be used:
%      (e.g. afunc = @(x) mean(x,'omitnan') - default if not defined              
% OUTPUT
%   mnval - mean values in the time intervals between times in dst1
%   numts - number of time steps sampled in each interval
% NOTES
%   the sampling frequency is dst1 is assumed to be a longer intervals
%   than dst2, and the timeseries are assumed to cover the same time
%   period.
% SEE ALSO
%   use getoverlappingtimes.m to extract the period common to two
%   timesereis datasets in dstables.
%
% Author: Ian Townend
% CoastalSEA (c)Apr 2021
%--------------------------------------------------------------------------
%
    if nargin<3
        funchandle = @(x) mean(x,'omitnan');
    end
    times = dst1.RowNames;     %times in dst1
    nint = length(times);      %no. of intervals in dst1
    mnval = zeros(nint,1);
    numts = mnval;
    %check whether the dst2 timeseries has time before the first time in
    %the dst1 timeseries. Set up loop by defining endint for  
    %the i-1 step to become startint at i=1. Offset by delt/2 of dst2 so   
    %start is start-1 to capture the first value at start
    delt = (dst2.RowNames(2)-dst2.RowNames(1))/2;
    startdate = dst2.RowRange{1};
    if startdate<times(1)               
        endint = startdate-delt;    %dst2 starts before dst1
    else                  
        endint = times(1)-delt;     %no offset, dst1 is the start 
    end
    
    %
    hw = waitbar(0,'Compiling interval statistic');
    for i=1:nint   
        %get values for each interval in dst1
        startint = endint+hours(1);
        endint = times(i); %use the dst1 time with no offset to get record 'before' this time
        ds = getsampleusingtime(dst2,startint,endint);
        if ~isempty(ds)
            dsdata = rmmissing(ds.DataTable); %remove missing data          
            numts(i,1) = height(dsdata); %record the length of each interval sample
            if ~isempty(dsdata{1,1}) && height(dsdata)>1
                mnval(i,1) = funchandle(dsdata{:,1});                            
            elseif ~isempty(dsdata{1,1})
                mnval(i,1) = dsdata{1,1};
            else
                mnval(i,1) = 0;  %should not get here
            end
        else
            mnval(i,1) = 0;
        end
        clear ds
        waitbar(i/nint)
    end  
    close(hw)
end