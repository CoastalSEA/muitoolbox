function [xint,yint] = check_xyz_dims(xint,yint)
%
%-------function help------------------------------------------------------
% NAME
%   check_xyz_dims.m
% PURPOSE
%   check that dimensions of array for 3D plotting are not too big
% USAGE
%   [xint,yint] = check_xyz_dims(xint,yint)
% INPUTS
%   xint - number of intervals on the x-axis
%   yint - number of intervals on the y-axis
% OUTPUT
%   xint - number of intervals on the x-axis (adjusted as needed)
%   yint - number of intervals on the y-axis (adjusted as needed)
% SEE ALSO
%   used in muiPlots
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    [~, sys] = memory;
    maxdim = sys.PhysicalMemory.Available;  %depends on available memory
    arraydim = maxdim+1;
    
    while arraydim>maxdim
        prompt = {'Define number of intervals for X-axis', ...
            'Define number of intervals for Y-axis'};
        inptitle = 'Define gridding interval';
        numlines = 1;
        defaultvalues{1} = num2str(floor(xint));
        defaultvalues{2} = num2str(floor(yint));
        useInp=inputdlg(prompt,inptitle,numlines,defaultvalues);
        if isempty(useInp)        %user cancelled
            xint =[]; yint = [];  %cannot be preset because in and out
            return; 
        end 
        
        xint = str2double(useInp{1});
        yint = str2double(useInp{2});
        arraydim = xint*yint;
        if arraydim > maxdim
            hw = warndlg(sprintf('X*Y dimensions must be less than %1.0e',maxdim));
            uiwait(hw);
        end
    end
end 