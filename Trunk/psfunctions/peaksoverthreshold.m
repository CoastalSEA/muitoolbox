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
%   tint  - time interval between peaks; separation is >=tint (hours) 
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
    pks = zeros(1,1); 
    locs = []; 
    %find all peaks and all location indices
    %minpeakdist = 1; minpeakh = 0; %default values in peakseek
    [alocs,apks] = peakseek(var);  
    idx = find(apks>=vthr);
    
    %
    if method==1        %all peaks above a threshold
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
    elseif method==3    %peaks that have a separation of at least tint hours
        ts1 = mdate(alocs(idx));           %date/time of each peak
        dt  = time(caldiff(ts1,'time'));   %interval between peaks
        dt = [dt',tint];                   %pad dt to make same length as idx
        pkt = apks(idx);                   %peaks over threshold
        j = 1;
        id_grpst = 1;                      %counter for the starting record of a group
        while id_grpst<=length(idx)
            if dt(id_grpst)<tint
                %get group of peaks each separated by <tint
                %NB dt is the forward interval relative to the ith peak (ie from peak i to i+1)
                offset = id_grpst-1; %offset for ids within group
                id_grpend = offset+find(dt(id_grpst:end)>=tint,1,'first'); %id of last peak with separation <tint
                if isempty(id_grpend), id_grpend = length(dt); end
                idpks = findgrpeaks(pkt,dt,tint,id_grpst,id_grpend,[]);
                if isempty(idpks)
                    %should always return at least one value
                    warndlg('Failed to find peak of group in peakoverthreshold')
                    return
                end
                
                idpks = sort(idpks);       %put peak ids in ascending order
                npks = length(idpks);      %number of peaks found
                pks(j:j+npks-1) = pkt(idpks);
                locs(j:j+npks-1) = alocs(idx(idpks));
                
                j = j+npks-1;              %increment array index
                id_grpst = id_grpend+1;    %increment loop counter
            else
                pks(j) = apks(idx(id_grpst));
                locs(j) = alocs(idx(id_grpst));
                id_grpst = id_grpst+1;
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
end
%%
function idpks = findgrpeaks(pkt,dt,tint,idst,idnd,idpks)
    %find the highest peak between idst and idnd and recursively check for
    %peaks before or after the maximum but at least tint duation distant
    [~,id_gmax] = max(pkt(idst:idnd)); %largest peak in group and id in group subset
    id_gpk = idst-1+id_gmax;
    idpks = [idpks,id_gpk];
    
    %handle prior peaks
    cdt = cumsum(dt(idst:id_gpk-1),'reverse');  %sum durations before group peak
    id_prior = idst-1+find(cdt>=tint,1,'last');  %index of peak nearest to group peak but at least tint distant
    if ~isempty(id_prior)
        idpks = findgrpeaks(pkt,dt,tint,idst,id_prior,idpks);
    end
    
    %handle post peaks
    cdt = cumsum(dt(id_gpk:idnd-1),'forward');  %sum durations after group peak
    id_post = id_gpk+find(cdt>=tint,1,'first'); %index of peak nearest to group peak but at least tint distant
    if ~isempty(id_post)
        idpks = findgrpeaks(pkt,dt,tint,id_post,idnd,idpks);
    end
end
  