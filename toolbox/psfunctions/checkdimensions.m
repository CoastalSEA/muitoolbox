function isvalid = checkdimensions(varargin)
%
%-------function help------------------------------------------------------
% NAME
%   scatter_plot.m
% PURPOSE
%   check that the dimensions of the selected data match
% USAGE
%   scatter_plot(varargin)
%   e.g. scatter_plot(x,y) where x and y are vectors or arrays
%        scatter_plot(obj) where obj is muiPlots or class derived from muiPlots
% INPUTS
%   varargin - either two vectors or matrices to be compared, or a class
%              instance derived from muiPlots where obj.Data holds a struct
%              of the input variables to be checked
% OUTPUT
%   isvalid - logical true if the selected input variables match
% SEE ALSO
%   muiPlots, scatter_plot.m
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
%
    isvalid = false;    
    nrec = length(varargin);
    if nrec==1
        obj = varargin{1}; %call from muiPlot or related class    
        data = struct2cell(obj.Data);
        vecdim = cellfun(@isvector,data);
        dimlen = cellfun(@length,data(vecdim));
        matsze = cellfun(@numel,data(~vecdim))/dimlen;
        if all(vecdim)          %all data are vectors
            isvalid = true;
        elseif diff(matsze)==0  %a vector + arrays of same size
            isvalid = true;
        else                    %vectors that match array size
            varsz = size(data{~vecdim});
            isvalid = all(ismember(varsz(varsz>1),dimlen));
        end    
    elseif nrec==2
        x = varargin{1}; 
        y = varargin{2};         
        if isvector(x)
            %check that the dimensions of the selected vectors match
            if length(x)==length(y)
                isvalid = true; 
            end
        elseif ismatrix(x)
            %check that the dimensions of the selected matrices match
            if isequal(size(x), size(y))
                isvalid = true; 
            end
        end 
    else
        warndlg('Input not recognised in checkdimensions');
        isvalid = false; return;
    end
    %
    if ~isvalid
        warndlg('Dimensions of selected variables do not match')
    end
end