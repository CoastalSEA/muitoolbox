function newvar = diffpadded(var,n,dim,ispost)
%
%-------function help------------------------------------------------------
% NAME
%   diffpadded.m
% PURPOSE
%  Differences and approximate derivatives padded to be same length as
%  input variable
% USAGE
%   newvar = diffpadded(var,n,dim,ispost)
% INPUTS
%   var - input array, specified as a vector, matrix, or multidimensional array. 
%   n - difference order, calculates the nth difference by applying the 
%       diff(X) operator recursively n times
%   dim - dimension to operate along (NB: coded for up to 3D)
%   ispost - true if NaN is to be added to end of record (optional)
%           default is to add to the start of the record
% OUTPUT
%   newvar - padded array of differences, returned as a scalar, vector, 
%            matrix, or multidimensional array.
% SEE ALSO
%   used as a function call from Derive Ouput UI
%
% Author: Ian Townend
% CoastalSEA (c) July 2022
%--------------------------------------------------------------------------
    diffvar = diff(var,n,dim);
    
    sz = num2cell(size(var));
    newvar = NaN(sz{:});
    if ispost
        if dim==1
            newvar(1:end-1,:,:) = diffvar;
        elseif dim==2
            newvar(:,1:end-1,:) = diffvar;
        else
            newvar(:,:,1:end-1) = diffvar;
        end            
    else
        if dim==1
            newvar(2:end,:,:) = diffvar;
        elseif dim==2
            newvar(:,2:end,:) = diffvar;
        else
            newvar(:,:,2:end) = diffvar;
        end  
    end
end
    
    
    
