function var = get_variable(mobj,promptxt)
%
%-------function help------------------------------------------------------
% NAME
%   get_variable.m
% PURPOSE
%   retrieve selected variable based on selection made using selectui
% USAGE
%   var = get_variable(mobj,promptxt)
% INPUTS
%   mobj - ModelUI instance
%   promptxt - text used as prompt in selection UI (optional)
% OUTPUT
%   var - data and metadata for selected variable. struct with fields:
%         caserec, classrec, name, data, label, desc, case, scale
% NOTES
%   called from tableviewer_user_plots as part of TableViewer App.
% SEE ALSO
%   calls selectui and muiSelectUI
%
% Author: Ian Townend
% CoastalSEA (c) May 2024
%--------------------------------------------------------------------------
% 
    if nargin<2, promptxt = 'Select variable:'; end
    
    [UIsel,UIset] = selectui(mobj,promptxt);      %calls UI to make selection
    if isempty(UIsel), var = []; return; end
    
    var.caserec = UIsel(1).caserec;
    [cobj,var.classrec] = getCase(mobj.Cases,UIsel(1).caserec); %selected class instance
    dsnames = fieldnames(cobj.Data);
    dst = cobj.Data.(dsnames{UIsel(1).dataset}); %selected dstable
    var.name = dst.VariableNames{UIsel(1).variable};
    var.data= dst.(var.name);
    var.label = dst.VariableLabels{UIsel(1).variable};
    var.desc = dst.VariableDescriptions{UIsel(1).variable};
    var.case = dst.Description;
    var.scale = UIset.scaleList{UIsel(1).scale};
    if UIsel(1).scale>1
        %adjust data if user has selected to rescale variable
        dim = 1; %dimension to apply scaling function if matrix
        var.data = scalevariable(var.data,var.scale,dim);
        var.label = sprintf('%s-%s',var.scale,var.label);
    end
end