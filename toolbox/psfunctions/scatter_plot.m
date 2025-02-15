function scatter_plot(mobj)                       
%
%-------function help------------------------------------------------------
% NAME
%   scatter_plot.m
% PURPOSE
%   scatter plot of 2 variables of same length, with points that can be
%   scaled by a third variable
% USAGE
%   scatter_plot(mobj)
% INPUTS
%   mobj - ModelUI instance
% OUTPUT
%   scatter plot of selected variables
% SEE ALSO
%   TableViewer and tableviewer_user_tools.m, EstuaryDB and edb_user_tools.m
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
%
    questxt = 'Scatter plot with points (2D) or scaled data points (3D):';
    %prompt user to select type of scatter plot required
    answer = questdlg(questxt,'Scatter','2D','3D','2D');

    %prompt user to select variables to be used in plot
    %NB uses =get_variable to restrict selection to variables only to
    %select variables or dimensions use get_selection
    promptxt = 'Select X-variable:';    
    [indvar,indsel] = get_variable(mobj,promptxt,'XYZmxvar',1);
    if isempty(indvar), return; end
    promptxt = 'Select Y-variable:';    
    [depvar,depsel] = get_variable(mobj,promptxt,'XYZmxvar',1);
    if isempty(depvar), return; end  
    isvalid = checkdimensions(indvar.data,depvar.data);
    if ~isvalid, return; end

    if strcmp(answer,'3D')
        promptxt = 'Select variable to scale scatter points:';    
        ok = 0;
        while ok<1
            scalevar = get_variable(mobj,promptxt,'XYZmxvar',1);
            if isempty(scalevar), return; end
            scalevar.data
            isvalid = isnumeric(scalevar.data) && checkdimensions(indvar.data,scalevar.data);
            if isvalid
                ok = 1;
            else
                warndlg('Invlid data selection (different size or not numeric)')
            end
        end
        markersz = scalevar.data/max(scalevar.data)*1000; %scaling to give size in points
    else
        markersz = 36; %Matlab default value
    end

    %now do something with selected data
    %indvar and depvar are structs with the following fields:
    %name - variable name, data - selected data, label - variable axis label, 
    %desc - variable description, case - case description
    hf = figure('Tag','UserFig');    
    ax = axes (hf);
    legtxt = sprintf('%s(%s)',depvar.desc,indvar.desc);    
    hs = scatter(ax,indvar.data,depvar.data,markersz,'filled','DisplayName',legtxt);
    xlabel(indvar.label)
    if strcmp(indsel.scale,'Log')
        idx = find(mod(ax.XTick(:), 1) == 0);
        ax.XTick = ax.XTick(idx); %remove non integer exponents
        ax.XTickLabel = cellstr(num2str(ax.XTick(:), '10^{%d}'));
    end
    ylabel(depvar.label)
    if strcmp(depsel.scale,'Log')
        idy = find(mod(ax.YTick(:), 1) == 0);
        ax.YTick = ax.YTick(idy);  %remove non integer exponents
        ax.YTickLabel = cellstr(num2str(ax.YTick(:), '10^{%d}'));
    end
   
    legend('Location','best')
    seltxtX = get_selection_text(indvar,6,'X'); %full description of dimensions
    titxtX = get_selection_text(indvar,5,'X');  %short description of dimensions

    seltxtY = get_selection_text(depvar,6,'Y'); %full description of dimensions
    titxtY = get_selection_text(depvar,5,'Y');  %short description of dimensions            
                
    seltxt = sprintf('%s\n%s',seltxtX,seltxtY);         
    title(sprintf('%s\n%s',titxtX,titxtY))
    if strcmp(answer,'3D')
        hs.MarkerFaceAlpha = 0.5; %transparency
        seltxtZ = get_selection_text(scalevar,6,'Z'); %full description of dimensions
        titxtZ = get_selection_text(scalevar,5,'Z');  %short description of dimensions
        seltxt = sprintf('%s\n%s',seltxt,seltxtZ);
        subtitle(titxtZ)
    end
    
    %create button to allow user to view detailed selection description 
    hf.Units = 'normalized';
    butxt = 'Selection';   %text to appear on button
    position = [0.85,0.92,0.1,0.05];          %position of button on parent (units as per parent)
    callback =  @(src,evt)display_selection(src,evt); %function to be called on button press
    tag = 'selbutton';
    tooltip = 'Details of selection made';
    hbut = setactionbutton(hf,butxt,position,callback,tag,tooltip);
    hbut.UserData = seltxt;
end