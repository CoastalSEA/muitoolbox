function isallvec = check_vector_lengths(varargin)
%
%-------function help------------------------------------------------------
% NAME
%   check_vector_lengths.m
% PURPOSE
%   check that all input values are either scalar or vectors of the same length 
% USAGE
%   isallvec = check_vector_lengths(varargin)
%INPUT
%   varargin - vector variables to be compared for length
%OUTPUT
%   isallvec - true if all vectors are the same length, false if all
%   inputs are scalar, empty if input vectors are different lengths
% SEE ALSO
%   used in tma_spectrum and ucrit
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%----------------------------------------------------------------------
%
    for i = 1:length(varargin)
        lenvars(i) = length(varargin{i});  %get the length of each input variable
    end
    
    nrec = find(lenvars>1);                %find those that are not scalar
    if isempty(nrec)
        %all inputs are scalar values
        isallvec = false;
    else
        %check that vectos are all the same length
        if length(nrec)>1 && ~all(lenvars(nrec)==lenvars(nrec(1)))
            warndlg('Vector inputs are a different length');
            isallvec = [];
            return;
        end
        isallvec = true;  %vectors are the same length
    end
end