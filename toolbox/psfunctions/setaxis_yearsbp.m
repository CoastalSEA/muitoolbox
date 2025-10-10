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
%   cfig - handle to figure to modify (optional). If figure handle is not
%          included user is prompted to select an existing figure
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
        cfig = select_figure; 
    end
    figure(cfig);
    ax = gca;
    ax.XLabel.String = 'Years BP';
    xtcks = ax.XTick;
    if nargin<2
        zeroyear = ax.XLim(2);    %use upper x-limit as the Present
    end
    newtime = zeroyear-xtcks;
    if contains(xtcks.Format,'u')
        newtime.Format = 'y';     %force to years if generic format
    else
        newtime.Format = xtcks.Format;
    end

    ax.XTickLabel = string(newtime);
end
