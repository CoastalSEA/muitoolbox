classdef muiDataUI < handle %replaces DataGUIinterface
%
%-------abstract class help------------------------------------------------
% NAME
%   muiDataUI.m
% PURPOSE
%   Abstract class for creating graphic user interface to select data
%   and pass selection to applications
% NOTES
%   Typically called by class implementation of muiModelUI
% SEE ALSO
%   ModelPlots.m amd DataStats for examples of usage
%
% Author: Ian Townend
% CoastalSEA (c) Dec 2020
%--------------------------------------------------------------------------
%     
    properties (Transient)
        %struct for handles to figure and tabs
        dataUI = struct('Figure',[],'Tabs',[])    
        %  dataUI.Figure     handle for UI figure
        %  dataUI.Tabs       handle for UI tabs
        TabContent = muiDataUI.defaultTabContent
        UIsettings            %struct of UI settings
        UIselection           %struct array UI selections (1:n)
    end

    properties (Abstract)  %properties that all subclasses must include
        TabOptions         %names of tabs providing different data accces options
    end

    methods (Abstract,Access=protected) %methods that all subclasses must define
        setTabContent(obj,src)          %layout options for individual tabs 
        setVariableLists(obj,src,mobj)  %initialise selection variables
        setTabActions(obj,src,mobj)     %callback to control tab updating
        UseSelection(obj,src,evt,mobj)  %function to do something with selected data
    end
%--------------------------------------------------------------------------
% initialise figure and tabs
%--------------------------------------------------------------------------
    methods (Access=protected)       %methods common to all uses
        function setDataUIfigure(obj,mobj,GuiTitle)
            if isempty(obj)
                error('No input')
            end
%             obj.UIsettings = muiDataUI.uisel;  %initialise struct for settings
%             obj.UIselection = muiDataUI.uisel; %initialise struct array for selections
            %initialise UI figure
            obj.dataUI.Figure = figure('Name',GuiTitle, ...
                'NumberTitle','off', ...
                'MenuBar','none', ...
                'Units','normalized', ...
                'CloseRequestFcn',@(src,evt)exitDataUI(obj,src,evt,mobj),...
                'Resize','on','HandleVisibility','on', ...
                'Visible','off','Tag','DataUI');
            obj.dataUI.Figure.Position(1:2)=[0.16 0.3]; 
            axes('Parent',obj.dataUI.Figure, ...
                'Color',[0.94,0.94,0.94], ...
                'Position',[0 0.002 1 1], ...
                'XColor','none', ...
                'YColor','none', ...
                'ZColor','none', ...
                'Tag','DataUIaxes');
        end
 %%
        function setDataUItabs(obj,mobj)
            if isempty(obj.TabOptions)
                return;
            end
            obj.dataUI.Tabs = uitabgroup(obj.dataUI.Figure, ...
                'Tag','DataUItabs');
            obj.dataUI.Tabs.Position = [0 0 1 1];
            %
            ntab = length(obj.Tabs2Use);
            %
            for i=1:ntab
                tabname = obj.Tabs2Use{i};
                tabtitle = sprintf('  %s  ',tabname);
                ht = uitab(obj.dataUI.Tabs,'Title',tabtitle,...
                    'Tag',tabname,'ButtonDownFcn', ...
                    @(src,evd)obj.setTabActions(src,evd,mobj));
                uipanel('Parent',ht,'Units','normalized',...
                    'Position',[.005 .005 0.99 0.99],'Tag',[tabname,'Panel']);
                %now add controls to tab
                setTabContent(obj,ht);             %defines what controls to use                
                setDataOptionControls(obj,ht,mobj);%selection controls
                setVariableLists(obj,ht,mobj);     %assign values to variables
                setXYZpanel(obj,ht,mobj); %XYZ button panel
                setAdditionalButtons(obj,ht,mobj); %addtional action buttons
                setTabControlButtons(obj,ht,mobj); %tab control buttons 
                setHeaderText(obj,ht)              %add any text defined for header
            end
            ht = findobj(obj.dataUI.Tabs,'Tag',obj.Tabs2Use{1});
            initialiseUIselection(obj,ht);      %initialise date selection
            initialiseUIsettings(obj,ht);       %initialise button settings
            obj.dataUI.Tabs.SelectedTab = ht;
%             setTabActions(obj,ht,[],mobj);    %tab specific actions
            obj.dataUI.Figure.Visible = 'on';
        end  
%%
%--------------------------------------------------------------------------
% initialise data selection options for each tab
%--------------------------------------------------------------------------
        function setDataOptionControls(obj,src,mobj)
            %intialise data selection options and labels
            hf = src;
            itab = strcmp(obj.Tabs2Use,src.Tag);  
            vartitle = obj.TabContent(itab).Titles;
            varorder = obj.TabContent(itab).Order;
            nvar = length(vartitle);
            intheight = obj.TabContent(itab).Window/(nvar+1);
            header = obj.TabContent(itab).Header;
            for i=1:nvar
                height = 1-i*intheight-header;
                uicontrol('Parent',hf, 'Style','text',...
                    'String',vartitle{i},...
                    'HorizontalAlignment', 'left',...
                    'Units','normalized', ...
                    'Position',[0.1 height-0.01/i 0.4 0.04],...
                    'Tag',varorder{i});
                obj.TabContent(itab).Selections{i} = uicontrol('Parent',hf, ...
                    'Style',obj.TabContent(itab).Style{i}, ...
                    'Units','normalized', ...
                    'Position',[0.26 height 0.58 0.04], ...
                    'String','Not yet set', ...
                    'ListboxTop',1, ...
                    'Callback',@(src,evt)updateSelection(obj,src,evt,mobj), ...
                    'Tag',varorder{i}, ...
                    'Value',int16(1)); %max list length is 32767
                if strcmp(obj.TabContent(itab).Style{i},'slider')
                    setSlider(obj,hf,i)
                end
            end
        end
%%
%--------------------------------------------------------------------------
% initialise control buttons and header text
%--------------------------------------------------------------------------
        function setTabControlButtons(obj,src,mobj)   
            % GUI control buttons - user defined lables + close
            idx = strcmp(obj.TabOptions,src.Tag);
            butpos = obj.TabContent(idx).TabButPositions;
            butlabel = obj.TabContent(idx).TabButtons;
            nbut = length(butlabel);
            for i=1:nbut
                uicontrol('Parent',src,'Tag','UserButton',...
                    'Style','pushbutton','String',butlabel{i},...
                    'Units','normalized', ...
                    'Position', [butpos(i,1) butpos(i,2) 0.15 0.08],...                    
                    'Callback', @(src,evt)setSelection(obj,src,evt,mobj));
            end
            %Create push button to close plotting GUI
            uicontrol('Parent',src,...
                'Style','pushbutton',...
                'String', 'Close',...
                'Units','normalized', ...
                'Position', [0.75 0.03 0.15 0.08], ...
                'Callback', @(src,evt)exitDataUI(obj,src,evt,mobj));
        end  
%%
        function setHeaderText(obj,src)
            %set the header text on the selected tab
            itab = strcmp(obj.Tabs2Use,src.Tag);
            boxtxt = obj.TabContent(itab).HeadText;
            header = obj.TabContent(itab).Header;
            pos = [0.02, 1-header-0.03, 0.96, header];
            uicontrol('Parent',src,'Style','text','String', boxtxt,...
            'BackgroundColor',[0.94,0.94,0.94],'HorizontalAlignment', 'center',...        
            'Units','normalized','Position', pos,'Tag','HeaderText');
        end
%%
%--------------------------------------------------------------------------
% initialise data selection and settings
%--------------------------------------------------------------------------
        function initialiseUIselection(obj,src)
            %initialise the struct used to hold variable selections
            obj.UIselection = [];
            itab = strcmp(obj.Tabs2Use,src.Tag);
            nvar = obj.TabContent(itab).XYZnvar;
            names = obj.TabContent(itab).XYZlabels; 
            for i=1:nvar
                obj.UIselection.(names{i}) = muiDataUI.uisel;
            end
        end
%%
        function initialiseUIsettings(obj,src)
            %initialise the struct used to hold button settings
            obj.UIsettings = [];
            itab = strcmp(obj.Tabs2Use,src.Tag);  
            names = obj.TabContent(itab).ActButNames; 
            nbut = length(names);            
            obj.UIsettings = struct('Type','','Scale',1,'Equation','');
            for i=1:nbut    
                obj.UIsettings.(names{i}) = false;
            end
        end
%%
%--------------------------------------------------------------------------
% initialise additional buttons that control selection settings
%--------------------------------------------------------------------------
        function setAdditionalButtons(obj,src,mobj) 
            %additional action control buttons
            %NB mobj may be used in the callback
            idx = strcmp(obj.Tabs2Use,src.Tag);
            butnames = obj.TabContent(idx).ActButtons;
            butpos = obj.TabContent(idx).ActButPos;
            butcall = obj.TabContent(idx).ActButCall;
            buttip = obj.TabContent(idx).ActButTip; 
            varorder = obj.TabContent(idx).Titles;
            nvar = length(varorder);
        %     if strcmp(src.Parent.Parent.Name,'Derive output')
        %         nvar = nvar-1; %no idea why this is needed!!! 
        %                        %works without this for all other UIs
        %     end
            height = obj.TabContent(idx).Window/(nvar+1);
            head = obj.TabContent(idx).Header;
            for i=1:length(butnames)
                if butpos(i,2)<0
                    butdef.tag = varorder{-butpos(i,2)};  
                    butpos(i,2) = 1+butpos(i,2)*height-0.012-head;                
                else
                    butdef.tag = sprintf('Button%d',i);
                end
                butdef.call = butcall{i};
                butdef.txt = butnames{i};
                butdef.tip = buttip{i};
                butdef.metadata = 'ActionButton';
                butdef.pos = [butpos(i,1),butpos(i,2),0.04,0.055];
                captureButton(obj,src,mobj,butdef);
            end
        end
%%
%--------------------------------------------------------------------------
% initialise XYZpanel
%--------------------------------------------------------------------------
        function h_pan = setXYZpanel(obj,src,mobj) 
            %add a panel with buttons to capture selected variable and dimensions
            %with a summary of each selection in a text window
            idx = strcmp(obj.Tabs2Use,src.Tag);
            panpos = obj.TabContent(idx).XYZpanel;
            nbut = obj.TabContent(idx).XYZnvar;
            if isempty(panpos)
                return; %no panel specified
            end
            %create holding panel
            h_pan = uipanel(src,'Units','normalized','Position',panpos,'Tag','XYZpanel');
            helptxt = @(txt) sprintf('Make selection using menu above and press %s button to load',...
                         txt);
            boxtxt = 'Make selection';            
            butdef.call = '@(src,evt)XYZselection(obj,src,evt,mobj)';
            vartxt = obj.TabContent(idx).XYZlabels;
            txtlen = cellfun(@length,vartxt);
            %caters for button text of varying length up to 9 characters
            butwidth = 0.05+(max(txtlen)-1)*0.01;
            offset = 0.05-(max(txtlen)-1)*0.005;

            if nbut==2
                butdef.pos = [offset,0,butwidth,0.22];
                postxt = [0.15,0,0.78,0.4];
                posbut2 = [0.66,0.16];
                postxt2 = [0.55,0.05];
            elseif nbut==3  
                butdef.pos = [offset,0,butwidth,0.15];
                postxt = [0.15,0,0.78,0.3];
                posbut2 = [0.745,0.425,0.105];
                postxt2 = [0.67,0.35,0.03];
            end

            for i=1:nbut
                %add XYZ selection button
                butdef.txt = vartxt{i};
                butdef.tip = helptxt(vartxt{i});
                butdef.metadata = 'xyzButton';
                butdef.pos(2) = posbut2(i);
                butdef.tag = sprintf('%s-button',vartxt{i});
                captureButton(obj,h_pan,mobj,butdef);
                %add XYZ text box for selection string
                tagtxt = sprintf('%stext',vartxt{i});
                postxt(2) = postxt2(i);
                uicontrol('Parent',h_pan,'Style','text','String', boxtxt,...                
                          'BackgroundColor',[0.9 0.9 0.9],...
                          'HorizontalAlignment', 'left',...
                          'Units','normalized','Position', postxt,...
                          'Tag',tagtxt);
            end           
        end 
%%
%--------------------------------------------------------------------------
% additional callback functions
%--------------------------------------------------------------------------
        function captureButton(obj,src,mobj,butdef)            %#ok<INUSL>
            %create a button to capture user input
            %NB:obj is needed because it is used in the button
            %callback 'butcall'. mobj may also be in the callback function
            %src - handle to the parent object
            %butdef - structure with the following definitions
            %tag - tag name, pos - position of button, txt - text
            %tip - help tip text, call - sting of button callback function

            hb = uicontrol('Parent',src,'Tag',butdef.tag,...
                           'Style','pushbutton',...
                           'String', butdef.txt,...
                           'Units','normalized', ...
                           'Position', butdef.pos, ...
                           'TooltipString',butdef.tip,...
                           'UserData',butdef.metadata,...
                           'Callback', eval(butdef.call));
            %NB TooltipString changed to Tooltip in 2018b
            %may need to change in the future
            if isletter(butdef.txt)
                hb.FontName = 'FixedWidth';
            else
                hb.FontName = 'Symbol';
            end
        end   
%%
        function isbut = checkButtonSetting(obj,txt)
            %check whether any current button setting matches txt
            %assumes that characters are not duplicated on a tab
            %similar function included in PlotFig
            %returns isbut=true if txt is found on an Action Button
            isbut = false;
            h_but = findobj(obj.DataGuiTabs.SelectedTab,'UserData','ActionButton');
            for i=1:length(h_but)
                butstr = h_but(i).String;
                if strcmp(butstr,txt)
                    isbut = true;
                end
            end
        end
%%
        function updateSelection(obj,src,~,mobj)
            %callback function from uicontrols keeps track of currrent selection
            ht = src.Parent;
            setVariableLists(obj,ht,mobj)
        end
        
%%
        function XYZselection(obj,src,~,mobj)
            %call inputUI to select a variable to assign to XYZ field
            xyz = src.String;       %XYZ button identifier
            itab = strcmp(obj.Tabs2Use,src.Parent.Parent.Tag);
            selected = obj.TabContent(itab).Selections;
            order = obj.TabContent(itab).Order;
            for i=1:length(order)
                idx = selected{i}.Value;
                if iscell(selected{i}.String)
                    desc.(order{i}) = selected{i}.String{idx};
                else %uicontrol unpacks 1x1 cells with character vectors
                    desc.(order{i}) = selected{i}.String;
                end
            end
            %get selected Case and dataset (NB caserec must be # in full
            %list of Catalogue, not a subset)
            [dst,caserec,idset] = getDataset(mobj.Cases,desc.Case,desc.Dataset);
            %get variable, row and dimension descriptions
            idvar = find(strcmp(dst.VariableDescriptions,desc.Variable));           
            [dstnames,dstdesc] = getVarAttributes(dst,idvar);
            %set up call to inputUI
            figtitle = 'Select variable';
            inputxt = {'Select:','Range:'};
            varRange = dst.VariableRange.(dstnames{1});
            rangetext = var2range(varRange);
            defaultinput = {dstdesc,rangetext};
            promptxt = sprintf('Select the property to use and any limits to be applied to the data range of the selected property');  
            %call inputUI
            %% need to add scaling options
            
            h_inp = inputUI('FigureTitle', figtitle,...
                                    'InputFields',inputxt,...
                                    'Style',{'linkedpopup','edit'},...
                                    'ControlButtons',{'','Ed'},...
                                    'ActionButtons',{'Select','Close'},...
                                    'DefaultInputs',defaultinput,...
                                    'UserData',{[],varRange},...
                                    'PromptText',promptxt,...
                                    'DataObject',dst);           
            waitfor(h_inp,'Action')
            selection = h_inp.UIselection;
            delete(h_inp.GUIfig)  
    
            %use selection        
            %define case,dataset,variable,ivar,range 
            if ~isempty(selection)
                obj.UIselection(itab).(xyz).caserec = caserec;
                obj.UIselection(itab).(xyz).dataset = idset;
                obj.UIselection(itab).(xyz).variable = idvar;
                obj.UIselection(itab).(xyz).property = selection{1};
                obj.UIselection(itab).(xyz).range = selection{2};                               
                boxtext = sprintf('%s: %s',dstdesc{selection{1}},...
                                                        selection{2});   
                vartxt = sprintf('%stext',src.String); 
                h_box = findobj(src.Parent,'Tag',vartxt);
                h_box.String = boxtext;     
            end
            %alternative code below clears the text if user cancels
%             else
                %user cancelled - clear selection and update text
%                 obj.UIselection(itab).(xyz) = muiDataUI.uisel;
%                 boxtext = 'Make selection';
%             end  
%             vartxt = sprintf('%stext',src.String); 
%             h_box = findobj(src.Parent,'Tag',vartxt);
%             h_box.String = boxtext;
        end        
%%
        function setSelection(obj,src,~,mobj)
            %set the selection and pass to the instantiating class method
            if strcmp(src.String,'Clear')%clear variable selection in the UI                
                initialiseUIselection(obj,src.Parent);
                initialiseUIsettings(obj,src.Parent);  
                resetVariableSelectioin(obj,src);
                clearXYZselection(obj,src.Parent);
            else
                itab = strcmp(obj.Tabs2Use,src.Parent.Tag);
                assignSelection(obj,mobj,itab);  %selections in UI
                assignSettings(obj,itab);        %settings in UI
                UseSelection(obj,src,mobj);      %do something with selection
            end      
        end         
%%
        function assignSelection(obj,mobj,itab)
            %update the UIselection to the current values
            %check that assignments have dimensions that match-up
            nvar = obj.TabContent(itab).XYZnvar;
            names = obj.TabContent(itab).XYZlabels;
            uisel = obj.UIselection(itab);
            %selected variable dimensions
            dimdiff = zeros(1,nvar); propsused = dimdiff;
            for i=1:nvar %for each variable that has been selected
                usi = uisel.(names{i});
                propsused(i) = usi.property;
                if usi.property>1
                    pdim = 1;
                else
                    dst(i) = getDataset(mobj.Cases,usi.caserec,usi.dataset);
                    pdim = getVariableDimensions(dst(i),usi.variable);
                end
                %if pdim>=nvar then there are more dimensions than needed
                dimdiff(i) = pdim-nvar+1;
            end
            %
            if any(dimdiff>0) %some variables need subselection
                subVarSelection(obj,uisel,dst,names,propsused,dimdiff);
            end
            
            %STILL NEED TO CHECK THAT DIMENSIONS MATCH CORRECTLY
            %Handle selection of two multi-dimensional arrays
        end
%%
        function subVarSelection(obj,uisel,dst,names,propsused,dimdiff)
            %use inputUI to make a subselection for variables with more
            %dimensions than required by calling function
            idx = find(dimdiff>0);
            for j=1:sum(dimdiff>0)
                idvar = uisel.(names{idx(j)}).variable;
                [~,dstdesc] = getVarAttributes(dst(idx(j)),idvar);
                %find attributes that have not yet been defined
                inputxt = dstdesc(~ismember(dstdesc,dstdesc(propsused)));
                ndim = length(inputxt);
                range = cell(ndim,1); rangetext = range;
                for k=1:ndim
                    range{k} = getVarAttRange(dst(idx(j)),dstdesc,inputxt{k});
                    rangetext{k} = var2range(range{k});
                end
                promptxt = sprintf('Select the value(s) to be used for the remaining dimensions');
                style = repmat({'slider'},1,ndim);
                buttons = repmat({'Ed'},1,ndim);
                %call inputUI
                h_inp = inputUI('FigureTitle', 'Select Value',...
                                'InputFields',inputxt,...
                                'Style',style,...
                                'ControlButtons',buttons,...
                                'ActionButtons',{'Select','Close'},...
                                'DefaultInputs',rangetext(:),...
                                'UserData',range(:),...
                                'PromptText',promptxt,...
                                'DataObject',dst(idx(j)));
                waitfor(h_inp,'Action')
                selection = h_inp.UIselection;
                delete(h_inp.GUIfig)
                for i=1:length(selection)
                    obj.UIselection(itab).(names{idx(j)}).dims(i).name = inputxt{i};
                    obj.UIselection(itab).(names{idx(j)}).dims(i).value = selection{i};
                end
            end        
        end
%%
        function assignSettings(obj,itab)
            %update the UIsettings to the current values
            uiset = obj.UIsettings;
            uisfields = fieldnames(uiset);
            h_but = findobj(obj.DataGuiTabs.SelectedTab,'UserData','ActionButton');
            
            butnames = obj.TabContent(itab).ActButNames; 
            nbut = length(butnames);
            for i=1:nbut
                value = h_but(i).Value;
                obj.UIsettings.(butnames{i}) = value;
            end
            
            order = obj.TabContent(itab).Order;
            setoptions = {'Type','Scale','Equation'};
            typeset = ismember(setoptions,order);
            if any(typeset)
                for i=1:sum(typeset)
                    S = obj.TabContent(itab).Selections;
                    value = 1;
                    obj.UIsettings.(setoptions{i}) = value;
                end
            end 
        end
%%
        function resetVariableSelectioin(obj,src)
            %return variable selections to initial settings
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab).Selections;
            for i=1:length(S)
                S{i}.Value = 1;
            end
        end
%%
        function clearXYZselection(~,src)
            %clear the text in the XYZ panel
            h_pan = findobj(src.Children,'Tag','XYZpanel');
            h_text = findobj(h_pan.Children,'Style','text');
            nvar = length(h_text);            
            for j=1:nvar
                h_text(j).String =  'Make selection';
            end
        end
%%
        function exitDataUI(obj,~,~,mobj)    
            %delete GUI figure and pass control to main GUI to reset obj
            delete(obj.dataUI.Figure);
            obj.dataUI.Figure = [];  %clears deleted handle
            clearDataUI(mobj,obj);
        end            
    end    
%%
    methods (Static, Access = protected)
        function selection = uisel()
            %return a default struct for UI selection definition
            %caseid or caserec?? Defaullt includes:
            % caserec - caserec in listid of selected case
            % dataset - id to key word in MetaData to select specific dstable
            % variable - id to selected Variable in table 
            % property - name of what to use: variable,row or a dimension description  
            % range - limits set for property
            % dims - struct to hold dimension 'name' and 'value' when
            %        subselecting from a multi-dimensional array
            selection = struct('caserec',0,'dataset',0,'variable',0,...
                               'property',0,'range',[],'dims',[]);
            %dims is a struct array used for variables that are n-d arrays              
            selection.dims = struct('name','','value',[]);
        end 
%%         
        function S = defaultTabContent()
            %default structure for tab contents used to define TabContent
            %selection options - do not use tab names in main menu
            S.Window = 0.75;                       %size of option list window
            S.Header = 0.00;                       %height of header if required
            S.HeadText = {''};                     %header text to include
            %Specification of uicontrol for each selection variable  
            S.Titles = {'Case','Dataset','Variable','Type'};                                                           
            S.Style = {'popupmenu','popupmenu','popupmenu','popupmenu'}; 
            S.Order = {'Case','Dataset','Variable','Type'};  %default list of key words
            S.Scaling = {'Linear','Log','Relative: V-V(x=0)','Scaled: V/V(x=0)',...
                'Normalised','Normalised (-ve)'};  %options for ScaleVariable
            %Tab settings options
            S.Type = {'Line','Bar','Scatter','Stem','Stairs',...
                'Horizontal bar'}; %used for type of plot or stats
            %Tab control button options
            S.TabButtons = {'New','Add','Delete','Clear'}; %labels for tab button definition
            S.TabButPositions = [0.05,0.14;0.25,0.14;0.45,0.14;0.65,0.14]; %default positions
            %XYZ panel definition (if required)
            S.XYZnvar = 3;                         %default uses X,Y and Z
            S.XYZpanel = [0.05,0.25,0.9,0.3];      %position for XYZ button panel
            S.XYZlabels = {'X','Y','Z'};           %default button labels
            %Action button specifications
            S.ActButNames = {'Refresh','Edit'};    %names assigned selection struct
            S.ActButtons = {char(174),'Et'};       %labels for additional action buttons
            % Negative values in ActButPos indicate that a
            % button is alligned with a selection option numbered in the 
            % order given by S.Titles
            S.ActButPos = [0.86,-1;0.86,-4];    
            %action button callback function names
            S.ActButCall = {'@(src,evt)refreshDataList(obj,src,evt,mobj)',...
                            '@(src,evt)editRange(obj,src,evt)'};
            %tool tips for buttons             
            S.ActButTip = {'Refresh data list','Edit range'};   
            %Handle to uicontrol for each selection option
            S.Selections = {};
        end
    end
end