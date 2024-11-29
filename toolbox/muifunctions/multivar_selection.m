function [select,setting] = multivar_selection(mobj,varnames,promptxt,varargin)                       
%
%-------function help------------------------------------------------------
% NAME
%   multivar_selection.m
% PURPOSE
%   select one or more variables
% USAGE
%   select = multivar_selection(mobj,varnames,promptxt,varargin)
%   e.g. multiple selection returning 2 variables each with 3 selections 
%        for upper, central and lower values of a variable
%     varnames = {'Xvar','Yvar'};
%     promptxt = {'Select variables for X-Axis:','Select variables for Y-Axis:'};              
%     select = multivar_selection(mobj,varnames,promptxt,...
%                             'XYZnset',3,...                           %minimum number of buttons to use for selection
%                             'XYZmxvar',[1,1,1],...                    %maximum number of dimensions per selection button, set to 0 to ignore subselection
%                             'XYZpanel',[0.05,0.2,0.9,0.3],...         %position for XYZ button panel [left,bottom,width,height]
%                             'XYZlabels',{'Upper','Central','Lower'}); %default button labels 
% INPUTS
%   mobj - ModelUI instance
%   varnames - cell array of selection variable names to use
%   promptxt - cell array of prompts to use
%   varargin - modifications to the muiSelectUI tab selection options
% OUTPUT
%   select - selections made with fields: case, dset, desc, 
%   label, data, attribs, dvals. Any scaling applied is used to amend 
%   desc and label fields.
%   setting - struct with selection details: caserec, classrec, scale.
% NOTES
%   Calls get_selection for each selection, which returns a struct
%   as created by muiCatalogue.getProperty 
% SEE ALSO
%   called as part of EstuaryDB App from edb_user_plots
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
%  
    answer = questdlg('Load saved selection?','User plots','Yes','No','No');
    if strcmp(answer,'Yes')         
        [fname,path] = getfiles('FileType','*.mat;',...
                        'PromptText','Select saved selection file:');
        S = load([path,fname],'-mat');
        select = S.select;
    else
        for i=1:length(varnames)
             [select.(varnames{i}),setting.(varnames{i}),select.names] = ...
                           selectMVar(mobj,promptxt{i},varargin{:});
             if isempty(select.(varnames{i})), select = []; return; end
        end

        answer = questdlg('Save selection?','User plots','Yes','No','Yes');
        if strcmp(answer,'Yes')
            selname = inputdlg('Name selection','User plots',1,{'Case XX'});
            if ~isempty(selname)
                save(selname{1},'select')
            end
        end        
    end
end
%%
function [mvar,mset,names] = selectMVar(mobj,promptxt,varargin)
    %call muiSelectUI via get_selection and selectui, returns array mvar
    %   with data and metadata for selected variable. struct with 
    %   getProperty fields: case, dset, desc, label, data, attribs, dvals  
    %   any scaling applied is used to amend variable desc and label 
    [mvar,mset] = get_selection(mobj,promptxt,varargin{:});
    if isempty(mvar), return; end

    names = mvar(1).dvals.row;
end