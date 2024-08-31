function rotatebutton(hax,src,~)
%
%-------function help------------------------------------------------------
% NAME
%   rotatebutton.m
% PURPOSE
%   callback for the rotate button on a figure or tab plot
% USAGE
%   rotatebutton(hax,src,~)
% INPUTS
%   hax - plot axes handle
%   src - src is the button handle that called rotatebutton
% OUTPUT
%   
% SEE ALSO
%   used in
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    ha = findobj(hax);
    if isempty(ha), rotate3d off; return; end
    hr = rotate3d(hax);
    if strcmp(hr.Enable,'on')   %if on, switch off
        hr.Enable = 'off';
        src.String = 'Rotate off';
    else                        %if off, switch on
        hr.Enable = 'on';
        src.String = 'Rotate on'; 
    end              
end   