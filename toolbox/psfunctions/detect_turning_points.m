function [hf, turnIdx, turnTimes, turnValues, slopes] = detect_turning_points(t, y, smoothWindow,isplot)
% detectTrendTurningPoints
% Detects turning points in the *trend* of a time series (not raw peaks/troughs).
%
% INPUTS:
%   t            - Time vector (numeric, same length as y)
%   y            - Data vector
%   smoothWindow - Window size for smoothing (default = 10)
%   isplot       - logical flag to create plot if true (optional default false)
%
% OUTPUTS:
%   hf           - handle to figure
%   turnIdx      - Indices of turning points in the trend
%   turnTimes    - Corresponding times of turning points
%   turnValues   - Corresponding values of turning points
%   slopes       - Slope of each linear segment between turning points
%
% Example:
%   t = (1:100)';
%   y = cumsum(randn(100,1) + 0.1);
%   [idx, tt, tv] = detectTrendTurningPoints(t, y, 8);

    if nargin < 3
        smoothWindow = 10; % default smoothing window
        isplot = false;
    elseif nargin<4
        isplot = false;
    end

    % Ensure column vectors
    t = t(:);
    y = y(:);

    % Step 1: Smooth the data to get the underlying trend
    yTrend = smoothdata(y, 'loess', smoothWindow);

    % Step 2: Compute slope (first derivative)
    dy = gradient(yTrend);

    % Step 3: Find zero-crossings in slope (trend turning points)
    signChange = diff(sign(dy));
    turnIdx = find(signChange ~= 0) + 1; % +1 to align with actual index
    turnIdx = [1;turnIdx;numel(yTrend)];

    % Step 4: Extract times and values (pad with end values)
    turnTimes = t(turnIdx);
    turnValues = yTrend(turnIdx);

    % Step 5: Convert time differences to numeric for slope calculation
    if isdatetime(t) || isduration(t)
        dtNumeric = years(diff(turnTimes)); % slope per year
    else
        dtNumeric = diff(turnTimes); % numeric time
    end

    slopes = diff(turnValues) ./ dtNumeric;

    % Step 6: Plot results
    if isplot
        hf = figure('Tag','PlotFig');
        plot(t, y, 'k:', 'LineWidth', 1); hold on;
        plot(turnTimes, turnValues, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);

    % Draw straight lines between turning points
    for i = 1:length(turnIdx)-1
        segT = [turnTimes(i), turnTimes(i+1)];
        segY = [turnValues(i), turnValues(i+1)];
        plot(segT, segY, 'b-', 'LineWidth', 1.5);
    end

    xlabel('Time');
    ylabel('Value');
    title('Trend Turning Points with Linear Segments');
    legend('Raw Data', 'Turning Points', 'Trend Segments', 'Location', 'best');
    grid on;
    end
end
