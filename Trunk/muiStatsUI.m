classdef muiStatsUI < muiDataUI
%
%-------class help------------------------------------------------------
% NAME
%   muiStatsUI.m
% PURPOSE
%   Class implements the muiDataUI class to access data for statistical
%   analysis
% SEE ALSO
%   muiDataUI.m
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
% 
    properties (Transient)
        %Abstract variables for muiDataUI----------------------------------        
        % names of tabs providing different data accces options
        TabOptions = {'General','Timeseries','Taylor','Intervals'};       
        % selections that force a call to setVariableLists
        updateSelections = {'Case','Dataset'};
        %Additional variables for application------------------------------
        Tabs2Use         %number of tabs to include  (set in getPlotGui)
    end  
%%  
    methods (Access=protected)
        function obj = muiStatsUI(mobj)
            %initialise standard figure and menus
            guititle = 'Statistical Analysis';
            setDataUIfigure(obj,mobj,guititle);    %initialise figure     
        end
    end
%%    
    methods (Static)
        function obj = getStatsUI(mobj)
            %this is the function call to initialise the UI and assigning
            %to a handle of the main model UI (mobj.mUI.StatsUI) 
            %options for selection on each tab are defined in setTabContent
            if isempty(mobj.Cases.Catalogue.CaseID)
                warndlg('No data available to analyse');
                obj = [];
                return;
            elseif isa(mobj.mUI.StatsUI,'muiStatsUI')
                obj = mobj.mUI.StatsUI;
                if isempty(obj.dataUI.Figure)
                    %initialise figure
                    guititle = 'Statistical Analysis';
                    setDataUIfigure(obj,mobj,guititle);    
                    setDataUItabs(obj,mobj); %add tabs 
                else
                    getdialog('Stats UI is open');
                end
            else
                obj = muiStatsUI(mobj);
                idx = find(~ismember(mobj.DataUItabs.Stats,obj.TabOptions));
                if ~isempty(idx)
                    txt1 = 'Unknown stats type defined in main UI for DataUItabs.Stats';
                    for j=1:length(idx)
                        txt1 = sprintf('%s\n"%s" not defined',txt1,mobj.DataUItabs.Stats{idx(j)});
                    end
                    warndlg(txt1)
                    obj = [];
                    return
                end
                obj.Tabs2Use = mobj.DataUItabs.Stats;
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
                case 'General'
                    setGenTab(obj,src);
                case 'Timeseries'
                    setTimeTab(obj,src);
                case 'Taylor'
                    setTaylorTab(obj,src);
                case 'Intervals'
                    setIntervalsTab(obj,src);
            end             
        end                
%%
        function setVariableLists(obj,src,mobj)
            %initialise the variable lists or values
            %Abstract function required by muiDataUI
            %called during initialisation by muiDataUI.setDataUItabs and 
            %whenever muiDataUI.updateCaseList is called
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            sel_uic = S.Selections;
            caserec = sel_uic{strcmp(S.Order,'Case')}.Value;
            cobj = getCase(mobj.Cases,caserec);
            dsnames = fieldnames(cobj.Data); 
            ids = sel_uic{strcmp(S.Order,'Dataset')}.Value;
            for i=1:length(sel_uic)                
                switch sel_uic{i}.Tag
                    case 'Case'
                        muicat = mobj.Cases.Catalogue;
                        sel_uic{i}.String = muicat.CaseDescription;
                        sel_uic{i}.UserData = sel_uic{i}.Value; %used to track changes
                    case 'Dataset'
                        sel_uic{i}.String = dsnames; 
                        sel_uic{i}.UserData = sel_uic{i}.Value; %used to track changes
                    case 'Variable'     
                        ds = fieldnames(cobj.Data);
                        sel_uic{i}.String = cobj.Data.(ds{ids}).VariableDescriptions;
                        sel_uic{i}.Value = 1;
                    case 'Type'
                        sel_uic{i}.String = S.Type;
                end
            end        
            obj.TabContent(itab).Selections = sel_uic;
        end
%%       
        function setTabActions(obj,src,evt,mobj) 
            %actions needed when activating a tab
            %Overload default function in muiDataUI to add controls
            initialiseUIselection(obj,src);
            initialiseUIsettings(obj,src);
            updateCaseList(obj,src,evt,mobj);
            clearXYZselection(obj,src);
            switch src.Tag
                case 'General'                    
                case 'Timeseries'                    
                case 'Taylor'
                    %reset the radial limit value
                    itab = strcmp(obj.Tabs2Use,src.Tag);
                    S = obj.TabContent(itab);  
                    obj.TabContent(itab).Selections{4}.String  = S.Other{1};
                case 'Intervals'                    
            end
        end         
%%        
        function useSelection(obj,src,mobj)  
            %make use of the selection made to create a plot of selected type
            %Abstract function required by muiDataUI
            muiStats.getStats(obj,src,mobj);
        end   
    end 
%%
%--------------------------------------------------------------------------
% Additional methods used to define tab content
%--------------------------------------------------------------------------
    methods (Access=private)    
        function setGenTab(obj,src)
            %customise the layout of the General Statistics tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.8,0.14]; %vertical position and height of header
            txt1 = 'For Descriptive stats of a vector variable, only X needs to be defined';
            txt2 = 'If variable is a matrix, subsample array when assiging to X button';
            txt3 = 'For Regression and X-correlation: X is independent, Y is dependent variable';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            
            %Specification of uicontrol for each selection variable  
            S.Titles = {'Case','Datset','Variable','Statistic'};            
            S.Style = repmat({'popupmenu'},1,4);
            S.Order = {'Case','Dataset','Variable','Type'};
            S.Type  = {'Descriptive for X','Regression','Cross-correlation','User'};
            
            %Tab control button options
%             S.TabButText = {'Select','Clear'};    %labels for tab button definition
%             S.TabButPos = [0.1,0.03;0.3,0.03];    %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 1;                          %minimum number of buttons to use
            S.XYZmxvar = [1,1];                     %maximum number of dimensions per selection
            S.XYZpanel = [0.05,0.20,0.9,0.2];       %position for XYZ button panel
            S.XYZlabels = {'X','Y'};                %default button labels
            
            %Action button specifications
            setActionButtonSpec(obj);
        
            obj.TabContent(itab) = S;               %update object          
        end 
%%
        function setTimeTab(obj,src)
            %customise the layout of the Timeseries Statistics tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.8,0.14]; %vertical position and height of header
            txt1 = 'Select the variables to be used and assign to Var button.';
            txt2 = 'Define time subsample range when assigning to Var button';
            txt3 = 'Choose Statistic to be used and press Select';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            
            %Specification of uicontrol for each selection variable  
            S.Titles = {'Case','Datset','Variable','Statistic'};            
            S.Style = repmat({'popupmenu'},1,4);
            S.Order = {'Case','Dataset','Variable','Type'};
            S.Type = {'Descriptive','Regression','Peaks','Clusters','Extremes',...
                      'Poisson Stats','Hurst Exponent','User'};
           
            %Tab control button options
%             S.TabButText = {'Select','Clear'};    %labels for tab button definition
%             S.TabButPos = [0.1,0.03;0.3,0.03];    %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 1;                          %minimum number of buttons to use
            S.XYZmxvar = [1,1];                     %maximum number of dimensions per selection
            S.XYZpanel = [0.05,0.20,0.9,0.1];       %position for XYZ button panel
            S.XYZlabels = {'Var'};                  %default button labels
            
            %Action button specifications
            setActionButtonSpec(obj);
        
            obj.TabContent(itab) = S;               %update object;
        end 
%%
        function setTaylorTab(obj,src)
            %customise the layout of the Taylor Diagram Statistics tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.8,0.14]; %vertical position and height of header            
            txt1 = 'Select the Reference variable to compare with and assign to Ref button';
            txt2 = 'Select the Test variable to be tested and assign to Test button';
            txt3 = 'Define the Radial limit to used in the plot (default is 1)';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            
            %Specification of uicontrol for each selection variable  
            S.Titles = {'Case','Datset','Variable','Radial limit'};            
            S.Style = {'popupmenu','popupmenu','popupmenu','edit'};
            S.Order = {'Case','Dataset','Variable','Other'};
            S.Other = {'2'};
            
            %Tab control button options
            S.TabButText = {'New','Add','Delete','Clear'}; %labels for tab button definition
            S.TabButPos = [0.1,0.14;0.3,0.14;0.5,0.14;0.7,0.14]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 1;                          %minimum number of buttons to use
            S.XYZmxvar = [2,2];                     %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.25,0.91,0.2];      %position for XYZ button panel
            S.XYZlabels = {'Ref','Test'};           %default button labels
           
            %Action button specifications
            setActionButtonSpec(obj);
            
            obj.TabContent(itab) = S;               %update object;
        end    
 %%
        function setIntervalsTab(obj,src)
            %customise the layout of the Intervals Statistics tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.8,0.14]; %vertical position and height of header
            txt1 = 'Select the Case/Dataset to define the Reference time intervals (any Variable as only time used)';
            txt2 = 'Select the Case/Dataset and Variable to Sample for statistcs over the Reference time intervals';
            txt3 = 'Run the analysis with the Select button and you will be prompted to specify the statistic to use';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            
            %Specification of uicontrol for each selection variable  
            S.Titles = {'Case','Datset','Variable'};            
            S.Style = repmat({'popupmenu'},1,3);
            S.Order = {'Case','Dataset','Variable'};
            
            %Tab control button options
%             S.TabButText = {'Select','Clear'};    %labels for tab button definition
%             S.TabButPos = [0.1,0.03;0.3,0.03];    %default positions
            
            %XYZ panel definition (if required) 
            S.XYZnset = 2;                          %minimum number of buttons to use
            S.XYZmxvar = [3,3];                     %maximum number of dimensions per selection
            S.XYZpanel = [0.05,0.2,0.9,0.2];        %position for XYZ button panel
            S.XYZlabels = {'Reference','Sample'};   %default button labels
            
            %Action button specifications
            setActionButtonSpec(obj);
            S.ActButPos = [0.86,-1;0.895,0.27];     %positions for action buttons   
       
            obj.TabContent(itab) = S;               %update object;
        end 
%%
        function setActionButtonSpec(~)
            %Default Action button specification for Stats UIs
            S.ActButNames = {'Refresh','IncNaN'}; %names assigned selection struct
            S.ActButText = {char(174),'+N'};      %labels for additional action buttons
            % Negative values in ActButPos indicate that a
            % button is alligned with a selection option numbered in the 
            % order given by S.Titles
            S.ActButPos = [0.86,-1;0.86,-4];   %positions for action buttons   
            % action button callback function names
            S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)',...
                            '@(src,evt)setIncNaN(src,evt)'};            
            S.ActButTip = {'Refresh data list',...%tool tips for buttons
                           'Include NaNs in output'};            
        end
    end

end