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

    delete(hplot)
    if strcmp(src.String,'-NaN')
        src.String = '+NaN';
        src. Tooltip = 'Include NaNs in plot';
        idx = ~isnan(data{2});  
        avar = data{1}(idx);
        if iscategorical(avar)
            svar = string(avar);
            avar = categorical(svar);   %new sorted categorical array  
            avar = reordercats(avar,svar);
        end
        data{1} = avar;
        data{2} = data{2}(idx);
    elseif strcmp(src.String,'+NaN')
        src.String = '-NaN';
        src. Tooltip = 'Exclude NaNs in plot';
    end
    hold on
        hb = bar(ax,data{1},data{2});
        hb.FaceColor = fc;
    hold off

end 