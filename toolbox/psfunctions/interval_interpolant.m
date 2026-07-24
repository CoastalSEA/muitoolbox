function Vq = interval_interpolant(x, tStart, v, xq, tq)
%
%-------function help------------------------------------------------------
% NAME
%   interval_interpolant.m
% PURPOSE
%   Interpolates a space–time surface where:
%     - each spatial position x(k) has its own irregular time intervals
%     - variable is piecewise-constant in time at each x
%     - variable varies in space (interpolated) 
% USAGE
%   Vq = interval_interpolant(x, tStart, v, xq, tq);
% INPUT
%   x        : vector of spatial positions (length Nx)
%   tStart   : cell array, tStart{k} = start times for x(k)
%   v        : cell array, v{k} = values for each interval at x(k)
%   xq       : query positions (length Nqx)
%   tq       : query times (length Nqt)  
% OUTPUT
%   Vq       : Nqx-by-Nqt matrix, Vq(i,j) = V(xq(i), tq(j)) 
% SEE ALSO
%   called in wrm_transport_plots.m
%
% Author: Ian Townend & Copilot
% CoastalSEA (c)July 2026
%----------------------------------------------------------------------
%
    Nx  = numel(x);
    Nqx = numel(xq);
    Nqt = numel(tq);

    % Output matrix
    Vq = nan(Nqx, Nqt);

    % --- For each query time, determine interval index at each x ---
    hw = waitbar(0,'Interpolating surface');
    N = Nx+Nqt;

    % --- For each query time, determine interval index at each x ---
    intervalIndex = cell(Nx,1);
    for k = 1:Nx
        tS = tStart{k};
        edges = [tS(:); datetime('Inf')];
        intervalIndex{k} = discretize(tq, edges);
        waitbar(k/N,hw)
    end

    % --- For each query time, build spatial interpolant for that interval ---
    % - Vectorised slice extraction
    Vslice = nan(Nx, Nqt);
    
    for k = 1:Nx
        idx = intervalIndex{k};     % interval index for this x across all tq
        vals = v{k};                % values for this x
    
        % Fix NaNs (times before first interval)
        idx(isnan(idx)) = 1; %assigns first value to times before first interval 
    
        % Clamp to valid range
        idx(idx < 1) = 1;
        idx(idx > numel(vals)) = numel(vals);
    
        % Safe vectorised assignment
        Vslice(k,:) = vals(idx);
    end
     
    % - Interpolate each time slice
    Vq = nan(numel(xq), Nqt);
    
    for j = 1:Nqt
        F = griddedInterpolant(x(:), Vslice(:,j), 'linear', 'nearest');
        Vq(:,j) = F(xq);
    end
end

