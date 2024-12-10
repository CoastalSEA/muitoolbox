function newdst = scale_data(dst)
%
%-------function help------------------------------------------------------
% NAME
%   scale_data.m
% PURPOSE
%   function to scale variables in a dataset based on user defined factors
%   for each variable.
% USAGE
%   dst = scale_variables(wl,t,issave,isplot)
%   e.g. in Derive output UI: scale_variables(x,t,1,0)
% INPUT
%   dst - selected dataset to extract variables from for scaling
% OUTPUT (optional)
%   newdst - dstable containing the scaled variables and metadata
%
% Author: Ian Townend
% CoastalSEA (c)Dec 2024
%--------------------------------------------------------------------------
%
    varnames = dst.VariableNames;
    vardesc = dst.VariableDescriptions;
    selection = listdlg("ListString",vardesc,"PromptString",...
                'Select variables to scale:','SelectionMode','multiple',...
                'ListSize',[150,200],'Name','Scale data');
    if isempty(selection),return; end

    scaling_factors = [];
    for i=1:length(selection)
        promptxt = {sprintf('Scaling factor for %s?',vardesc{selection(i)})};
        answer = inputdlg(promptxt,'Scale Variable',1,{'1'});
        if isempty(answer), return; end  %user cancelled
        fact = str2double(answer{1});
        vars{i} = dst.(varnames{i})*fact; %#ok<AGROW> 
        scaling_factors = sprintf('%s\n%s x %.2f',scaling_factors,varnames{i},fact);
    end

    dsp = setDSproperties(dst,selection);
    rows = dst.RowNames;
    newdst = dstable(vars{:},'RowNames',rows,'DSproperties',dsp);
    %Source and MetaData are set in muiUserModel. 
    %Put fit parameters in UserData
    newdst.UserData = scaling_factors;
end
%%
function dsp = setDSproperties(dst,idv)
    %use existing DSproperties to define properties for variables that are
    %rescaled
    idx = 1:length(dst.VariableNames);
    idy = ismember(idx,idv);
    idx = idx(~idy);
    dsp = copy(dst.DSproperties);
    dsp.Variables(idx) = [];
end
