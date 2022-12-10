function my_mui_plot(cobj)
%
%-------function help------------------------------------------------------
% NAME
%   my_mui_plot.m
% PURPOSE
%   generate a plot by calling muiPlots. Example produces an animation 
%   from a 3D dstable passed as a class object that inherits DGinterface   
% USAGE
%   my_mui_plot(obj)
% INPUTS
%   cobj - instance of class obj with data to be plotted
% OUTPUT
%   animation
% SEE ALSO
%   example of direct call to muiPlots.newAnimation
%
% Author: Ian Townend
% CoastalSEA (c) Dec 2022
%--------------------------------------------------------------------------
%
    hf = figure('Name','Animation', ...
                    'Units','normalized', ...
                    'Resize','on','HandleVisibility','on', ...
                    'Visible','off','Tag','PlotFig');
    %create an instance of muiPlots and populate the properties that are
    %needed for the newAnimation method
    obj = muiPlots.get_muiPlots();   %create new instance          
    obj.Plot.CurrentFig = hf;
    obj.Plot.FigNum = hf.Number;
    obj.UIset.callTab = '3DT';
    obj.UIset.Polar = false;
    obj.UIset.Type.String = 'surf';
    obj.AxisLabels.X = 'Distance from mouth (m)';
    obj.AxisLabels.Y = 'Width (m)';
    obj.AxisLabels.Y = 'Elevation (mAD)';
    obj.Legend = [];
    [~,slr,~] = netChangeWL(cobj.RunParam.WaterLevels,cobj);
    obj.Title = sprintf('Case: %s, slr=%0.3g m',cobj.Data.Grid.Description,slr);
    %extract the plot data
    obj.Data.X = cobj.Data.Grid.Dimensions.X;
    obj.Data.Y = cobj.Data.Grid.Dimensions.Y;
    obj.Data.Z = cobj.Data.Grid.Z;
    obj.Data.T = cobj.Data.Grid.RowNames;
    
    %control range of z used in animatio
    ulim = max(obj.Data.Z,[],'All');
    dlim = min(obj.Data.Z,[],'All');
    prmptxt = {'Upper elevation limit','Lower elevation limit'};
            dlgtitle = 'Animation';
            defaults = {num2str(ulim),num2str(dlim)};
            answer = inputdlg(prmptxt,dlgtitle,1,defaults);
    if isempty(answer)
        return; 
    else
        uplimit = str2double(answer{1});    %z value of upper limit
        dnlimit = str2double(answer{2});    %z value of lower limit
    end      
    obj.Data.Z(obj.Data.Z>uplimit) = NaN;
    obj.Data.Z(obj.Data.Z<dnlimit) = NaN;
    
    %generate default animation
    getAplot(obj);