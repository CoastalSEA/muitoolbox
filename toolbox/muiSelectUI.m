classdef muiSelectUI < muiDataUI
%
%-------class help------------------------------------------------------
% NAME
%   muiSelectUI.m
% PURPOSE
%   Class implements the muiDataUIclass to access data
% SEE ALSO
%   muiDataUI.m
%
% Author: Ian Townend
% CoastalSEA (c) May 2024
%--------------------------------------------------------------------------
% 
    properties (Transient)
        %Abstract variables for muiDataUI----------------------------------       
        % names of tabs providing different data accces options
        TabOptions = {'Select'};   
        % selections that force a call to setVariableLists
        updateSelections = {'Case','Dataset'};
        %Additional variables for application------------------------------
        Tabs2Use         %number of tabs to include  (set in getPlotGui) 
        Selected = false
    end 
%%  
    methods (Access=protected)
        function obj = muiSelectUI(mobj)
            %initialise standard figure and menus
            guititle = 'Select Data';
            setDataUIfigure(obj,mobj,guititle);    %initialise figure     
        end
    end
%%    
    methods (Static)
        function obj = getSelectUI(mobj)
            %this is the function call to initialise the UI and assigning
            %to a handle of the main model UI (mobj.mUI.SelectUI) 
            %options for selection on each tab are defined in setTabContent
            if isempty(mobj.Cases.Catalogue.CaseID)
                warndlg('No data available');
                obj = [];
                return;
            else
                obj = muiSelectUI(mobj);
                obj.Tabs2Use = {'Select'};
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
            setSelectTab(obj,src)            
        end                
%%
        function setVariableLists(obj,src,mobj)
            %Abstract function required by DataGUIinterface
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
        function useSelection(obj,~,~)  
            %make use of the selection made to create a plot of selected type
            %Abstract function required by DataGUIinterface
            obj.Selected = true;
        end           
%%
        function exitDataUI(obj,~,~,~)    %overload muiDataUI method
            %delete GUI figure and pass control to main GUI to reset obj
            delete(obj.dataUI.Figure);
            obj.dataUI.Figure = [];  %clears deleted handle
            obj.Selected = true;
        end  

    end
%%
%--------------------------------------------------------------------------
% Additional methods used to define tab content
%--------------------------------------------------------------------------
    methods (Access=private)
        function setSelectTab(obj,src)
            %customise the layout of the Edit tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.8,0.14]; %vertical position and height of header
            txt1 = 'Select Case, Dateset and Variable.';
            txt2 = 'Use the ''Var'' button to select the attibute of the variable (data or a dimension)';
            txt3 = 'There are options to define the attribute range of the variable (if required).';   
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            
            %Specification of uicontrol for each selection variable  
            S.Titles = {'Case','Datset','Variable'};            
            S.Style = {'popupmenu','popupmenu','popupmenu'};
            S.Order = {'Case','Dataset','Variable'};
            %S.Scaling %options for ScaleVariable - use default
           
            %Tab control button options
            S.TabButText = {'Select','Clear'}; %labels for tab button definition
            S.TabButPos = [0.1,0.03;0.3,0.03]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 1;                     %minimum number of buttons to use
            S.XYZmxvar = 2;                    %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.2,0.91,0.15]; %position for XYZ button panel
            S.XYZlabels = {'Var'};             %default button labels
            
            %Action button specifications - use default

            obj.TabContent(itab) = S;         %update object
        end          
    end
end
