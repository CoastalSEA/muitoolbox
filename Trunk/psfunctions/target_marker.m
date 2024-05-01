function [hcr,hrg] = target_marker(varargin)
%
%-------header-------------------------------------------------------------
% NAME
%   target_marker.m
% PURPOSE
%   add one or more target symbols to a plot
% USAGE
%   [hcr,hrg] = target_marker(varargin); e.g.:
%   target_marker(x,y);             %just x and y values
%   target_marker(ax,x,y);          %axes handle and x, y values
%   target_marker(-,Name,Value);    %any of above and Name_Value scatter
%                                   % marker properties
%   [hcr,hrg] = target_marker(x,y); %return handles to cross and circle
%                                   % markers used to construct target marker                               
% INPUTS
%   varargin: x, y, or axes and x, y,followed by any scatter plot properties 
%   as Name-Value pairs.
% OUTPUTS
%   hcr - handle to cross marker
%   hrg - handle to circle marker
%
% Author: Ian Townend
% CoastalSEA (c) Apr 2024
%--------------------------------------------------------------------------
%
    nvar = length(varargin);
    if isa(varargin{1},'axes')           %first variable is x, y
        ax = varargin{1};
        x = varargin{2};
        y = varargin{3};
        offset = 3;
    else                                 %axes not specified
        ax = gca;
        x = varargin{1};
        y = varargin{2};
        offset = 2;
    end

    nprop = nvar-offset;
    if nprop>0 && rem(nprop,2)==0        %additional properties defined                 
        for j=1:2:nprop
            prop.(varargin{offset+j}) = varargin{offset+j+1};
        end
    elseif nprop>0
        warndlg('Properties should be specified as Name-Value pairs')
        return;        
    end

    hold on
    hcr = scatter(ax,x,y,'+');              %plot cross
    hrg = scatter(ax,x,y,'o');              %plot circle

    propnames = fieldnames(prop);
    alpi = 1;                            %default transparency
    for j=1:length(propnames)
        prop2set = propnames{j};
        if strcmp(prop2set,'SizeData')
            hcr.SizeData = prop.SizeData;
            hrg.SizeData = prop.SizeData/3;
        elseif strcmpi(prop2set,'alpha')
            alpi = prop.(prop2set);            
        else
            hcr.(prop2set) = prop.(prop2set);
            hrg.(prop2set) = prop.(prop2set);
        end
    end
    hold off
    hrg.MarkerFaceAlpha = alpi;
end
