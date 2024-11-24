function [avar,idx] = sort_var(dst,avar)                       
%
%-------function help------------------------------------------------------
% NAME
%   sort_var
% PURPOSE
%   function to sort avar array to order defined by a selected index or in 
%   ascending order Input variable can be numeric, character, string or 
%   categoraical array. If categorical the categories are reordered so that
%   they plot in the defined order
% USAGE
%   [loc,idx] = sort_var(dst,xvar);
% INPUTS
%   dst - dstable that holds variable to be used as an index
%   avar - a-variable to be sorted
% OUTPUT
%   avar - sorted a-variable in ascending order
%   idx - indices used to sort the input version of avar
% SEE ALSO
%   used in muiTableImport for scalar tabPlot
%
% Author: Ian Townend
% CoastalSEA (c) Oct 2024
%--------------------------------------------------------------------------
%  
    %option to plot alphabetically or in index order
    answer = questdlg('Sort X-variable?','Import','Index','Sorted',...
                                                     'Unsorted','Sorted');
    if strcmp(answer,'Index')
        %allow user to select a variable to sort by (must return
        %vector of unique values)
        ok = 1;
        while ok>0
            idvar = [];
            vardesc = dst.VariableDescriptions;
            idv = listdlg('PromptString','Select variable:',...
                       'SelectionMode','single',...
                       'ListString',vardesc);
            if isempty(idv), break; end
            idvar = dst.(dst.VariableNames{idv});
            if isunique(idvar)
                ok = 0; 
            else
                hw = warndlg('Index variable must be vector of unique values');
                waitfor(hw)
            end
        end
        if isempty(idvar), return; end
        [~,idx] = sort(idvar);      %return indices so other variables can be sorted
        avar = avar(idx);
        if iscategorical(avar)
            svar = string(avar);
            avar = categorical(svar);   %new sorted categorical array  
            avar = reordercats(avar,svar);
        end

    elseif strcmp(answer,'Sorted')
        %sort categorical rownames into alphabetical order
        [avar,idx] = sort(avar);   %return indices so other variables can be sorted
        if iscategorical(avar)
            svar = string(avar);
            avar = categorical(svar);  %new sorted categorical array 
        end
    else
        idx = 1:length(avar);
    end
end