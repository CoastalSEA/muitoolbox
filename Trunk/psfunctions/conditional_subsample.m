function [tout,varout] = conditional_subsample(varin,tvar,thr,mobj,method)
%
%-------function help------------------------------------------------------
% NAME
%   conditional_subsample.m
% PURPOSE
%   Subsample input variable based on a condition set by another variable
% USAGE
%   [tout,varout] = conditional_subsample(varin,tvar,thr,mobj)
% INPUT
%   varin - variable to be subsampled
%   tvar - time of var to be subsampled
%   thr - threshold value used for condition
%   mobj - handle to CoastalTools to allow access to data
%   method - interpolation method used in interp1 (optional, default = linear)
% OUTPUT
%   tout - time for the resampled variable
%   varout - resampled variable
% NOTES
% 	User prompted to select threshold condition condition (==,<,>, etc)
%
% Author: Ian Townend
% CoastalSEA (c)June 2018
%--------------------------------------------------------------------------  
    tout = []; varout = [];
    muicat = mobj.Cases;
    if nargin<5
        method = 'linear';
    end
    
    promptxt = 'Select condition data set';
    [caserec,isok] = selectRecord(muicat,'PromptText',promptxt,...
                                                    'ListSize',[300,100]);
    if isok<1, return; end %user cancelled 
    
    dst = getDataset(muicat,caserec,1);           
    time4cond = dst.RowNames;  
    varnames = dst.VariableNames;
    if length(varnames)>1
        ptxt = 'Select variable to be used';
        [varec,ok] = listdlg('Name','Subsample variable',...
                        'ListSize',[200,100],'SelectionMode','single', ...
                        'PromptString',ptxt,'ListString',varnames);
        if ok<1, return; end   %user cancelled            
    else
        varec = 1;
    end
    var4cond = dst.(varnames{varec});
    
    ptxt = 'Select condition to be used';
    caselist = {'<=','>=','==','<','>'};
   [idp,ok] = listdlg('Name','Subsample condition', ...
                      'ListSize',[200,100],'SelectionMode','single', ...
                      'PromptString',ptxt,'ListString',caselist); 
    if ok<1, return; end   %user cancelled
    
    %to get a data record call
    condvar = interp1(time4cond,var4cond,tvar,method);
    %apply condition to record and get index for valid records
    switch idp
        case 1
            idx = find(condvar<=thr);
        case 2
            idx = find(condvar>=thr);
        case 3
            idx = find(condvar==thr);
        case 4
            idx = find(condvar<thr);
        case 5
            idx = find(condvar>thr);
    end
%     var(~idx) = NaN;
    %var is matrix with datenum(time) in first column and 
    %variable in column 2
    varout = varin(idx);
    tout = tvar(idx);
end