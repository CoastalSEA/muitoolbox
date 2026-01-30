function h = getplothandles(ax)
%
%-------function help------------------------------------------------------
% NAME
%   getplothandles.m
% PURPOSE
%   find only the handles corresponding to actual plotted data (plot, line, 
%   scatter, stem, bar, etc.) from the specified axes (ax).
% USAGE
%   h = getplothandles(ax);
% INPUT
%   ax - axes handle
% OUTPUT
%   h - array of handles corresponding to actual plotted data (plot, line, 
%   scatter, stem, bar, etc.) from the specified axes, ax
%   
% SEE ALSO
%   generated using chatGPT
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2026
%--------------------------------------------------------------------------
%
    if nargin < 1 || isempty(ax)
        ax = gca;
    end

    % Detect whether yyaxis is in use    
    % yyaxis always creates two YAxis objects; normal axes have one
    axList = allchild(ax);

    % Valid plot-related graphics types
    validTypes = [
        "line" ...
        "scatter" ...
        "bar" ...
        "stem" ...
        "stair" ...     % <-- stairs() produces 'stair'
        "area" ...
        "patch" ...
        "surface" ...
        "image" ...
        "contour" ...
        "quiver" ...
        "histogram" ...
        "errorbar" ...
        "hggroup"];     % used internally for some plot types  

    h = gobjects(0);  % output as graphics array
    for anaxis = axList
        if isempty(anaxis)
            continue
        end

        % Get Type robustly
        types = get(anaxis,'Type');
        if ischar(types)
            types = {types};
        end
        types = string(types);

        % First pass: filter by type
        raw = anaxis( ismember(types, validTypes) );

        % Expand hggroup containers and keep chart primitives
        for k = 1:numel(raw)
            obj = raw(k);

            % High-level chart primitives (scatter, bar, histogram, etc.)
            if isa(obj, "matlab.graphics.chart.primitive.Chart")
                h(end+1) = obj; %#ok<AGROW>
                continue
            end

            % Simple primitives (line, stair, patch, etc.)
            if ~strcmp(obj.Type, "hggroup")
                h(end+1) = obj; %#ok<AGROW>
                continue
            end

            % hggroup: extract children
            groupKids = obj.Children;
            if ~isempty(groupKids)
                gTypes = get(groupKids,'Type');
                if ischar(gTypes)
                    gTypes = {gTypes};
                end
                gTypes = string(gTypes);

                mask = ismember(gTypes, validTypes);
                h = [h; groupKids(mask)]; %#ok<AGROW>
            end
        end
    end
    h = h(:);  % return column vector
end