function y = general_logistic(x,p,isinv)
%
%-------header-------------------------------------------------------------
% NAME
%   general_logisitic.m
% PURPOSE
%   function to return a curve defined by the generalised logisitc equation
% INPUTS
%   x - data
%   p - struct containing:
%       A - left horizontal asymptote
%       B - growth rate
%       C - upper asymptote of A+(K-A)/C^(1/nu) - typically 1
%       K - right horizontal asymptote when C=1
%       nu >0 - affects proximity to which asymptote maximum growth occurs
%       M - start point
%       Q- related to the value y(0).
%   isinv - logical flag to invert the y values 
% OUTPUTS
%   y - values at x
% SEE AlSO
%   https://en.wikipedia.org/wiki/Generalised_logistic_function
% USAGE
%   x = (0:0.1:5)-1.5;
%   params = struct('A',0,'B',3,'C',1,'K',1,'nu',0.5,'M',0,'Q',0.5);
%   y = general_logistic(x,params,true);
%
% Author: Ian Townend
% CoastalSEA (c) Apr 2024
%--------------------------------------------------------------------------
%        
    nom = p.K-p.A;
    denom = (p.C+p.Q*exp(-p.B*(x-p.M))).^(1/p.nu);
    y = p.A+nom./denom;        %general logistic values
    if isinv
        y = 1-y;               %inverted values
    end
end
