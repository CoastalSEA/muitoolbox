classdef muiPlotsUI < muiDataUI
%
%-------class help------------------------------------------------------
% NAME
%   muiPlotsUI.m
% PURPOSE
%   Class implements the muiDataUI to access data for use in
%   plotting
% SEE ALSO
%   muiDataUI.m, PlotFig.m
%
% Author: Ian Townend
% CoastalSEA (c) Dec 2020
%--------------------------------------------------------------------------
% 
    properties (Transient)
        %Abstract variables for muiDataUI---------------------------        
        % names of tabs providing different data accces options
        TabOptions = {'2D','3D','4D','2DT','3DT','4DT'}; 
        % selections that force a call to setVariableLists
        updateSelections = {'Case','Dataset'};
        %Additional variables for application------------------------------
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
            %this is the function call to initialise the UI and assigning
            %to a handle of the main model UI (mobj.mUI.PlotsUI) 
            %options for selection on each tab are defined in setTabContent
            if isempty(mobj.Cases.Catalogue.CaseID)
                warndlg('No data available to plot');
                obj = [];
                return;
            elseif isa(mobj.mUI.PlotsUI,'muiPlotsUI')
                obj = mobj.mUI.PlotsUI;
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
                idx = find(~ismember(mobj.DataUItabs.Plot,obj.TabOptions));
                if ~isempty(idx)
                    txt1 = 'Unknown plot type defined in main UI for DataUItabs.Plot';
                    for j=1:length(idx)
                        txt1 = sprintf('%s\n"%s" not defined',txt1,mobj.DataUItabs.Plot{idx(j)});
                    end
                    warndlg(txt1)
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
            %Abstract function required by muiDataUI
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
        function setVariableLists(obj,src,mobj) %**
            %initialise the variable lists or values
            %Abstract function required by muiDataUI
            %called during initialisation by muiDataUI.setDataUItabs and 
            %whenever muiDataUI.updateCaseList is called
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            sel_uic = S.Selections;
            caserec = sel_uic{strcmp(S.Order,'Case')}.Value; %**
            cobj = getCase(mobj.Cases,caserec);
            dsnames = fieldnames(cobj.Data); %**
            ids = sel_uic{strcmp(S.Order,'Dataset')}.Value; %**
            for i=1:length(sel_uic)                
                switch sel_uic{i}.Tag
                    case 'Case'
                        muicat = mobj.Cases.Catalogue;
                        sel_uic{i}.String = muicat.CaseDescription;
                        sel_uic{i}.UserData = sel_uic{i}.Value; %used to track changes
                    case 'Dataset'
                        sel_uic{i}.String = dsnames; %**
                        sel_uic{i}.UserData = sel_uic{i}.Value; %used to track changes
                    case 'Variable' 
                        ds = fieldnames(cobj.Data);
                        sel_uic{i}.String = cobj.Data.(ds{ids}).VariableDescriptions;
                        sel_uic{i}.Value = 1;
                    case 'Type'
                        sel_uic{i}.String = S.Type;
                    otherwise
                        sel_uic{i}.String = 'Not set';
                end
            end        
            obj.TabContent(itab).Selections = sel_uic;
        end
%%        
        function useSelection(obj,src,mobj)  
            %make use of the selection made to create a plot of selected type
            %Abstract function required by muiDataUI
            if strcmp(src.String,'Save')   %save animation to file
                saveAnimation(obj,src,mobj);
            else
                muiPlots.getPlot(obj,mobj);
            end
        end   
%%
        function saveAnimation(~,~,mobj)
            %save an animation plot created by PlotFig.newAnimation    
            ModelMovie = mobj.mUI.Plots.ModelMovie;
            if isempty(mobj.mUI.Plots) || isempty(ModelMovie)
                warndlg('No movie has been created. Create movie first');
            else
                saveAnimation2File(mobj.mUI.Plots);
            end
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
            S.HeadPos = [0.86,0.1];    %header vertical position and height
            txt1 = 'For a cartesian plot (line, bar, etc) select variable and dimension to use for X and Y axes';
            txt2 = 'For a Polar or Rose plot, switch the + button to O and set X to a direction variable';
            txt3 = 'Use the XY button to swap the X and Y variables without needing to reassign them';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            
            %Specification of uicontrol for each selection variable  
            %Use default lists
            
            %Tab control button options
            S.TabButText = {'New','Add','Delete','Clear'}; %labels for tab button definition
            S.TabButPos = [0.1,0.14;0.3,0.14;0.5,0.14;0.7,0.14]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 2;                           %minimum number of buttons to use
            S.XYZmxvar = [1,1];                      %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.25,0.91,0.2];       %position for XYZ button panel
            S.XYZlabels = {'Var','X'};               %default button labels
            
            %Action button specifications
            S.ActButNames = {'Refresh','Swap','Polar'}; %names assigned selection struct
            S.ActButText = {char(174),'XY','+'};     %labels for additional action buttons
            % Negative values in ActButPos indicate that a
            % button is alligned with a selection option numbered in the 
            % order given by S.Titles
            S.ActButPos = [0.86,-1;0.895,0.37;0.895,0.28];%positions for action buttons   
            % action button callback function names
            S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)',...
                            '@(src,evt)setXYorder(src,evt)',...
                            '@(src,evt)setPolar(src,evt)'};
            % tool tips for buttons             
            S.ActButTip = {'Refresh data list',...
                           'Swap from X-Y to Y-X axes',...
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
            S.HeadPos = [0.86,0.1];    %header vertical position and height
            txt1 = 'For a contour or surface plot, select a variable with at least 2 dimensions';
            txt2 = 'If the variable has more than 2 dimensions you will be prompted to select a sub-set';
            txt3 = 'Select dimensions to use for the X-Y axes';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            
            %Specification of uicontrol for each selection variable  
            %Use default lists except for:
            S.Type = {'surf','contour','contourf','contour3','mesh','User'}; 
            
            %Tab control button options - use defaults
           
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
            S.HeadPos = [0.86,0.1];    %header vertical position and height
            txt1 = 'For a scalar or vector volume plot, select a variable with at least 3 dimensions';
            txt2 = 'If the variable has more than 3 dimensions you will be prompted to select a sub-set';
            txt3 = 'Select dimensions to use for the X-Y-Z axes';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            
            %Specification of uicontrol for each selection variable 
            %Use default lists except for:
            S.Type = {'slice','contourslice','isosurface','streamlines','User'};
            
            %Tab control button options - use defaults
            
            %XYZ panel definition (if required)
            S.XYZnset = 4;                         %minimum number of buttons to use
            S.XYZmxvar = [3,1,1,1];                %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.14,0.91,0.4];     %position for XYZ button panel
            S.XYZlabels = {'Var','X','Y','Z'};     %button labels
            
            %Action button specifications - use default
            
            obj.TabContent(itab) = S;              %update object
        end
%%
        function set2DT_tab(obj,src)
            %customise the layout of the 2DT tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.86,0.1];    %header vertical position and height
            txt1 = 'For an animation of a line, surface or volume';
            txt2 = 'Select the Variable, Time and the property to define the X-axis';
            txt3 = 'Ensure that Time and X selections are correctly matched to the dimensions of the variable';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            
            %Specification of uicontrol for each selection variable  
            %Use default lists 
            
            %Tab control button options
            S.TabButText = {'Run','Save','Clear'};  %labels for tab button definition
            S.TabButPos = [0.1,0.03;0.3,0.03;0.5,0.03]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 3;                          %minimum number of buttons to use
            S.XYZmxvar = [2,1,1];                   %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.14,0.91,0.30];     %position for XYZ button panel
            S.XYZlabels = {'Var','Time','X'}; %button labels
            
            %Action button specifications
            S.ActButNames = {'Refresh','Polar'};   %names assigned selection struct
            S.ActButText = {char(174),'+'};        %labels for additional action buttons
            % Negative values in ActButPos indicate that a
            % button is alligned with a selection option numbered in the 
            % order given by S.Titles
            S.ActButPos = [0.86,-1;0.895,0.17];    %positions for action buttons   
            %action button callback function names
            S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)',...
                            '@(src,evt)setPolar(src,evt)'};
            %tool tips for buttons             
            S.ActButTip = {'Refresh data list',...
                            'XY to Polar; X data in degrees'};   
     
            obj.TabContent(itab) = S;               %update object
        end   
%%
        function set3DT_tab(obj,src)
            %customise the layout of the 2DT tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.88,0.1];    %header vertical position and height
            txt1 = 'For an animation of a line, surface or volume, select a variable with at least 2 dimensions';
            txt2 = 'Select the Time and properties to define the X and Y axes';
            txt3 = 'Ensure that Time and XY selections are correctly matched to the dimensions of the variable';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            %Specification of uicontrol for each selection variable  
            %Use default lists except for:
            S.Type = {'surf','contour','contourf','contour3','mesh','User'}; 
            
            %Tab control button options
            S.TabButText = {'Run','Save','Clear'};  %labels for tab button definition
            S.TabButPos = [0.1,0.03;0.3,0.03;0.5,0.03]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 3;                          %minimum number of buttons to use
            S.XYZmxvar = [3,1,1,1];                 %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.14,0.91,0.40];     %position for XYZ button panel
            S.XYZlabels = {'Var','Time','X','Y'}; %button labels
            
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
    
            obj.TabContent(itab) = S;               %update object            
        end
%%
        function set4DT_tab(obj,src)
            %customise the layout of the 2DT tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.89,0.1];    %header vertical position and height
            txt1 = 'For an animation of a volume, select a variable with at least 3 dimensions';
            txt2 = 'Select the Time and properties to define the X Y and Z axes';
            txt3 = 'Ensure that Time and XYZ selections are correctly matched to the dimensions of the variable';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            %Specification of uicontrol for each selection variable  
            %Use default lists except for:
            S.Type = {'slice','contourslice','isosurface','streamlines','User'}; 
            
            %Tab control button options
            S.TabButText = {'Run','Save','Clear'};  %labels for tab button definition
            S.TabButPos = [0.1,0.03;0.3,0.03;0.5,0.03]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 5;                          %minimum number of buttons to use
            S.XYZmxvar = [4,1,1,1,1];               %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.14,0.91,0.48];     %position for XYZ button panel
            S.XYZlabels = {'Var','Time','X','Y','Z'}; %button labels
            
            %Action button specifications - use defaults
    
            obj.TabContent(itab) = S;               %update object            
        end        
    end
end