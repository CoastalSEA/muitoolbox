function [avar,idx] = sort_var(obj,mobj,idd,avar)                       
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
%   [loc,idx] = sort_var(obj,mobj,idd,avar);
% INPUTS
%   obj - handle to class instance containing dataset to be sorted and
%         index variable if this is used
%   mobj - handle to model class instances containing datasets that could 
%          be used as the index variable
%   idd - index of dataset to use for variable to be sorted
%   avar - a-variable to be sorted (n>1) or a scalar index to the variable
%          to use (optional)
% OUTPUT
%   avar - sorted a-variable in ascending order
%   idx - indices used to sort the input version of avar
% NOTE
%   selection option is only for a variable but a dimension can be passed
%   in as avar.
% SEE ALSO
%   used in muiTableImport for scalar tabPlot and userPlot
%
% Author: Ian Townend
% CoastalSEA (c) Oct 2024
%--------------------------------------------------------------------------
%  
    datasets = fieldnames(obj.Data);
    if nargin<3        
        adst = obj.Data.(datasets{idd});         %selected dataset
        promptxt = 'Select Variable to Sort:';
        [~,idv] = selectAttribute(adst,1,promptxt); %1 - select a variable
        avar = adst.(adst.VariableNames{idv});
    elseif isscalar(avar)
        adst = obj.Data.(datasets{idd});         %selected dataset
        avar = adst.(adst.VariableNames{avar});  %variable index used as input
    end

    %option to plot alphabetically or in index order
    answer = questdlg('Sort X-variable?','Import','Index','Sorted',...
                                                     'Unsorted','Sorted');
    if strcmp(answer,'Index')
        %allow user to select a variable to sort by (must return
        %vector of unique values)
        if length(mobj.Cases.DataSets.muiTableImport)>1
            obj = selectCaseObj(mobj.Cases,[],{'muiTableImport'});
        end
        
        datasetname = getDataSetName(obj,'Select Dataset to use for index');
        if isempty(datasetname)
            dst = adst; 
        else
            dst = obj.Data.(datasetname);
        end   

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
        if isempty(idvar), idx = []; return; end
        
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