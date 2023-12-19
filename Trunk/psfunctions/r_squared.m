function R2 = r_squared(z,zest)
%
%-------function help------------------------------------------------------
% NAME
%   r_squared.m
% PURPOSE
%   compute the R-squared value a measure of goodness of fit between the 
%   observed data and its estimation (may be from a regression or other model)
% USAGE
%   R2 = r_squared(z,zest)
% INPUTS
%   z - observed data
%   zest - model estimate
% OUTPUT
%   R2 - R-squared value, or Coefficient of determination
% NOTES
%   based on calcuateR2.m - Calculate R-squared 
%   R2 = calcuateR2(z,z_est) takes two inputs - The observed data x and its
%   estimation z_est (may be from a regression or other model), and then
%   compute the R-squared value a measure of goodness of fit. R2 = 0
%   corresponds to the worst fit, whereas R2 = 1 corresponds to the best fit.
% SEE ALSO
%   stderror.m and regression_model.m
% 
% Copyright @ Md Shoaibur Rahman (shaoibur@bcm.edu)
%https://www.mathworks.com/matlabcentral/fileexchange/55128-calculate-r-squared-value
% modified to handle NaNs, IHT, 19 Dec 23
%--------------------------------------------------------------------------
%
    T = table(z,zest);
    T = rmmissing(T);
    r = T.z-T.zest;
    normr = norm(r);
    SSE = normr.^2;
    SST = norm(T.z-mean(T.z))^2;
    R2 = 1 - SSE/SST;
end
