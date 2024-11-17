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
    
    props = [];
    [UIsel,UIset] = selectui(mobj,promptxt,varargin{:});      %calls UI to make selection
    if isempty(UIsel), return; end %user cancelled
    sel.caserec = UIsel(1).caserec;
    [~,sel.classrec] = getCase(mobj.Cases,UIsel(1).caserec);  %included to be consistent with get_variable
    props = getProperty(mobj.Cases,UIsel,'array');
    sel.scale = UIset.scaleList{UIsel(1).scale};
    if UIsel(1).scale>1
        %adjust data if user has selected to rescale variable
        dim = 1; %dimension to apply scaling function if matrix
        props.data = scalevariable(props.data,props.scale,dim);
        props.label = sprintf('%s-%s',props.scale,props.label);
        props.desc = sprintf('%s-%s',props.scale,props.desc); %????
    end
end




