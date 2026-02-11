function [tin,vm] = wrap_angle(var,tin,varRange,israd)
%
%-------function help------------------------------------------------------
% NAME
%   wrap_angle.m
% PURPOSE
%   wrap a direction variable over a defined range using degree or radian
%   input
% USAGE
%   [tin,vm] = wrap_angle(var,tin,israd)
% INPUTS
%   var - input vector of angles in degrees or radians
%   tin - time variable not used, just passed to output
%   varRange - 2 element vector with min and max range values in degrees
%              eg [-180,180] or [0,360]
%   israd - flag, true if input variable is in radians (optional, defaults
%           to false)
% OUTPUT
%   tin - time variable for data assignement
%   vm - direction variable mapped to varRange interval (degrees)
% NOTES
%   output suitable for use in muiManipUI class
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2026
%--------------------------------------------------------------------------
%
	if nargin<4
		israd = false;
	end
	%
    if israd
        var = rad2deg(var,360);
    end
    range = abs(varRange(2)-varRange(1));
	vm = mod(var-varRange(1),range)+varRange(1);
end
