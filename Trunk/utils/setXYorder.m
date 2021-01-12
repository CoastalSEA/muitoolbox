        function setXYorder(src,~)
            %switch X and Y data on the XY plotting tab
            if strcmp(src.String,'XY')
                src.String = 'YX';
                src.UserData = 1;
                src. TooltipString = 'Press to swap from Y-X to X-Y axes';
            elseif strcmp(src.String,'YX')
                src.String = 'XY';
                src.UserData = 0;
                src. TooltipString = 'Press to swap from X-Y to Y-X axes';
            end
        end