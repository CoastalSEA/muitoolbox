function [isdd,isdt] = isdatdur(varnames,varargin)
%
%-------function help------------------------------------------------------
%NAME
%   isdatdur.m
%PURPOSE
%   identify whether RowNames or Variable in a dstable are datetime or
%   duration
% USAGE
%   [isdd,isdt] = isdatdur(varnames,dst1,dst2)
% INPUT
%   varnames - character vector or cell array of variables to test in same
%              order as the dstables to which they apply
%   varargin - one or more dstables, or an array of dstables
% OUTPUT
%   vectors of logical results in order of input dstables
%   isdd : true - datetime or duration; false - npt either data type
%   isdt : true - datetime; false - duration;
%          
% NOTES
%   
% SEE ALSO
%   used in muiStats.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%--------------------------------------------------------------------------
%
    if length(varargin)==1 && length(varargin{1})>1
        %input is an arrary of dstables 
        varargin = num2cell(varargin{1});
    end
    nvar = length(varargin);
    isdd(1,nvar) = false;
    isdt(1,nvar) = false;
    %
    if ~iscell(varnames)
        %same varname applies to all dstables
        varnames = repmat({varnames},nvar,1);
    elseif length(varnames)~=nvar
        warndlg('Error in isdatdur. varnames must be a cell array of same length as the number of dstables')
        return
    end
    %
    for i=1:nvar
        %test selected varname for each input dstable
        if isdatetime(varargin{i}.(varnames{i}))
            isdd(i) = true;
            isdt(i) = true;
        elseif isduration(varargin{i}.(varnames{i}))
            isdd(i) = true;
        end
    end
end
    