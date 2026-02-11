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
            ok = getPlotData(obj,mobj.Cases,'array');
            if ok<1, return; end %data not found
            isvalid = checkdimensions(obj);
            if ~isvalid, return; end
            
            if ~isempty(obj.UIset.Type) && strcmp(obj.UIset.Type.String,'User')
                user_plot(obj,mobj);  %pass control to user function
            else
                %generate the plot
                setPlot(obj,mobj);
            end
        end
%%
        function obj = get_muiPlots()
            %get an instance of muiPlots for a stand along function that is
            %not useing muiPlotsUI
            obj = muiPlots;                   %create new instance
        end        
    end
%%   
    methods (Access=protected)
       function setPlot(obj,mobj)    
            %manage plot generation for different types and add/delete                   
            %get an existing figure of create a new one
            getFigure(obj); 
            %call the specific plot type requested
            callPlotType(obj);
            %assign muiPlots instance to handle
            mobj.mUI.Plots = obj;
            if isvalid(obj.Plot.CurrentFig)
                obj.Plot.CurrentFig.Visible = 'on';
            end
       end   
%%
        function ok = getPlotData(obj,muicat,dtype,legformat)
            %get the data to be used in the plot
            % dtype - data format to be returned: array, table, dstable,
            % splittable or timeseries
            % legtype - format to use for the legend text
            ok = 1;
            if nargin<4
                legformat = 'Default';
            end
            nvar = length(obj.UIsel);
            %initialise struct used in muiCatalogue.getProperty
            props(nvar) = setPropsStruct(muicat);
            for i=1:nvar
                %get the data and labels for each variable
                if obj.UIsel(i).caserec>0
                    props(i) = getProperty(muicat,obj.UIsel(i),dtype);
                    if isempty(props(i).data), ok = ok-1; end
                end
            end
            if ok<=0, return; end
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
                if obj.UIsel(i).scale>1 && obj.UIsel(i).property==1  %apply selected scaling to variable
                    usescale = obj.UIset.scaleList{obj.UIsel(i).scale};
                    dim = 1; %dimension to apply scaling function if matrix
                    data2use = scalevariable(data2use,usescale,dim);
                    props(i).label = sprintf('%s-%s',usescale,props(i).label);
                end
                obj.Data.(xyz{i}) = data2use;
                obj.AxisLabels.(xyz{i}) = props(i).label;
                mtxt = sprintf('%s\n%s: %s',mtxt,xyz{i},obj.UIsel(i).desc);
            end
            obj.MetaData = mtxt;
            
            %generate legend text
            obj.Legend = setLegendText(obj,props,legformat,1); %returns root case(dset)var
            idplotvar = find([obj.UIsel(:).property]==1);
            for ivar=2:length(idplotvar)
                legtxt = setLegendText(obj,props,legformat,ivar);
                obj.Legend = sprintf('%s\n%s',obj.Legend,legtxt);               
            end

            %description of selection for use as title (short dims text option)
            obj.Title = get_selection_text(props(1),3); %use dependent variable to define title
        end
%%    
        function legtext = setLegendText(~,props,legformat,ivar)
            %set the legend text based on the type of plot and selection made
            if isstruct(legformat(ivar))   %use defined adjustments for legend
                %legformat is a struct with:
                % idx - logical array of the text positions to replace (1-3)
                % text - replacement text - array size must match sum(idx)
                % eg [0,1,0] replaces the central value with string in text
                % to give Case(text)Variable
                deflegend = {props(ivar).case,props(ivar).dset,props(ivar).desc};
                idtxt = logical(legformat(ivar).idx);
                if isempty(legformat(ivar).text) %no alternative text provided
                    %apply idx as a mask to use just one or two of
                    %the default descriptions, Case,Dataset,Variable
                    % eg idx = [1,0,1] gives Case(Variable) 
                    deflegend = deflegend(idtxt);
                    legmask = {'%s','%s (%s)'};
                    legtext = sprintf(legmask{sum(idtxt)},deflegend{:});
                else
                    if ischar(legformat(ivar).text)
                        deflegend(idtxt) = {legformat(ivar).text}; 
                    else
                        deflegend(idtxt) = legformat(ivar).text; 
                    end
                    legtext = sprintf('%s (%s) %s',deflegend{:}); 
                end
            else  %use default text for legend based on Case(Dataset)Variable
                legtext = sprintf('%s (%s) %s',props(ivar).case,...
                                       props(ivar).dset,props(ivar).desc);
            end
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
                            elseif obj.UIset.Polar
                                addPolarPlot(obj)
                            else
                                add2Dplot(obj);
                            end
                        case 'Delete'           %delete variable from 2D plot                            
                            del2Dplot(obj);
                    end
                case '3D'
                    new3Dplot(obj);
                case '4D'
                    new4Dplot(obj);
                case {'2DT','3DT','4DT'}
                    newAnimation(obj);
                otherwise
                    warndlg('Could not find plot option in callPlotType');
            end
        end
%%
%--------------------------------------------------------------------------
% Functions for 2d plots
%--------------------------------------------------------------------------
        function [x,y,hf,fnum,symb] = plot2Ddata(obj)
            %information required to create, add or delete 2D plot            
            x = checkcharcat(obj.Data.X);
            y = checkcharcat(obj.Data.Y);
%             x = obj.Data.X;
%             if iscell(x), x = categorical(x); end %assumes cell is char vector of unique values
%             y = obj.Data.Y;
%             if iscell(y), y = categorical(y); end %assumes cell is char vector of unique values        
            idx = obj.Plot.FigNum==obj.Plot.CurrentFig.Number;
            hf = findobj('Number',obj.Plot.FigNum(idx));
            fnum = num2str(hf.Number); 
            %set up symbol
            symb = {'-','none'};
            %check x-y variables
            if length(x)~=length(y)
               delete(hf)
               obj.Plot.FigNum(idx)=[];
               warndlg('Length of X and Y do not match')
               x = []; y = [];  hf = [];
            end
            
            %nested function ----------------------------------------------
            function var = checkcharcat(invar)
				%check for categorical data and if unique set as an ordered data set
                if iscell(invar)
                    if isunique(invar)
                        %retain order of var by specifying categories
                        var = categorical(invar,invar,'Ordinal',true); %retains order of invar
                    else
                        %var has multiple occurrences of a category
                        var = categorical(invar,'Ordinal',true);
                    end
                elseif iscategorical(invar) && isunique(invar)
                    var = categorical(invar,invar,'Ordinal',true); %retains order of invar
                elseif strcmp(obj.UIset.Type.String,'bar') && ...
                                   (isdatetime(invar) || isduration(invar))
                    var = categorical(invar,invar,'Ordinal',true); %retains order of invar
                else
                    var = invar;
                end
            end
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
            if isempty(x), return; end
            figax = axes('Parent',hfig,'Tag','PlotFigAxes'); 
            hold(figax,'on')
            [hptype,symb] = get2DPlotFunc(obj); %function handle for plot type
            if strcmp(symb{1},'grouped') && iscategorical(y)
                cats = categories(y);
                y = double(y); %convert categorical data to numerical
            else
                cats = [];
            end
            
            %add checks for list type variables 
            xlist = false;
            if islist(x,2)
                xtxt = x; x = 1:length(x); xlist = true;
            end
            ylist = false;
            if islist(y,2)
                ytxt = y; y = 1:length(y); ylist = true;
            end
            
            %check whether RightYaxis button has been set to use right axis
            if isfield(obj.UIset,'RightYaxis') && obj.UIset.RightYaxis
                yyaxis(figax,'right')         %use right axis if true
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

            %handle ticks for categoric data
            if strcmp(symb{1},'grouped')&& strcmp(obj.UIset.Type.String,'barh') ...
                                                    && ~isempty(cats)
                xticks(1:length(cats));
                xticklabels(cats);
            elseif strcmp(symb{1},'grouped') && ~isempty(cats)
                yticks(1:length(cats));
                yticklabels(cats);
            end
            
            if xlist
                xticks(1:length(x));
                xticklabels(xtxt);
            end
            if ylist
                yticks(1:length(y));
                yticklabels(ytxt);
            end
            
            %handle ticks for log scaled data
            if strcmp(obj.UIset.scaleList{obj.UIsel(1).scale},'Log')
                idx = find(mod(figax.XTick(:), 1) == 0);
                figax.XTick = figax.XTick(idx); %remove non integer exponents
                figax.XTickLabel = cellstr(num2str(figax.XTick(:), '10^{%d}'));
            end

            if obj.UIsel(2).scale>0 && ...
                      strcmp(obj.UIset.scaleList{obj.UIsel(2).scale},'Log')
                idy = find(mod(figax.YTick(:), 1) == 0);
                figax.YTick = figax.YTick(idy); %remove non integer exponents
                figax.YTickLabel = cellstr(num2str(figax.YTick(:), '10^{%d}'));
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
            hp = allchild(figax); %seems to do what getplothandles does without the validType check
            idline = numel(hp)+1;
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

            %check axis values are compatible
            dtype = class(figax.XLim);
            if ~isa(x,dtype)    
                warndlg('X-data type not compatible with existing axis')
                return;
            end
            
            %check whether RightYaxis button has been set to use right axis
            %only use hold on if axes has already been defined
            if isfield(obj.UIset,'RigthYaxis')
                is2Yaxes = ~isscalar(figax.YAxis);
                if ~is2Yaxes && obj.UIset.RightYaxis
                    %yyaxis(figax,'left') 
                    yyaxis(figax,'right') 
                elseif is2Yaxes && obj.UIset.RightYaxis 
                    yyaxis(figax,'right')    
                    hold(figax,'on');
                elseif is2Yaxes && ~obj.UIset.RightYaxis 
                    %reset y-axis to use the left axis
                    yyaxis(figax,'left') 
                    hold(figax,'on');
                else
                    hold(figax,'on');
                end  
            else
                hold(figax,'on');
            end         
                        
            [hptype,symb] = get2DPlotFunc(obj); %function handle for plot type
            %call uses figax,x,y,'LineStyle','Marker','DisplayName','Tag'
            hp(idline) = hptype(figax,x,y,symb{1},symb{2},...
                                            obj.Legend,num2str(idline));
            
            %if left and right axes are being used check they are labelled
            if isfield(obj.UIset,'RigthYaxis') && ~isscalar(figax.YAxis) %NB:can be updated by plot from is2Yaxes
                if obj.UIset.RightYaxis && isempty(figax.YAxis(2).Label.String)
                    figax.YAxis(2).Label.String = obj.AxisLabels.Y;
                elseif ~obj.UIset.RightYaxis && isempty(figax.YAxis(1).Label.String)
                    figax.YAxis(1).Label.String = obj.AxisLabels.Y;
                end
            end

            hp(idline).UserData = obj.MetaData;                             
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
            hp = allchild(figax); %seems to do what getplothandles does without the validType check
            hl = findobj('Type','legend','Tag',fnum);
            idline = [];

            if strcmp(obj.Plot.CurrentFig.Name,'Rose plot')
                warndlg('Cannot delete individual rose plots')
                return;
            elseif hfig.UserData==1 %XY have been swapped
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
                        idline(nline) = i; %#ok<AGROW> 
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
                    promptxt = {'To add reference line enter angle to degTN:',...
                                'Variable intensity subdivistions (eg 0 0.5 1 ...)',...
                                'Percentage circles to draw (eg 10 20 30)'};
                    rinp = inputdlg(promptxt,'Rose plot');
                    rose.theta = parseInput(rinp{1});
                    rose.di = parseInput(rinp{2});
                    rose.ci = parseInput(rinp{3});
                    rh = wind_rose(x,y,'parent',figax,'dtype','meteo',...
                        'shore',rose.theta,'di',rose.di,'ci',rose.ci,...
                        'labtitle',obj.Legend,'lablegend',obj.AxisLabels.Y);
                    rax = rh.Parent;
                    rax.UserData = rose;
            end
            %-nested function----------------------------------------------
            function var = parseInput(vartxt)
                if isempty(vartxt)
                    var = [];
                else
                    var = str2num(vartxt); %#ok<ST2NM> parsing scalar and vector
                end
            end
        end
%%
        function addPolarPlot(obj)
            %modify figure to add polar or rose plot
            if strcmp(obj.Plot.CurrentFig.Name,'Rose plot')
                addRosePlot(obj)
            else
                add2Dplot(obj)
            end
        end
%%       
        function addRosePlot(obj)
            %modify figure to subplots and add rose
            %get an existing figure of create a new one
            [x,y,hfig,~,~] = plot2Ddata(obj);
            figax = findobj(hfig,'Type','Axes','-or','Type','PolarAxes');
            rose = figax.UserData;
            if isscalar(figax)
                %order and interaction with wind_rose is not straightforward
                s1 = subplot(1,2,1,figax);
                set(s1,'Position',[0.03 0.1 0.45 0.8] ,'Units', 'normalized');
                set(groot,'CurrentFigure',hfig)
                s2 = subplot(1,2,2);
                set(s2,'Position',[0.5 0.1 0.45 0.8] ,'Units', 'normalized');
                if isempty(rose)
                    wind_rose(x,y,'parent',s2,'dtype','meteo',...
                        'labtitle',obj.Legend,'lablegend',obj.AxisLabels.Y);
                else
                    wind_rose(x,y,'parent',figax,'dtype','meteo',...
                        'shore',rose.theta,'di',rose.di,'ci',rose.ci,...
                        'labtitle',obj.Legend,'lablegend',obj.AxisLabels.Y);
                end
            else
                warndlg('Only one plot can be added using a Rose')
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
                    yexist(:,i) = hp.YData; %#ok<AGROW> 
                end
            end
            y = horzcat(yexist,y);
            %now revise legend and axis labels
            hleg = findobj(hfig,'Type','legend');
            legtxt = horzcat(hleg.String,obj.Legend);
            
            delete(hp)
            [hptype,symb] = get2DPlotFunc(obj); %function handle for plot type
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
                warndlg('Dimensions are not compatible with variable')
                return;
            end

            zsize = size(z);
            if zsize(1)==length(x)
                z = z';
            end

            %retrospective addition of iscmap to allow user to select color map
            iscmap = true;
            if isfield(obj.UIset,'iscmap')
                iscmap = obj.UIset.iscmap;
            end
            %
            if isfield(obj.UIset,'Polar') && obj.UIset.Polar
                muiPlots.rtSurface(x,y,z,24,yint,obj.AxisLabels.Y,...
                                               obj.Legend,obj.Title,iscmap);
            else
                if isempty(obj.UIset.Type.String)
                    ptype = 'surf';
                else
                    ptype = obj.UIset.Type.String;
                end
                muiPlots.xySurface(x,y,z,xint,yint,obj.AxisLabels.X,...
                              obj.AxisLabels.Y,obj.Legend,obj.Title,...
                              ptype,iscmap);
            end
        end 
%%
%--------------------------------------------------------------------------
% Functions for 4D plots
%--------------------------------------------------------------------------
        function new4Dplot(~)
            %control and definition of plots that are 4D
            warndlg('Not yet implemented')
        end
%%
%--------------------------------------------------------------------------
% Functions for animations
%--------------------------------------------------------------------------
        function newAnimation(obj)
            %generate an animation for user selection.
            hfig = obj.Plot.CurrentFig;
            hfig.Visible = 'on';

            t = obj.Data.T;  %obj.Data.T is modified by call to converTime in new3Dplot
            nrec = length(t);
            
            switch obj.UIset.callTab
                case '2DT'
                    var = obj.Data.Y;
                    vari = setTimeDependentVariable(obj,var,1);
                    obj.Data.Y = vari;   %first time step
                    if obj.UIset.Polar
                        newPolarplot(obj);                              
                    else
                        new2Dplot(obj);  
                    end
                    if ~isvalid(hfig), return; end
                    figax = gca;
                    hp = figax.Children;
                    hp.YDataSource = 'vari';
                    if ~obj.UIset.Polar
                        figax.YLimMode = 'manual';   
                        figax.YLim = minmax(var);
                    end
                case '3DT'
                    var = obj.Data.Z;
                    vari = setTimeDependentVariable(obj,var,1); 
                    obj.Data.Z = vari;  %first time step
                    new3Dplot(obj)
                    if ~isvalid(hfig), return; end
                    figax = gca;
                    stype = 'surface';
                    if contains(obj.UIset.Type.String,'contour')
                        stype = 'contour';
                    end
                    hp = findobj(figax.Children,'Type',stype);
                    hp.ZDataSource = 'vari';   %changed from CDataSource to plot contours and surfaces 23Aug23

                    figax.ZLimMode = 'manual'; %fix limits of z-axis
                    figax.ZLim = minmax(var);  
                    figax.CLim = figax.ZLim;  

                    if isfield(obj.UIset,'Polar') && obj.UIset.Polar
                        theta = obj.Data.X;
                        rad = obj.Data.Y;
                        for i=1:nrec
                            vari = setTimeDependentVariable(obj,var,i); 
                            polarvar(i,:,:) = muiPlots.reshapePolarGrid(theta,...
                                                              rad,vari,24);  %#ok<AGROW> 
                        end
                        var = polarvar;
                    end
                case '4DT'
                    warndlg('Not ready yet')
                    return;
                case 'Digraph'
                    g = obj.Data.network;     %digraph
                    y = obj.Data.Y;           %variable used to color nodes 
                    nsze = obj.Data.nodesize; %size of nodes
                    obj.Title =sprintf('Network for %s',obj.AxisLabels.Y);
                    [hp,hg]  = muiPlots.nodalnetwork(g,y,nsze,obj.Legend,obj.Title);
                    var.graph = hg; var.plot = hp;
                    figax = gca;
            end 
           
            adjustAxisTicks(obj,figax);  %adjust tick labels  if defined
            figax.Position = [0.16,0.16,0.65,0.75]; %make space for slider bar
            title(sprintf('%s \nTime = %s',obj.Title,string(t(1))))

            figax.NextPlot = 'replaceChildren';
            figax.Tag = 'PlotFigAxes';            
            Mframes(nrec) = struct('cdata',[],'colormap',[]);
            Mframes(1) = getframe(gcf); %NB print function allows more control of 
            for i=2:nrec
                vari = setTimeDependentVariable(obj,var,i); %#ok<NASGU>
                refreshdata(hp,'caller')
                title(sprintf('%s \nTime = %s',obj.Title,string(t(i))))
                drawnow;                 
                Mframes(i) = getframe(gcf); 
                %NB print function allows more control of resolution 
            end
            idm = size(obj.ModelMovie,1);            
            obj.ModelMovie{idm+1,1} = hfig.Number;
            obj.ModelMovie{idm+1,2} = Mframes;   %save movie to class property
            obj.Data.T = t;     %restore datetime values
            obj.Data.Z = var;   %restore Z values
            figax.UserData = obj.Data;  %store data set in UserData to
                                        %allow user to switch between plots
            %add replay and slider
            setControlPanel(obj,hfig,nrec,string(t(1)));  
        end
    end
%%
    methods
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
                case 'Digraph'
                    g = var.graph;
                    vari = var;
                    vari.plot.NodeCData = g.Nodes.NodeColors(:,idx);
            end
        end
%%
        function adjustAxisTicks(obj,figax)
            %allow axis tick labels to be set 
            if isstruct(obj.TickLabels)
                labnames = fieldnames(obj.TickLabels);
                labels = struct2cell(obj.TickLabels);                
                for i=1:2:length(labels)
                    figax.(labnames{i}) = labels{i};
                    figax.(labnames{i+1}) = labels{i+1};
                    if strcmp(labnames{i},'XTick')
                        nlab = length(labels{i+1});
                        mxlen = max(cellfun(@length,labels{i+1}));
                        if nlab*mxlen>100
                            figax.XTickLabelRotation = 45;
                        end
                    end
                end
            end
        end
%%
        function hm = setControlPanel(obj,hfig,nrec,t0)
            %intialise button to re-run animation and slider to scroll through
            %add playback button
            buttxt = 'Run';   
            butpos = [0.05,0.01,0.05,0.05];
            butcall = @(src,evt)runMovie(obj,src,evt);
            buttag = 'runMovie';
            buttip = 'Press to rerun animation';         
            hm(1) = setactionbutton(hfig,buttxt,butpos,butcall,buttag,buttip);
            buttxt = 'Save';   
            butpos = [0.12,0.01,0.05,0.05];
            butcall = @(src,evt)runMovie(obj,src,evt);
            buttag = 'saveMovie';
            buttip = 'Press to save animation';  
            hm(2) = setactionbutton(hfig,buttxt,butpos,butcall,buttag,buttip);
            %add slide control            
            hm(3) = uicontrol('Parent',hfig,...
                    'Style','slider','Value',1,... 
                    'Min',1,'Max',nrec,'sliderstep',[1 1]/nrec,...
                    'Callback', @(src,evt)runMovie(obj,src,evt),...
                    'HorizontalAlignment', 'center',...
                    'Units','normalized', 'Position', [0.2,0.01,0.6,0.04],...
                    'Tag','stepMovie');
            hm(4) = uicontrol('Parent',hfig,...
                    'Style','text','String',t0,'Units','normalized',... 
                    'Position',[0.8,0.01,0.15,0.03],'Tag','FrameTime');
        end
%%
        function runMovie(obj,src,~)
            %callback function for animation figure buttons and slider
            hfig = src.Parent;
            idm = hfig.Number==[obj.ModelMovie{:,1}];
            if strcmp(src.Tag,'runMovie')       %user pressed run button
                if license('test', 'Image_Processing_Toolbox')   %tests whether product is licensed (returns 1 if it is)
                    implay(obj.ModelMovie{idm,2});
                else
                    hmf = figure;
                    movie(hmf,obj.ModelMovie{idm,2});
                end
            elseif strcmp(src.Tag,'saveMovie')  %user pressed save button 
                saveanimation2file(obj.ModelMovie{idm,2});
            else                                %user moved slider
                val = ceil(src.Value);          %slider value 
                %get figure axis, extract variable and refresh plot                
                figax = findobj(hfig,'Tag','PlotFigAxes'); 
                time = figax.UserData.T(val);   %time slice selected
                var = figax.UserData.Z;
                              
                hp = figax.Children;
                vari = setTimeDependentVariable(obj,var,val); %#ok<NASGU>
                refreshdata(hp,'caller')
                title(sprintf('%s \nTime = %s',obj.Title,string(time)))
                drawnow;
                %update slider selection text
                stxt = findobj(hfig,'Tag','FrameTime');
                stxt.String = string(time);
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
        function hfig = getFigureHandle(obj)
            %get figure created using muiPlots.setFigure
            idfig = obj.Plot.FigNum==obj.Plot.CurrentFig.Number;
            hfig = findobj('Number',obj.Plot.FigNum(idfig));
        end
%%
        function casedef = getRunParams(obj,mobj,idx)
            %get the run time parameters for the idx property selection
            caserec = obj.UIsel(idx).caserec;
            cobj = getCase(mobj.Cases,caserec);
            casedef = cobj.RunParam;
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
            if isvalid(obj) && isfield(obj.Plot,'FigNum')
                obj.Plot.FigNum(src.Number==obj.Plot.FigNum)=[];
                if ~isempty(obj.ModelMovie)
                    idm = src.Number==[obj.ModelMovie{:,1}];
                    obj.ModelMovie(idm,:) = [];
                end
            end
            delete(src);
        end         
%%
        function convertTime(obj)
            %convert time for plotting
            fname = fieldnames(obj.Data);
            nrec = length(fname);
            for i=1:nrec
                x = obj.Data.(fname{i});
                if isdatetime(x) || isduration(x)
                    obj.Data.(fname{i}) = time2num(x);
                end
            end
        end 
%%
        function getAplot(obj)
            %allow external function to call muiPlots plot
            %see cf_animation in the ChannelForm model for example of usage
            callPlotType(obj)
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
            if diff(zmnmx)==0, zmnmx(2) = Inf; end
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
        function h = xySurface(x,y,z,xint,yint,xtext,ytext,legendtext,...
                                                  titletxt,ptype,iscmap)
            %surface plot of X,Y,Z data  
            if nargin<11, iscmap=true; end
            wid = 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId';
            warning('off',wid)
              [xq,yq,zq] = muiPlots.reshapeXYZ(x,y,z,xint,yint);
              h = muiPlots.get3DPlotType(xq,yq,zq,ptype);
            warning('on',wid)
            hold on
            xlabel(xtext);
            ylabel(ytext);
            title(titletxt);
            hold off
            
            %handle axes that are text of some form
            if islist(x,1)  
                xticks(1:length(x));
                xticklabels(x);
            end
            if islist(y,1)
                yticks(1:length(y));
                yticklabels(y);
            end           
            
            %set color map based on user selection
            if iscmap, cmap = cmap_selection; else, cmap = []; end
            if isempty(cmap), cmap = 'parula'; end
            colormap(cmap)
            cb = colorbar;
            cb.Label.String = legendtext;   
        end
%%
        function h = rtSurface(x,y,z,tint,rint,ytext,legendtext,titletxt,iscmap)
            %surface plot of R,T,Z polar data   
            if nargin<9, iscmap=true; end
            wid = 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId';
            radints = linspace(min(y),ceil(max(y)),rint);
            theints = linspace(0,2*pi,tint+1);
            radrange = [0,ceil(max(y))];
            [tq,rq] = meshgrid(theints,radints);                    
            warning('off',wid)
            vq = griddata(deg2rad(x),y,z,tq,rq);
            warning('on',wid)
            polarplot3d(vq,'plottype','surfn','TickSpacing',360/tint,...
                'RadLabels',4,'RadLabelLocation',{20 'top'},...
                'RadialRange',radrange,'polardirection','cw');
            ax = gca;
            ax.XLim = [-1,1];
            ax.YLim = [-1,1];
            axis equal
            axis(gca,'off')
            view(2)
            shading interp 
            
            title(sprintf('Radial axis: %s\n%s',ytext,titletxt));
            axis(gca,'off')
            if iscmap, cmap = cmap_selection; else, cmap = []; end
            if isempty(cmap), cmap = 'parula'; end
            colormap(cmap)
            cb = colorbar;
            cb.Label.String = legendtext; 
            h = gca;
        end      
%%
        function [hp,hg] = nodalnetwork(g,y,nsze,legendtext,titletxt)
            %nodal network plot using instance of a digraph netwok
            %g - handle to digraph
            %y - variable that defines node colors
            hp = plot(g);
            hp.MarkerSize = nsze;
            clim([min(min(y)),max(max(y))]);
            hg.Nodes.NodeColors = y';
            title(titletxt);
            cmap = cmap_selection;
            colormap(cmap)
            cb = colorbar;
            cb.Label.String = legendtext;
        end     
%%
        function [xq,yq,zq] = reshapeXYZ(x,y,z,xint,yint)
            %ensure that XYZ are arrays of the same dimension. Additional
            %check required when plotting variables where the variable and
            %a dimension are a function of another dimension (eg elevation
            %and chainage are both a function of time so that one dimension 
            %is a nx1 vector and the other dimension and variable are nxm
            if ~isnumeric(x) || ~isnumeric(y) %check for text variables
                [x,y] = muiPlots.makeNumeric(x,y);
            end

            %isallmat = isvector(x) && ~isvector(y); %do not know why this was added

            if (isvector(x) && isvector(y)) || isequal(size(x), size(y), size(z))  %possibly only need check x and y?
                %x and y are vectors so use griddata to get arrays or
                % x, y and z are are already array of same size so regrid
                % them to selected xint and yint
                minX = min(min(x)); maxX = max(max(x));
                minY = min(min(y)); maxY = max(max(y));
                xint = (minX:(maxX-minX)/xint:maxX);
                yint = (minY:(maxY-minY)/yint:maxY);
                [xq,yq] = meshgrid(xint,yint);
                zq = griddata(x,y,z,xq,yq);
            elseif isvector(x) && ~isvector(y)
                %x is vector and y is array with same dimensions as z
                if iscolumn(x), x = x'; end  
                xq = repmat(x,1,size(z,1))';
                yq = y';
                zq = z;
            elseif isvector(y) && ~isvector(x)
                %y is vector and x is array with same dimensions as z
                xq = x;
                if isrow(y), y = y'; end  
                yq = repmat(y,1,size(z,2));
                zq = z;
            else
                xq = []; yq = []; zq = [];
            end
        end
        
%%
        function [x,y] = makeNumeric(x,y)
            %check x and y values and convert to numeric if any form of
            %text
            if isvector(x) && ~isnumeric(x)
                x = 1:length(x);
            end
            %
            if isvector(y) && ~isnumeric(y)
                y =  1:length(y);
            end
        end
%%
function P = reshapePolarGrid(theta,rad,S,tint)
            %format spectral array to be in format required by polarplot3d
            wid = 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId';
            %interpolate var(phi,T) onto plot domain defined by tints,rints
            %intervals match those set to initialise plot in SpectralTransfer.polar_plot
            rint = length(rad)-1;
            radints = linspace(min(rad),ceil(max(rad)),rint);
            theints = linspace(0,2*pi,tint+1);
            [Tq,Rq] = meshgrid(theints,radints); 
            warning('off',wid)
            P = griddata(deg2rad(theta),rad,S,Tq,Rq);
            P(isnan(P)) = 0;  %fill blank sector so that it plots the period labels
            warning('on',wid)
        end        
    end
end