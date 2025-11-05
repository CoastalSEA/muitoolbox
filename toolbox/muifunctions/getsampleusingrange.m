function newdst =getsampleusingrange(obj)
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
    timerange = var2range(obj.RowRange);
    selection = inputgui('FigureTitle','Levels',...
                         'InputFields',{'Time'},...
                         'Style',{'edit'},...
                         'ControlButtons',{'Ed'},...
                         'ActionButtons', {'Select','Cancel'},...
                         'DefaultInputs',{timerange},...
                         'PromptText','Select time range to use');
    if isempty(selection)
        newdst = copy(obj);
    else
        seltime = range2var(selection{1});                
        newdst = getsampleusingtime(obj,seltime{:});
    end 
end