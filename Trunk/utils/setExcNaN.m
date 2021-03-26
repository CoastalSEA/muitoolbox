function setExcNaN(src,~)
    %set data selection to include or exclude NaNs
    if strcmp(src.String,'+N')
        src.String = '-N';
        src.UserData = 1;
        src. TooltipString = 'Switch to include NaNs in output';
    elseif strcmp(src.String,'-N')
        src.String = '+N';
        src.UserData = 0;
        src. TooltipString = 'Switch to exclude NaNs in output';
    end
end 