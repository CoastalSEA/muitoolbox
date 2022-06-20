 function [skill,ok] = setskillparameters(skill,dst)
%
%-------function help------------------------------------------------------
% NAME
%   setskillparameters.m
% PURPOSE
%   initialise the skill properties used for Taylor plot and local skill
%   score plots. Skill score requires correlation coefficient and exponent.
%   Other parameters relate to local skill score
% USAGE
%   skill = setskillparameters()
% INPUT
%   skill - existing skill struct
%   dst -  dstable of variable being plotted if 2D subdomain being sampled
% OUTPUT
%   skill - struct to hold input parameters required for Taylor skill score
%               Inc - flag - true if skill score is to be plotted
%               Ro - reference correlation coefficient
%               n - skill exponent
%               W - local skill sampling window
%               iter - local skill iteration method (0 or 1)
%               subdomain - skill score averaging window (grids only)
%               SD - subdomain defined as [x0,xN,y0,yN];
%   ok - user cancels from input UI
% NOTES
%   Taylor, K, 2001, Summarizing multiple aspects of model performance 
%   in a single diagram, JGR-Atmospheres, V106, D7. 
%   Bosboom J and Reniers A J H M, 2014, Displacement-based error metrics 
%   for morphodynamic models. Advances in Geosciences, 39, 37-43, 10.5194/adgeo-39-37-2014.
%   Bosboom J, Reniers A J H M and Luijendijk A P, 2014, On the perception 
%   of morphodynamic model skill. Coastal Engineering, 94, 112-125, 
%   https://doi.org/10.1016/j.coastaleng.2014.08.008.
% SEE ALSO
%   used in muiStats and simYGORmodel
%
% Author: Ian Townend
% CoastalSEA (c)June 2022
%--------------------------------------------------------------------------
%          
    if nargin<1
        skill = []; dst = [];
    end
    
    if isempty(skill)
        skill = skillStruct();
        answer = questdlg('Plot skill score?',...
                             'Skill score','Yes','No','Yes');
        if strcmp(answer,'Yes'), skill.Inc = true; end                 
    end
    %
    if skill.Inc      %flag to include skill score
        default = {num2str(skill.Ro),num2str(skill.n),...
            num2str(skill.W),num2str(skill.iter),num2str(skill.subdomain)};
        promptxt = {'Reference correlation, Ro','Exponent,n ',...
                    'Local skill window','Iteration option (0 or 1)',...
                    'Skill score averaging window (grids only)'};
        titletxt = 'Define skill score parameters:';
        answer = inputdlg(promptxt,titletxt,1,default);
        if isempty(answer), ok = 0; return; end  %user cancels

        skill.Ro = str2double(answer{1});     %reference correlation coefficient
        skill.n = str2double(answer{2});      %skill exponent
        skill.W = str2double(answer{3});      %local skill sampling window
        skill.iter = logical(str2double(answer{4})); %local skill iteration method
        skill.subdomain = str2num(answer{5}); %#ok<ST2NM> %subdomain sampling (use str2num to handle vector)
        if ~isempty(dst)
            [vdim,~,vsze] = getvariabledimensions(dst,1);
            if vdim==3 && isa(dst,'dstable')
                skill.SD = getSubDomain(dst,skill.subdomain,vsze);
            end
        else
            skill.SD = [];
        end
    end
    ok = 1;
end
%%
function sd = getSubDomain(dst,subdomain,vsze)
    %find the subdomain in integer grid indices defined by x,y range
    %subdomain defined as [x0,xN,y0,yN];
    % dst is a dstable with the variable being plotted and the associated
    % dimensions
    if ~isempty(dst.Dimensions)
        dnames = dst.DimensionNames;
        x = dst.Dimensions.(dnames{1});
        y = dst.Dimensions.(dnames{2});
    else
        x = 1:vsze(2);
        y = 1:vsze(3);
    end

    if isempty(subdomain) || length(subdomain)~=4
        subdomain = [min(x),max(x),min(y),max(y)];
    end
    ix0 = find(x<=subdomain(1),1,'last');
    ixN = find(x>=subdomain(2),1,'first');
    iy0 = find(y<=subdomain(3),1,'last');
    iyN = find(y>=subdomain(4),1,'first');
    sd.x = [ix0,ix0,ixN,ixN];
    sd.y = [iyN,iy0,iy0,iyN];
end
%%
function skill = skillStruct()
    %return an empty struct for the Taylor skill input parameters
    skill = struct('Inc',false,'Ro',1,'n',1,'W',0,'iter',false,...
                   'subdomain',[],'SD',[]);
end  