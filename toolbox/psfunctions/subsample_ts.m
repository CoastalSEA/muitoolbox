function [newtime,newvar] = subsample_ts(var,vartime,mobj,method,tol)
%
%-------function help------------------------------------------------------
% NAME
%   subsample_ts.m
% PURPOSE
%   create a timeseries by interpolating one time time series to the times
%   of another timeseries
% USAGE
%   [newtime,newvar] = subsample_ts(var,vartime,mobj,method,tol)
% INPUT
%   var - variable to be subsampled
%   vartime - time of var to be subsampled
%   mobj - handle to muiModelUI instance to allow access to data
%   method - interpolation method used in interp1 (optional, default = linear)
%            when method defined as 'none', function only selects data with a
%            date match.
%   tol - only required if menthod ='none' and the datetimes are to be
%         matched using a tolerance. tol in seconds
% OUTPUT
%   newtime - time for the resampled variable
%   newvar - resampled variable 
%   metadata - struct of casevar and description used to define time intervals
%                               USE NOT YET IMPLEMENTED IN muiManipUI
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
    cobj = getCase(muicat,caserec);
    if isempty(cobj), return; end

    dnames = fields(cobj.Data);
    if numel(dnames)>1
        [~,idd] = selectDataset(muicat,cobj);
    else
        idd = 1;
    end
    dst =  cobj.Data.(dnames{idd});          
    newtime = dst.RowNames;       

    if strcmp(method,'none')
        if nargin<5
            inp = inputdlg({'Use a tolerance (s)? [0 for exact match]'},'Subsample',1,{'0'});
            if isempty(inp) || stcmp(inp{1},'0')
                tol = [];
            else
                tol = seconds(str2double(inp{1}));
            end
        else
            tol = seconds(tol);
        end


        if isempty(tol)
            [idn,idv] = ismember(newtime, vartime);
            newvar = var(idv(idv>0));
            newtime = newtime(idn);
        else
            D = abs(newtime - vartime');      % duration matrix
            [minDiff, idx] = min(D, [], 2);
            tf = minDiff <= tol;
            loc = idx(tf);
            newtime = newtime(tf);
            newvar = var(loc);
        end
    else
        newvar = interp1(vartime,var,newtime,method);
    end
    metadata.caserec = caserec;
    metadata.desc = dst.Description;
end




