function [props,sel] = get_variable(mobj,promptxt,varargin)
%
%-------function help------------------------------------------------------
% NAME
%   get_variable.m
% PURPOSE
%   retrieve selected variable based on selection made using selectui
%   selection restricted to variable - dimensions cannot be selected
% USAGE
%   props = get_variable(mobj,promptxt,varagin)
% INPUTS
%   mobj - ModelUI instance
%   promptxt - text used as prompt in selection UI (optional)
%   varargin - Name,Value pairs for properties set in TabContent (optional)
% OUTPUT
%   props - data and metadata for selected variable. struct with fields:
%         getProperty fields: case, dset, desc, label, data, attribs, dvals  
%         any scaling applied is used to amend variable desc and label         
%   sel - addtional details of selection made: caserec, classrec, scale
% NOTES
%   called from tableviewer_user_plots as part of TableViewer App.
%   scaled data is returned if this option is selected
%   alternative to get_selection which allows variables or dimensions to be selected
% SEE ALSO
%   calls selectui and muiSelectUI
%
% Author: Ian Townend
% CoastalSEA (c) May 2024
%--------------------------------------------------------------------------
% 
    if nargin<2
        promptxt = 'Select data:'; 
        varargin = {};
    elseif nargin<3
        varargin = {};
    end
    
    props = [];
    ok = 0;
    while ok<1
        [UIsel,UIset] = selectui(mobj,promptxt,varargin{:});      %calls UI to make selection
        if isempty(UIsel), return; end %user cancelled
        if UIsel.property==1
            ok = 1;
        else
            warndlg('Only variables can be selected. Use plot UI to plot variables against dimensions')
        end
    end
    if isempty(UIsel),  return; end
    if ~strcmp(fieldnames(UIset),'scaleList'), return; end    %user did not complete selection of variable
    
    sel.caserec = UIsel(1).caserec;
    [cobj,sel.classrec] = getCase(mobj.Cases,UIsel(1).caserec); %selected class instance
    dsnames = fieldnames(cobj.Data);
    props.dset = dsnames{UIsel(1).dataset};
    dst = cobj.Data.(props.dset); %selected dstable
    props.name = dst.VariableNames{UIsel(1).variable};
    %extract the data based on any sub-selection and meta-text description
    [props.data,props.attribs,props.dvals] = subselectData(dst,UIsel,mobj);
    props.label = dst.VariableLabels{UIsel(1).variable};
    props.desc = dst.VariableDescriptions{UIsel(1).variable};
    props.case = dst.Description;
    sel.scale = UIset.scaleList{UIsel(1).scale};
    if UIsel(1).scale>1
        %adjust data if user has selected to rescale variable
        dim = 1; %dimension to apply scaling function if matrix
        props.data = scalevariable(props.data,sel.scale,dim);
        props.label = sprintf('%s-%s',sel.scale,props.label);
        props.desc = sprintf('%s-%s',props.scale,props.desc); %????
    end
end
%%
function [data,attribdesc,dvals] = subselectData(dst,UIsel,mobj)
    %if a subselection has been made apply this to the data
    %extract indices as in muicatalogue.getProperty  
    
    %need to decide whether better to use name, desc or label ******
    [attribnames,attribdesc,attriblabel] = getVarAttributes(dst,UIsel.variable);     %#ok<ASGLU>
    [idx,dvals] = getSelectedIndices(mobj.Cases,UIsel,dst,attribnames);                        %extracts array for selected variable
    data = getData(dst,idx.row,idx.var,idx.dim);
    if isempty(data), return; end
    data = squeeze(data{1}); %getData returns a cell array
    %apply any subselection of the variable range
    outopt = 'array';
    useprop = attribnames{UIsel.property};
    varange = dst.VariableRange.(useprop);
    dvals.var = UIsel.range;
    data = getVariableSubSelection(mobj.Cases,data,varange,dvals.var,outopt);  
end
