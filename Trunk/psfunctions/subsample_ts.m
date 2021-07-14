function [newtime,newvar] = subsample_ts(var,vartime,mobj,method)
%
%-------function help------------------------------------------------------
% NAME
%   subsample_ts.m
% PURPOSE
%   create a timeseries and call interpolateTSdata
% USAGE
%   newvar = subsample(var,tvar,mobj)
% INPUT
%   var - variable to be subsampled
%   tvar - time of var to be subsampled
%   mobj - handle to CoastalTools to allow access to data
%   method - interpolation method used in interp1 (optional, default = linear)
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
    newvar = interp1(vartime,var,newtime,method);
end