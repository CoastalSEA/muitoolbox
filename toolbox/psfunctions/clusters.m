function cls = clusters(mdate,mpks,clint)
%
%-------function help------------------------------------------------------
% NAME
%   clusters.m
% PURPOSE
%   Function to find clusters of peaks over a threshold
% USAGE
%   cls = clusters(mdate,mpks,tint)
%INPUT
%   mdate - vector of time of mpks
%   mpks  - peaks above threshold (eg returned from function 'peaks')
%   clint - separation interval for clusters (days) a new cluster exists if
%           time between consecutive peaks is > than clint
%OUTPUT
%   cls - structure ('date','pks') containing values, the date of the 
%         cluster and the values of peaks within each cluster      
%
% Author: Ian Townend
% CoastalSEA (c)June 2015
%--------------------------------------------------------------------------
%
    idx = 1:length(mpks);
    cls.date = [];
    cls.pks = [];
    %cls.per = [];
    %interval between peaks
    dt  = time(caldiff(mdate,'time'));   %'time' converts time of calendar duration to duration
    dt = [dt',clint];                     %pad dt to make same length as idx
    j = 1;
    count =1;
    while count<=length(idx)
        if dt(count)<clint
            id_idx = find(idx>idx(count) & dt>clint); 
            if ~isempty(id_idx)
                id_idx = id_idx(1);
            else
                id_idx = length(idx);
            end
            cls(j).date = mdate(count:id_idx);
            cls(j).pks = mpks(count:id_idx);
            %cls(j).per = mper(count:id_idx);
            count = id_idx+1;
            j = j+1;
        else
            count = count + 1;
        end 
    end

