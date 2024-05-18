function var = get_variable(mobj,promptxt)
%
%-------function help------------------------------------------------------
% NAME
%   get_variable.m
% PURPOSE
%   retrieve selected variable based on selection made using selectui
% USAGE
%   var = get_variable(mobj)
% INPUTS
%   mobj - ModelUI instance
%   promptxt - text used as prompt in selection UI (optional)
% OUTPUT
%   var - data and metadata for selected variable. struct with fields:
%         name, data, label, desc
% NOTES
%    called from edb_tools and edg_user_plot as part of EstuaryDB App.
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

    cobj = getCase(mobj.Cases,UIsel(1).caserec); %selected class instance
    dsnames = fieldnames(cobj.Data);
    dst = cobj.Data.(dsnames{UIsel(1).dataset}); %selected dstable
    var.name = dst.VariableNames{UIsel(1).variable};
    var.data= dst.(var.name);
    var.label = dst.VariableLabels{UIsel(1).variable};
    var.desc = dst.Description;
    if UIsel(1).scale>1
        %adjust data is user has selected to rescale variable
        usescale = UIset.scaleList{UIsel(1).scale};
        dim = 1; %dimension to apply scaling function if matrix
        var.data = scalevariable(var.data,usescale,dim);
        var.label = sprintf('%s-%s',usescale,var.label);
    end
end