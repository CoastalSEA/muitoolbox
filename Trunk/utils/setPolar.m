        function setPolar(src,~) 
            %set XY plot to be polar instead of cartesian
            if strcmp(src.String,'+')
                src.String = 'O';
                src.UserData = 1;
                src. TooltipString = 'Polar to XY';
            elseif strcmp(src.String,'O')
                src.String = '+';
                src.UserData = 0;
                src. TooltipString = 'XY to Polar; X data in degrees or radians';
            end
        end
