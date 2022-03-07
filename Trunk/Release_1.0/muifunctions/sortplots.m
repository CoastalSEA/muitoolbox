function ordered_hp = sortplots(hp)
%
%-------function help------------------------------------------------------
% NAME
%   sortplots.m
% PURPOSE
%   reorder plot handles so that the legend plots in sequence added
% USAGE
%   orderedhp = sortplots(hp)
% INPUTS
%   hp - handles to an array of graphical objects
% OUTPUT
%   ordred_hp - handle to ordered array based on values in the Tag property
% SEE ALSO
%   used in muiPlots.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    linetag = zeros(1,length(hp));
    for i = 1:length(hp)
        linetag(i) = str2double(hp(i).Tag);
    end
    [~,idx] = sort(linetag);
    ordered_hp = hp(idx);            
end