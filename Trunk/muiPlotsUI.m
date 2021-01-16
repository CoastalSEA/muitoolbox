classdef muiPlotsUI < muiDataUI
%
%-------class help------------------------------------------------------
% NAME
%   muiPlotsUI.m
% PURPOSE
%   Class implements the DataGUIinterface to access data for use in
%   plotting
% SEE ALSO
%   muiDataUI.m, PlotFig.m
%
% Author: Ian Townend
% CoastalSEA (c) Dec 2020
%--------------------------------------------------------------------------
% 
    properties (Transient)
        %Abstract variables for DataGUIinterface---------------------------        
        %names of tabs providing different data accces options
        TabOptions = {'2D','3D','4D','2DT','3DT','4DT'};       
        %Additional variables for application------------------------------
        GuiChild         %handle for muiPlot to track figures generated
        Tabs2Use         %number of tabs to include  (set in getPlotGui)     
    end  
%%  
    methods (Access=protected)
        function obj = muiPlotsUI(mobj)
            %initialise standard figure and menus
            guititle = 'Select Data for Plotting';
            setDataUIfigure(obj,mobj,guititle);    %initialise figure     
        end
    end
%%    
    methods (Static)
        function obj = getPlotsUI(mobj)
            %this is the function call to initialise the Plot GUI.
            %the input is a handle to the data to be plotted  
            %the options for plot selection are defined in setTabContent
            if isempty(mobj.Cases.Catalogue.CaseID)
                warndlg('No data available to plot');
                obj = [];
                return;
            elseif isa(mobj.mUI.Plots,'muiPlotsUI')
                obj = mobj.mUI.Plots;
                if isempty(obj.dataUI.Figure)
                    %initialise figure 
                    guititle = 'Select Data for Plotting';
                    setDataUIfigure(obj,mobj,guititle);    
                    setDataUItabs(obj,mobj); %add tabs 
                else
                    getdialog('Plot UI is open');
                end
            else
                obj = muiPlotsUI(mobj);
                if any(~ismember(mobj.DataUItabs.Plot,obj.TabOptions))
                    warndlg('Unknown plot type defined in main UI for DataUItabs.Plot')
                    obj = [];
                    return
                end
                obj.Tabs2Use = mobj.DataUItabs.Plot;
                setDataUItabs(obj,mobj); %add tabs                
            end                
        end
    end
%%
%--------------------------------------------------------------------------
% Abstract methods required by muiDataUI to define tab content
%--------------------------------------------------------------------------
    methods (Access=protected) 
        function setTabContent(obj,src)
            %setup default layout options for individual tabs
            %Abstract function required by DataGUIinterface
            itab = find(strcmp(obj.Tabs2Use,src.Tag));
            obj.TabContent(itab) = muiDataUI.defaultTabContent;
            
            %customise the layout of each tab. Overload the default
            %template with a function for the tab specific definition
            switch src.Tag
                case '2D'
                    set2D_tab(obj,src);
                case '3D'
                    set3D_tab(obj,src);
                case '4D'
                    set4D_tab(obj,src);
                case '2DT'
                    set2DT_tab(obj,src);
                case '3DT'
                    set3DT_tab(obj,src); 
                case '4DT'
                    set4DT_tab(obj,src);   
            end             
        end                
%%
        function setVariableLists(obj,src,mobj)
            %Abstract function required by DataGUIinterface
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            sel_uic = S.Selections;
            cobj = getCase(mobj.Cases,1);
            for i=1:length(sel_uic)                
                switch sel_uic{i}.Tag
                    case 'Case'
                        muicat = mobj.Cases.Catalogue;
                        sel_uic{i}.String = muicat.CaseDescription;
                    case 'Dataset'
                        if isempty(cobj.MetaData)
                            sel_uic{i}.String = {'Dataset'};
                        else
                            sel_uic{i}.String = cobj.MetaData;
                        end
                    case 'Variable'     
                        sel_uic{i}.String = cobj.Data{1}.VariableDescriptions;
                    case 'Type'
                        sel_uic{i}.String = S.Type;
                end
            end        
            obj.TabContent(itab).Selections = sel_uic;
        end
%%       
        function setTabActions(obj,src,~,~) 
            %actions needed when activating a tab
            %Abstract function required by DataGUIinterface
            initialiseUIselection(obj,src);
            initialiseUIsettings(obj,src);
            resetVariableSelection(obj,src);
            clearXYZselection(obj,src);
            switch src.Tag
                case {'2D','3D','4D'}
                case {'2DT','3DT','4DT'}
            end
        end 
%%
%         function usevardim = getUseTypeDim(obj)
%             %get the dimensions required for the selected plot type
%             ptype = obj.UIsettings.Type.String;
%             switch ptype
%                 case 'line'
%                     usevardim = 2;
%                 case {'surf','contour','contourf','contour3','mesh'}   
%                     usevardim = 3;
%                 otherwise
%                     usevardim = 4;
%             end
%         end
%%        
        function UseSelection(obj,src,mobj)  
            %make use of the selection made to create a plot of selected type
            %Abstract function required by DataGUIinterface
            if strcmp(src.String,'Save')   %save animation to file
                saveAnimation(obj,src,mobj);
            else
                muiPlots.getPlot(obj,mobj);
            end
        end   
%%
        function saveAnimation(~,~,mobj)
            %save an animation plot created by PlotFig.newAnimation    
            
            ModelMovie = mobj.mUI.Plots.GuiChild.ModelMovie;
            if isempty(ModelMovie)
                warndlg('No movie has been created. Create movie first');
                return;
            end
            [file,path] = uiputfile('*.mp4','Save file as','moviefile.mp4');
            if file==0, return; end
            v = VideoWriter([path,file],'MPEG-4');
            open(v);
            writeVideo(v,ModelMovie);
            close(v);
        end    
    end
%%
%--------------------------------------------------------------------------
% Additional methods used to define tab content
%--------------------------------------------------------------------------
    methods (Access=private)
        function set2D_tab(obj,src)
            %customise the layout of the 2D tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            S.HeadPos = [0.9,0.06];    %header vertical position and height
            S.HeadText = {'For a 1D plot (line, bar, etc) select variable and property to use for X and Y axes'};
            
            %Specification of uicontrol for each selection variable  
%             S.Titles = {'Case','Datset','Plot variable','Plot type'};            
%             S.Style = {'popupmenu','popupmenu','popupmenu','popupmenu'};
%             S.Order = {'Case','Dataset','Variable','Type'};
            %Use default Scaling list
            %Use default Type list
            
            %Tab control button options
            S.TabButText = {'New','Add','Delete','Clear'}; %labels for tab button definition
            S.TabButPos = [0.1,0.14;0.3,0.14;0.5,0.14;0.7,0.14]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 2;                           %minimum number of buttons to use
            S.XYZmxvar = [1,1];                      %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.25,0.91,0.2];       %position for XYZ button panel
            S.XYZlabels = {'Dep','Ind'};             %default button labels
            
            %Action button specifications
            S.ActButNames = {'Refresh','Polar','Swap'}; %names assigned selection struct
            S.ActButText = {char(174),'+','XY'};     %labels for additional action buttons
            % Negative values in ActButPos indicate that a
            % button is alligned with a selection option numbered in the 
            % order given by S.Titles
            S.ActButPos = [0.86,-1;0.895,0.37;0.895,0.28];%positions for action buttons   
            % action button callback function names
            S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)',...
                            '@(src,evt)setPolar(src,evt)',...
                            '@(src,evt)setXYorder(src,evt)'};
            % tool tips for buttons             
            S.ActButTip = {'Refresh data list','Swap from X-Y to Y-X axes',...
                            'XY to Polar; X data in degrees or radians'};         
            obj.TabContent(itab) = S;                %update object
        end
%%
        function set3D_tab(obj,src)
            %customise the layout of the 3D tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.9,0.06];    %header vertical position and height
            S.HeadText = {'For a contour or surface plot, select variable with 2 or more dimensions and properties to use for the X-Y axes'};
            
            %Specification of uicontrol for each selection variable  
%             S.Titles = {'Case','Datset','Plot variable','Plot type'};            
%             S.Style = {'popupmenu','popupmenu','popupmenu','popupmenu'};
%             S.Order = {'Case','Dataset','Variable','Type'};
            %Use default Scaling list
            S.Type = {'surf','contour','contourf','contour3','mesh','User'}; 
            
            %Tab control button options
%             S.TabButText = {'Select','Clear'};     %labels for tab button definition
%             S.TabButPos = [0.1,0.03;0.3,0.03];     %default positions
           
            %XYZ panel definition (if required)
            S.XYZnset = 3;                         %minimum number of buttons to use
            S.XYZmxvar = [2,1,1];                  %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.14,0.91,0.3];     %position for XYZ button panel
            S.XYZlabels = {'Var','X','Y'};         %button labels
            
            %Action button specifications
            S.ActButNames = {'Refresh','Polar'};   %names assigned selection struct
            S.ActButText = {char(174),'+'};        %labels for additional action buttons
            % Negative values in ActButPos indicate that a
            % button is alligned with a selection option numbered in the 
            % order given by S.Titles
            S.ActButPos = [0.86,-1;0.895,0.27];    %positions for action buttons   
            %action button callback function names
            S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)',...
                            '@(src,evt)setPolar(src,evt)'};
            %tool tips for buttons             
            S.ActButTip = {'Refresh data list',...
                            'XY to Polar; X data in degrees'};         
            obj.TabContent(itab) = S;              %update object
        end
%%

        function set4D_tab(obj,src)
            %customise the layout of the 4D tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.9,0.06];    %header vertical position and height
            S.HeadText = {'For a scalar or vector volume plot'};
            
            %Specification of uicontrol for each selection variable  
%             S.Titles = {'Case','Datset','Plot variable','Plot type'};            
%             S.Style = {'popupmenu','popupmenu','popupmenu','popupmenu'};
%             S.Order = {'Case','Dataset','Variable','Type'};
            %Use default Scaling list
            %Tab settings options
            S.Type = {'slice','contourslice','isosurface','streamlines','User'};
            
            %Tab control button options
%             S.TabButText = {'Select','Clear'};   %labels for tab button definition
%             S.TabButPos = [0.1,0.03;0.3,0.03];   %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 4;                         %minimum number of buttons to use
            S.XYZmxvar = [3,1,1,1];                %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.14,0.91,0.4];     %position for XYZ button panel
            S.XYZlabels = {'Var','X','Y','Z'};     %button labels
            
            %Action button specifications - use default
%             S.ActButNames = {'Refresh'};         %names assigned selection struct
%             S.ActButText = {char(174)};          %labels for additional action buttons
%             % Negative values in ActButPos indicate that a
%             % button is alligned with a selection option numbered in the 
%             % order given by S.Titles
%             S.ActButPos = [0.86,-1];             %positions for action buttons   
%             %action button callback function names
%             S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)'};
%             %tool tips for buttons             
%             S.ActButTip = {'Refresh data list'};      

            obj.TabContent(itab) = S;              %update object
        end
%%
        function set2DT_tab(obj,src)
            %customise the layout of the 2DT tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.9,0.06];    %header vertical position and height
            S.HeadText = {'For an animation of a line, surface or volume'};
            
            %Specification of uicontrol for each selection variable  
%             S.Titles = {'Case','Datset','Plot variable','Plot type'};            
%             S.Style = {'popupmenu','popupmenu','popupmenu','popupmenu'};
%             S.Order = {'Case','Dataset','Variable','Type'};
            %Use default Scaling list
            %Use default Type list
            
            %Tab control button options
            S.TabButText = {'Run','Save','Clear'};  %labels for tab button definition
            S.TabButPos = [0.1,0.03;0.3,0.03;0.5,0.03]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 3;                          %minimum number of buttons to use
            S.XYZmxvar = [2,1,1];                   %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.14,0.91,0.30];     %position for XYZ button panel
            S.XYZlabels = {'Var','Time','X'}; %button labels
            
            %Action button specifications
%             S.ActButNames = {'Refresh'};          %names assigned selection struct
%             S.ActButText = {char(174)};           %labels for additional action buttons
%             % Negative values in ActButPos indicate that a
%             % button is alligned with a selection option numbered in the 
%             % order given by S.Titles
%             S.ActButPos = [0.86,-1];              %positions for action buttons   
%             %action button callback function names
%             S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)'};
%             %tool tips for buttons             
%             S.ActButTip = {'Refresh data list'};         
            obj.TabContent(itab) = S;               %update object
        end   
%%
        function set3DT_tab(obj,src)
            %customise the layout of the 2DT tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.9,0.06];    %header vertical position and height
            S.HeadText = {'For an animation of a line, surface or volume'};
            
            %Specification of uicontrol for each selection variable  
%             S.Titles = {'Case','Datset','Plot variable','Plot type'};            
%             S.Style = {'popupmenu','popupmenu','popupmenu','popupmenu'};
%             S.Order = {'Case','Dataset','Variable','Type'};
            %Use default Scaling list
            %Use default Type list
            S.Type = {'surf','contour','contourf','contour3','mesh','User'}; 
            
            %Tab control button options
            S.TabButText = {'Run','Save','Clear'};  %labels for tab button definition
            S.TabButPos = [0.1,0.03;0.3,0.03;0.5,0.03]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 3;                          %minimum number of buttons to use
            S.XYZmxvar = [3,1,1,1];                 %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.14,0.91,0.40];     %position for XYZ button panel
            S.XYZlabels = {'Var','Time','X','Y'}; %button labels
            
            %Action button specifications - use default
    
            obj.TabContent(itab) = S;               %update object            
        end
%%
        function set4DT_tab(obj,src)
            %customise the layout of the 2DT tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.9,0.06];    %header vertical position and height
            S.HeadText = {'For an animation of a volume'};
            
            %Specification of uicontrol for each selection variable  
%             S.Titles = {'Case','Datset','Plot variable','Plot type'};            
%             S.Style = {'popupmenu','popupmenu','popupmenu','popupmenu'};
%             S.Order = {'Case','Dataset','Variable','Type'};
            %Use default Scaling list
            %Use default Type list
            S.Type = {'slice','contourslice','isosurface','streamlines','User'}; 
            
            %Tab control button options
            S.TabButText = {'Run','Save','Clear'};  %labels for tab button definition
            S.TabButPos = [0.1,0.03;0.3,0.03;0.5,0.03]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 5;                          %minimum number of buttons to use
            S.XYZmxvar = [4,1,1,1,1];               %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.14,0.91,0.48];     %position for XYZ button panel
            S.XYZlabels = {'Var','Time','X','Y','Z'}; %button labels
            
            %Action button specifications - use default
    
            obj.TabContent(itab) = S;               %update object            
        end        
    end
end