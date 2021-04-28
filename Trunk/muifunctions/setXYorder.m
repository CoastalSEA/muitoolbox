        function setXYorder(src,~)
            %callback function for button to switch X and Y data (eg on
            % a UI selecting data for plotting)
            if strcmp(src.String,'XY')
                src.String = 'YX';
                src.UserData = 1;
                src. TooltipString = 'Switch from Y-X to X-Y axes';
            elseif strcmp(src.String,'YX')
                src.String = 'XY';
                src.UserData = 0;
                src. TooltipString = 'Switch from X-Y to Y-X axes';
            end
        end