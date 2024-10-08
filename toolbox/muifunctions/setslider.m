function setslider(src,~)
%
%-------function help------------------------------------------------------
% NAME
%   setslider.m
% PURPOSE
%   Define slider range text and value for data selection uicontrol   
% USAGE
%   setslider(src)
% INPUT
%   src - handle to slider widget that is to be linked to variable
% OUTPUT
%   Sets up range text and current value in source units by linking the
%   scale of 0-100 set for the slider to the variable range values
% SEE ALSO
% called by inputUI when using sliders as a control Style
%   
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    startvalue = var2str(src(1).UserData{1});
    endvalue = var2str(src(1).UserData{2});
    if isdatetime(src(1).UserData{1})
        dt = between(src(1).UserData{1},src(1).UserData{2})/2;
        midpoint = src(1).UserData{1}+dt;
    elseif iscategorical(src(1).UserData{1})
        dst = src(2).UserData;
        if iscategorical(dst.RowNames)
            if dst.RownNames(1)==src(1).UserData{1}
                npt = round(height(dst)/2);
                midpoint = dst.RowNames(npt);
            end
        elseif ~isempty(dst.Dimensions)
            fnames = fieldnames(dst.Dimensions);
            for i=1:length(fnames)
                if iscategorical(dst.Dimensions.(fnames{i})) && ...
                          char(dst.Dimensions.(fnames{i})(1))==src(1).UserData{1}
                    npt = round(length(dst.Dimensions.(fnames{i}))/2);
                    midpoint = dst.Dimensions.(fnames{i})(npt);
                    src(1).UserData = dst.Dimensions.(fnames{i});
                    break
                end
            end
        end
    else
        average = (src(1).UserData{2}-src(1).UserData{1})/2;
        midpoint = src(1).UserData{1}+average;
    end
    slidevalue = var2str(midpoint);
    %
    S = src(1);
    S.Min = 0;
    S.Max = 100;            
    S.Value = 50;
    S.SliderStep = [0.1,0.2];
    S.String = [];
    %end marker text
    pos = src(1).Position;
    pos1 = src(1).Position(1);
    endpos = pos(1)+pos(3);
    pos(2) = pos(2)+pos(4)+0.01;
    pos(3) = pos(3)/3;
    pos(4) = pos(4)*0.8;
    uicontrol('Parent',src(1).Parent,...
        'Style','text','String',startvalue{1},...
        'HorizontalAlignment', 'left',...
        'Units','normalized', 'Position', pos,...
        'Tag',['slide-start',src(1).Tag(end)]);
    pos(1) = endpos-pos(3);
    uicontrol('Parent',src(1).Parent,...
        'Style','text','String',endvalue{1},...
        'HorizontalAlignment', 'right',...
        'Units','normalized', 'Position', pos,...
        'Tag',['slide-end',src(1).Tag(end)]);
    pos(1) = pos1+(endpos-pos1)/2-pos(3)/2;
    idx = split(src(1).Tag,'uic');
    uicontrol('Parent',src(1).Parent,...
                'Style','text','String',slidevalue{1},...                    
                'HorizontalAlignment', 'center',...
                'Units','normalized', 'Position', pos,...
                'Tag',['slide-val',idx{2}]);
end 