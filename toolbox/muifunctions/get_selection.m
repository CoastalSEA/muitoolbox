function [props,sel] = get_selection(mobj,promptxt,varargin)
%
%-------function help------------------------------------------------------
% NAME
%   get_selection.m
% PURPOSE
%   retrieve selected variable or dimension based on selection made 
%   using selectui
% USAGE
%   var = get_selection(mobj,promptxt,varagin)
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
%   scaled data is returned if this option is selected
%   alternative to get_variable which only allows variables to be selected
% SEE ALSO
%   calls selectui and muiSelectUI
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
% 
    if nargin<2
        promptxt = 'Select data:'; 
        varargin = {};
    elseif nargin<3
        varargin = {};
    end
       
    [UIsel,UIset] = selectui(mobj,promptxt,varargin{:});      %calls UI to make selection
    if isempty(UIsel), props = []; sel = [];  return; end %user cancelled

    for i=1:length(UIsel)
        sel(i).caserec = UIsel(i).caserec; %#ok<*AGROW> 
        [sel(i).obj,sel(i).classrec] = getCase(mobj.Cases,UIsel(i).caserec);  %included to be consistent with get_variable
        props(i) = getProperty(mobj.Cases,UIsel(i),'array');
        sel(i).scale = UIset.scaleList{UIsel(i).scale};
        if UIsel(1).scale>1 %only test first selection because all must be same
            %adjust data if user has selected to rescale variable
            dim = 1; %dimension to apply scaling function if matrix
            props(i).data = scalevariable(props(i).data,sel(i).scale,dim);
            props(i).label = sprintf('%s-%s',sel(i).scale,props(i).label);
            props(i).desc = sprintf('%s-%s',sel(i).scale,props(i).desc); 
        end
    end
end




