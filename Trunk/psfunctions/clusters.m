function cls = clusters(mdate,mpks,tint)
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
%   tint  - time interval for clusters (hours)
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
    dt  = time(caldiff(mdate,'time'));   %interval between peaks
    dt = [dt',tint];                     %pad dt to make same length as idx
    j = 1;
    count =1;
    while count<=length(idx)
        if dt(count)<tint
            id_idx = find(idx>idx(count) & dt>tint);
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

