function cmap = cmap_selection(idsel,zoptions)
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
%           values of zi (Z values) if using landsea color map. If no 
%           argument included the user is prompted to select a map from 
%           a list.
%   zoptions - struct with files for Z values and zeroLevel (only used for
%              gradient2zero options)
% OUTPUT
%   cmap - RGB values for selected color map
% COLORMAP OPTIONS
%   1 - parula; 2 - turbo; 3 - hsv; 4 - hot; 5 - cool; 6 - spring; 
%   7 - summer; 8 - autumn; 9 - winter; 10 - gray; 11 - bone; 12 - copper; 
%   13 - pink; 14- jet; 15 -lines; 16 - colorcube; 17 - prism; 18 - flag; 
%   19 - BuGnYl; 20 - YlGnBu; 21 - anomalie B-R; 22 - anomalie R-B; 
%   23 - gradient2zero'; 24 - select color grad2zero'
% NOTES
%   NB: > YlGnBu is a bespoke map generated using cbrewer.m
%       > anomalie requires the file cmapanomalie.mat
%       > pass the idsel = zi values to use the landsea map
%       > idsel 23 and 24 require zoptions. zeroLevel allows color
%         mid-point (white) to be positioned at a non-zero level
% Author: Ian Townend
% CoastalSEA (c)Apr 2021
%--------------------------------------------------------------------------
%
    matlabcmaps = {'parula','turbo','hsv','hot','cool','spring','summer',...
                   'autumn','winter','gray','bone','copper','pink','jet',...
                   'lines','colorcube','prism','flag','BuGnYl','YlGnBu',...
                   'anomalie B-R','anomalie R-B','gradient2zero',...
                   'select color grad2zero','integer step colors'};
               
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
        case 'gradient2zero'                       %idsel = 23
            cmap = zero_gradient(zoptions,0);
        case 'select color grad2zero'              %idsel = 24
            cmap = zero_gradient(zoptions,1);
        case 'integer step colors'                 %idsel = 25
            cmap = integerColormap(zoptions);
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

%%
function cmap = zero_gradient(zops,issel)
    %create colormap that has gradients either side of zero
    colornames = {'crimson blue';'dark blue';'orange';'yellow ochre';'pale yellow';...
              'purple';'burnt green';'light blue';'scarlet';'dark grey';...
              'mid grey';'light grey';'red';'green';'blue';'cyan';...
              'magenta';'yellow';'black';'white'};

    minVal    = min(zops.Z(:));   % actual min
    maxVal    = max(zops.Z(:));   % actual max
    zeroLevel = zops.zeroLevel;  % asymmetric zero reference
    nTotal    = 256;              % total colors in colormap

    zeroColor = [1 1 1];          % white at zero
    if issel
        %prompt user to select 2 colors
        selection = selectColors(colornames);
        posColor  = mcolor(selection{1});   % color for max value
        negColor  = mcolor(selection{2});   % color for min value
    else
        posColor  = mcolor(2);              % color for max value
        negColor  = mcolor(7);              % color for min value
    end

    % ==== PROPORTIONAL COLOR SPLIT ====
    negRange = zeroLevel - minVal;
    posRange = maxVal - zeroLevel;
    totalRange = negRange + posRange;
    
    nNeg = max(2, round(nTotal * (negRange / totalRange)));
    nPos = max(2, nTotal - nNeg);
    
    % ==== BUILD COLOR GRADIENTS ====
    negMap = [linspace(negColor(1), zeroColor(1), nNeg)', ...
              linspace(negColor(2), zeroColor(2), nNeg)', ...
              linspace(negColor(3), zeroColor(3), nNeg)'];
    
    posMap = [linspace(zeroColor(1), posColor(1), nPos)', ...
              linspace(zeroColor(2), posColor(2), nPos)', ...
              linspace(zeroColor(3), posColor(3), nPos)'];
    
    cmap = [negMap; posMap];
end

%%
function selection = selectColors(colornames)
    %prompt user to select 2 colors
    fields = {'Positive color','Negative color'};
    varargin =  {'FigureTitle','Select colors',...
                'PromptText','Select +ve and -ve color',...
                'InputFields',fields,...
                'InputOrder',{'',''},...
                'Style',repmat({'popupmenu'},1,numel(fields)),...
                'ControlButtons',{},...
                'DefaultInputs',{colornames,colornames},...
                'UserData',{},...%for popupmenu cell array used to set initial values
                'DataObject',[],...
                'SelectedVar',{},...
                'ActionButtons',{'Select','Close'},...
                'Position',[]};
    selection = inputUI.getUI(varargin{:});
end

%%
function cmap = integerColormap(n)
    % Validate input
    % if isstruct(zoptions)
    %     n = zoptions.n;
    %     scheme = zoptions.scheme;
    % else
    %     n = zoptions;
    %     scheme = 'lines'; %default
    % end

    if ~isscalar(n) || n <= 0 || n >= 10 || floor(n) ~= n
        error('n must be an integer between 1 and 9.');
    end

    % Create green colors for negatives
    negColors = summer(n);

    % Create blue colors for positives
    posColors = sky(n);
    posColors = posColors(end-n+1:end, :); % take top n warm shades

    % Assemble colormap: negatives, zero (white), positives
    cmap = [negColors; 1 1 1; posColors];





    % if ~ismember(scheme, {'lines', 'parula'})
    %     error('scheme must be ''lines'' or ''parula''.');
    % end
    % 
    % % Total number of discrete levels
    % numLevels = 2 * n + 1;
    % 
    % % Generate base colors
    % switch scheme
    %     case 'lines'
    %         baseColors = lines(numLevels - 1); % exclude zero for now
    %     case 'parula'
    %         baseColors = parula(numLevels - 1);
    % end
    % 
    % % Assign colors: negative values first, then zero, then positive
    % cmap = zeros(numLevels, 3);
    % cmap(1:n, :) = baseColors(1:n, :);         % negative values
    % cmap(n+1, :) = [1, 1, 1];                  % zero is white
    % cmap(n+2:end, :) = baseColors(n+1:end, :); % positive values
end