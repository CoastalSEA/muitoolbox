function [ds1out,ds2out] = getoverlappingtimes(ds1,ds2,isoffset)
%
%-------function help------------------------------------------------------
% NAME
%   getoverlappingtimes.m
% PURPOSE
%   Find the start and end dates of the overlapping portions of two 
%   timeseries in dstables and trim both to the common interval.
% USAGE
%   [ds1out,ds2out] = getoverlappingtimes(ds1,ds2,isoffset)
% INPUTS
%   dst1 - dstable containing time series data
%   dst2 - dstable containing time series data
%   isoffset - logical flag to indicate if an offset is to be included
% OUTPUT
%   dst1out - trimmed dst1 to same period as dst2
%   dst2out - trimmed dst2 to same period as dst2 
% NOTES
%   isoffset is used to extend the duration of the records returned to
%   ensure that dst1 starts before dst2 (using a mean value if no data
%   available). This is used in Sim_YGOR to align wave and beach profile
%   data with the wave data starting one time interval before the start of
%   the beach profile data.
% SEE ALSO
%   getinterdata.m to extract mean values in the intervals of a less
%   frequently sampled dataset. Uses dstable version of getsampleusingtime
%
% Author: Ian Townend
% CoastalSEA (c)Apr 2021
%--------------------------------------------------------------------------
%
    if nargin<4
        isoffset = false;
    end

    [start1,end1] = ds1.RowRange{:};
    [start2,end2] = ds2.RowRange{:};
    if start2>end1 || end2<start1
        ds1out = []; ds2out = [];
        return;        %timeseries do not overlap
    else
        starttime = max(start1,start2);
        endtime = min(end1,end2);
    end

    if isoffset
        %see if ds2 start before first time occurence in ds1 and extend ds1
        %by an average interval to capture the first interval in tds2
        tsc1_dur = (end1-start1)/height(ds1.DataTable); %average time interval 
        stoffset = start1-tsc1_dur;                        %start including offset
        if starttime==start1 
            starttime = max(stoffset,start2);
        end
    end 

    %introduce small offset to start and end so records at ends are included
    starttime = starttime-minutes(1);
    endtime = endtime+minutes(1);

    %get the timeseries using the defined interval (works for ts and tsc)
    ds1out = getsampleusingtime(ds1,starttime,endtime);
    ds2out = getsampleusingtime(ds2,starttime,endtime);
end