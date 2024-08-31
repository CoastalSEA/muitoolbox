function  mnvals = getpreceedingdata(inpdst,refdst,prevint)
%
%-------function help------------------------------------------------------
% NAME
%   getpreceedingdata.m
% PURPOSE
%   Compute  the mean values of the input dst, inpdst, for the 
%   interval preceeding each occurrence in the reference timeseries,
%   refdst, using the duration defined by prevint in days 
% USAGE
%   [mnval,numts] = getpreceedingdata(dst1,dst2)
% INPUTS
%   inpdst - dstable sampled to create mean values at the times of refdst
%   refdst - dstable that defines the time intervals to use
%   prevint - interval used to generate means from inpdst
% OUTPUT
%   mnvals - dstable of mean values for inpdst over defined interval prior 
%            to the time intervals in refdst
% NOTES
%   the sampling frequency is refdst is assumed to be a longer intervals
%   than inpdst, and the timeseries are assumed to cover the same time
%   period.
% SEE ALSO
%   used in Sim_YGOR.m. use getoverlappingtimes.m to extract the period 
%   common to two timesereis datasets in dstables.
%
% Author: Ian Townend
% CoastalSEA (c)Apr 2021
%--------------------------------------------------------------------------
%
    nprof = height(refdst.DataTable);
    var_dates = refdst.RowNames;
    vars = inpdst.VariableNames;
    nvars = length(vars);
    sttime = var_dates-days(prevint)-hours(1); %start times with small offset
    mnvals = NaN(nprof,nvars);
    for i=1:nprof
        dsti = getsampleusingtime(inpdst,sttime(i),var_dates(i));
        if ~isempty(dsti)
            if height(dsti.DataTable)>1
                mnvals(i,:) = mean(dsti.DataTable{:,:},1,'omitnan');  %mean of records in interval
            elseif height(dsti.DataTable)==1
                mnvals(i,:) = dsti.DataTable{1,:};     %single value
            end
        else
            %use the NaN value preassigned
        end  
    end 
    mnvals = num2cell(mnvals,1);
    mnvals = dstable(mnvals{:},'RowNames',var_dates,'VariableNames',vars);
end