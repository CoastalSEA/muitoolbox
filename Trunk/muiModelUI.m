classdef muiModelUI < handle
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
        mUI = struct('Figure',[],'Menus',[],'Tabs',[],'PlotsUI',[],...
                             'EditUI',[],'ManipUI',[],'StatsUI',[],...
                                                'Plots',[],'Stats',[])        
            % mUI.Figure        %handle for main UI figure
            % mUI.Menus         %handle for drop down menus in main UI
            % mUI.Tabs          %handle for the Tabs in the main main UI
            % mUI.PlotsUI       %handle for plotting UI
            % mUI.EditUI        %handle for editing UI
            % mUI.ManipUI       %handle for data manipulation UI
            % mUI.StatsUI       %handle for statistics UI
            % mUI.Plots         %handle to muiPlots object
            % mUI.Stats         %handle to muiStats object
        TabProps         %structure to hold PropertyTab and position for each data input
        ModelInputs      %classes required by model used in isValidModel check 
        DataUItabs       %structure to define muiDataUI tabs for each use 
    end
    
    properties 
        Constants = muiConstants.Evoke  %constants used by applications
        Info                            %project information
        Cases                           %handle to DataSets and Catalogue
        Inputs                          %handle to data input classes
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
        setTabAction(obj)     %define how selected data is to be used
        setTabProperties(obj) %get locations for data input display  
        runMenuOptions(obj)
    end    
%%    
    methods (Access = protected)  %methods common to all uses
        function initialiseUI(obj,modelLogo)
            %call functions that intitialise menus and tabs 
            splashFigure(obj,modelLogo);          
            setGuiFigure(obj);   %initialise figure
            setAppMenus(obj);    %initialise menus                         
            setAppTabs(obj);     %initialise tabs
            TabProperties(obj);  %set locations for data input display
            obj.Info = muiProject;    %initialise project information
            obj.Cases = muiCatalogue; %initialise Catalogue
            obj.mUI.Figure.Visible = 'on';
        end        
%%   
%--------------------------------------------------------------------------
% Functions called by intialiseUI
%--------------------------------------------------------------------------
        function splashFigure(obj,modelLogo)
            %display splash figure as part of model initialisation
            if nargin<2 || isempty(modelLogo)
                modelLogo = 'mui_logo.jpg';
            end
            vtxt = sprintf('%s  Version: %s;  Copyright: %s',...
                                     obj.modelName,obj.vNumber,obj.vDate);
            hf = figure('Units','normalized','MenuBar','none',...
                'Name',vtxt,'NumberTitle','off',...
                'ToolBar','none',...
                'Position',[0.35 0.55 0.3 0.4],'Resize','off',...
                'Visible','off','Tag','fig0');
            logo = imread(modelLogo);
            a2 = axes('units', 'normalized', 'position', [0 0 1 1], ...
                'color',[0.8 0.8 0.8], 'Tag','a4');
            imagesc(logo)
            axis equal
            axis off
            set(a2,'XTickLabel','','YTickLabel','')
            hf.Visible = 'on';
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
                'CloseRequestFcn',@obj.closeMainFig, ...
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
                warndlg(sprintf('Submenu for %s has not been defined',subMenuDef.Label));
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
        function setSubMenu(~,Parent,MenuDef)
            %create a sub-menu item in the UI figure
            for i = 1:length(MenuDef.List)
                hm = uimenu('Parent',Parent,'Text',MenuDef.List{i},...                    
                                    'MenuSelectedFcn',MenuDef.Callback{i});
                if ~isempty(MenuDef.Separator)
                    hm.Separator = MenuDef.Separator{i};
                end
            end
        end
%%
        function addAppMenus(obj,menuitems)
            %add a menu items to an existing menu 
            menulabels = fieldnames(menuitems);
            nmenus = length(menulabels);
            for i=1:nmenus
                MenuDef = menuitems.(menulabels{i});
                obj.mUI.Menus.(menulabels{i}) = setUIMenus(obj,MenuDef);
                addSubMenus(obj,obj.mUI.Menus.(menulabels{i}),MenuDef,1);
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
                uitab(subtabgrp,'Title',subvals{1}','Tag',['sub',tabtag],...
                    'ButtonDownFcn',subvals{2});
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
            hInfo = obj.Info;
            Prompt = {'Project Name','Date'};
            Title = 'Project';
            NumLines = 1;
            DefaultValues = {'',datestr(clock,1)};
            %use updated properties to call inpudlg and return new values            
            answer=inputdlg(Prompt,Title,NumLines,DefaultValues);
            if length(answer)>1
                hInfo.ProjectName = answer{1};
                hInfo.ProjectDate = answer{2};
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
            obj.DrawMap;
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
%             choice = questdlg('Do you want to save model before exiting?', ...
%                 'Exit','Yes','No','Cancel','No');
%             if strcmp(choice,'Yes')
%                 savefile(obj,0,0);
%             elseif strcmp(choice,'Cancel')
%                 return;
%             end
            %remove any linked UIs
            linkedguis = fieldnames(obj.mUI);
            for i=4:length(linkedguis) %first 3 entries are for main Figure
                if ~isempty(obj.mUI.(linkedguis{i}))
                    %original
%                     exitDataGui(obj.mUI.(linkedguis{i}),[],[],obj);
                    %try
                    obj.mUI.(linkedguis{i}) = [];
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
            obj.Constants = sobj.Constants; 
            obj.Inputs = sobj.Inputs;
            obj.Cases = sobj.Cases;
            if obj.vNumber~=sobj.vNumber 
                %preserve vNumber and vDate to version currently running 
                %overwrites saved values, if the loaded model is saved 
                msg1 = sprintf('Project file was created with version:%s',sobj.vNumber);
                msg2 = sprintf('If saved, will be saved as %s',obj.FigTitle);
                warndlg(sprint('%s\n%s',msg1,msg2))  
            end
            %
            clear sobj
        end    
%%
        function closeMainFig(obj,~,~)
            %callback function for CloseResponseFcn button
            delete(obj.mUI.Figure);
            delete(obj);    %delete the class object
        end
%%
        function saveModel(obj)
            %save model setup and results to a mat file as sobj
            spath = obj.Info.PathName;
            sfile = obj.Info.FileName;
            sobj = obj; 
            save([spath,sfile],'sobj');
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
                case 'Model'
                    obj.clearModel;
                case 'Figures'
                    obj.clearFigures;
                case 'Cases'
                    obj.clearCases;
            end
        end
%%
        function clearModel(obj,~,~)     %%why is this in ModelUI?*****
            %delete the current model object, obj, and reinitialise
            %called when closing and when opening or creating a new project             
            obj.Info = muiProject;
            obj.Constants = muiConstants.Evoke;
            obj.Cases = muiCatalogue; %CHECK THAT THIS REMOVES ALL DATA
            obj.Inputs = [];
            obj.DrawMap;  
        end
%%        
        function clearFigures(~,~,~)
            hpf = findobj('tag','PlotFig');
            hsf = findobj('tag','SummaryTable');
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
        function clearCases(obj,~,~)
            %delete selected cases from Case list and delete case            
            type = getCaseType(obj);
            deleteCases(obj.Cases,type,'All');
            obj.DrawMap;
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
                    editRecord(muicat);
                    obj.DrawMap; 
                case 'Edit Data Set'
                    obj.mUI.EditUI = muiEditUI.getEditUI(obj);    
                case 'Save Data Set'
                    saveCase(muicat);
                case 'Delete Case'
                    deleteCases(muicat,getCaseType(obj));
                    obj.DrawMap;
                case 'Reload Case'
                    reloadCase(muicat,obj,getCaseType(obj));      
                case 'View Case Settings'
                    viewCaseSettings(muicat,getCaseType(obj));
                case 'Export Case'
%                     DataSet.exportDataSet(obj);
                case 'Import Case'
%                     DataSet.importDataSet(obj); 
            end   
        end   
%%
        function type = getCaseType(obj)
            %option to select type of data to use in project option
            casetypes = unique(obj.Cases.Catalogue.CaseType);

            if length(casetypes)>1
                %add All option and use button or list to get user to choose
                casetypes = [casetypes,'All'];
                if length(casetypes)<4
                    type = questdlg('Clear which data type?','Clear cases',...
                        casetypes,'All');
                else
                    selection = listdlg('ListString',casetypes);
                    type = casetypes{selection};
                end
            else
                type = 'All';
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
        function tabRunModel(obj)
            %run the model (assumes the default model call is used in UI)
            src.Text = 'Run Model';
            runMenuOptions(obj,src,[]);
        end 
%%  Need to see if this is needed
        function getTabData(obj,src,~)
            %get data required for a tab action (eg plot or tabulation)
            %user selected data are held in the structure 'inp' including:
            %caseid, handle, idh, dprop, id_rec, casedesc.
            refresh;
            muicat = obj.Cases.Catalogue;
            if isempty(muicat) && isempty(obj.Inputs) %no runs & no data
                return;
            elseif isempty(muicat)
                %there are no model results saved so run model
                tabRunModel(obj);
                %check whether model returned a result
                if isempty(muicat)
                    ht = findobj(src,'Type','axes');
                    delete(ht);
                    return;
                end
            end

            if height(muicat)>1
                [caserec,ok] = selectRecord(obj.Cases,'PromptText','Select case to plot',...
                                           'ListSize',[200,140]);
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
            %calls displayProperties for all classes with PropertyTab set
            %to the same value as src.Tag            
            ht1 = findobj(src,'Type','uitable');
            delete(ht1);
            ht2 = findobj(src,'Tag','TableTitle');
            delete(ht2);
            if isempty(obj.Inputs), return; end
            h_mdl = fieldnames(obj.Inputs);
            for k=1:length(h_mdl)
                sobj = obj.Inputs.(h_mdl{k});
                if ~isempty(sobj) && isprop(sobj(1),'TabDisplay')...
                                  && strcmp(sobj.TabDisplay.Tab,src.Tag)
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
            %check that there are some cases
            if isempty(obj.Cases.Catalogue.CaseID), return; end 
            %get selected case            
            selrow = evt.Indices(1);
            idx = find(tabSubset(obj,src.Parent.Tag));       
            caserec = idx(selrow);
            %get class DataSet for selected record
            classname = obj.Cases.Catalogue.CaseClass;
            cds = obj.Cases.DataSets.(classname{caserec})(caserec);
            
            dstables = cds.Data;   %extract data tables (can be more than one)
            ntables = length(dstables);
            tabnames = {'Data'};
            if ntables>1 
                tabnames = cds.MetaData;
            end
            
            %generate tables to be displayed
            tables = cell(ntables,1);
            tabtxts = cell(ntables,1);
            for i=1:ntables
                dst = dstables{i};
                source = dst.Source;
                lastmod = datestr(dst.LastModified);
                meta = dst.MetaData;

                name = dst.VariableNames';
                desc = dst.VariableDescriptions';
                unit = dst.VariableUnits';            
                tables{i,1} = table(name,desc,unit);
                %output summary to tablefigure
                tabtxts{i,1} = sprintf('Metadata for %s dated: %s\n%s',...
                                                     source,lastmod,meta);
            end

            h_fig = tabtablefigure('Case Metadata',tabnames,tabtxts,tables);
            
            %add button to access DSproperties of each table displayed
            h_tab = findobj(h_fig.Children,'Tag','GuiTabs');
            h_but = findobj(h_fig.Children,'Tag','uicopy');
            position = h_but.Position;
            position(1) = 10;
            for j=1:ntables
                itab = h_tab.Children(j);  %NEEDS TO CHECK THIS WORKS WITH MUTLIPLE DATASETS
                setactionbutton(itab,'DSproperties',position,...
                    @(src,evt)getDSProps(obj,src,evt),...
                   'getDSP','View the dstables DSproperties',dstables{i});
            end
            %adjust position on screen            
            h_fig.Position(1)=  h_fig.Position(3)*3/2; 
%             screendata = get(0,'ScreenSize');
%             h_fig.Position(2)=  screendata(4)-h_fig.Position(2)-h_fig.Position(4); 
            h_fig.Visible = 'on';
        end
%%
        function getDSProps(~,src,~)
            if istable(src.UserData.DataTable)
                displayDSproperties(src.UserData.DSproperties);
            end
        end
%%
        function isvalidhandle = isValidHandle(obj,inphandles)
            %check whether classes needed to run model have been instantiated
            % called by IsValidModel
            
            % first ccheck that Input classes exist            
            if isempty(obj.Inputs), isvalidhandle = false; return; end
            
            nhandles = length(inphandles);
            definedinput = fieldnames(obj.Inputs);
            isvalidhandle = false(nhandles,1);
            for i=1:nhandles
                if any(strcmp(definedinput,inphandles{i}))
                    localObj = obj.Inputs.(inphandles{i});
                    if ~isempty(localObj) && isvalid(localObj(end))
                        %checks that handle is not empty and that it is a valid
                        %handle variable (ie is a subclass of handle class)
                        isvalidhandle(i) = true; 
                    end
                else
                    warndlg(sprintf('Input handle %s is not in ModelHandles list',inphandles{i}));
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
                ProjectNam = ['Project Name: ' pName];
                ProjectDat = ['Date Created: ' pDate];
            else
                ProjectNam = 'Project Name:              ';
                ProjectDat = 'Date Created:             ';
            end
            uicontrol('Parent', hf, 'Style', 'text',...
                'String', ProjectNam,...
                'HorizontalAlignment', 'left',...
                'Units','normalized', ...
                'Position',[0.07 0.955 0.5 0.04]);
            uicontrol('Parent', hf, 'Style', 'text',...
                'String', ProjectDat,...
                'HorizontalAlignment', 'left',...
                'Units','normalized', ...
                'Position',[0.6 0.955 0.3 0.04]);
            MapTable(obj,ht);
        end        
%%
        function isvalidmodel = isValidModel(obj,modelname)
            %check whether the minimum set of classes needed to run model
            %have valid data. This function uses getCharProperties in
            %PropertyInterface and so the input handles checked need to
            %inherit this interface for this function to work.
            inphandles = obj.ModelInputs.(modelname);            
            ishandle = isValidHandle(obj,inphandles);    
            if any(~ishandle)  
                %at least one of the input classes isempty
                isvalidmodel = false;
            else
                %all the input handles are valid handles
                nhandles = length(inphandles);
                isvalidmodel = false(nhandles,1);
                for i=1:nhandles
                    localObj = obj.Inputs.(inphandles{i});                         
                    if isprop(localObj(end),'Data') && ...
                            ~isempty(localObj(end).Data.DataTable) &&...
                            ~isempty(localObj(end).Data.DataTable{:,1})
                        %an input timeseries or table has been loaded
                        isvalidmodel(i) = true;    
                    else
                        %input data is loaded using PropertyInterface
                        isvalidmodel(i) = isValidInstance(localObj);
                    end
                end
                isvalidmodel = all(isvalidmodel);
            end
        end 
%%
        function callStaticFunction(~,fname,inp1)
            %call a class function to load data or run a model
            heq = str2func(['@(inp1) ',[fname,'(inp1)']]); 
            try
               heq(inp1); 
            catch
               warndlg(sprintf('Unable to run function %s',fname));                       
            end
        end
%%
%         function minp = getModelInputs(obj,classname)
%             %property ModelInputs is protected. return values for specific
%             %class. Used in muiDataSet
%             minp = obj.ModelInputs.(classname);
%         end
%%  
        function clearDataUI(obj,guiobj)
            %function to tidy up plotting and data access GUIs
            %first input variable is the ModelUI handle (unused)
            name = class(guiobj);
            %handle subclasses that inherit standard GUI
            idx = regexp(name,'_');
            if ~isempty(idx)
                name = name(idx+1:end);
            end
            switch name
                %define case for each plot/data GUI
                case 'muiPlotsUI'
                    figObj = [];
                    if ~isempty(obj.mUI.Plots)
                        localObj = obj.mUI.Plots.Plot.FigNum;
                        nfig = length(localObj);
                        figObj = gobjects(1,nfig);
                        for i=1:nfig
                            figObj(i) = findobj('tag','PlotFig',...
                                                'Number',localObj(i));
                        end
                    end
                    deleteFigObj(obj,figObj,'Plots');
                case 'muiStatsUI'
                    figObj = findobj('Tag','StatFig','-or','Tag','StatTable');                   
                    deleteFigObj(obj,figObj,'Stats');
                    
%                 case 'muiEditUI'
%                     delete(obj.mUI.EditUI)
%                     obj.mUI.EditUI = [];
%                 case 'muiManipUI'
%                     delete(obj.mUI.ManipUI)
%                     obj.mUI.ManipUI = [];
            end
            guiobjtxt = name(4:end);
            delete(obj.mUI.(guiobjtxt))
            obj.mUI.(guiobjtxt) = [];
        end
    end
end