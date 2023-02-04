function cmap = cmap_selection(idsel)
%
%-------function help------------------------------------------------------
% NAME
%   cmap_selection.m
% PURPOSE
%   select a color map definition from Matlab default list and cbrewer
%   generated mat files
% USAGE
%   cmap = cmap_selection(idsel)
% INPUTS
%   idsel - index to row selection in color table (integer value), or
%           values of zi if using landsea color map
% OUTPUT
%   cmap - RGB values for selected color map
% NOTES
%   NB: YlGnBu is a bespoke map generated using cbrewer.m
%   anomalie requires the file cmapanomalie.mat
%   idsel = 21 calls landsea map and requires zi to be passed
% Author: Ian Townend
% CoastalSEA (c)Apr 2021
%--------------------------------------------------------------------------
%
    matlabcmaps = {'parula','turbo','hsv','hot','cool','spring','summer',...
                   'autumn','winter','gray','bone','copper','pink','jet',...
                   'lines','colorcube','prism','flag','BuGnYl','YlGnBu',...
                   'anomalie B-R','anomalie R-B'};
               
    if nargin<1
        promptxt = 'Select colormap:';
        [idsel,ok] = listdlg('Name','Colormap','SelectionMode','single',...
                        'PromptString',promptxt,'ListString',matlabcmaps,...
                         'ListSize',[160,320]);                    
        if ok<1, cmap = []; return; end   
    elseif license('test','MAP_Toolbox') && length(idsel)>1
        %pass zi values as idsel
        [cmap,~] = landsea(idsel);                 %requires Mapping toolbox
        return;
    elseif length(idsel)>1
        warndlg('Mapping toolbox not found');
        cmap = []; return;
    end
    %
    switch matlabcmaps{idsel}
        case 'BuGnYl'                              %idsel = 19
            cmap = YlGnBu();
        case 'YlGnBu'                              %idsel = 20
            cmap = YlGnBu();
            cmap = flipud(cmap);
        case 'anomalie B-R'                        %idsel = 21
            cstruct = load('cmapanomalie','-mat');
            cmap = cstruct.cmapanomalie;
        case 'anomalie R-B'                        %idsel = 22
            cstruct = load('cmapanomalie','-mat');
            cmap = flipud(cstruct.cmapanomalie);   
        otherwise                                  %idsel = 1-18 Matlab defaults
            cmap = colormap(matlabcmaps{idsel});
    end
end
%%
function cmap = YlGnBu()
    %definition of YlGnBu map generated using cbrewer.m
    cmap = [1,1,0.850980392156863;
            0.952941176470588,0.980392156862745,0.745098039215686;
            0.929411764705882,0.972549019607843,0.694117647058824;
            0.909803921568627,0.964705882352941,0.678431372549020;
            0.866666666666667,0.949019607843137,0.690196078431373;
            0.780392156862745,0.913725490196078,0.705882352941177;
            0.643137254901961,0.858823529411765,0.721568627450980;
            0.498039215686275,0.803921568627451,0.733333333333333;
            0.396078431372549,0.772549019607843,0.745098039215686;
            0.325490196078431,0.749019607843137,0.760784313725490;
            0.254901960784314,0.713725490196078,0.768627450980392;
            0.172549019607843,0.654901960784314,0.772549019607843;
            0.113725490196078,0.568627450980392,0.752941176470588;
            0.109803921568627,0.466666666666667,0.705882352941177;
            0.133333333333333,0.368627450980392,0.658823529411765;
            0.152941176470588,0.298039215686275,0.635294117647059;
            0.160784313725490,0.243137254901961,0.615686274509804;
            0.145098039215686,0.203921568627451,0.580392156862745;
            0.105882352941176,0.164705882352941,0.498039215686275;
            0.0313725490196078,0.113725490196078,0.345098039215686];
end
%%
function [cmap,climits] = landsea(zi,range)
    %definition of land-sea cmap - requires Mapping toolbox
    if nargin<2, range = [min(zi,[],'All'),max(zi,[],'All')]; end
    cmapsea = [0,0,0.2;  0,0,1;  0,0.45,0.74;  0.30,0.75,0.93; 0.1,1,1];
    cmapland = [0.95,0.95,0.0;  0.1,0.7,0.2; 0,0.4,0.2; 0.8,0.9,0.7;  0.4,0.2,0];
    [cmap,climits] = demcmap(range,128,cmapsea,cmapland);
end