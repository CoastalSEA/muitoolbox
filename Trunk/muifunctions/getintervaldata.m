function  [mnval,numts] = getintervaldata(dst1,dst2)
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
    times = dst1.RowNames;     %times in dst1
    nint = length(times);      %no. of intervals in dst1
    mnval = zeros(nint,1);
    numts = mnval;
    %check whether the dst2 timeseries has time before the first time in
    %the dst1 timeseries. Set up loop by defining endint for  
    %the i-1 step to become startint at i=1. Offset by 2 hours so   
    %start is start-1 to capture the first value at start
    startdate = dst2.RowRange{1};
    if startdate<times(1)               
        endint = startdate-hours(2);    %dst2 starts before dst1
    else                  
        endint = times(1)-hours(2);     %no offset, dst1 is the start 
    end
    %
    for i=1:nint   
        %get values for each interval in dst1
        startint = endint+hours(1);
        endint = times(i); %use the dst1 time with no offset to get record 'before' this time
        ds = getsampleusingtime(dst2,startint,endint);
        dsdata = ds.DataTable;
        numts(i,1) = height(dsdata); %record the length of each interval sample
        if ~isempty(dsdata{1,1}) && height(dsdata)>1
            mnval(i,1) = mean(dsdata{:,1},'omitnan');                            
        elseif ~isempty(dsdata{1,1})
            mnval(i,1) = dsdata{1,1};
        else
            mnval(i,1) = 0;
        end
        clear ds
    end   
end