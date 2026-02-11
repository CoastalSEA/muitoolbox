function out = reconstruct_timeseries(X1_new, model, X2_true)
%
%-------function help------------------------------------------------------
% NAME 
%   reconstruct_timeseries.m
% PURPOSE
%   apply a learned linear transform to X1 to match X2 and test match 
%   against additional validation data from X2
% USAGE
%   for reconstruction or extension of timeseries use:
%       out = reconstruct_timeseries(X1_new, model);    
%   for validation of timeseries use:
%       out = reconstruct_timeseries(X1_overlap, model, X2_overlap);
% INPUTS
%   X1_new : NxM matrix of new predictor data
%   model  : struct from match_timeseries (uses model.linear.A and model.linear.b)
%   X2_true (optional) : NxM matrix of true X2 for validation
% OUTPUTS
%   out - struct contains fields for:
%         X2_est      – reconstructed X2
%         skill       – struct of RMSE, bias, correlation (if X2_true provided)
%         rangeCheck  – struct showing extrapolation risk
% NOTES
%   This function does not modify the model; it only applies it.
%   Variables for X1 and X2 must be in the order that they are to be matched ie 1-M 
% SEE ALSO
%   match_timeseries.m which is used in ct_data_cleanup.match_ts
%
% Author: chatGPT 5.1 
% CoastalSEA (c) Jan 2026

    %% --- Input validation -------------------------------------------------
    if ~isfield(model, 'linear') || ~isfield(model.linear, 'A')
        error('MODEL must be the output of match_timeseries with .linear.A and .linear.b.');
    end

    A = model.linear.A;
    b = model.linear.b;

    if size(X1_new,2) ~= size(A,1)
        error('X1_new must have the same number of variables (columns) as the model.');
    end

    %% --- 1. Apply the transform ------------------------------------------
    X2_est = X1_new * A + b;

    out.X2_est = X2_est;



    %% --- 2. Skill metrics (if X2_true provided) ---------------------------
    if nargin >= 3 && ~isempty(X2_true)
        if size(X2_true) ~= size(X2_est)
            error('X2_true must match the size of X1_new.');
        end

        %% --- Remove rows with missing data ----------------------------------
        valid = all(~isnan(X2_est),2) & all(~isnan(X2_true),2);
        X2_est = X2_est(valid,:);
        X2_true = X2_true(valid,:);    

        M = size(X2_true,2);
        rmse = zeros(1,M);
        bias = zeros(1,M);
        corrv = zeros(1,M);
        for k = 1:M 
            ek = X2_est(:,k) - X2_true(:,k); 
            rmse(k) = sqrt(mean(ek.^2)); 
            bias(k) = mean(ek); 
            C = corrcoef(X2_est(:,k), X2_true(:,k)); 
            corrv(k) = C(1,2); 
        end
        out.skill = table(rmse(:),bias(:),corrv(:),'RowNames',model.rows(:),...
                           'VariableNames',{'RMSE','Bias','Corr'});
    end

    %% --- 3. Range / extrapolation check ----------------------------------
    if isfield(model, 'X1_range')
        % If you want, we can store ranges in match_timeseries later
        oldMin = model.X1_range.min;
        oldMax = model.X1_range.max;

        newMin = min(X1_new,[],1);
        newMax = max(X1_new,[],1);

        out.rangeCheck.oldMin = oldMin;
        out.rangeCheck.oldMax = oldMax;
        out.rangeCheck.newMin = newMin;
        out.rangeCheck.newMax = newMax;

        out.rangeCheck.exceeds = (newMin < oldMin) | (newMax > oldMax);
    else
        out.rangeCheck = 'No range info stored in model.';
    end
end
