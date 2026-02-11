function [newdst,ok] =getsampleusingrange(obj,promptxt)
%
%-------function help------------------------------------------------------
% NAME
%   getsampleusingrange.m
% PURPOSE
%    uses an input UI to obtain a date range and then extract the data for
%    that range from the input table
% USAGE
%    newdst =getsampleusingrange(obj)
% INPUTS
%   obj - instance of a dstable class object
%   promptxt - prompt to use (optional)
% OUTPUTS
%   newdst - dstable containing data for the selected time range
% NOTES
%   uses inputUI to get datetime and function getsampleusingtime in dstable
% SEE ALSO
%   used in ctWaveSpectra and waveModels
%
% Author: Ian Townend
% CoastalSEA (c) Oct 2025
%
%--------------------------------------------------------------------------
% 
    if nargin<2, promptxt = 'Select time range to use'; end

    timerange = var2range(obj.RowRange);
    selection = inputgui('FigureTitle','Levels',...
                         'InputFields',{'Time'},...
                         'Style',{'edit'},...
                         'ControlButtons',{'Ed'},...
                         'ActionButtons', {'Select','Cancel'},...
                         'DefaultInputs',{timerange},...
                         'PromptText',promptxt);
    if isempty(selection)
        newdst = copy(obj);
        ok = 0;  %user cancelled
    else
        seltime = range2var(selection{1});                
        newdst = getsampleusingtime(obj,seltime{:});
        ok = 1;
    end 
end