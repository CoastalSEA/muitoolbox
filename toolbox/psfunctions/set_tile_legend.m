function set_tile_legend(ax, loc)
%
%-------function help------------------------------------------------------
% NAME
%   set_tile_legend.m
% PURPOSE
%   manage legends across multiple tiles with the option to hide plot lines.
%   Generated using GPT-5:
% USAGE
%   set_tile_legend(ax, loc)
%   e.g: set_tile_legend(spi,'southeast') where spi is the tile handle
% INPUTS
%   ax - plot axis tile handle
%   loc - location to position legend (e.g. 'best')
% OUTPUT
%   updated legend associated with ax
% NOTES
%   Freeze the legend: Prevents disappearance during redraws, and you can 
%                      still manually refresh it when you choose.
%   Filter by IconDisplayStyle: Preserves any p.Annotation.LegendInformation.IconDisplayStyle='off' exclusions.
%   Limit to a specific axes: Never pull objects from other tiles 
%
%   NB use hold(ax,'on') when adding lines to existing plot.
%
% Author: GPT-5
% CoastalSEA (c) Sept 25
%--------------------------------------------------------------------------
%
    if nargin < 2, loc = 'best'; end
    % Collect only legend-worthy objects from THIS axes
    h = collectLegendObjects(ax);

    % Create/update legend on this axes only
    lgd = legend(ax, h, 'Location', loc);

    % Freeze to avoid “disappearing” on redraws
    lgd.AutoUpdate = 'off';
end

%%
function h = collectLegendObjects(ax)
    %collect legend objects that have not been switched off and maintain order
    % Start from the axes’ children to avoid cross-axes leakage
    ch = ax.Children; % top -> bottom order (newest first)

    % Keep only objects with DisplayName and not explicitly excluded
    keep = false(size(ch));
    for k = 1:numel(ch)
        hasName = isprop(ch(k), 'DisplayName') && ~isempty(ch(k).DisplayName);
        % Safe guard: Annotation/LegendInformation exists on HG objects
        excl = false;
        if isprop(ch(k), 'Annotation') && ~isempty(ch(k).Annotation)
            li = ch(k).Annotation.LegendInformation;
            excl = strcmp(li.IconDisplayStyle, 'off');
        end
        keep(k) = hasName && ~excl;
    end

    % Keep creation order (oldest first) for intuitive legend ordering
    ch = flipud(ch);           % oldest first
    keep = flipud(keep);
    h = ch(keep);
end