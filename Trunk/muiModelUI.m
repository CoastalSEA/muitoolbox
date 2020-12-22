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
        mUI = struct('Figure',[],'Menus',[],'Tabs',[],'Plots',[],...
                          'Edit',[],'Manip',[],'Stats',[])        
            % mUI.Figure        %handle for main GUI figure
            % mUI.Menus         %handle for drop down menus in GUI
            % mUI.Tabs          %handle for the Tabs in the main GUI
            % mUI.Plots         %handle for plotting
            % mUI.Edit          %handle for editing
            % mUI.Manip         %handle for data manipulation  
            % mUI.Stats         %handle for statistics GUI
 
        TabProps         %structure to hold PropertyTab and position for each data input
        ModelInputs      %classes required by model used in isValidModel check 
        DataUItabs       %structure to define number of muiDataUI tabs for each use 
%         SaveDataString   %uses ModelInputs if not defined  
    end
    
    properties 
        Constants = muiConstants.Evoke  %constants used by applications
        Info = muiProject               %project information
        Cases = muiCatalogue            %handle to DataSets and Catalogue
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
        setMenus(obj)      %application specific menus
        setTabs(obj);      %initialise tabs that are specific to the model
        setTabAction(obj)     %define how selected data is to be used
        setTabProperties(obj);%get locations for data input display  
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
            figure('Units','normalized','MenuBar','none',...
                'Name',vtxt,'NumberTitle','off',...
                'ToolBar','none',...
                'Position',[0.35 0.55 0.3 0.4],'Resize','off',...
                'CloseRequestFcn','',...
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
                'Tag','MainFig');
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
            for i = 1:length(menulabels)   
                %initialise top level menu
                MenuDef = menustruct.(menulabels{i});
                obj.mUI.Menus(i) = setUIMenus(obj,MenuDef(1));
                %check for submenus and initialise if defined
                addSubMenus(obj,obj.mUI.Menus(i),MenuDef,1);
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
        
%% functions to initialise tabs --------------------------------------------
        function setAppTabs(obj)
            %initialise the user defined tabs and subtabs
            [tabs,subtabs] = setTabs(obj);
            tabtags = fieldnames(tabs);
            if nargin<4 || isempty(subtabs)
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
        function newproject(obj,~,~)
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
                cpath = cd(pname);
                ispath = true;
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
%%
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
            casetypes = unique(obj.Cases.Catatlogue.CaseType);
            
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

            deleteCases(obj.Cases,type,'All');
            obj.DrawMap;
        end
%%
%-------------------------------------------------------------------------
% Project menu functions
%--------------------------------------------------------------------------                    
        function editProject(obj,~,~)
            %call function to edit Project details (name, date, etc)
            editProject(obj.Info)
            obj.DrawMap;
        end
%%
        function projectScenario(obj,src,~)
            %call functions to edit, save, delete or reload a scenario
            mobj = obj.Data;   %handle to muiCatalogue
            switch src.Text
                case 'Edit Description'            
                    editCase(mobj);
                    obj.DrawMap; 
                case 'Edit Data Set'
                    obj.mUI.Edit = DataEdit.getEditGui(mobj);    
                case 'Save'
                    saveCase(mobj);
                case 'Delete'
                    deleteCases(mobj);
                    obj.DrawMap;
                case 'Reload'
                    reloadCase(mobj);      
                case 'View settings'
                    viewCaseSettings(mobj);
            end   
        end                                                    
%%
        function runExpImp(obj,src,~)
            %call functions to export or import a dataset
            switch src.Text
                case 'Export'
                    DataSet.exportDataSet(obj);
                case 'Import'
                    DataSet.importDataSet(obj);
            end
        end
%%
%-------------------------------------------------------------------------
% HELP menu function
%--------------------------------------------------------------------------
        function Help(~,~,~)
            doc muitoolbox
        end
    end
%%
%--------------------------------------------------------------------------
% Tab Case list and Property tables and function for Case list callback 
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
        function MapTable(obj,ht)
            % load case descriptions
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
                'CellSelectionCallback',@obj.scenarioCallback,...
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
            %srctxt - Tag for selected tab (eg src.Tag)
            %default version. can be overloaded for specific model
            %implementation
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
        function getTabData(obj,src,~,varargin)
            %get data required for a tab action (eg plot or tabulation)
            %user selected data are held in the structure 'inp' including:
            %caseid, handle, idh, dprop, id_rec, casedesc.
            refresh;
            if isempty(obj.Cases.Catalogue)                            
                %there are no model results saved so run model
                tabRunModel(obj);
                %check whether model returned a result
                if isempty(obj.Cases.Catalogue)
                    ht = findobj(src,'Type','axes');
                    delete(ht);
                    return;
                end
            end
            %get the model type or class to used for selection
            if ~isempty(varargin), varargin = varargin{1}; end
            %prompt to select a case and then retrieve data pointers
            %see Results.getCaseRecord for details of output
            if height(obj.Cases.Catalogue)>1
                [inp.useCase,~,~,ok] = ScenarioList(obj.Data,varargin,...
                                                    'ListSize',[200,140]);
                if ok<1, return; end
            else
                inp.useCase = 1;
            end
            
            cobj = obj.Cases.Catalogue;
            inp.caseid = cobj.CaseID(inp.useCase); 
            if ~isempty(varargin)  && ~contains(cobj.CaseType(inp.useCase),varargin)
                return;
            end
            
            [inp.handle,inp.idh,inp.dprop,inp.id_rec,...
                inp.aprop] = getCaseRecord(cobj,obj,inp.caseid);
            if isempty(inp.handle), return; end
            obj = obj.(inp.handle)(inp.idh);
            dataset = obj.(inp.dprop{1}){inp.id_rec};
            if isa(dataset,'tscollection')
                tsnames = gettimeseriesnames(dataset);
                metatxt = dataset.(tsnames{1}).Name;
            else
                metatxt = dataset.Properties.VariableDescriptions{1};
            end
            cdesc = obj.Cases.Catalogue.CaseDescription{inp.useCase}; 
            if isempty(metatxt)
                inp.casedesc = cdesc;
            else
                inp.casedesc = sprintf('%s - %s',cdesc,metatxt);  
            end
            %pass the input data used for the model case
            inp.casemodel = obj.Cases.Catalogue.CaseModel{inp.useCase};
            setTabAction(obj,src,obj,inp);
        end
 %%
        function tabRunModel(gobj)
            %run the model and assign results to model handle
            src.Text = 'Run Model';
            runModel(gobj,src,[]);
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
%--------------------------------------------------------------------------
% Additional Functions
%--------------------------------------------------------------------------    
       function caseCallback(obj,src,evt)
            %called from tabs listing cases by clicking on a tab row
            %check that there are some cases
            if isempty(obj.Cases.Catalogue.CaseID), return; end 
            %get selected case
            selrow = evt.Indices(1);
            idx = find(tabSubset(obj,src.Parent.Tag));           %%************
            caserec = idx(selrow);
            [dataset,~] = getCaseDataSet(obj.Data,obj,caserec); %%**************
            if istable(dataset)
                name = dataset.Properties.VariableNames;
                desc = dataset.Properties.VariableDescriptions;
                unit =  dataset.Properties.VariableUnits;
                meta = dataset.Properties.UserData.MetaData;
                %output summary of Table to the command line
                format compact
                summary(dataset)
%             else
%                 name = gettimeseriesnames(dataset);
% %                 desc = localObj.ResDef.varDesc;
%                 for i = 1:length(name)
%                     desc{1,i} = dataset.(name{i}).DataInfo.UserData;
%                     unit{1,i} = dataset.(name{i}).DataInfo.Units;
%                     meta{1,i} = dataset.(name{i}).UserData.MetaData; 
%                 end
            end
%             desc = desc(1:length(name));
            userdata = horzcat(name',desc',unit',meta');
            hf = figure('Name','Scenrios summary', ...
                'Units','normalized', ...
                'Position',[0.04,0.65,0.3,0.2],...
                'Resize','on','HandleVisibility','on', ...
                'Tag','PlotFig');
            colnames = {'Variable','Description','Units','Metadata'};
            tc = uitable('Parent',hf, ...
                'Units','normalized', ...
                'ColumnName', colnames,'ColumnWidth',{60 120 40 1800}, ...
                'Data',userdata);
            tc.Position(3:4)=[0.935 0.8];  
            tc.Position(2)=0.9-tc.Position(4);
        end
%%  

%%possibly move this function??????????????????????????????
        function clearGui(obj,guiobj)
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
                case 'ModelPlots'
                    figObj = [];
                    if ~isempty(obj.mUI.Plots.GuiChild)
                        localObj = obj.mUI.Plots.GuiChild.PlotFigureNum;
                        nfig = length(localObj);
                        figObj = gobjects(1,nfig);
                        for i=1:nfig
                            figObj(i) = findobj('tag','PlotFig',...
                                                'Number',localObj(i));
                        end
                    end
                    deleteFigObj(obj,figObj,objtype);
%                         if ~isempty(localObj)
%                             %check whether user wants to delete plots
%                             %generated by this GUI
%                             answer = questdlg('Delete existing plots?',...
%                                                  'Plots','Yes','No','No');
%                             if strcmp(answer,'Yes')
%                                 %delete each plot and then clear GUI handle
%                                 for i=1:length(localObj)
%                                     hf = findobj('tag','PlotFig',...
%                                                     'Number',localObj(i));
%                                     delete(hf);
%                                 end
%                                 clear hf
%                                 delete(obj.mUI.Plots)
%                                 obj.mUI.Plots = [];
%                             end
%                         end
%                     else
%                         delete(obj.mUI.Plots)
%                         obj.mUI.Plots = [];
%                     end
                case 'DataStats'
                    figObj = findobj('Tag','StatFig','-or','Tag','StatTable');                   
                    deleteFigObj(obj,figObj,objtype);
%                     if ~isempty(figObj)
%                         answer = questdlg('Delete existing plots and tables?',...
%                                                  'Stats Figures','Yes','No','No');
%                         if strcmp(answer,'Yes')
%                             %delete each plot and then clear GUI handle
%                             for i=1:length(figObj)
%                                 hf = figObj(i);
%                                 delete(hf);
%                             end
%                             clear hf
%                             delete(obj.mUI.Stats)
%                             obj.mUI.Stats = [];
%                         end
%                     else
%                         delete(obj.mUI.Stats)
%                         obj.mUI.Stats = [];
%                     end
                case 'DataEdit'
                    delete(obj.mUI.Edit)
                    obj.mUI.Edit = [];
                case 'DataManip'
                    delete(obj.mUI.Manip)
                    obj.mUI.Manip = [];
            end
        end
    
%%
        function deleteFigObj(obj,figObj,objtype)
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
end