classdef muiPlots < handle
%
%-------class help---------------------------------------------------------
% NAME
%   muiPlot.m
% PURPOSE
%   Class to implement the generation of a range of plot types
% SEE ALSO
%   called from muiPlotsUI.m, which defines the selection and settings in
%   properties UIselection and UIsettings. Uses muiCatalogue to access
%   data.
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2021
%--------------------------------------------------------------------------
%
    properties (Transient)
        Plot            %struct array for:
                        %   FigNum - index to figures created
                        %   CurrentFig - handle to current figure
                        %   Order - struct that defines variable order for
                        %           plot type options (selection held in Order)

        ModelMovie      %store animation in case user wants to save
        UIsel           %structure for the variable selection made in the UI
        UIset           %structure for the plot settings made in the UI
        Data            %data to use in plot (x,y,z)
        TickLabels      %struct for XYZ tick labels
        AxisLabels      %struct for XYZ axis labels
        Legend          %Legend text
        MetaData        %text summary of primary variable selection
        Title           %Title text
        Order           %order of variables for selected plot type
        idxfig          %figure number of the current figure
    end
%%    
    methods (Access=protected)  %allows muiPlot to be used as a superclass
        function obj = muiPlots
            %types of plot avaiable based on number of dimensions
            obj.Plot.FigNum = [];
            obj.Plot.CurrentFig = [];  
            obj.Plot.Order = muiPlots.setVarOrder;
        end      
    end
%%    
    methods (Static)
        function getPlot(gobj,mobj)
            %get existing instance or create new class instance
            if isa(mobj.mUI.Plots,'muiPlots')
                obj = mobj.mUI.Plots;    %get existing instance          
                clearPreviousPlotData(obj);
            else
                obj = muiPlots;                   %create new instance
            end
            obj.UIsel = gobj.UIselection;
            obj.UIset = gobj.UIsettings;
            
            %set the variable order for selected plot type
            obj.Order = obj.Plot.Order.(obj.UIset.callTab);
            
            %get the data to be used in the plot
            ok = getPlotData(obj,mobj.Cases);
            if ok<1, return; end %data not found
            isvalid = checkdimensions(obj);
            if ~isvalid, return; end
            
            if strcmp(obj.UIset.Type.String,'User')
                UserPlot(obj,mobj);  %pass control to user function
            else
                %generate the plot
                setPlot(obj,mobj);
            end
        end
    end
%%   
    methods (Access=protected)
        function ok = getPlotData(obj,muicat)
            %get the data to be used in the plot
            ok = 1;
            nvar = length(obj.UIsel);
            %initialise struct used in muiCatalogue.getProperty
            props(nvar) = setPropsStruct(muicat);
            for i=1:nvar
                %get the data and labels for each variable
                props(i) = getProperty(muicat,obj.UIsel(i),'array');
                if isempty(props(i).data), ok = ok-1; end
            end
            xyz = obj.Order;
            if any(strcmp(fieldnames(obj.UIset),'Swap')) && obj.UIset.Swap      
                %flip order of variables if selected
                xyz = fliplr(xyz); %only applies to 2D
            end
            %
            mtxt = 'Selection used:';
            for i=1:length(xyz)
                %assign the data to the correct axis  
                data2use = props(i).data;
                if obj.UIsel(i).scale>1 %apply selected scaling to variable
                    usescale = obj.UIset.scaleList{obj.UIsel(i).scale};
                    dim = 1; %dimension to apply scaling function if matrix
                    data2use = scalevariable(data2use,usescale,dim);
                end
                obj.Data.(xyz{i}) = data2use;
                obj.AxisLabels.(xyz{i}) = props(i).label;
                mtxt = sprintf('%s\n%s: %s',mtxt,xyz{i},obj.UIsel(i).desc);
            end
            obj.Legend = sprintf('%s (%s)',props(1).case,props(1).dset);
            obj.MetaData = mtxt;
            %description of selection (may need sub-selection if more than
            %one case/variable used in plot)
            dimtxt = {props(:).desc};
            title = sprintf('%s (',dimtxt{1});
            for j=2:length(dimtxt)
                title = sprintf('%s%s, ',title,dimtxt{j});
            end
            obj.Title = sprintf('%s)',title(1:end-2));
        end
    
%%
        function setPlot(obj,mobj)    
            %manage plot generation for different types and add/delete                   
            %get an existing figure of create a new one
            getFigure(obj); 
            %call the specific plot type requested
            callPlotType(obj);
            %assign PlotFig instance to handle
            mobj.mUI.Plots = obj;
            obj.Plot.CurrentFig.Visible = 'on';
        end
%%
        function callPlotType(obj)
            %call the function specific to the selected plot type           
            switch obj.UIset.callTab        %call function based on Tab
                case '2D'                    
                    switch obj.UIset.callButton %and Tab Button used
                        case 'New'              %create new 2D plot
                            %check whether cartesian or polar plot
                            if obj.UIset.Polar
                                newPolarplot(obj);                              
                            else
                                new2Dplot(obj);  
                            end
                        case 'Add'              %add variable to 2D plot
                            if strcmp(obj.UIset.Type,'bar')
                                addBarplot(obj);
                            else
                                add2Dplot(obj);
                            end
                        case 'Delete'           %delete variable from 2D plot
                            del2Dplot(obj);
                    end
                case '3D'
                    new3Dplot(obj);
%                     switch obj.UIset.callButton       %and Tab Button used
%                         case 'New'          %create new 3D plot
%                             new3DZplot(obj);
%                         otherwise
%                             if isempty(obj.Data.z) && ~strcmp(hf.Name,'Rose plot')
%                                 switch obj.UIsel.srcVal
%                                     case 'Add'
%                                         add3Dplot(obj);
%                                     case 'Delete'
%                                         del3Dplot(obj);
%                                 end
%                             else
%                                 warndlg('Cannot Add or Delete for Rose or 3D plots');
%                                 return;
%                             end
%                     end
                case '4D'
                    new4Dplot(obj);
                    warndlg('Under development')
                    return;
                case {'2DT','3DT','4DT'}
                    newAnimation(obj);
                otherwise
                    warndlg('Could not find plot option in getPlot');
            end
        end
%%
%--------------------------------------------------------------------------
% Functions for 2d plots
%--------------------------------------------------------------------------
        function [x,y,hf,fnum,symb] = plot2Ddata(obj)
            %information required to create, add or delete 2D plot
            x = obj.Data.X;
            y = obj.Data.Y;
            idx = obj.Plot.FigNum==obj.Plot.CurrentFig.Number;
            hf = findobj('Number',obj.Plot.FigNum(idx));
            fnum = num2str(hf.Number); 
            %set up symbol
            symb = {'-','none'};
        end
%%
        function [plotfunc,symb] = get2DPlotFunc(obj)
            %setup function call for plot using obj.UIsel.PlotType
            markers = '''LineStyle'',s1,''Marker'',s2';
            %display summary text in legend
            display = '''DisplayName'',leg,''Tag'',t1';  
            %display metadata for selection in a temporary popup dialogue
            namedisp = '''ButtonDownFcn'',@godisplay';  
            plot_type = obj.UIset.Type.String;
            switch plot_type
                case 'line'
                    plot_type = 'plot';
                    symb = {'-','none'};
                case 'bar'
                    markers = '''BarLayout'',s1,''Horizontal'',s2';
                    symb = {'grouped','off'};
                case 'scatter'
                    markers = '''MarkerFaceColor'',s1,''Marker'',s2';
                    symb = {'none','.'};
                case 'stem'
                    symb = {'-','o'};
                case 'stairs'
                    symb = {'-','none'};
                case 'barh'
                    plot_type = 'bar';
                    markers = '''BarLayout'',s1,''Horizontal'',s2';
                    symb = {'grouped','on'};
                otherwise
                    plot_type = 'plot';
                    symb = {'-','.'};
            end
            %
            plotxt = sprintf('%s(parent,x,y,%s,%s,%s)',plot_type,...
                                                 markers,display,namedisp);
            plotfunc = str2func(['@(parent,x,y,s1,s2,leg,t1) ',plotxt]);                                       
        end        
%%
        function new2Dplot(obj)
            %generate new 2D plot in figure
            [x,y,hfig,fnum,~] = plot2Ddata(obj);
            figax = axes('Parent',hfig,'Tag','PlotFigAxes'); 
            hold(figax,'on')
            [hptype,symb] = get2DPlotFunc(obj); %function handle for plot type
            if strcmp(symb{1},'grouped') && iscategorical(y)
                cats = categories(y);
                y = double(y); %convert categorical data to numerical
            else
                cats = [];
            end
            %hptype uses figax,x,y,'LineStyle','Marker','DisplayName','Tag'
            hp = hptype(figax,x,y,symb{1},symb{2},obj.Legend,'1');
            hp.UserData = obj.MetaData;
            if strcmp(obj.UIset.Type.String,'barh')
                xlabel(obj.AxisLabels.Y)
                ylabel(obj.AxisLabels.X)
            else
                xlabel(obj.AxisLabels.X)
                ylabel(obj.AxisLabels.Y)
            end
            title(obj.Title)
            if strcmp(symb{1},'grouped')&& strcmp(obj.UIset.Type.String,'barh') ...
                                                    && ~isempty(cats)
                xticks(1:length(cats));
                xticklabels(cats);
            elseif strcmp(symb{1},'grouped') && ~isempty(cats)
                yticks(1:length(cats));
                yticklabels(cats);
            end
            hl = legend(figax,hp,'Location','best');
            hl.Tag = fnum;
            hold(figax,'off')
        end
%%
        function add2Dplot(obj)
            %add data set to existing 2D plot
            [x,y,hfig,fnum,~] = plot2Ddata(obj);
            figax = hfig.CurrentAxes; 
            hold(figax,'on');                    
            hp = findobj(figax,'Type',obj.UIset.Type.String);
            idline = length(hp)+1;
            if isa(figax,'matlab.graphics.axis.PolarAxes')
                x = deg2rad(x);
            end
            % 
            if strcmp(obj.UIset.Type.String,'stem') && ~iscategorical(x)
                %add small offset to x for multiple stem plots
                if length(x)>1
                    dx = x(2)-x(1);
                    x = x+(idline-1)*dx/100; 
                else
                    x = x+(idline-1)*x/10000;
                end
            end            
            [hptype,symb] = get2DPlotFunc(obj); %function handle for plot type
            %call uses figax,x,y,'LineStyle','Marker','DisplayName','Tag'
            hp(idline) = hptype(figax,x,y,symb{1},symb{2},...
                                            obj.Legend,num2str(idline));
            hp =sortplots(hp);
            hl = legend(figax,hp,'Location','best');
            hl.Tag = fnum;
            hold(figax,'off')
        end
%%
        function del2Dplot(obj)
            %delete data set from existing 2D plot
            [x,y,hfig,fnum,~] = plot2Ddata(obj);
            figax = hfig.CurrentAxes; 
            hold(figax,'on');
            hp = findobj(figax,'Type',obj.UIset.Type.String);
            hl = findobj('Type','legend','Tag',fnum);
            idline = [];
            
            if hfig.UserData==1 %XY have been swapped
                if isa(figax,'matlab.graphics.axis.PolarAxes')
                    lineData = 'ThetaData'; %plot is polar
                    delVar = deg2rad(x);
                else
                    lineData = 'YData'; %plot is cartesian
                    delVar = x;
                end
            else
                  if isa(figax,'matlab.graphics.axis.PolarAxes')
                      lineData = 'RData'; %plot is polar
                  else
                      lineData = 'YData'; %plot is cartesian
                  end
                  delVar = y;
            end
            %
            nline = 1;
            for i=1:length(hp)
                if numel(delVar)==numel(hp(i).(lineData))
                    delVar = reshape(delVar,size(hp(i).(lineData)));
                    if isequaln(hp(i).(lineData),delVar)
                        idline(nline) = i;
                        delete(hp(i));
                        nline = nline+1;
                    end
                end
            end
            %            
            if ~isempty(idline)
                hp(idline) = [];
                hp =sortplots(hp);
                if isempty(hp)
                    delete(hl)
                else
                    hl = legend(figax,hp,'Location','best');
                    hl.Tag = fnum;
                end
            end
            hold(figax,'off')
        end
%%
        function newPolarplot(obj)
            %generate new Polar plot in figure
            [x,y,hfig,fnum,~] = plot2Ddata(obj);
            if ~isnumeric(x) || ~isnumeric(y)
                %trap setting 'O' button for non-direction data selection
                warndlg('Check that X is a direction variable and Y is numeric');
                close(hfig); return;
            end

            figax = hfig.CurrentAxes;
            answer = questdlg('Select plot type','Polar plots',...
                                                'Polar','Rose','Polar');
            switch answer
                case 'Polar'
                    %Note: assignement using plot type only works for a new
                    %plot. When adding only Line and Scatter can be used
                    ptype = {'Line','Bar','Scatter','Stem','Stairs','Horizontal bar'};
                    symoptions = {'-';'.';'o';':';'x';'+'};
                    idx = strcmpi(ptype,obj.UIset.Type.String);
                    symb = symoptions{idx};
                    %
                    hfig.Name = 'Polar plot';
                    figax = polaraxes('Parent',hfig,'Tag','PlotFigAxes');
                    figax.ThetaZeroLocation = 'top';
                    figax.ThetaDir = 'clockwise';
                    hold(figax,'on')
                    hp = polarplot(deg2rad(x),y,symb,...
                                    'DisplayName',obj.Legend,'Tag','1');
                    figax.Title.String = obj.AxisLabels.Y;
                    hl = legend(figax,hp,'Location','best');
                    hl.Tag = fnum;
                    hold(figax,'off')
                case 'Rose'
                    hfig.Name = 'Rose plot';
                    wind_rose(x,y,'parent',figax,'dtype','meteo',...
                       'labtitle',obj.Legend,'lablegend',obj.AxisLabels.Y);
            end
        end
%%
        function addBarplot(obj)
            %check if there are any existing bars, create matrix of y and plot
            [x,y,hfig,fnum,~] = plot2Ddata(obj);
            figax = hfig.CurrentAxes; 
            hold(figax,'on');
            hp = findobj(figax,'Type',obj.UIset.Type.String);
            if ~isempty(hp)
                for i=1:length(hp)
                    yexist(:,i) = hp.YData;
                end
            end
            y = horzcat(yexist,y);
            %now revise legend and axis labels
            hleg = findobj(hfig,'Type','legend');
            legtxt = horzcat(hleg.String,obj.Legend);
            
            delete(hp)
            [hptype,symb] = getPlotFunc(obj); %function handle for plot type
            %call uses figax,x,y,'LineStyle','Marker','DisplayName','Tag'
            hptype(figax,x,y,symb{1},symb{2},...
                                            obj.Legend,num2str(size(y,2)));                        
            hl = legend(figax,legtxt,'Location','best');
            hl.Tag = fnum;
            hold(figax,'off')
        end        
%%
%--------------------------------------------------------------------------
% Functions for 3D plots
%--------------------------------------------------------------------------
        function new3Dplot(obj)
            %control and definition of plots that are 3D
            convertTime(obj);
            x = obj.Data.X;
            y = obj.Data.Y;
            z = obj.Data.Z;

            xint = length(x)-1;
            yint = length(y)-1;
            [xint,yint] = check_xyz_dims(xint,yint);
            if isempty(xint) || isempty(yint)
                idx = obj.Plot.FigNum==obj.idxfig;
                obj.Plot.FigNum(idx)=[];
                delete(fig);
                return;
            end

            zsize = size(z);
            if zsize(1)==length(x)
                z = z';
            end

            %
            if isfield(obj.UIset,'Polar') && obj.UIset.Polar
                muiPlots.rtSurface(x,y,z,24,yint,obj.AxisLabels.Y,...
                                               obj.Legend,obj.Title);
            else
                if isempty(obj.UIset.Type.String)
                    ptype = 'surf';
                else
                    ptype = obj.UIset.Type.String;
                end
                muiPlots.xySurface(x,y,z,xint,yint,obj.AxisLabels.X,...
                              obj.AxisLabels.Y,obj.Legend,obj.Title,ptype);
            end
        end 
%%
        function convertTime(obj)
            %convert time for plotting
            fname = fieldnames(obj.Data);
            nrec = length(fname);
            for i=1:nrec
                x = obj.Data.(fname{i});
                if isdatetime(x) || isduration(x)
                    obj.Data.(fname{i}) = numericTime(x);
                end
            end
            %
            function timeout = numericTime(timein)
                %convert datatime to numeric time
                if isdatetime(timein)
                    startyear = year(timein(1));
                    timeout = startyear+years(timein-datetime(startyear,1,1));
                else
                    timeout = cellstr(timein);
                    timeout = split(timeout);
                    timeout = cellfun(@str2num,timeout(:,1));
                end
            end
        end
%%
%--------------------------------------------------------------------------
% Functions for 4D plots
%--------------------------------------------------------------------------

%%
%--------------------------------------------------------------------------
% Functions for animations
%--------------------------------------------------------------------------
        function newAnimation(obj)
            %generate an animation for user selection.
            hfig = obj.Plot.CurrentFig;
            hfig.Visible = 'on';
            switch obj.UIset.callTab
                case '2DT'
                    var = obj.Data.Y;
                    vari = setTimeDependentVariable(obj,var,1);
                    obj.Data.Y = vari;   %first time step
                    new2Dplot(obj)
                    figax = gca;
                    hp = figax.Children;
%                     vari = setTimeDependentVariable(obj,var,1); %#ok<NASGU>
                    hp.YDataSource = 'vari';
                    figax.YLimMode = 'manual';                    
                case '3DT'
                    var = obj.Data.Z;
                    vari = setTimeDependentVariable(obj,var,1); 
                    obj.Data.Z = vari;  %first time step
                    new3Dplot(obj)
                    figax = gca;
                    hp = figax.Children;
                    hp.ZDataSource = 'vari';
                    figax.ZLimMode = 'manual';
                case '4DT'
                    warndlg('Not ready yet')
                    return;
            end
            t = obj.Data.T;
            % checkAxisTicks(obj,figax);
            title(sprintf('%s \nTime = %s',obj.Title,string(t(1))))
            Mframes(1) = getframe(gcf); %NB print function allows more control of 
            hold(figax,'on')
            for i=2:length(t)
                vari = setTimeDependentVariable(obj,var,i); %#ok<NASGU>
                refreshdata(hp,'caller')
                title(sprintf('%s \nTime = %s',obj.Title,string(t(i))))
                drawnow;                 
                Mframes(i) = getframe(gcf); 
                %NB print function allows more control of resolution 
            end
            hold(figax,'off')
            obj.ModelMovie = Mframes;                         
        end
%%
        function vari = setTimeDependentVariable(obj,var,idx)
            %adjust shape of dynamic variable depending on no. of dimensions
            switch obj.UIset.callTab
                case '2DT'
                    vari = var(idx,:);
                case '3DT' 
                    vari = squeeze(var(idx,:,:));
                    zsize = size(vari,1);
                    if zsize==length(obj.Data.X)
                        vari = vari';
                    end
                case '4DT'    
                    vari = squeeze(var(idx,:,:,:));
            end
        end
%%
        function checkAxisTicks(obj,figax)
            %allow axis tick labels to be set       TICKLABELS NOT SET
            labnames = fieldnames(obj.TickLabels);
            labels = struct2cell(obj.TickLabels);
            for i=1:2:length(labels)
                figax.(labnames{i}) = labels{i};
                figax.(labnames{i+1}) = labels{i+1};
            end
        end
%%
        function isvalid = checkdimensions(obj)
            %check that the dimensions of the selected data match
            data = struct2cell(obj.Data);
            vecdim = cellfun(@isvector,data);
            dimlen = cellfun(@length,data(vecdim));
            if all(vecdim) %all data are vectors
                isvalid = true;
            else
                varsz = size(data{~vecdim});
                isvalid = all(ismember(varsz(varsz>1),dimlen));
            end
            %
            if ~isvalid
                warndlg('Dimensions of selected variables do not match')
            end
        end
%%    
%--------------------------------------------------------------------------
% Get and Set figure and utility functions
%--------------------------------------------------------------------------
        function getFigure(obj)
            %get existing figure or generate a new one as required
            if any(strcmp(obj.UIset.callButton,{'New','Select','Run'}))
                setFigure(obj);      %create new figure
            else
                if length(obj.Plot.FigNum)>1
                    cfig = gcf;
                    obj.idxfig = cfig.Number;
                    while ~any(obj.Plot.FigNum==obj.idxfig)
                        prmptxt = 'Select figure to Add/Delete plots';
                        hd = setdialog(prmptxt); 
                        waitfor(obj,'idxfig')
                        delete(hd);
                    end                    
                else
                    obj.idxfig = obj.Plot.FigNum;
                end
                idx = obj.Plot.FigNum==obj.idxfig;
                obj.Plot.CurrentFig = findobj('Number',obj.Plot.FigNum(idx));
            end
        end
 %%
        function setFigure(obj)
            %create figure for new plot and assign index to figure (idxfig)
            if isempty(obj.Plot.FigNum)
                idx = 1;
            else
                idx = length(obj.Plot.FigNum)+1;
            end

            hf = figure('Name','Results Plot', ...
                'Units','normalized', ...
                'CloseRequestFcn',@obj.closeFigure, ...
                'WindowButtonDownFcn',@obj.getCurrentFigure, ...
                'Resize','on','HandleVisibility','on', ...
                'Visible','on','Tag','PlotFig');
            %move figure to top right
            hf.Position(1) = 1-hf.Position(3)-0.01;
            hf.Position(2) = 1-hf.Position(4)-0.12;
            obj.Plot.FigNum(idx) = hf.Number;
            obj.idxfig = hf.Number;
            %if user has used Tools>Clear all>Figures this can cause
            %duplicate figure numbers so force the list to be unique
            obj.Plot.FigNum = unique(obj.Plot.FigNum);
            obj.Plot.CurrentFig = hf;
        end 
%%
        function getCurrentFigure(obj,src,~)
            %find index for figure to use to add or delete a component
            obj.idxfig = src.Number;
        end    
%%
        function clearPreviousPlotData(obj)
            %reset the property values used to create a plot
            obj.Data = [];            %data to use in plot (x,y,z)
            obj.TickLabels = [];      %struct for XYZ tick labels
            obj.AxisLabels = [];      %struct for XYZ axis labels
            obj.Legend = [];          %Legend text
            obj.MetaData = [];        %text summary of primary variable selection
            obj.Title = [];           %Title text
            obj.Order = [];           %order of variables for selected plot type
        end
%%        
        function closeFigure(obj,src,~)
            %clear a selected figure and update figure number index
            obj.Plot.FigNum(src.Number==obj.Plot.FigNum)=[];
            delete(src);
        end         
    end      
%%
%--------------------------------------------------------------------------
% Static muiPlots functions
%--------------------------------------------------------------------------
    methods(Static, Access=protected)
        function varorder = setVarOrder()
            %struct that holds the order of the variables for different
            %plot types        
            varnames = {'2D','3D','4D','2DT','3DT','4DT'};
            %types of plot in 2,3 and 4D            
            d2 = {'Y','X'};
            d3 = {'Z','X','Y'};
            d4 = {'V','X','Y','Z'};
            %types of animaton in 2,3 and 4D        
            t2 = {'Y','T','X'};
            t3 = {'Z','T','X','Y'};
            t4 = {'V','T','X','Y','Z'};
            varorder = table(d2,d3,d4,t2,t3,t4,'VariableNames',varnames);
        end
    end
%%
%--------------------------------------------------------------------------
% Static open access functions
%--------------------------------------------------------------------------
    methods (Static)
        function h = get3DPlotType(x,y,z,ptype)
            %generate plot based on ptype selection
            xmnmx = minmax(x);
            ymnmx = minmax(y);
            zmnmx = minmax(z);
            range = [xmnmx(:)',ymnmx(:)',zmnmx(:)'];
            switch ptype
                case 'surf'
                    h = surf(x,y,z,'EdgeColor','none'); 
                    axis(range)
                    shading interp
                case 'contour'
                    [~,h] = contour(x,y,z);
                case 'contourf'
                    [~,h] = contourf(x,y,z,'LineColor','none');
                    axis(range(1:4))
                case 'contour3'
                    [~,h] = contour3(x,y,z);
                case 'mesh'                
                    h = mesh(x,y,z);
                otherwise
                    warndlg('Unknown 3D plot type')
            end
        end        
%%
        function xySurface(x,y,z,xint,yint,xtext,ytext,legendtext,...
                                                      titletxt,ptype)
            %surface plot of X,Y,Z data            
            wid = 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId';
            minX = min(min(x)); maxX = max(max(x));
            minY = min(min(y)); maxY = max(max(y));
            xint = (minX:(maxX-minX)/xint:maxX);
            yint = (minY:(maxY-minY)/yint:maxY);
            [xq,yq] = meshgrid(xint,yint);
            warning('off',wid)
             zq = griddata(x,y,z,xq,yq);
             muiPlots.get3DPlotType(xq,yq,zq,ptype);
            warning('on',wid)
            hold on
            xlabel(xtext);
            ylabel(ytext);
            title(titletxt);
            hold off
            cmap = cmap_selection;
            colormap(cmap)
            cb = colorbar;
            cb.Label.String = legendtext;   
        end
%%
        function rtSurface(x,y,z,tint,rint,ytext,legendtext,titletxt)
            %surface plot of R,T,Z polar data            
            wid = 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId';
            radints = linspace(min(y),ceil(max(y)),rint);
            theints = linspace(0,2*pi,tint+1);
            radrange = [0,ceil(max(y))];
            [tq,rq] = meshgrid(theints,radints);                    
            warning('off',wid)
            vq = griddata(deg2rad(x),y,z,tq,rq);
            warning('on',wid)
            polarplot3d(vq,'plottype','contour','TickSpacing',360/tint,...
                'RadLabels',4,'RadLabelLocation',{20 'top'},...
                'RadialRange',radrange,'polardirection','cw');
            title(sprintf('Radial axis: %s\n%s',ytext,titletxt));
            cmap = cmap_selection;
            colormap(cmap)
            cb = colorbar;
            cb.Label.String = legendtext; 
        end       
    end
    
end