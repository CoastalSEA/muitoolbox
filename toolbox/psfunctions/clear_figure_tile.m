function clear_figure_tile(tiledLayoutObj, row, col, varargin)
% clear_figure_tile  Clears or removes a specific tile in a tiledlayout by row/column.
%
%   clear_figure_tile(tiledLayoutObj, row, col) clears the contents of the
%   specified tile but keeps axis properties (labels, limits, etc.).
%
%   clear_figure_tile(..., 'reset', true) resets axes to default settings.
%   clear_figure_tile(..., 'remove', true) completely removes the axes from the tile.
%
%   Inputs:
%       tiledLayoutObj - Handle to a tiledlayout object
%       row, col       - Row and column of the tile (1-based)
%
%   Row/column indexing is 1-based and follows the layout's grid order.
%
%   Example:
%       t = tiledlayout(2,2);
%       for k = 1:4
%           ax = nexttile;
%           plot(ax, rand(1,5));
%       end
%       clear_figure_tile(t, 1, 2); % Clear tile at row 1, col 2
%       clear_figure_tile(t, 2, 1, 'remove', true); % Remove tile at row 2, col 1

    % --- Validate layout object ---
    if ~isa(tiledLayoutObj, 'matlab.graphics.layout.TiledChartLayout')
        error('First argument must be a tiledlayout object.');
    end

    % --- Validate row/col ---
    if ~isscalar(row) || ~isscalar(col) || row < 1 || col < 1
        error('Row and column must be positive integers.');
    end

    % Parse optional flags
    p = inputParser;
    addParameter(p, 'reset', false, @(x)islogical(x) && isscalar(x));
    addParameter(p, 'remove', false, @(x)islogical(x) && isscalar(x));
    parse(p, varargin{:});
    resetAxes = p.Results.reset;
    removeAxes = p.Results.remove;

    % Get layout size
    layoutRows = tiledLayoutObj.GridSize(1);
    layoutCols = tiledLayoutObj.GridSize(2);

    if row > layoutRows || col > layoutCols
        error('Row/column exceeds layout size (%dx%d).', layoutRows, layoutCols);
    end

    % --- Compute tile index in row-major order ---
    tileIndex = (row - 1) * layoutCols + col;

    % --- Get the correct axes handle using nexttile ---
    targetAx = nexttile(tiledLayoutObj, tileIndex);

    % --- Perform action ---
    if removeAxes
        delete(targetAx); % Completely remove axes
    elseif resetAxes
        cla(targetAx, 'reset'); % Clear and reset axes
    else
        cla(targetAx); % Clear contents but keep axes properties
    end
end


