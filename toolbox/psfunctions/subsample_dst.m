function outdst = subsample_dst(muicat)
%
%-------function help------------------------------------------------------
% NAME
%   subsample_dst.m
% PURPOSE
%   subsample all variables in a dstable using the times from another
%   dataset (+/- a tolerance).
% USAGE
%   outdst = subsample_dst(mobj.Cases);
% INPUT
%   muicat - handle to muiVatalogue assigned to mobj.Cases of model instance
% OUTPUT
%   outdst - reasmpled dstable
% NOTES
%   called from ct_data_cleanup
%
% Author: Ian Townend
% CoastalSEA (c) March 2026
%--------------------------------------------------------------------------
%
    %get the dataset to be subsampled
    promptxt = 'Select dataset to be subsampled at new time intervals';
    [obj,~,dsnames,ido] = selectCaseDataset(muicat,[],[],promptxt);
    if isempty(obj), return; end
    if numel(dsnames)>1
        answer = questdlg('Subsample all datasets or just the selected one?',...
                          'Subsample','All','Selected','All');
        if strcmp(answer,'Selected')
            dsnames = dsnames(ido);
        end
    end

    %get the dataset used for the subsample time intervals
    promptxt = 'Select dataset to define sub-sample time intervals';
    [cobj,~,dnames,idc] = selectCaseDataset(muicat,[],[],promptxt);
    if isempty(cobj), return; end
    timedst =  cobj.Data.(dnames{idc});         
    clear cobj dnames

    inp = inputdlg({'Use a tolerance (s)? [0 for exact match]'},'Subsample',1,{'0'});
    if isempty(inp) || strcmp(inp{1},'0')
        tol = [];
    else
        tol = seconds(str2double(inp{1}));
    end

    dst = obj.Data;
    for i=1:numel(dsnames)
        [newtime,idt] = getTimes2Use(dst.(dsnames{i}),timedst,tol);
        outdst.(dsnames{i}) = copy(dst.(dsnames{i}));
        subtable = dst.(dsnames{i}).DataTable(idt,:);  
        outdst.(dsnames{i}).DataTable = subtable;
        outdst.(dsnames{i}).RowNames = newtime; %update times in case there is an offset
    end
    %save sumsampled dataset
    classname = metaclass(obj).Name;
    heq = str2func(classname);
    newobj = heq();                         %new instance of class object
    newobj.Data = outdst;
    newobj.idFormat = obj.idFormat;         %needed if inherits muiDataSet
    setCase(muicat,newobj,'data');
    getdialog(sprintf('Subsampled dataset saved as %s',classname));
end
%%
function [newtime,idt] = getTimes2Use(dst,timedst,tol)
    %get the times to use for sampling
    vartime = dst.RowNames;            %dataset being sampled
    newtime = timedst.RowNames;        %dataset to define new times

    if isempty(tol)
        [idn,idv] = ismember(newtime, vartime);
        idt = find(idv(idv>0));
        newtime = newtime(idn);
    else
        % Ensure vartime is sorted
        [vartimeSorted, ~] = sort(vartime);
        
        % Find nearest neighbour index for each newtime
        idx = interp1(vartimeSorted, 1:numel(vartimeSorted), newtime, 'nearest', 'extrap');
        
        % Compute actual time difference
        minDiff = abs(newtime - vartimeSorted(idx));
        
        % Apply tolerance
        tf = minDiff <= tol;
        idt = idx(tf);
        
        % Filter
        newtime = newtime(tf);
    end
end