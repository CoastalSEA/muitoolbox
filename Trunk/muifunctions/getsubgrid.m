function [xo,yo,zo,ixo,iyo] = getsubgrid(xi,yi,zi,subdomain)
%
%-------function help------------------------------------------------------
% NAME
%   getsubgrid.m
% PURPOSE
%   extract a subdomain from a grid (xi,yi,zi) and return the extracted
%   grid and the source grid indices of the bounding rectangle 
% USAGE
%   [xo,yo,zo,ixo,iyo] = getsubgrid(xi,yi,zi,subdomain)
% INPUTS
%   xi,yi,zi - input grid as x,y vectors and z array
%   subdomain - subdomain to be extracted, defined as [x0,xN,y0,yN]
% OUTPUT
%   xo,yo,zo - ouput grid for subdomain as x,y vectors and z array
%   ixo,iyo - indices of bounding subdomain in the input xi,yi grid 
% SEE ALSO
%   used in ModelSkill App getUserTools function.
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
%
%%
    %
    if isempty(subdomain)
        subdomain = [min(xi),max(xi),min(yi),max(yi)];
    end
    %find indices for bounding rectangle of subgrid
    ix0 = find(xi<=subdomain(1),1,'last');
    ixN = find(xi>=subdomain(2),1,'first');
    iy0 = find(yi<=subdomain(3),1,'last');
    iyN = find(yi>=subdomain(4),1,'first');
    ixo = [ix0,ix0,ixN,ixN,ix0];
    iyo = [iyN,iy0,iy0,iyN,iyN];
    %extract grid values within subdomain    
    xo = xi(min(ixo):max(ixo));
    yo = yi(min(iyo):max(iyo));
    zo = zi(min(iyo):max(iyo),min(ixo):max(ixo));
end