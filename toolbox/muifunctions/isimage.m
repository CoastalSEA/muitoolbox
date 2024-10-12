function isim = isimage(array)
%
%-------header-------------------------------------------------------------
% NAME
%   isimage.m
% PURPOSE
%   test whether an array is the right size and data type to be an image
% USAGE
%   isim = isimage(array);
% INPUTS
%   array - array to be tested - can be a matrix for grey sccale images or 
%   an [m,n,3] array for colour images with numerical values permissable
%   for the image type. array can be the image array or a cell containing
%   the array
% OUTPUT
%   isim -  array of logical values - true if array is an image
%           isim(1) is for truecolor and isim(2) is for greyscale
%           NB: these are separated because the greyscale condition could 
%           be an array that is not an image
% NOTES
%   based on valid type for data input in imshow:
%   greyscale or binary - int8, int16, int32, int64, uint8, uint16, uint32, 
%                         uint64, single, or double
%   truecolor - int8, int16, single, or double
% Author: Ian Townend
% CoastalSEA (c) Oct 2024
%--------------------------------------------------------------------------
% 
    if iscell(array), array = cell2mat(array); end
    %greyscale or binary array (NB this could be a non-image array)
    isgs = ismatrix(array) && ~isvector(array) && ...
                       (isnumeric(array) || islogical(array));
    %truecolor array - because thrid dimension is 3 most likely to be image
    istc = ndims(array)==3 && size(array, 3)==3 && ...   
                (isa(array, 'uint8') || isa(array, 'uint16') || ...
                   isa(array, 'single') || isa(array, 'double'));

    isim = [istc,isgs];
end
