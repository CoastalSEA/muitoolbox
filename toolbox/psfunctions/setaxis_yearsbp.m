function setaxis_yearsbp(cfig,zeroyear)
%
%-------function help------------------------------------------------------
% NAME
%   setaxis_yearsbp.m
% PURPOSE
%   adjust the x-axis to display years Before Present (BP), reverse
%   the axis tick labels and add new axis label
% USAGE
%   setaxis_yearsbp; or setaxis_yearsbp(cfig); or setaxis_yearsbp(cfig,zeroyear);
% INPUTS
%   cfig - handle to figure to modify (optional)
%   zeroyear - year for Present when defining Years Before Present (optional)
% OUTPUT
%   updated figure
% NOTE
%   changes the x-axis labels and tick-labels but not the x-axis values
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
% 
    if nargin<1 || isempty(cfig)
        cfig = selectedFigure; 
    end
    figure(cfig);
    ax = gca;
    ax.XLabel.String = 'Years BP';
    xtcks = ax.XTick;
    if nargin<2
        zeroyear = xtcks(end);
    end
    ax.XTickLabel = zeroyear-xtcks;
end
%
function cfig = selectedFigure
    %prompt user to select a figure
    cfig = [];
    figs = findall(0,'type','figure');
    if isempty(figs), return; end
    fignums = [figs(:).Number];
    if length(fignums)>1
        prmptxt = 'Select Figure Number:';                       
        hd = listdlg('PromptString',prmptxt,'ListString',string(fignums'),...
                     'ListSize',[100,200],'SelectionMode','single'); 
        if isempty(hd), return; end
    else
        hd = fignums;
    end
    
    cfig = figs(hd);
end
