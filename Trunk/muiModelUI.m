classdef (Abstract = true) muiModelUI < handle
%
%-------abstract class help------------------------------------------------
% NAME
%   muiModelUI.m
% PURPOSE
%   Abstract class for creating graphic user interface with pulldown menus 
%   to control application and tabs to display settings and output.
% REQUIRES
%   muiProjects.m, muiConstants.m, dscatalogue.m
% SEE ALSO
%   ModelUI.m for example of usage
%
% Author: Ian Townend
% CoastalSEA (c)Sept 2020
%--------------------------------------------------------------------------
%       
    properties (Hidden, Transient)
        %struct to handles for UI
        mUI = struct('Figure',[],'Menus',[],'Tabs',[],'EditUI',[],'ManipUI',[],...
                     'PlotsUI',[],'Plots',[],'StatsUI',[],'Stats',[])                                                       
            % mUI.Figure        %handle for main UI figure
            % mUI.Menus         %handle for drop down menus in main UI
            % mUI.Tabs          %handle for the Tab Group in the main main UI
            % mUI.PlotsUI       %handle for plotting UI
            % mUI.EditUI        %handle for editing UI
            % mUI.ManipUI       %handle for data manipulation UI
            % mUI.StatsUI       %handle for statistics UI
            % mUI.Plots         %handle to muiPlots object
            % mUI.Stats         %handle to muiStats object
        TabProps         %structure to hold TabDisplay and position for each data input
        ModelInputs      %classes required by model used in isValidModel check 
        DataUItabs       %structure to define muiDataUI tabs for each use 
        SupressPrompts = false %flag for unit testing to supress user promts       
    end
    
    properties 
        Inputs                          %handle to data input classes
        Cases                           %handle to DataSets and Catalogue
        Info                            %project information
        Constants = muiConstants.Evoke  %constants used by applications       
    end

    properties (Abstract, Access = protected)   
        %properties that all subclasses must include
        vNumber          %version number of model
        vDate            %date of current version
        modelName        %name for model/user interface        
    end

    methods (Abstract, Access = protected)    
        %methods that all subclasses must define
        setMenus(obj)         %application specific menus
        setTabs(obj)          %initialise tabs that are specific to the model
        setTabAction(obj)     %define how tab callbacks are to be handled.
        setTabProperties(obj) %get locations for data input display  
    end    
%%    
    methods (Access = protected)  %methods common to all uses
        function initialiseUI(obj,modelLogo)
            %call functions that intitialise menus and tabs 
            if ~obj.SupressPrompts
                splashFigure(obj,modelLogo); 
            end
            setGuiFigure(obj);   %initialise figure
            setAppMenus(obj);    %initialise menus                         
            setAppTabs(obj);     %initialise tabs
            TabProperties(obj);  %set locations for data input display
            obj.Info = muiProject;    %initialise project information
            obj.Cases = muiCatalogue; %initialise Catalogue
            if ~obj.SupressPrompts
                obj.mUI.Figure.Visible = 'on';
            end
        end        
%%   
%--------------------------------------------------------------------------
% Functions called by intialiseUI
%--------------------------------------------------------------------------
        function splashFigure(obj,modelLogo)
            %display splash figure as part of model initialisation
            if nargin<2 || isempty(modelLogo)
                modelLogo = 'muitoolbox_logo.jpg';
            end
            vtxt = sprintf('%s Version: %s; Copyright: %s',...
                                     obj.modelName,obj.vNumber,obj.vDate);
            figure('Units','normalized','MenuBar','none',...
                'Name',vtxt,'NumberTitle','off',...
                'ToolBar','none',...
                'Position',[0.35 0.55 0.3 0.4],'Resize','off',...
                'Visible','on','Tag','fig0');
            logo = imread(modelLogo);
            a2 = axes('units', 'normalized', 'position', [0 0 1 1], ...
                'color',[0.8 0.8 0.8], 'Tag','a4');
            imagesc(logo)
            axis equal
            axis off
            set(a2,'XTickLabel','','YTickLabel','')
            pause(2);
            fig0  = findobj('Tag', 'fig0');
            delete(fig0);
            clear a2 logo vtxt fig0
        end 
%%
        function setGuiFigure(obj)
            %initialise the figure for the main UI
            if isempty(obj)
                error('No input')
            end
            figTitle = sprintf('%s  Version: %s;  Copyright: %s',...
                                    obj.modelName,obj.vNumber,obj.vDate);
            obj.mUI.Figure = figure('Name',figTitle, ...
                'NumberTitle','off', ...
                'MenuBar','none', ...
                'Units','normalized', ...
                'CloseRequestFcn',@obj.exitprogram, ...
                'Resize','on','HandleVisibility','on', ...
                'Visible','off','Tag','MainFig');
            axes('Parent',obj.mUI.Figure, ...
                'Color',[0.94,0.94,0.94], ...
                'Position',[0 0.002 1 1], ...
                'XColor','none', ...
                'YColor','none', ...
                'ZColor','none', ...
                'Tag','Mui');  
            obj.mUI.Tabs = uitabgroup(obj.mUI.Figure,'Tag','muiTabs');
            obj.mUI.Tabs.Position = [0 0 1 0.96];
        end
        
%% functions to initialise menus -------------------------------------------
        function obj = setAppMenus(obj)
            %initiale user defined menus and submenus
            menustruct = setMenus(obj);
            menulabels = fieldnames(menustruct);
            nmenus = length(menulabels);
            for i = 1:nmenus
                %initialise top level menu
                MenuDef = menustruct.(menulabels{i});
                obj.mUI.Menus.(menulabels{i}) = setUIMenus(obj,MenuDef(1));
                %check for submenus and initialise if defined
                addSubMenus(obj,obj.mUI.Menus.(menulabels{i}),MenuDef,1);
            end
        end
        %%       
        function count = addSubMenus(obj,TopMenu,MenuDef,count)
            %recursively initialise submenu        
            submenu = find(strcmp(MenuDef(count).Callback,'gcbo;'));
            if ~isempty(submenu)
                idm = count;
                for i=1:length(submenu)            
                    count=count+1;
                    MenuDef(count).Label = MenuDef(idm).List(submenu(i));            
                    initSubMenu(obj,TopMenu,MenuDef(count)); 
                    %now call the function recursively to set sub-submenus, etc
                    count = addSubMenus(obj,TopMenu,MenuDef,count);
                end
            end    
        end 
        %%   
        function initSubMenu(obj,TopMenu,subMenuDef)
            %define the submenu parent and call setSubMenu to initialise the submenu
            subParent = findobj(TopMenu,'Label',subMenuDef.Label{1});
            if isempty(subParent)
                warndlg(sprintf('Submenu for %s has not been defined',subMenuDef.Label{1}));
                return;
            end
            setSubMenu(obj,subParent,subMenuDef);
        end
        %%
        function hMenu = setUIMenus(obj,MenuDef)
            %create a main menu item in the UI figure  
            Parent = obj.mUI.Figure;
            hMenu = uimenu('Parent',Parent,'Text',char(MenuDef.Label));
            if isempty(MenuDef.List)
                %if no menu list defined simply add the label
                MenuDef.List = {MenuDef.Label};
            end
            setSubMenu(obj,hMenu,MenuDef);
        end
        %%
        function setSubMenu(~,parent,MenuDef)
            %create a sub-menu item in the UI figure
            for i = 1:length(MenuDef.List)
                hm = uimenu('Parent',parent,'Text',MenuDef.List{i},...                    
                                    'MenuSelectedFcn',MenuDef.Callback{i});
                if ~isempty(MenuDef.Separator)
                    hm.Separator = MenuDef.Separator{i};
                end
            end
        end
%%
        function addAppMenus(obj,menuitems)
            %add a menu items to an existing menu 
            %option to reorder the full top level menus
            menulabels = fieldnames(menuitems);
            nmenus = length(menulabels);
            for i=1:nmenus
                MenuDef = menuitems.(menulabels{i});
                obj.mUI.Menus.(menulabels{i}) = setUIMenus(obj,MenuDef);
                addSubMenus(obj,obj.mUI.Menus.(menulabels{i}),MenuDef,1);
            end
        end
%%
        function modifySubMenus(obj,menuitem,MenuDef)
            %modify sub-menu items that have already been defined
            hMenu = obj.mUI.Menus.(menuitem);            %top level menu object
            delete(hMenu.Children)                       %delete all submenus
            setSubMenu(obj,hMenu,MenuDef.(menuitem)(1)); %create top level submenu
            addSubMenus(obj,hMenu,MenuDef.(menuitem),1); %add additional submenus
        end
%%
        function muimenu = findSubMenu(obj,menuitem,varargin)
            %find a submenu belonging to menuitem, ie: menuitem>submenu1>submenu2
            % varargin - Text labels for sub menu string, eg {'submenu1','submenu2'}
            hMenu = obj.mUI.Menus.(menuitem);
            for i=1:length(varargin)
                muimenu = findobj(hMenu,'Text',varargin{i});
            end
        end
%%
        function mt = menuStruct(~,menulabels)
            %set up empty struct for menu definition
            MenuParts = {'Label','List','Callback','Separator','SubMenu'};
            datacell = cell(5,1);
            subcell = cell(3,1);
            for i=1:length(menulabels)
                menuoption = matlab.lang.makeValidName(menulabels{i});
                mt.(menuoption) = cell2struct(datacell,MenuParts,1);
                mt.(menuoption).SubMenu = cell2struct(subcell,MenuParts(2:4),1);
                mt.(menuoption).Label = menulabels{i};
            end
        end
%% functions to initialise tabs -------------------------------------------
        function setAppTabs(obj,tabs,subtabs)
            %initialise the user defined tabs and subtabs
            if nargin<2
                [tabs,subtabs] = setTabs(obj);
            end
            
            tabtags = fieldnames(tabs);
            if isempty(subtabs)
                subtags = [];
            else
                subtags = fieldnames(subtabs);
            end
            %
            for i=1:length(tabtags)
                vals = tabs.(tabtags{i});
                uitab(obj.mUI.Tabs,'Title',vals{1}','Tag',tabtags{i},...
                                                'ButtonDownFcn',vals{2});
                if ~isempty(subtags) && any(strcmp(subtags,tabtags{i}))
                    obj = setSubTab(obj,tabtags{i},subtabs);
                end
            end
        end
        %%
        function obj = setSubTab(obj,tabtag,subtabs)
            %initialise a tabgroup for subtabs and add tabs to tabgroup
            tabhandle = findobj(obj.mUI.Tabs,'Tag',tabtag);
            subtabgrp = uitabgroup(tabhandle,'Tag',['sub',tabtag]);
            for j=1:size(subtabs.(tabtag),1)
                subvals = subtabs.(tabtag)(j,:);
                uitab(subtabgrp,'Title',subvals{1}','Tag',strip(subvals{1}),...
                                               'ButtonDownFcn',subvals{2});
            end
        end   
%%        
        function [muitab,muitabgrp] = findSubTab(obj,parent,subtab)
            %find the subtab that belongs to parent and return the uitab
            %object and the uitabgroup it belongs to
            muitab = findobj(obj.mUI.Tabs,'Tag',parent);
            muitabgrp = findobj(muitab,'Type','uitabgroup');
            if ~isempty(muitabgrp)
                muitab = findobj(muitabgrp,'Tag',subtab);
            else
                muitab = [];
            end
        end
%%
        function obj = TabProperties(obj)
            %set the tab and position to display class data tables
            %props format: {class name, tab tag name, position, ...
            %               column width, table title}
            props = setTabProperties(obj);
            for i=1:size(props,1)
                obj.TabProps.(props{i,1}).Tab = props{i,2};
                obj.TabProps.(props{i,1}).Position = props{i,3};
                obj.TabProps.(props{i,1}).ColWidth = props{i,4};
                obj.TabProps.(props{i,1}).TableTitle  = props{i,5};
            end
        end    
%%
%--------------------------------------------------------------------------
% FILE menu functions
%--------------------------------------------------------------------------
        function fileMenuOptions(obj,src,~)
            %callback function for File menu options
            switch src.Text
                case 'New'
                    obj.newproject;
                case 'Open'
                    obj.openfile;
                case 'Save'
                    obj.savefile;
                case 'Save as'
                    obj.saveasfile;
                case 'Exit'  
                    obj.exitprogram;
            end                     
        end
%%
        function newproject(obj,~,~)
            %clear any existing model and initialise a new project
            obj.clearModel;
            Prompt = {'Project Name','Date'};
            Title = 'Project';
            NumLines = 1;
            DefaultValues = {'',char(datetime,"dd-MMM-yyyy")};
            %use updated properties to call inpudlg and return new values            
            answer=inputdlg(Prompt,Title,NumLines,DefaultValues);
            if length(answer)>1
                obj.Info.ProjectName = answer{1};
                obj.Info.ProjectDate = answer{2};
                obj.DrawMap;
            end
        end
%%       
        function obj = openfile(obj,~,~)
            %check to see if there is a file open and whether this needs to be saved
            spath = obj.Info.PathName;
            sfile = obj.Info.FileName;
            
            %if input data defined or data/model classes exist, check need
            %to save existing project setup
            isdata = ~isempty(obj.Inputs) || ~isempty(obj.Cases.DataSets); 
            if exist([spath,sfile],'file')==2 && any(isdata)                                    
                ansQ = questdlg('Do you want to save the current model file?', ...
                    'Save file','Save','Save as','No','No');
                if strcmp('Save', ansQ)==1
                    @obj.savefile;
                elseif strcmp('Save as', ansQ)==1
                    @obj.saveasfile;
                end
            end

            %clear existing model and file name
            obj.clearModel;
            %
            [sfile,spath] = uigetfile({'*.mat','MAT-files (*.mat)'},...
                                       'Open work file');
            if isequal(sfile,0)
               return         %user selected cancel
            else
               obj.Info.PathName=spath;
               obj.Info.FileName=sfile; 
            end
            [~, ~, ext] = fileparts(sfile);
            if strcmp(ext,'.mat')
                loadModel(obj);
            end

            %force the initialisation of datasets.
            ht = findobj(obj.mUI.Tabs.Children,'-depth',0,...
                                    '-not','ButtonDownFcn','');
            for i=1:length(ht)
                hs = func2str(ht(i).ButtonDownFcn);
                if contains(hs,'refresh')
                    DrawMap(obj,ht(i));
                end
            end
        end
%%        
        function obj = savefile(obj,~,~)
            %save the current project to a mat file
            pname = obj.Info.PathName;
            fname = obj.Info.FileName;
            if exist([pname,fname],'file')==2
                [~, ~, ext] = fileparts(fname);
                if strcmp(ext,'.mat')
                    saveModel(obj);
                else
                    warndlg('Unknown file type')
                end
            else
                obj = saveasfile(obj,0,0);
            end
        end
%%        
        function obj = saveasfile(obj,~,~)
            %prompt user to Save As in selected folder
            pname = obj.Info.PathName;
            ispath = false;
            if ~isempty(pname)   %check if already using a path
                try
                    cpath = cd(pname);
                    ispath = true;
                catch
                    getdialog('Path not found')
                end
            end
                
            [sfile,spath] = uiputfile({'*.mat','MAT-files (*.mat)'}, ...
                           'Save Asmita work file');
            if isequal(sfile,0)|| isequal(spath,0)
                return     %user selected cancel
            else
                obj.Info.PathName = spath;
                obj.Info.FileName = sfile;
            end

            [~, ~, ext] = fileparts(sfile);
            if strcmp(ext,'.mat')
                saveModel(obj);
            else
                warndlg('Unknown file type')
            end
            
            if ispath, cd(cpath); end   %return to working folder
        end
%%
        function exitprogram(obj,~,~)
            %delete all existing figures and delete UI
            choice = questdlg('Do you want to save model before exiting?', ...
                'Exit','Yes','No','Cancel','No');
            if strcmp(choice,'Yes')
                savefile(obj,0,0);
            elseif strcmp(choice,'Cancel')
                return;
            end
            %remove any linked UIs
            linkedguis = fieldnames(obj.mUI);
            for i=4:length(linkedguis) %first 3 entries are for main Figure
                if ~isempty(obj.mUI.(linkedguis{i})) && ...
                                        isvalid(obj.mUI.(linkedguis{i}))
                    clearDataUI(obj,obj.mUI.(linkedguis{i}))
                end
            end   
            delete(obj.mUI.Figure);
            delete(obj);    %delete the class object
        end 
%% functions called by File menu options ----------------------------------
        function loadModel(obj)
            %load sobj from mat file contents and assign to model handles
            ipath = obj.Info.PathName;
            ifile = obj.Info.FileName;
            load([ipath,ifile],'sobj');
            obj.Info = sobj.Info;
            obj.Info.PathName =  ipath;  %path and file name may change
            obj.Info.FileName = ifile;   %reset to current values
            obj.Constants = sobj.Constants; 
            obj.Inputs = sobj.Inputs;
            obj.Cases = sobj.Cases;
            if ~strcmp(obj.vNumber,sobj.vNumber)
                %preserve vNumber and vDate to version currently running 
                %overwrites saved values, if the loaded model is saved 
                msg1 = sprintf('Project file was created with version:%s',sobj.vNumber);
                msg2 = sprintf('If saved, will be saved as %s',obj.mUI.Figure.Name);
                warndlg(sprintf('%s\n%s',msg1,msg2))  
            end
            %activate variables in dstables
            if isa(obj.Cases,'muiCatalogue')
                activateTables(obj.Cases);
            end
            %
            clear sobj
        end    
%%
        function saveModel(obj)
            %save model setup and results to a mat file as sobj
            spath = obj.Info.PathName;
            sfile = obj.Info.FileName;
            sobj = obj; 
            save([spath,sfile],'sobj','-v7.3');
            clear sobj
        end
%%
%--------------------------------------------------------------------------
% TOOLS menu functions
%--------------------------------------------------------------------------                 
        function refresh(obj,src,~)
            obj.DrawMap(src);
        end
%%   
        function toolsMenuOptions(obj,src,~)
            %callback function for Tools menu options
            switch src.Text
                case {'Project','Model'}
                    obj.clearModel;
                case 'Figures'
                    obj.clearFigures;
                case {'Cases','Data','Models'}
                    clearCases(obj,src.Text);
            end
        end
%%
        function clearModel(obj,~,~)     %%why is this in ModelUI?*****
            %delete the current model object, obj, and reinitialise
            %called when closing and when opening or creating a new project             
            obj.Info = muiProject;
            obj.Constants = muiConstants.Evoke;
            obj.Cases = muiCatalogue; 
            obj.Inputs = [];
            htabs = findobj(obj.mUI.Tabs,'Type','uitab');
            for i=1:length(htabs)
                htabgrp = findobj(htabs(i),'Type','uitabgroup');
                if isempty(htabgrp)
                    delete(htabs(i).Children)
                end
            end
            obj.DrawMap;              
        end
%%        
        function clearFigures(~,~,~)
            hpf = findobj('tag','PlotFig');
            hsf = findobj('tag','StatFig');
            if ~isempty(hpf) && ~isempty(hsf)
                quest = 'Delete plot figures, stats figures or both?';                
                answer = questdlg(quest,'Clear','Plots','Stats','Both','Both');
            elseif ~isempty(hpf)
                answer = 'Plots';
            elseif ~isempty(hsf)
                answer = 'Stats';
            else
                return;
            end
            %
            switch answer
                case 'Plots'
                    delete(hpf);
                    clear hpf
                case 'Stats'
                    delete(hsf);
                    clear hsf
                case 'Both'
                    delete(hpf);
                    delete (hsf);
                    clear hpf hsf
            end     
        end      
%%        
        function clearCases(obj,type)
            %delete selected cases from Case list and delete case 
            muicat = obj.Cases;
            if strcmp(type,'Cases')
                deleteCases(muicat);
            else
                caserec = find(tabSubset(obj,type));
                deleteCases(muicat,caserec);
            end
            ht = findobj(obj.mUI.Tabs.Children,'Tag',type);
            DrawMap(obj,ht);
        end
%%
%-------------------------------------------------------------------------
% Project menu functions
%--------------------------------------------------------------------------                    
        function editProjectInfo(obj,~,~)
            %call function to edit Project details (name, date, etc)
            editProject(obj.Info)
            obj.DrawMap;
        end
%%
        function projectMenuOptions(obj,src,~)
            %call functions to edit, save, delete or reload a scenario
            muicat = obj.Cases;   %handle to muiCatalogue
            switch src.Text
                case 'Edit Description'            
                    editCase(muicat);
                    obj.DrawMap; 
                case 'Edit Data Set'
                    obj.mUI.EditUI = muiEditUI.getEditUI(obj);    
                case 'Save Data Set'
                    saveCase(muicat);
                case 'Delete Case'
                    deleteCases(muicat);
                    obj.DrawMap;
                case 'Reload Case'
                    reloadCase(muicat,obj);      
                case 'View Case Settings'
                    viewCaseSettings(muicat);
                case 'Export Case'
                    exportCase(muicat);
                case 'Import Case'
                    importCase(muicat); 
            end   
        end           
%%
%-------------------------------------------------------------------------
% HELP menu function
%--------------------------------------------------------------------------
        function Help(~,~,~)
            doc muitoolbox
        end
%%
%--------------------------------------------------------------------------
% Functions for Case list, Property tables and Case list callback 
%--------------------------------------------------------------------------        
        function MapTable(obj,ht)
            % load case descriptions and display on tab
            % called by DrawMap
            idx = tabSubset(obj,ht.Tag);
            
            caseid = obj.Cases.Catalogue.CaseID(idx);
            casedesc = obj.Cases.Catalogue.CaseDescription(idx);
            cdata = {'0','Description of individual Data (input data or model output)'};
            for i=1:length(caseid)
                case_id = num2str(caseid(i));
                cdata(i,:) = {case_id,char(casedesc{i})};
            end
            % draw table of case descriptions
            tc=uitable('Parent',ht,'Units','normalized',...
                'CellSelectionCallback',@obj.caseCallback,...
                'Tag','cstab');
            tc.ColumnName = {'Case ID','Case Description'};
            tc.RowName = {};
            tc.Data = cdata;
            %width = tc.Extent(3);
            tc.ColumnWidth = {50 469};
            tc.RowStriping = 'on';
            tc.Position(3:4)=[0.935 0.8];    %may need to use tc.Extent?
            tc.Position(2)=0.9-tc.Position(4);
        end
%%
        function subset = tabSubset(obj,srctxt)  
            %get the cases of a given CaseType and return as logical array
            %in CoastalTools seperate data from everything else
            % srctxt - Tag for selected tab (eg src.Tag)
            % Called by MapTable. Separate function so that it can be 
            % overloaded for specific model implementation
            casetype = obj.Cases.Catalogue.CaseType;
            switch srctxt
                case 'Cases'
                    subset = true(length(casetype),1);
                case 'Data'
                    subset = contains(casetype,'data');
                case 'Models'
                    subset = ~contains(casetype,'data');    
                otherwise
                    subset = [];
            end
        end
%%
        function getTabData(obj,src,~)
            %get data required for a tab action (eg plot or tabulation)
            %user selected data are held in the structure 'inp' including:
            %caseid, handle, idh, dprop, id_rec, casedesc.
            refresh;
            muicat = obj.Cases.Catalogue;
            if isempty(muicat) && isempty(obj.Inputs) %no runs & no data
                return;
            elseif isempty(muicat)
                %there are no model results saved
                return;
            end

            if height(muicat)>1
                [caserec,ok] = selectRecord(obj.Cases,'PromptText','Select case',...
                                           'ListSize',[200,240]);
                if ok<1, return; end
            else
                caserec = 1;
            end
            
            cobj = getCase(obj.Cases,caserec);
            setTabAction(obj,src,cobj);
        end
%%        
        function InputTabSummary(obj,src,~)
            %display table(s) of Property values on tab defined by src
            %calls displayProperties for all classes with TabDisplay.Tab 
            %set to the same value as src.Tag            
            ht1 = findobj(src,'Type','uitable');
            delete(ht1);
            ht2 = findobj(src,'Tag','TableTitle');
            delete(ht2);
            if isempty(obj.Inputs), return; end
            h_mdl = fieldnames(obj.Inputs);
            for k=1:length(h_mdl)
                sobj = obj.Inputs.(h_mdl{k});
                if ~isempty(sobj) && isprop(sobj(1),'TabDisplay')...
                                  && strcmp(sobj(1).TabDisplay.Tab,src.Tag)
                    %obj inherits PropertyInterface
                    displayProperties(sobj,src);
                end
            end
        end
%%
%--------------------------------------------------------------------------
% Additional Functions
%--------------------------------------------------------------------------    
        function caseCallback(obj,src,evt)
            %called from tabs listing cases by clicking on a tab row
            if evt.Indices(2)~=1, return; end %only selection of column 1 used to access metadata
            selrow = evt.Indices(1);
            idx = find(tabSubset(obj,src.Parent.Tag)); 
            if isempty(idx), return; end
            caserec = idx(selrow);
            %get class DataSet for selected record
            muicat = obj.Cases;
            casedesc = muicat.Catalogue.CaseDescription{caserec}; 
            cobj = getCase(muicat,caserec);
            
            dstables = cobj.Data;   %extract data tables (can be more than one)
            dstnames = fieldnames(dstables);
            ntables = length(dstnames);
            
            %generate tables to be displayed
            tables = cell(ntables,1);
            tabtxts = cell(ntables,1);
            for i=1:ntables
                dst = dstables.(dstnames{i});
                lastmod = char(dst.LastModified);
                meta = dst.MetaData;
                name = dst.VariableNames';
                desc = dst.VariableDescriptions';
                unit = dst.VariableUnits';            
                tables{i,1} = table(name,desc,unit);
                %output summary to tablefigure
                tabtxts{i,1} = sprintf('Metadata for %s dated: %s\n%s',...
                                                casedesc,lastmod,meta);
                clear dst 
            end
              
            h_fig = tabtablefigure('Case Metadata',dstnames,tabtxts,tables);
            
            %add button to access DSproperties of each table displayed
            h_tab = findobj(h_fig.Children,'Tag','GuiTabs');
            h_but = findobj(h_fig.Children,'Tag','uicopy');
            position = h_but.Position;
            position(1) = 10;            
            sourcepos = [h_fig.Position(3)-70, h_fig.Position(4)-22, 60, 18];
            sourcetxt = cell(ntables,1);
            for j=1:ntables
                itab = h_tab.Children(j); 
                dst = dstables.(dstnames{j});
                setactionbutton(itab,'DSproperties',position,...
                    @(src,evt)getDSProps(obj,src,evt),...
                   'getDSP','View the dstables DSproperties',dst);
                if iscell(dst.Source)
                    sourcetxt = dst.Source;
                else
                    sourcetxt{j} = sprintf('%s: %s',dstnames{j},dst.Source);
                end
                clear dst
            end
            setactionbutton(h_fig,'Source',sourcepos,...
                   @(src,evt)getSource(obj,src,evt),'getSource',...
                   'View data source details',sourcetxt);
            %adjust position on screen            
            h_fig.Position(1)=  h_fig.Position(3)*3/2; 
            % screendata = get(0,'ScreenSize');
            % h_fig.Position(2)=  screendata(4)-h_fig.Position(2)-h_fig.Position(4); 
            h_fig.Visible = 'on';
        end
%%
        function getDSProps(~,src,~)
            if istable(src.UserData.DataTable)
                displayDSproperties(src.UserData.DSproperties);
            end
        end
%%
        function getSource(~,src,~)
            if~isempty(src.UserData)
                if iscell(src.UserData) && length(src.UserData)>1
                    %cell with multiple cells (eg several filenames)
                    stable = cell2table(src.UserData,'VariableNames',{'Sources'});
                    headtext = 'The following sources were used for the selected data set';
                    tablefigure('Sources',headtext,stable);
                elseif iscell(src.UserData)
                    %single cell containting character vector or string
                    msgbox(sprintf('Source: %s',src.UserData{1}));
                else
                    %character vector or string
                    msgbox(sprintf('Source: %s',src.UserData));
                end
            end
        end
%%
        function deleteFigObj(obj,figObj,objtype)
            %delete any figures created by a Data UI
            % called by clearDataUI
            if ~isempty(figObj)
                %check whether user wants to delete plots
                %generated by this GUI
                answer = questdlg('Delete existing plots?',...
                                     objtype,'Yes','No','No');
                if strcmp(answer,'Yes')
                    %delete each plot and then clear GUI handle
                    for i=1:length(figObj)
                        hf = figObj(i);
                        delete(hf);
                    end
                    clear hf
                    delete(obj.mUI.(objtype))
                    obj.mUI.(objtype) = [];
                end
            else
                delete(obj.mUI.(objtype))
                obj.mUI.(objtype) = [];
            end
        end
    end  
%--------------------------------------------------------------------------
% Unprotected functions that can be called from any class
%--------------------------------------------------------------------------   
    methods 
        function DrawMap(obj,src)
            if nargin<2 || ~isgraphics(src,'uitab')
                src = [];
                src.Tag = obj.mUI.Tabs.Children(1).Tag; %defaults to first tab
            end
            hf = obj.mUI.Figure;
            ht = findobj(hf,'Tag',src.Tag);
            axtxt = sprintf('ax%s',src.Tag);
            ha = findobj(hf,'Tag',axtxt);
            htable = findobj(ht,'Type','uitable');
            delete(htable);
            if isempty(ha)
                ha = axes('Parent',ht,'Tag',axtxt,...
                    'Color',[0.9,0.9,0.9], ...
                    'Position', [0 0 1 1], ...
                    'XColor','none', 'YColor','none','ZColor','none', ...
                    'NextPlot','replacechildren');
                ha.XLim = [0 1];
                ha.YLim = [0 1];
                ha.Color = [0.96,0.96,0.96];
            end
            
            % draw project title and date
            pName = obj.Info.ProjectName;
            pDate = obj.Info.ProjectDate;
            if ~isempty(pName)
                ProjectName = ['Project Name: ' pName];
                ProjectDate = ['Date Created: ' pDate];
            else
                ProjectName = 'Project Name:              ';
                ProjectDate = 'Date Created:             ';
            end
            
            hproj = findobj(hf,'Tag','projtxt');
            if isempty(hproj)
                uicontrol('Parent', hf, 'Style', 'text',...
                    'String', ProjectName,...
                    'HorizontalAlignment', 'left',...
                    'Units','normalized', ...
                    'Position',[0.07 0.955 0.5 0.04],...
                    'Tag','projtxt');
                uicontrol('Parent', hf, 'Style', 'text',...
                    'String', ProjectDate,...
                    'HorizontalAlignment', 'left',...
                    'Units','normalized', ...
                    'Position',[0.6 0.955 0.3 0.04],...
                    'Tag','projtxt');
            else
                hproj(2).String = ProjectName;
                hproj(1).String = ProjectDate;
            end
            MapTable(obj,ht);
        end        
%%
        function isvalidmodel = isValidModel(obj,modelname)
            %check whether the minimum set of classes needed to run model
            %have valid data. This function uses getCharProperties in
            %PropertyInterface and so the classes checked need to
            %inherit this interface for this function to work.
            
            % first check that Input & DataSet classes exist  
            if isempty(obj.Inputs) && isempty(obj.Cases.DataSets)
                isvalidmodel = false;
                return; 
            end
            
            inphandles = obj.ModelInputs.(modelname);  
            isvalidmodel = false(length(inphandles),1);

            if ~isempty(obj.Inputs)
                definedinput = fieldnames(obj.Inputs);
                isinp = find(ismember(inphandles,definedinput));
                for i=1:length(isinp)
                    localObj = obj.Inputs.(inphandles{isinp(i)}); 
                    %input data is loaded using PropertyInterface
                    isvalidmodel(isinp(i)) = isValidInstance(localObj);
                end               
            end
            
            if ~isempty(obj.Cases.DataSets)
                definedsets = fieldnames(obj.Cases.DataSets);
                isdata = find(ismember(inphandles,definedsets));
                for i=1:length(isdata)
                    localObj = obj.Cases.DataSets.(inphandles{isdata(i)});
                    isvalidmodel(isdata(i)) = isa(localObj,inphandles{isdata(i)});
                end
            end
            isvalidmodel = all(isvalidmodel);  
        end 
%%  
        function clearDataUI(obj,guiobj)
            %function to tidy up plotting and data access GUIs
            %first input variable is the ModelUI handle (unused)
            name = class(guiobj);
            %handle subclasses that inherit standard GUI - code below
            %assumes 3 charachter suffix
            idx = regexp(name,'_');
            if ~isempty(idx)
                name = ['mui',name(idx+1:end)];
            end
            %
            switch name
                %define case for each plot/data GUI
                case 'muiPlotsUI'
                    figObj = [];
                    if ~isempty(obj.mUI.Plots) && isvalid(obj.mUI.Plots) && ...
                            isfield(obj.mUI.Plots.Plot,'FigNum') && ...
                                ~isempty(obj.mUI.Plots.Plot.FigNum)
                        localObj = obj.mUI.Plots.Plot.FigNum;
                        nfig = length(localObj);
                        figObj = gobjects(1,nfig);
                        count = 1;
                        for i=1:nfig
                            hfig = findobj('tag','PlotFig',...
                                                'Number',localObj(i));
                            if ~isempty(hfig)
                                figObj(count) = hfig;
                                count = count+1;
                            end               
                        end
                    end
                    deleteFigObj(obj,figObj,'Plots');
                case 'muiStatsUI'
                    figObj = findobj('Tag','StatFig','-or','Tag','StatTable');                   
                    deleteFigObj(obj,figObj,'Stats');
            end
            guiobjtxt = name(4:end);
            if ~isempty(obj.mUI.(guiobjtxt)) && ...
                            isvalid(obj.mUI.(guiobjtxt)) && ...
                                    isprop(obj.mUI.(guiobjtxt),'dataUI')               
                delete(obj.mUI.(guiobjtxt).dataUI.Figure);
            else

            end
            delete(obj.mUI.(guiobjtxt))
            obj.mUI.(guiobjtxt) = [];
        end
%%
        function callStaticFunction(obj,classname,fncname)
            %call a class function to load data or run a model
            muicat = obj.Cases;
            
            heq = str2func(['@(mcat,cname) ',[fncname,'(mcat,cname)']]); 
            try
               heq(muicat,classname); 
            catch ME
                msg = sprintf('Unable to run function %s\nID: ',fncname);
                disp([msg, ME.identifier])
                rethrow(ME)                     
            end
        end        
%%
        function cobj = getClassObj(obj,classtype,classname,msgtxt)
            %check if class exists and return class handle  
            % classtype - Cases, Inputs or mUI field
            % classname - name of class being called
            % msgtxt - message to display if class does not exist (optional)
            %NB returns the class object array. Use selectCase to get the
            %caserec id and selectCase obj to get the class instance for
            %the Case and the classrec id (both in muiCatalogue).
            switch classtype
                %classtype is hard coded so that can change in muiModelUI 
                %independently of naming in classess that are being saved
                case 'Inputs'
                    lobj = obj.Inputs;
                case 'Cases'
                    lobj = obj.Cases.DataSets; %map Cases to DataSets property
                case 'mUI'
                    lobj = obj.mUI;
                    if strcmp(classtype,'mUI') && ~isempty(lobj.(classname))
                        %mUI does not use Class names for field names
                        cobj = lobj.(classname);
                        return;
                    end 
                otherwise
                    cobj = [];
                    return;
            end
            %
            if isfield(lobj,classname) && ...
                            isa(lobj.(classname),classname)                
                cobj = lobj.(classname);  
            else
                if nargin>3
                    warndlg(msgtxt);
                end
                cobj = []; 
            end
        end
%%
        function setClassObj(obj,classtype,classname,cobj,msgtxt)
            %assign instance to muiModelUI property that hold class instances
            % classtype - Cases, Inputs or mUI field
            % classname - name of class being called (or fieldname for mUI)
            % msgtxt - message to display if class does not exist (optional)
            switch classtype
                %classtype is hard coded so that can change in muiModelUI 
                %independently of naming in classess that are being saved
                case 'Inputs'
                    obj.Inputs.(classname) = cobj;
                case 'Cases'
                    %use muiCatalogu.setCase to add new records. This call
                    %updates an existing record, which may contain
                    %multiple class instances ie cobj can be an array
                    obj.Cases.DataSets.(classname) = cobj;
                case 'mUI'
                    obj.mUI.(classname) = cobj;
                otherwise
                    if nargin>4
                        warndlg(msgtxt);
                    end
            end
        end
%%
        function closeMainFig(obj)
            %accessible function fo delete main UI and any linked UIs
            %used when modelUIs are run in silent mode (obj.SuppressPrompts=true)
            classname = metaclass(obj).Name;
            %remove any linked UIs
            linkedguis = fieldnames(obj.mUI);            
            for i=4:length(linkedguis) %first 3 entries are for main Figure
                if ~isempty(obj.mUI.(linkedguis{i})) && ...
                                        isvalid(obj.mUI.(linkedguis{i}))
                    clearDataUI(obj,obj.mUI.(linkedguis{i}))
                end
            end   
            delete(obj.mUI.Figure);
            delete(obj);    %delete the class object
            getdialog(sprintf('%s successfuully closed',classname));
        end
    end    
end