function out = match_timeseries(X1, X2)
%
%-------function help------------------------------------------------------
% NAME
%   match_timeseries.m
% PUROSE
%   Compute mappings between two multivariate time series
% USAGE
%   out = match_timeseries(X1, X2)
% INPUTS
%   X1, X2 : NxM matrices (M variables at two locations)
%   out = match_timeseries([H1 T1 D1], [H2 T2 D2]);
% OUTPUTS
%   out - struct contains fields for:
%           scaling – 1xM independent scale factors 
%           linear.A – MxM linear transform matrix 
%           linear.b – 1xM offset vector 
%           linear.resid – residuals after applying transform 
%           cca.A1 – canonical weights for X1 
%           cca.A2 – canonical weights for X2 
%           cca.r – canonical correlations
%           X1_range.min - minimum value in range of X1
%           X1_range.max - maximum value in range of X1
% NOTES
%   Handles NaNs by removing rows with any missing values.
%   Variables for X1 and X2 must be in the order that they are to be matched ie 1-M 
% SEE ALSO
%   reconstruct_timeseries.m. Both used in  in ct_data_cleanup.match_ts
%
% Author: chatGPT 5.1 
% CoastalSEA (c) Jan 2026

    %% --- Input validation -----------------------------------------------
    if nargin ~= 2
        error('Provide X1 and X2 as NxM matrices.');
    end
    if size(X1,2) ~= size(X2,2)
        error('X1 and X2 must have the same number of variables (columns).');
    end
    if size(X1,1) ~= size(X2,1)
        error('X1 and X2 must have the same number of rows.');
    end

    M = size(X1,2);  % number of variables

    %% --- Remove rows with missing data ----------------------------------
    valid = all(~isnan(X1),2) & all(~isnan(X2),2);
    X1 = X1(valid,:);
    X2 = X2(valid,:);

    %% --- 1. Independent scaling factors ---------------------------------
    scaling = zeros(1, M);
    for k = 1:M
        scaling(k) = X1(:,k) \ X2(:,k);
    end

    %% --- 2. Full multivariate linear transform --------------------------
    % Solve X1*A + b = X2
    X1_aug = [X1, ones(size(X1,1),1)];
    A_aug = X1_aug \ X2;      % (M+1) x M matrix

    A = A_aug(1:M,:);         % MxM transform
    b = A_aug(M+1,:);         % 1xM offset

    X2_hat = X1*A + b;
    resid = X2 - X2_hat;

    %% --- 3. Canonical correlation analysis ------------------------------
    [A1, A2, r] = canoncorr(X1, X2);

    %% --- Package output -------------------------------------------------
    out.scaling = scaling;

    out.linear.A = A;
    out.linear.b = b;
    out.linear.resid = resid;

    out.cca.A1 = A1;
    out.cca.A2 = A2;
    out.cca.r  = r;

    %% --- Add data Range -------------------------------------------------
    out.X1_range.min = min(X1,[],1);
    out.X1_range.max = max(X1,[],1);
end
