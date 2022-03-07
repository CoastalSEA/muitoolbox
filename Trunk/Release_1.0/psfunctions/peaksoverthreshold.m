function [locs,pks] = peaksoverthreshold(var,vthr,method,mdate,tint,outflg)
%
%-------function help------------------------------------------------------
% NAME
%   peaksoverthreshold.m
% PURPOSE
%   Function to find the peaks over a threshold, v_thr, and return 
%   these values, or the index of the these values, for the vector, var. 
% USAGE
%   out = peaksoverthreshold(var,vthr,method,mdate,tint,outflg)
% INPUTS
%   var - variable
%   vthr - threshold to be used
%   method - types of peaks to find
%            1 = all peaks above threshold
%            2 = peak within each up-down crossing of threshold
%            3 = peaks that have a separation of at least tint hours
%   mdate - vector of time of 'var'
%   tint  - time interval between peaks (hours)
%   outflg - 0:returns indices of peaks; 1:returns values (optional)
% OUTPUT
%   locs - array containing indices (or values of peaks if outflg used)   
%   pks - peak values of var over the threshold vthr
% NOTES
%   To find all peaks use v_thr=0
% SEE ALSO
%   peakseek.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2015
%--------------------------------------------------------------------------
%

%minpeakdist =1; minpeakh = 0; %default values in peakseek
[alocs,apks] = peakseek(var);  %find all peaks and all location indices
idx = find(apks>=vthr);
locs = [];
%
if method==1   %all peaks above a threshold
    pks=apks(idx);
    locs=alocs(idx);
    %
elseif method==2    %all peaks within each up-down crossing of threshold
    [idu,idd]=zero_crossing(var,vthr);
    i_all_pks = alocs(idx);
    nipk = length(idu);
    for i = 1:nipk
        %find all peaks between each up and down-crossing
        i_local_pks = i_all_pks(i_all_pks>idu(i) & i_all_pks<=idd(i));
        %find peak within each crossing - ie independent peak
        [pks(i),local_id] = max(var(i_local_pks));
        locs(i) = i_local_pks(local_id);
    end
    %
elseif method==3    %peaks that have a seperation of at least tint hours
%     ts = timeseries(var,cellstr(mdate));
%     ts1 = getsamples(ts,idx);
    ts1 = mdate(alocs(idx));           %date/time of each peak
    dt  = time(caldiff(ts1,'time'));   %interval between peaks
    dt = [dt',tint];                   %pad dt to make same length as idx
    pkt = apks(idx);
    j = 1;
    count =1;
    while count<=length(idx)
        if dt(count)<tint
            id_idx = find(idx>idx(count) & dt>tint);
            if ~isempty(id_idx)
                id_idx = id_idx(1);
            else
                id_idx = count+1;
            end
            pks(j) = max(pkt(count:id_idx));
            loc = find(pkt(count:id_idx)==pks(j));
            locs(j) = alocs(idx(count-1+loc(1)));
            count = id_idx+1;
        else
            pks(j) = apks(idx(count));
            locs(j) = alocs(idx(count));
            count = count+1;
        end
        j = j+1;
    end
else
    msgbox('Incorrect method in call to peaks.m')
   locs = []; pks = [];
    return
end
%
if nargout==1 && nargin==6
    if outflg==1
        locs=pks;
    end
end
  