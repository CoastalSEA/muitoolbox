function hf = compile_tiled_figure(mrows,ncols)
%
%-------function help------------------------------------------------------
% NAME
%   compile_tiled_figure
% PURPOSE
%   interactively add existing axes from single axes figures to a figure
%   with multiple tiles (regular grid only)
% USAGE
%   hf = compile_tiled_figure(mrows,ncols);
% INPUT
%   mrows - number of rows in tiled grid
%   ncols - number of columns in tiled grid
% OUTPUT
%   hf - handle to compiled figure
% NOTES
%   utility function in muitoolbox
% SEE ALSO
%   uses select_figure.m
%
% Author: Ian Townend
% CoastalSEA (c) Oct 2025
%----------------------------------------------------------------------
% 
    hf = figure('Tag','PlotFig');
    t = tiledlayout(hf,mrows,ncols,'TileSpacing','compact','Padding','compact');

    getdialog('Tile order is across each row in order of rows')
    
    for i=1:mrows*ncols
        hfig = select_figure('PlotFig');        %select a figure to use

        %check whether the source figure is a tiled layout and if so find
        %the correct tile (NB not tested for subplots****)
        idx = 1;
        tiles = findobj(hfig,'Type','tiledlayout');
        if ~isempty(tiles)
            ntiles = prod(tiles.GridSize);
            promptxt = sprintf('There is a %d by %d grid. Select tile (1-%d)',...
                               tiles.GridSize(1), tiles.GridSize(2), ntiles);
            inp = inputdlg({promptxt},'Compile figure',1,{num2str(ntiles)});
            if isempty(inp), return; end
            idx = ntiles-str2double(inp{1})+1;  %tiles are held in reverse order
        end

        nobj = 3;
        objtype = {'Axes','Legend','Colorbar'};
        allObj = gobjects(1,nobj);
        for j=1:nobj
            anobj = findobj(hfig,'Type',objtype{j});
            if ~isempty(anobj)
                if numel(anobj)>1, anobj = anobj(idx); end
                allObj(j) = anobj;
            end            
        end

        %remove empty graphics placeholders
        allObj = allObj(~arrayfun(@(x) isa(x,...
                         'matlab.graphics.GraphicsPlaceholder'),allObj));
        %make a copy of the axes and legend and get the new object types
        newObjs = copyobj([allObj(:)],t);      
        newTypes = arrayfun(@(x) x.Type,newObjs,'UniformOutput',false);

        newObjs(1).Parent = t;                %axes is first object
        newObjs(1).Layout.Tile = i;           %assign to the tile

        % %ensure the legend targets the copied axes’ lines
        if any(contains(newTypes,'legend'))
            legTile = newObjs(contains(newTypes,'legend'));
            % if ~isfield(legTile,'PlotChildren')
            legTile.PlotChildren = newObjs(1).Children; 
            % Some releases need this explicit association:
            set(legTile,'Axes',newObjs(1));
        end

        if any(contains(newTypes,'colorbar'))
            cbTile = newObjs(contains(newTypes,'colorbar'));
            cbTile.Axes = newObjs(1);   % Reassociate colorbar with axes
            %Copy the colormap explicitly (if desired) 
            hf.Colormap = hfig.Colormap;
        end

    end
end