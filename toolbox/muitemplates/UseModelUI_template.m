classdef UseModelUI_template < ModelUI                       % << Edit to classname
%
%-------class help---------------------------------------------------------
% NAME
%   UseModelUI_template.m
% PURPOSE
%   Main GUI for a bespoke implementation of ModelUI.
% SEE ALSO
%   Abstract class muiModelUI.m and tools provided in muitoolbox
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
% 
    properties
        %Properties defined in muiModelUI that need to be defined in setGui
        % ModelInputs  %classes required by model: used in isValidModel check 
        % DataUItabs   %struct to define type of muiDataUI tabs for each use                         
    end
    
    methods (Static)
        function obj = UseModelUI_template                   % << Edit to classname
            %constructor function initialises GUI          
        end
    end
%% ------------------------------------------------------------------------
% Definition of GUI Settings
%--------------------------------------------------------------------------  
    methods (Access = protected)
        function obj = setMUI(obj)
            %initialise standard figure and menus   
            modelLogo = 'mui_logo.jpg'; %default splash figure << edit to alternative
            
            %classes required to run model; format:          % << Edit to model and input parameters classnames                                                
            %obj.ModelInputs.<model classname> = {'Param_class1',Param_class2',etc}
            obj.ModelInputs.Model_template = {'ParamInput_template'};
            
            %tabs to include in DataUIs for plotting and statistical analysis
            %select which of the options are needed and delete the rest
            %Plot options: '2D','3D','4D','2DT','3DT','4DT'
            obj.DataUItabs.Plot = {'2D','3D','4D','2DT','3DT','4DT'};  
            %Statistics options: 'General','Timeseries','Taylor','Intervals'
            obj.DataUItabs.Stats = {'General','Timeseries','Taylor','Intervals'};
            
            %inherit from ModelUI constructor and overload some setup values
            obj.vNumber = '1.0';   
            obj.vDate   = 'Jan 2021';
            obj. modelName = 'UseModelUI_template';          % << Edit to application name
              
            
            initialiseUI(obj,modelLogo); %initialise menus and tabs   
            %if required call setAdditionalMenus and/or setAdditionalTabs
            setAdditionalMenus(obj);                         % << Delete if not needed
            setAdditionalTabs(obj)  
        end    
        
%% ------------------------------------------------------------------------
% Definition of Menu Settings
%--------------------------------------------------------------------------
        %Use default settings
        function setAdditionalMenus(obj)
            %add to or amend default menu settings。To make major
            %adjustments overload the setMenus function in ModelUI
                                                             % << Add any additional functionality required
            %demo code to delete menu item
            % menuname = 'Help';                      
            % delete(obj.mUI.Menus.(menuname));   
            
            %demo code to add menu items to end of existing menu list. 
            % Would need function plotMenuOptions to be added to make operational
            % menu = menuStruct(obj,{'Plot','Documentation'});
            % menu.Plot.List = {'Plot 1','Plot 2'};
            % menu.Plot.Callback = repmat({@obj.plotMenuOptions},[1,2]);
            % menu.Help(1).Callback = {@obj.Help};
            % addAppMenus(obj,menu)    
            
            %demo code to move the plot menu next to Setup
            % hm = findobj(obj.mUI.Figure.Children,'Type','uimenu','-depth',0);
            % hmenu = findobj(hm,'Text','Plot');
            %move 3 places to left - note: graphical objects stack is in reverse order
            % uistack(hmenu,'down',3); 

            %demo code to change a callback and delete sub-submenus
            % menuname = 'Setup';
            % hm = findSubMenu(obj,menuname,'Import Data');
            % hm.MenuSelectedFcn=@obj.setupMenuOptions; %change menu call fcn
            % delete(hm.Children);                      %delete sub-submenu
            
            %replace existing menu with a new defintion
            % menuname = 'Setup';
            % menu = menuStruct(obj,{menuname});
            % menu.Setup(1).List = {'Import Data','Input parameters',...
            %                           'Run parameters','Model Constants'};                                    
            % menu.Setup(1).Callback = [{'gcbo;'},repmat({@obj.setupMenuOptions},[1,3])];
            % 
            %add submenu for Import Data
            % menu.Setup(2).List = {'Load','Add','Delete','Quality Control'};
            % menu.Setup(2).Callback = repmat({@obj.loadMenuOptions},[1,4]);
            % modifySubMenus(obj,menuname,menu);
            
        end        
%% ------------------------------------------------------------------------
% Definition of Tab Settings
%--------------------------------------------------------------------------
        %Use default settings
        function setAdditionalTabs(obj)
            %add to or amend default tab settings. To make major
            %adjustments overload the setTabs function in ModelUI            
                                                            % << Add any additional functionality required
            %demo code to delete tab
            % tabname = 'Stats';   
            % ht = findobj(obj.mUI.Tabs,'Tag',tabname);
            % delete(ht);
            
            %demo code to reorder tabs
            % tabname = 'Stats';   
            % htab = findobj(obj.mUI.Tabs,'Tag',tabname);
            %move 1 place to left - note: tabgroup objects are in order
            % uistack(htab,'up',1); 
            
            %demo code to delete subtab
            % [ht,htgrp] = findSubTab(obj,'Stats','Extremes');
            % delete(ht) %deletes 'Extremes' tab
            % delete(htgrp) deletes all tabs of the Parent tabgroup to Extremes 
            
            %demo code to add tab
            % tabs.Tide = {'   Tide   ','gcbo;'};
            % subtabs.Tide(1,:) = {' Constituents ',@obj.getTabData};
            % subtabs.Tide(2,:) = {' Mean values ',@obj.getTabData};
            % setAppTabs(obj,tabs,subtabs);   
            
            %demo code to add subtab
            % tabtag = 'Inputs';   
            % subtabs.Inputs(1,:) = {' Demo1 ',@obj.getTabData};
            % subtabs.Inputs(2,:) = {' Demo2 ',@obj.getTabData};
            % setSubTab(obj,tabtag,subtabs)
        end        
 %%
        function props = setTabProperties(~)
            %define the tab and position to display class data tables
            %props format: {class name, tab tag name, position, ...
            %               column width, table title}
                                                             % << Edit input properties classnames 
            props = {...                                     % << Add additional inputs and adjust layout
                'ParamInput_template','Inputs',[0.95,0.48],{180,60},'Input parameters:';...
                'ParamInput_template','Inputs',[0.45,0.48],{180,60},'Run parameters:'};
        end      
        
%% ------------------------------------------------------------------------
% Callback functions used by menus and tabs
%-------------------------------------------------------------------------- 
        %Use defaults except:
        %% Setup menu -----------------------------------------------------
        function setupMenuOptions(obj,src,~)
            %callback functions for data input
            switch src.Text
                case 'Input parameters'                      % << Edit to call Parameter Input class
                    ParamInput_template.setInput(obj);                             
                    tabsrc = findobj(obj.mUI.Tabs,'Tag','Inputs');
                    InputTabSummary(obj,tabsrc);
                case 'Run parameters'                        % << Edit to call Parameter Input class
                    ParamInput_template.setInput(obj);                             
                    tabsrc = findobj(obj.mUI.Tabs,'Tag','Inputs');
                    InputTabSummary(obj,tabsrc);
                case 'Model Constants'
                    obj.Constants = setInput(obj.Constants);
            end
        end             
        %% Run menu -------------------------------------------------------
        function runMenuOptions(obj,src,~)
            %callback functions to run model
            switch src.Text                   
                case 'Run Model'                             % << Edit to call Model class
                    Model_template.runModel(obj); 
                case 'Derive Output'
                    obj.mUI.ManipUI = muiManipUI.getManipUI(obj);
            end            
        end  
        %% Help menu ------------------------------------------------------
        function Help(~,src,~)                               % << Edit to documentation name if available
            %menu to access online documentation and manual pdf file
            switch src.Text
                case 'Documentation'
                    doc UseModelUI_template  %must be name of html help file  
                case 'Manual'
                   XXX_open_manual;
            end
        end 
    end
end