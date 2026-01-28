function [newtime,newvar] = subsample_ts(var,vartime,mobj,method)
%
%-------function help------------------------------------------------------
% NAME
%   subsample_ts.m
% PURPOSE
%   create a timeseries by interpolating one time time series to the times
%   of another timeseries
% USAGE
%   [newtime,newvar] = subsample_ts(var,vartime,mobj,method)
% INPUT
%   var - variable to be subsampled
%   vartime - time of var to be subsampled
%   mobj - handle to muiModelUI instance to allow access to data
%   method - interpolation method used in interp1 (optional, default = linear)
%            when method defined as none, function only selects data with a
%            date match.
% OUTPUT
%   newtime - time for the resampled variable
%   newvar - resampled variable 
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    newtime = []; newvar = [];
    muicat = mobj.Cases;
    if nargin<4
        method = 'linear';
    end
    
    promptxt = 'Select dataset to define sub-sample time intervals';
    [caserec,isok] = selectRecord(muicat,'PromptText',promptxt,...
                                                    'ListSize',[300,100]);
    if isok<1, return; end %user cancelled 
    dst = getDataset(muicat,caserec,1);           
    newtime = dst.RowNames;       

    if strcmp(method,'none')
        [idn,idv] = ismember(newtime, vartime);
        newvar = var(idv(idv>0));
        newtime = newtime(idn);
    else
        newvar = interp1(vartime,var,newtime,method);
    end
end