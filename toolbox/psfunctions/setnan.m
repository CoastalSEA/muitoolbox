function setnan(ax,src,~)
%
%-------function help------------------------------------------------------
% NAME
%   setnan.m
% PURPOSE
%   callback function for button to include or exclude NaN values from plot
% USAGE
%   callback function: @(src,evdat)setnan(ax,src,evdat)
% INPUT
%   ax - axes for plot to be adjusted
%   src - handle to calling object (eg graphical button)
%   ~ - blank for event (required for callback)
% OUTPUT
%   change the String and Tooltip of src object and update the
%   plot to include or exclude the y-NaN values
% SEE ALSO
%   used in muiTableImport
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%--------------------------------------------------------------------------
%
    data = src.Parent.UserData;
    hplot = ax.Children;
    fc = hplot.FaceColor;
    cd = hplot.CData;
    idx = ~isnan(data{2}); 
    avar = data{1}(idx);
    delete(hplot)
    
    %toggle data based on button setting
    if strcmp(src.String,'-NaN')
        src.String = '+NaN';
        src. Tooltip = 'Include NaNs in plot';         
        if iscategorical(avar)
            avar = removecats(categorical(data{1}(idx), categories(data{1})));
        end
        data{1} = avar;
        data{2} = data{2}(idx);
        cd = cd(idx,:);
    elseif strcmp(src.String,'+NaN')
        src.String = '-NaN';
        src. Tooltip = 'Exclude NaNs in plot';
        %pad the cd array to include the nan values
        cdfull = repmat(cd(1,:),length(data{1}),1);
        %avar is source, data is target
        [~, src_idx, tgt_idx] = intersect(avar,data{1});
        cdfull(tgt_idx,:) = cd(src_idx,:);
        cd = cdfull;
    end
    
    %update axis labels
    if iscategorical(data{1})
        ax.XAxis.Categories = categories(data{1});
    else
        set(ax,'XTick',data{1},'XTickLabel',data{1});
    end
    
    %replot the bar chart
    hold on
        hb = bar(ax,data{1},data{2});
        hb.FaceColor = fc;
        hb.CData = cd;
    hold off
end 