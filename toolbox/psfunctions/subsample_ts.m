function output = subsample_ts(var,vartime,mobj,method,tol)
%
%-------function help------------------------------------------------------
% NAME
%   subsample_ts.m
% PURPOSE
%   create a timeseries by interpolating one timeseries to the times
%   of another timeseries
% USAGE
%   output = subsample_ts(var,vartime,mobj,method,tol)
% INPUT
%   var - variable to be subsampled
%   vartime - time of var to be subsampled
%   mobj - handle to muiModelUI instance to allow access to data
%   method - interpolation method used in interp1 (optional, default = linear)
%            when method defined as 'none', function only selects data with a
%            date match.
%   tol - only required if method ='none' and the datetimes are to be
%         matched using a tolerance. tol in seconds
% OUTPUT
%   output - struct with fields for:
%           var - cell array for newtime and resampled variable 
%           meta - struct of casevar and description used to define time intervals
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    output = [];
    muicat = mobj.Cases;
    if nargin<4
        method = 'linear';
    end
    
    promptxt = 'Select dataset to define sub-sample time intervals';
    [cobj,~,dnames,idd] = selectCaseDataset(muicat,[],[],promptxt);
    if isempty(cobj), return; end
    timedst =  cobj.Data.(dnames{idd});          
    newtime = timedst.RowNames;    

    if strcmp(method,'none')
        if nargin<5
            inp = inputdlg({'Use a tolerance (s)? [0 for exact match]'},'Subsample',1,{'0'});
            if isempty(inp) || strcmp(inp{1},'0')
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
            %original code runs out of memory with long timeseries vectors
            % D = abs(newtime - vartime');      % duration matrix
            % [minDiff, idx] = min(D, [], 2);
            % tf = minDiff <= tol;
            % loc = idx(tf);
            % newtime = newtime(tf);
            % newvar = var(loc,:);   %works for scalar or vector data

            % Ensure vartime is sorted
            [vartimeSorted, order] = sort(vartime);
            varSorted = var(order,:);
            
            % Find nearest neighbour index for each newtime
            idx = interp1(vartimeSorted, 1:numel(vartimeSorted), newtime, 'nearest', 'extrap');
            
            % Compute actual time difference
            minDiff = abs(newtime - vartimeSorted(idx));
            
            % Apply tolerance
            tf = minDiff <= tol;
            
            % Filter
            newtime = newtime(tf);
            newvar  = varSorted(idx(tf), :);
        end
    else
        newvar = interp1(vartime,var,newtime,method); %var can be scalar or vector data (ie interp1 handles vector or matrix)
    end
    %put new time and variable into a cell to match the output for default
    %derive output functions that return [time,variable] which is captured
    %as a cell array in muiUserModel.callfcn_dst using varout.
    outvar = {newtime,newvar};
    metadata.caserec = caserec;
    metadata.desc = sprintf('Sampled times obtained from %s',dst.Description);
    output = struct('var',{outvar},'meta',metadata);
end




