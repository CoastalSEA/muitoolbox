function replace_tile(figTiled, srcAxes, row, col)
% replace_tile Replace a tile in a tiledlayout with a copied axes
%
%   replace_tile(figTiled, srcAxes, row, col)
%   - figTiled : handle to figure containing a tiledlayout
%   - srcAxes  : handle to the source axes to copy
%   - row, col : tile position (1-based indexing)
%
%   Example:
%       replace_tile(figTgt, axSrc, 2, 1);

    % --- Validate inputs ---
    if ~ishandle(figTiled) || ~strcmp(get(figTiled, 'Type'), 'figure')
        error('First argument must be a valid figure handle.');
    end
    if ~ishandle(srcAxes) || ~strcmp(get(srcAxes, 'Type'), 'axes')
        error('Second argument must be a valid axes handle.');
    end
    if ~isscalar(row) || ~isscalar(col) || row < 1 || col < 1
        error('Row and column must be positive integers.');
    end

    % --- Find the tiledlayout in the figure ---
    tLayouts = findall(figTiled, 'Type', 'tiledlayout');
    if isempty(tLayouts)
        error('The target figure does not contain a tiledlayout.');
    end
    t = tLayouts(1); % Assume first tiledlayout

    % --- Check bounds ---
    if row > t.GridSize(1) || col > t.GridSize(2)
        error('Row/column exceeds tiledlayout grid size.');
    end

    % --- Convert row/col to tile index (row-major order) ---
    tileIndex = (row - 1) * t.GridSize(2) + col;

    % --- Get the target axes in that tile ---
    axTgt = nexttile(t, tileIndex);

    % --- Delete the existing axes in that tile ---
    delete(axTgt);

    % --- Create a new axes in the correct tile ---
    axNew = nexttile(t, tileIndex);

    % --- Copy children from source axes ---
    copyobj(allchild(srcAxes), axNew);

    % --- Copy limits first ---
    axNew.XLim = srcAxes.XLim;
    axNew.YLim = srcAxes.YLim;
    axNew.ZLim = srcAxes.ZLim;
    axNew.CLim = srcAxes.CLim;

    % --- Now copy tick positions and labels ---
    axNew.XTick = srcAxes.XTick;
    axNew.YTick = srcAxes.YTick;
    axNew.ZTick = srcAxes.ZTick;

    axNew.XTickLabel = srcAxes.XTickLabel;
    axNew.YTickLabel = srcAxes.YTickLabel;
    axNew.ZTickLabel = srcAxes.ZTickLabel;

    % Lock tick modes so MATLAB doesn't overwrite them
    axNew.XTickMode = 'manual';
    axNew.YTickMode = 'manual';
    axNew.ZTickMode = 'manual';
    axNew.XTickLabelMode = 'manual';
    axNew.YTickLabelMode = 'manual';
    axNew.ZTickLabelMode = 'manual';
    axNew.CLimMode = 'manual';

    % --- Copy other properties ---
    % datetick('y','yyyy'); %#ok<DATIC>  Bespoke*****
    grid on               %************************

    axNew.XLabel.String = srcAxes.XLabel.String;
    axNew.YLabel.String = srcAxes.YLabel.String;
    axNew.ZLabel.String = srcAxes.ZLabel.String;
    axNew.Title.String  = srcAxes.Title.String;
    axNew.View          = srcAxes.View;
    axNew.Colormap      = srcAxes.Colormap;
    
end

