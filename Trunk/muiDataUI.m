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
        issetXYZ = false      %flag to indicate whether data has been selected
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
            %initialise UI figure
            obj.dataUI.Figure = figure('Name',GuiTitle, ...
                'NumberTitle','off', ...
                'MenuBar','none', ...
                'Units','normalized', ...
                'CloseRequestFcn',@(src,evt)exitDataUI(obj,src,evt,mobj),...
                'Resize','on','HandleVisibility','on', ...
                'Visible','off','Tag','DataUI');
            obj.dataUI.Figure.Position(1:2) = [0.16 0.3]; 
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
            headoffset = 1-obj.TabContent(itab).HeadPos(1);
            nvar = length(vartitle);
            xyzpanel = obj.TabContent(itab).XYZpanel;
            window = 1-xyzpanel(2)-xyzpanel(4)-headoffset;
            intheight = window/nvar;
            
            for i=1:nvar
                height = 1-i*intheight+intheight/2-headoffset-0.01;
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
                    'Callback',@(src,evt)updateCaseList(obj,src,evt,mobj), ...
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
            itab = strcmp(obj.Tabs2Use,src.Tag);  
            butpos = obj.TabContent(itab).TabButPos;
            butlabel = obj.TabContent(itab).TabButText;
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
            vertpos = obj.TabContent(itab).HeadPos(1);
            header = obj.TabContent(itab).HeadPos(2);            
            pos = [0.04, vertpos, 0.92, header];
            uicontrol('Parent',src,'Style','text','String', boxtxt,...
            'BackgroundColor',[0.94,0.94,0.94],'HorizontalAlignment', 'left',...        
            'Units','normalized','Position', pos,'Tag','HeaderText');
        end
%%
%--------------------------------------------------------------------------
% initialise additional buttons that control selection settings
%--------------------------------------------------------------------------
        function setAdditionalButtons(obj,src,mobj) 
            %additional action control buttons
            %NB mobj may be used in the callback
            itab = strcmp(obj.Tabs2Use,src.Tag);
            butnames = obj.TabContent(itab).ActButNames;
            buttext = obj.TabContent(itab).ActButText;
            butpos = obj.TabContent(itab).ActButPos;
            butcall = obj.TabContent(itab).ActButCall;
            buttip = obj.TabContent(itab).ActButTip; 
        %------------------------------------------------------------------
        %     varorder = obj.TabContent(itab).Order;
        %     nvar = length(varorder);
        %     if strcmp(src.Parent.Parent.Name,'Derive output')
        %         nvar = nvar-1;     %no idea why this is needed!!! 
        %                            %works without this for all other UIs
        %     end
        %------------------------------------------------------------------
            for i=1:length(butnames)
                if butpos(i,2)<0
                    hprop = obj.TabContent(itab).Selections{-butpos(i,2)};                   
                    butpos(i,2) = hprop.Position(2)-0.01;                
                end
                butdef.call = butcall{i};
                butdef.txt = buttext{i};
                butdef.tip = buttip{i};
                butdef.metadata = 0;
                butdef.pos = [butpos(i,1),butpos(i,2),0.04,0.055];
                butdef.tag = butnames{i};
                captureButton(obj,src,mobj,butdef);
            end
        end
%%
%--------------------------------------------------------------------------
% initialise a text box for an equation or other such use
%--------------------------------------------------------------------------
        function setEquationBox(~,src)
            helptxt = sprintf('Matlab script to create new variable using t=time and x,y,z (not case sensitive):');
            txt1 = 'Write equation or Call function using the selection buttons above';
            txt2 = 'and time (t) if defined for variable(s) used';            
            tiptxt = sprintf('%s\n%s',txt1,txt2);
            uicontrol('Parent',src,...
                'Style','text',...
                'String', helptxt,...
                'HorizontalAlignment', 'left',...
                'Units','normalized', ...
                'Position', [0.08 0.25 0.7 0.04],...                
                'Tag','EqnText');
            uicontrol('Parent',src,...
                'Style','edit',...
                'HorizontalAlignment', 'left',...
                'Units','normalized', ...
                'Position', [0.08 0.15 0.82 0.1],...
                'TooltipString',tiptxt,...
                'ButtonDownFcn',@(src,evt)pasteText(src,evt),...
                'Tag','UserEqn');
        end
%%
%--------------------------------------------------------------------------
% initialise XYZpanel
%--------------------------------------------------------------------------
        function h_pan = setXYZpanel(obj,src,mobj) 
            %add a panel with buttons to capture selected variable and dimensions
            %with a summary of each selection in a text window
            itab = strcmp(obj.Tabs2Use,src.Tag);
            panpos = obj.TabContent(itab).XYZpanel;
            nbut = length(obj.TabContent(itab).XYZlabels);
            if isempty(panpos)
                return; %no panel specified
            end
            %create holding panel
            h_pan = uipanel(src,'Units','normalized','Position',panpos,'Tag','XYZpanel');
            helptxt = @(txt) sprintf('Make selection using menu above and press %s button to load',...
                         txt);
            boxtxt = 'Make selection';            
            butdef.call = '@(src,evt)XYZselection(obj,src,evt,mobj)';
            vartxt = obj.TabContent(itab).XYZlabels;
            txtlen = cellfun(@length,vartxt);
            %caters for button text of varying length up to 9 characters
            butwidth = 0.05+(max(txtlen)-1)*0.01;
            offset = 0.05-(max(txtlen)-1)*0.005;
            
            butheight = 0.48/nbut;
            txtheight = 0.8/nbut;
            butdef.pos = [offset,0,butwidth,butheight];
            postxt = [0.15,0,0.78,txtheight];
            intheight = 1/nbut;

            for i=1:nbut
                %add XYZ selection button
                posbut2 = 1-intheight*i+intheight/2-butheight/2;
                postxt2 = 1-intheight*i+intheight/2-txtheight/2;
                butdef.txt = vartxt{i};
                butdef.tip = helptxt(vartxt{i});
                butdef.metadata = 'xyzButton';
                butdef.pos(2) = posbut2;
                butdef.tag = sprintf('%s-button',vartxt{i});
                captureButton(obj,h_pan,mobj,butdef);
                %add XYZ text box for selection string
                tagtxt = sprintf('%stext',vartxt{i});
                postxt(2) = postxt2;
                uicontrol('Parent',h_pan,'Style','text','String', boxtxt,...                
                          'BackgroundColor',[0.9 0.9 0.9],...
                          'HorizontalAlignment', 'left',...
                          'Units','normalized','Position', postxt,...
                          'Tag',tagtxt);
            end           
        end 
%%
%--------------------------------------------------------------------------
% initialise properties for UI data selection and UI settings
%--------------------------------------------------------------------------
        function initialiseUIselection(obj,src)
            %initialise the struct used to hold variable selections
            obj.UIselection = muiDataUI.uisel;
            itab = strcmp(obj.Tabs2Use,src.Tag);
            names = obj.TabContent(itab).XYZlabels; 
            for i=1:length(names)
                obj.UIselection(i) = muiDataUI.uisel;
            end
        end
%%
        function initialiseUIsettings(obj,src)
            %initialise the struct used to hold button settings
            obj.UIsettings = []; %clear any existing struct
            %initialise the default settings fields
            obj.UIsettings = struct('Type','','Other',1,'Equation','');
            %initialise the addtional settings defined by buttons
            itab = strcmp(obj.Tabs2Use,src.Tag);  
            names = obj.TabContent(itab).ActButNames; 
            nbut = length(names);                    
            for i=1:nbut    
                obj.UIsettings.(names{i}) = 0;  %default button setting
            end
        end
%%
%--------------------------------------------------------------------------
% initialise an inputUI for selection and sub-sampling
%--------------------------------------------------------------------------
        function selection = setInputUI(obj,inp,xyz)
            %setup call to inputUI and await response
            uis = obj.UIselection(xyz);
            selvar = [uis.caserec,uis.dataset,uis.variable];
            h_inp = inputUI('FigureTitle', inp.title,...
                            'PromptText',inp.prompt,...
                            'InputFields',inp.fields,...
                            'Style',inp.style,...
                            'ControlButtons',inp.controls,...                            
                            'DefaultInputs',inp.default,...
                            'UserData',inp.userdata,...
                            'DataObject',inp.dataobj,...
                            'SelectedVar',selvar,...
                            'ActionButtons',inp.actions);  

            waitfor(h_inp,'Action')
            selection = h_inp.UIselection;
            delete(h_inp.UIfig)
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
        function updateCaseList(obj,src,~,mobj)
            %callback function from uicontrols keeps track of currrent selection
            ht = src.Parent;
            setVariableLists(obj,ht,mobj)
        end      
%%
%--------------------------------------------------------------------------
% functions to capture a selection
%--------------------------------------------------------------------------
        function XYZselection(obj,src,~,mobj)
            %call inputUI to select a variable to assign to XYZ field
            xyztxt = src.String;                %XYZ button identifier
            tabobj = src.Parent.Parent;      %parent Tab
            itab = strcmp(obj.Tabs2Use,tabobj.Tag);
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
            
            %assign variable selection
            xyz = strcmp(obj.TabContent(itab).XYZlabels,xyztxt);
%             obj.UIselection(xyz).tab = itab;
            obj.UIselection(xyz).xyz = xyz;
            obj.UIselection(xyz).caserec = caserec;
            obj.UIselection(xyz).dataset = idset;
            obj.UIselection(xyz).variable = idvar;
            
            %set up call to inputUI
            varRange = dst.VariableRange.(dstnames{1});
            rangetext = var2range(varRange);
            scalelist = obj.TabContent(itab).Scaling;
                
            %single variable or dimnsion selection
            inp.title    = 'Select variable';
            inp.prompt   = 'Select the property to use and any limits to be applied to the data range of the selected property';  
            %inputs for fields,style,controls,default and userdata have one value per
            %control even if empty (not required)
            if isempty(obj.TabContent(itab).Scaling)
                inp.fields   = {'Select:','Range:'};
                inp.style    = {'linkedpopup','edit'};
                inp.controls = {'','Ed'};
                inp.default  = {dstdesc,rangetext};
                inp.userdata = {[],varRange};                
            else
                inp.fields   = {'Select:','Range:','Scaling:'};
                inp.style    = {'linkedpopup','edit','popupmenu'};
                inp.controls = {'','Ed',''};
                inp.default  = {dstdesc,rangetext,scalelist};
                inp.userdata = {[],varRange,[]};
            end
            %pass a data object if used (eg for linkedpopup menus)
            inp.dataobj  = dst;
            inp.actions  = {'Select','Close'};            
            selection = setInputUI(obj,inp,xyz);
            
            %define selection by setting case,dataset,variable,property,
            %range,scale. Sub-sampling dims not defined by this selection.      
            if ~isempty(selection)
                obj.UIselection(xyz).property = selection{1};
                obj.UIselection(xyz).range = selection{2};
                if length(selection)>2
                    obj.UIselection(xyz).scale = selection{3};
                    boxtext = sprintf('%s: %s, scale: %s',dstdesc{selection{1}},...
                                    selection{2},scalelist{selection{3}});
                else
                    boxtext = sprintf('%s: %s',dstdesc{selection{1}},...
                                                            selection{2});
                end
                obj.UIselection(xyz).desc = boxtext;

%                 %if variable is to be used on its own or with specified
%                 %dimensions and needs to be constrained, get sub-sample

                pdim = getvariabledimensions(dst,idvar);
%                 if obj.TabContent(itab).XYZmxvar(xyz)==0
%                     %dimension depends on Type selection
%                     setOrderOptionSettings(obj,itab)
%                     mdim = getUseTypeDim(obj);
%                 else
%                     mdim = obj.TabContent(itab).XYZmxvar(xyz);
%                 end
                %
                mdim = obj.TabContent(itab).XYZmxvar(xyz);%no. of range properties
                if selection{1}==1         %variable selected not dimension
                    if pdim>mdim
                        ndim = pdim-mdim;  %no. of index properties  
%                         subVarSelection(obj,dst,1,xyz,mdim,ndim);  %
%                     end                                            %
                    else
                        ndim = 0;
                        mdim = pdim;
                    end
                    subVarSelection(obj,dst,1,xyz,mdim,ndim);
                end

                vartxt = sprintf('%stext',src.String); 
                h_box = findobj(src.Parent,'Tag',vartxt);
                h_box.String = obj.UIselection(xyz).desc;  
            end
        %------------------------------------------------------------------
        %     %alternative code below clears the text if user cancels
        %     else
        %         user cancelled - clear selection and update text
        %         obj.UIselection(itab).(xyz) = muiDataUI.uisel;
        %         boxtext = 'Make selection';
        %     end  
        %     vartxt = sprintf('%stext',src.String); 
        %     h_box = findobj(src.Parent,'Tag',vartxt);
        %     h_box.String = boxtext;
        %------------------------------------------------------------------
        end        
%%
        function setSelection(obj,src,~,mobj)
            %set the selection and pass to the instantiating class method
            checkXYZset(obj,src);
            if strcmp(src.String,'Clear')%clear variable selection in the UI                
                initialiseUIselection(obj,src.Parent);
                initialiseUIsettings(obj,src.Parent);  
                resetVariableSelection(obj,src.Parent);
                clearXYZselection(obj,src.Parent);
                clearEqnBox(obj,src.Parent);
            elseif strcmp(src.String,'Function')
                UseSelection(obj,src,mobj);    %do something with selection
            elseif obj.issetXYZ
                ok = assignSelection(obj,src,mobj);  %selections in UI
                if ok<1, return; end
                assignSettings(obj,src);  %settings in UI                
                UseSelection(obj,src,mobj);    %do something with selection
            else
                warndlg('Check that variables have been defined')
            end      
        end         
%%
%--------------------------------------------------------------------------
% functions to assign variable selection and settings
%--------------------------------------------------------------------------
        function ok = assignSelection(obj,src,mobj)
            %update the UIselection to the current values
            %check that assignments have dimensions that match-up
            ok = 1;
            itab = strcmp(obj.Tabs2Use,src.Parent.Tag);
            xyznames = obj.TabContent(itab).XYZlabels;
            nxyz = length(xyznames);
            uisel = obj.UIselection;
            %check dimensions of selectd variables
            for i=1:nxyz %for each variable assignment to xyz button
                usi = uisel(i);
                if usi.property<1
                    continue;
                elseif usi.property>1
                    pdim = 1;
                else
                    dst = getDataset(mobj.Cases,usi.caserec,usi.dataset);
                    vdim = getvariabledimensions(dst,usi.variable); 
                    setdims = cellfun(@ischar,{usi.dims(:).value});
                    pdim = vdim-sum(1-setdims);
                end
                
%                 if obj.TabContent(itab).XYZmxvar(i)==0
%                     %dimension depends on Type selection
%                     setOrderOptionSettings(obj,itab)
%                     usevardim = getUseTypeDim(obj);
%                 else
%                     usevardim = obj.TabContent(itab).XYZmxvar(i);
%                 end
%                 %
%                 if pdim>usevardim && usi.property==1                                       
%                     mdim = usevardim;    %no. range properties
%                     ndim = pdim-mdim;    %no. index properties

                %if variable is to be used on its own or with specified
                %dimensions and needs to be constrained, get sub-sample
                mdim = obj.TabContent(itab).XYZmxvar(i); %no. of range properties    
                if usi.property==1 && isempty(usi.dims(1).name)
                    if pdim>mdim
                        ndim = pdim-mdim;                     %no. of index properties              
                    else
                        ndim = 0;
                        mdim = pdim;
                    end
                    ok = subVarSelection(obj,dst,usi.property,i,mdim,ndim);
                end
                
                
                
                
%                 if pdim>mdim && usi.property==1                                        
% %                     mdim = obj.TabContent(itab).XYZmxvar(i); %no. range properties
%                     ndim = pdim-mdim;                     %no. of index properties
%                     ok = subVarSelection(obj,dst,usi.property,i,mdim,ndim);
%                 end                
            end
        end
%%
        function ok = subVarSelection(obj,dst,propsused,xyz,mdim,ndim)
            %use inputUI to make a subselection for variables with more
            %dimensions than required by calling function
            ok = 1;
            idvar = obj.UIselection(xyz).variable;
            [dstnames,dstdesc] = getVarAttributes(dst,idvar);
            %find attributes that have not yet been defined
            inputxt = dstdesc(~ismember(dstdesc,dstdesc(propsused)));
            nprop = length(inputxt);
            range = struct('val',{},'txt',{});
            for k=1:nprop
                range(k).val = getVarAttRange(dst,dstdesc,inputxt{k});
                range(k).txt = var2range(range(k).val);
            end

            boxtxt = obj.UIselection(xyz).desc;
            
            %sub-sampling of variable based on range and values required
            uinput = getUIinput(obj,mdim,ndim,dst,dstdesc,range);
            selection = setInputUI(obj,uinput,xyz);
            if isempty(selection), ok = 0; return; end            

            for j=1:mdim
                idx = strcmp(dstdesc,inputxt{selection{2*j-1}});
                obj.UIselection(xyz).dims(j).name = dstnames{idx};
                obj.UIselection(xyz).dims(j).value = selection{2*j};
                boxtxt = sprintf('%s, %s: %s',boxtxt,dstdesc{idx},selection{2*j});
            end
            %
            for i=1:ndim
                slidervals = selection{2*mdim+i};
                dimname = dstnames{strcmp(dstdesc,slidervals{1})};
                obj.UIselection(xyz).dims(mdim+i).name = dimname;
                obj.UIselection(xyz).dims(mdim+i).value = slidervals{2};
                txtval =  var2str(slidervals{2});
                boxtxt = sprintf('%s, %s: %s',boxtxt,slidervals{1},txtval{1});
            end

            %update boxtext description
            obj.UIselection(xyz).desc = boxtxt;
        end
%%
        function uinput = getUIinput(~,mdim,ndim,dst,dstdesc,range)
            %multi-dimension selection for a known variable
            %mdim - number of dimensions with ranges, 
            %ndim - number of dimensions with index
            uinput.title    = 'Select dimension';
            uinput.prompt   = 'Select the property to use and any limits to be applied to the range of the selected property';  
            %inputs for fields,style,controls,default and userdata have one value per
            %control even if empty (not required)
            seltext = repmat({'Select:','Range:'},1,mdim);
            uinput.fields   = [seltext(:);dstdesc(mdim+2:end)'];
            style1 = repmat({'linkedpopup','edit'},1,mdim);
            style2 = repmat({'linkedslider'},1,ndim);
            uinput.style    = [style1(:);style2(:)];
            mcontrol = repmat({'';'Ed'},1,mdim);
            ncontrol = repmat({'Ed'},1,ndim);
            uinput.controls = [mcontrol(:);ncontrol(:)];
            for j=1:2:2*mdim
                uinput.default{j} = dstdesc(2:end)';
                uinput.userdata{j} = {};
                uinput.default{j+1} = range((j+1)/2).txt;
                uinput.userdata{j+1} = range((j+1)/2).val;
            end
            %
            for k=1:ndim
                uinput.default{2*mdim+k} = range(mdim+k).txt;
                uinput.userdata{2*mdim+k} = range(mdim+k).val;
            end
            uinput.dataobj  = dst;
            uinput.actions  = {'Select','Cancel'};
        end
%%
        function assignSettings(obj,src)
            %update the UIsettings to the current values
            
            %get the current button value settings
            itab = strcmp(obj.Tabs2Use,src.Parent.Tag);
            butnames = obj.TabContent(itab).ActButNames; 
            nbut = length(butnames);
            for i=1:nbut
                h_but = findobj(obj.dataUI.Tabs.SelectedTab,'Tag',butnames{i});
                obj.UIsettings.(butnames{i}) = logical(h_but.UserData);
            end
            
            %get any order setting used such as Type or Other
            setOrderOptionSettings(obj,itab)
            
            %check whether an equation has been defined
            heqbox = findobj(src.Parent,'Tag','UserEqn');  
            if ~isempty(heqbox)
                obj.UIsettings.Equation = heqbox.String;
            end
            
            %get the name of the tab and button used to call setSelection
            obj.UIsettings.callTab = src.Parent.Tag;
            obj.UIsettings.callButton = src.String; 
            obj.UIsettings.scaleList = obj.TabContent(itab).Scaling;
        end
%%
        function setOrderOptionSettings(obj,itab)
            %
            order = obj.TabContent(itab).Order;
            setoptions = fieldnames(obj.UIsettings);         
            for i=1:2    %just check first two: Type and Other
                idx = strcmp(order,setoptions{i});
                if any(idx)
                    S = obj.TabContent(itab).Selections{idx};
                    if strcmp(S.Style,'edit')
                        obj.UIsettings.(setoptions{i}) = str2double(S.String);
                    elseif strcmp(S.Style,'popupmenu')
                        obj.UIsettings.(setoptions{i}).Value = S.Value;
                        obj.UIsettings.(setoptions{i}).String = S.String{S.Value};
                    else
                        warndlg('Option not defined in setOrderOptionsSettings')
                    end
                end
            end
        end
%%
        function checkXYZset(obj,src)
            %check that the correct number of variables have been set
            %the TabContent property XYZnset defines minimum requirement
            itab = strcmp(obj.Tabs2Use,src.Parent.Tag);
            nset = obj.TabContent(itab).XYZnset;
            xyzset = [obj.UIselection(:).property];
            if sum(xyzset>0)>=nset
                obj.issetXYZ = true;
            end            
        end
%%
%--------------------------------------------------------------------------
% funtions to reset and exit
%--------------------------------------------------------------------------
        function resetVariableSelection(obj,src)
            %return variable selections to initial settings
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab).Selections;
            for i=1:length(S)
                S{i}.Value = 1;
            end
        end
%%
        function clearXYZselection(obj,src)
            %clear the text in the XYZ panel
            h_pan = findobj(src.Children,'Tag','XYZpanel');
            h_text = findobj(h_pan.Children,'Style','text');
            nvar = length(h_text);            
            for j=1:nvar
                h_text(j).String =  'Make selection';
            end
            obj.issetXYZ = false;
        end
%%
        function clearEqnBox(~,src)
            %clear the equation box, src is the parent of the text uic
            h_eqnbox = findobj(src,'Tag','UserEqn');
            if ~isempty(h_eqnbox)
                h_eqnbox.String = '';
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
%--------------------------------------------------------------------------
% functions to initialise UIselection and TabContent structs
%--------------------------------------------------------------------------
    methods (Static, Access = protected)
        function selection = uisel()
            %return a default struct for UI selection definition
            %caseid or caserec?? Defaullt includes:
            % caserec - caserec in listid of selected case
            % dataset - id to key word in MetaData to select specific dstable
            % variable - id to selected Variable in table 
            % property - name of what to use: variable,row or a dimension description  
            % range - limits set for property
            % scale - any scaling function to be applied to the variable
            % dims - struct to hold dimension 'name' and 'value' when
            %        subselecting from a multi-dimensional array
            % desc - text string display in xyz selection text box
            selection = struct('xyz',0,'caserec',0,'dataset',0,...
                               'variable',0,'property',0,'range',[],...
                               'scale',0,'dims',[],'desc','');
            %dims is a struct array used for variables that are n-d arrays              
            selection.dims = struct('name','','value',[]);
        end 
%%         
        function S = defaultTabContent()
            %default structure for tab contents used to define TabContent
            %selection options - do not use tab names in main menu
            
            %Header size and text
            S.HeadPos = [1.0, 0.0];    %header vertical position and height
            S.HeadText = {''};         %header text to include
            
            %Specification of uicontrol for each selection variable  
            S.Titles = {'Case','Dataset','Variable','Type'};                                                           
            S.Style = {'popupmenu','popupmenu','popupmenu','popupmenu'}; 
            S.Order = {'Case','Dataset','Variable','Type'};  %default list of key words
            S.Scaling = {'Linear','Log','Relative: V-V(x=0)','Scaled: V/V(x=0)',...
                'Normalised','Normalised (-ve)'};  %options for ScaleVariable
            S.Type = {'line','bar','scatter','stem','stairs','barh','User'};
            S.Other = {'1'};
            
            %Tab control button options
            S.TabButText = {'Select','Clear'}; %labels for tab button definition
            S.TabButPos = [0.1,0.03;0.3,0.03]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 3;                      %minimum number of buttons to use
            S.XYZmxvar = [3,3,3];               %maximum number of dimensions per selection
            S.XYZpanel = [0.05,0.2,0.9,0.3];    %position for XYZ button panel
            S.XYZlabels = {'X','Y','Z'};        %default button labels
            
            %Action button specifications
            S.ActButNames = {'Refresh'};         %names assigned selection struct
            S.ActButText = {char(174)};          %labels for additional action buttons
            % Negative values in ActButPos indicate that a
            % button is alligned with a selection option numbered in the 
            % order given by S.Titles
            S.ActButPos = [0.86,-1];    
            %action button callback function names
            S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)'};
            %tool tips for buttons             
            S.ActButTip = {'Refresh data list'};   
            %Handle to uicontrol for each selection option
            S.Selections = {};
        end
    end
end