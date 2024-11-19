classdef inputUI < handle
%
%-------class help------------------------------------------------------
% NAME
%   inputUI.m
% PURPOSE
%   Creates a multi-field UI
% USAGE
%   Called by inputgui.m
% INPUT
%   Defined using varargin for the following fields and assigned to settings
%    FigureTitle     - title for the UI figure
%    PromptText      - text to guide user on selection to make
%    InputFields     - text prompt for input fields to be displayed
%    Style           - uicontrols for each input field (same no. as input fields)
%    ControlButtons  - text for buttons to edit or update selection 
%    DefaultInputs   - default text or selection lists
%    UserData        - data assigned to UserData of uicontrol
%    DataObject      - data object to use for selection
%    SelectedVar     - index vector to define case,dataset,variable selection  
%    ActionButtons   - text for buttons to take action based on selection
%    Position        - poosition and size of figure (normalized units)
% NOTES
%   Widget tag format is as follows: widgetname>uic# where widgetname is 
%   defined by settings.InputFields and #=idx is the index identifier of widget
% SEE ALSO
%   used in muiDataUI. See test_inputgui.m for examples of usage. 
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    properties (Transient)
        UIselection   %struct of current selection from input fields
        UIfig         %handle to UI figure
        Action        %indicate close or action state
    end
%%
    methods (Static)
        function selection = getUI(varargin)
            %alternative to inputgui function to call inputUI
            obj = inputUI(varargin{:});
            waitfor(obj,'Action')
            selection = obj.UIselection;
            delete(obj.UIfig)
        end
    end
%%           
    methods
        function obj = inputUI(varargin)
            %constructor initialises DSCproperties
            nvar = length(varargin)/2;
            settings = obj.getPropertyStruct(nvar);
            for k=1:2:length(varargin)
               settings.(varargin{k}) = varargin{k+1};
            end
            obj = inputUIfig(obj,settings);
        end
%%    
        function obj = inputUIfig(obj,settings)
            %User interface for nvar editable uicontrols         
            h_fig = figure('Name',settings.FigureTitle,'Tag','InputFig',...
                           'MenuBar','none',...
                           'Units','normalized',...
                           'Position',settings.Position,...
                           'Visible','off',...
                           'WindowStyle','modal',...
                           'CloseRequestFcn',@(src,evt)closeuicallback(obj,src,evt));                
            %resize figure based on character size of inputs
            h_fig.Units = 'characters';
            
            func = @(x,N) min(max(cellfun(@length,x)),N);            
            nvar = length(settings.InputFields); 
            unit_ht = 3.6;    %character height allocated to each row
            h_fig.Position(3) = 50+func(settings.InputFields,20)+...
                                        func(settings.DefaultInputs,100);
            h_fig.Position(4) = unit_ht*(nvar+2); 

            %add panel to figure
            pnlht = 1/(nvar+2);
            h_pnl = uipanel(h_fig,'Tag','PlotPanel','Units','normalized',...
                                 'Position',[0.005 pnlht 0.99 1-2*pnlht]);           
            %add prompt text to figure
            pos3 = h_fig.Position(3);
            pos4 = h_fig.Position(4);
            uicontrol('Parent',h_fig, 'Style','text',...
                      'String',settings.PromptText,...
                      'HorizontalAlignment', 'center',...
                      'Units','characters', ...
                      'Position',[1 pos4-unit_ht pos3-2 3],...
                      'Tag',sprintf('inptxt%d',0));
            
            %selcted variable
            h_fig.UserData = settings;
            
            %add widgets (uicontrols) to panel
            intheight = 1/nvar;
            txtheight = [0.4,0.18,0.12,0.09,0.06,0.06,0.05,0.05];
            widgetpos.pos4 = txtheight(nvar);
            count = 1;
            for i=1:nvar
                widgetpos.height = 1-i*intheight+intheight/2-widgetpos.pos4/2;
                hw = getwidget(h_pnl,settings,widgetpos,i);
                if strcmp(settings.Style{i},'linkedpopup')
                    %hw(1) is the ui popumenu and hw(2) the edit field button
                    %default set in getwidget is for hw(2) to call editrange
                    hw(1).Callback = @(src,evt)linkedPopUp(obj,src,evt);
                    hw(1).UserData = count; %used to track previous selection
                    hw(1).Value = count;
                    count = count+1;
                elseif strcmp(settings.Style{i},'slider') ||...
                        strcmp(settings.Style{i},'linkedslider')
                    hw(1).Callback = @(src,evt)updateSlider(obj,src,evt);
                    hw(2).Callback = @(src,evt)updateSlider(obj,src,evt);
                    hw(1).UserData = settings.UserData{i};
                    hw(2).UserData = settings.DataObject;
                    setslider(hw);
                elseif strcmp(settings.Style{i},'popupmenu') && length(hw)==2
                    %popupmenu that includes an edit button
                    hw(2).Callback = @(src,evt)editlist(src,evt);
                    hw(2).UserData = settings.UserData{i};
                end
            end
            
            if nvar==2 && all(strcmp(settings.Style,'popupmenu'))
                %two popupmenus - assume start and end range values and set
                %second popupmenu to the end value.
                hw(1).Value = length(hw(1).String);
            end

            %add buttons to figure
            nbut = length(settings.ActionButtons);
            butxt = fliplr(settings.ActionButtons);
            for j=1:nbut
                offset = 15*j;            
                getActionButtons(obj,h_fig,butxt{j},offset)
            end
            obj.UIfig = h_fig;
            obj.UIfig.Visible = 'on';
        end
    end
%%
    methods (Access=private)
        function getActionButtons(obj,h_fig,butxt,offset)
            %initialise any action buttons specified
            if strcmp(butxt,'Select')
                callback = @(src,evt)inputuicallback(obj,src,evt);
            else
                callback = @(src,evt)closeuicallback(obj,src,evt);
            end
            pos1 = h_fig.Position(3)-offset;
            uicontrol('Parent',h_fig,'Tag','SelectButton',...
                    'Style','pushbutton','String',butxt,...
                    'Units','characters', ...
                    'Position', [pos1 1 10 2],...                    
                    'Callback', callback); 
        end
%%
        function inputuicallback(obj,~,~)
            %callback function for inputUIfig
            uic = flipud(findobj(obj.UIfig,'-regexp','Tag','uic'));
            for i=1:length(uic)
                switch uic(i).Style
                    case {'popupmenu','listbox'}
                        obj.UIselection{i} = uic(i).Value;
                    case {'edit','text'}
                        obj.UIselection{i} = uic(i).String;
                    case 'slider'
                        uicname = split(uic(i).Tag,'>');
                        uicpos = getPosition(obj,uic(i));
                        obj.UIselection{i} = {uicname{1},uicpos};
                end                    
            end
            obj.Action = 1;
        end  
%%
        function linkedPopUp(obj,src,~)
            %link popopmenu to an editable range field
            
            %a new selection has been made using a linked popup menu
            selid = src.Value;                            %new selection in popupmenu
            selected = src.String{selid};                 %text selection           
            
            %get the handles to the existing functional uis
            hpan = findobj(obj.UIfig.Children,'Tag','PlotPanel');
            alledit = findobj(hpan,'Style','edit'); %all text edit uic
            allpopup = findobj(hpan,'Style','popupmenu'); %all popupmenu uic
            allslide = findobj(hpan,'Style','slider');    %all slider uic
            
            %change the linked edit range ui to the range of new selection
            hwtag = sprintf('uic%d',str2double(src.Tag(end))+1); %tag of linked edit range ui
            hw = findobj(alledit,'-regexp','Tag',hwtag);  %handle to linked edit range
            
            dst = obj.UIfig.UserData.DataObject;          %dataset selected
            
            %check that selection does not duplicate another popupmenu selection
            alllnkpops = find(strcmp(obj.UIfig.UserData.Style,'linkedpopup'));
            
            nprops = length(alllnkpops);
            lkpval = zeros(1,nprops);
            for i=1:nprops
                lkptag = sprintf('uic%d',alllnkpops(i));
                hlkp = findobj(allpopup,'-regexp','Tag',lkptag);
                lkpval(i) = hlkp.Value;
            end
            %if duplicated restore the original value
            if sum(lkpval==selid)>1 || selid==src.UserData
                src.Value = src.UserData;
                return;
            end
            
            %existing range values
            oldselid = src.UserData;        %previous selection in popupmenu
            oldrange = hw.UserData;         %current range in source units
            
            %get the new range settings     
            selectedvar = obj.UIfig.UserData.SelectedVar; %id for [case,dataset,variable]
            range = getVarAttRange(dst,selectedvar(3),selected);%selectedvar(3)==variable
            
            if length(range)>2
                rangetext = var2range({range{1},range{end}}); %range is a list
            else
                rangetext = var2range(range);                 %range is 1x2 cell
            end

            %update the linkedpopup edit range widget  
            src.UserData = selid;           %current selection
            hw.String = rangetext;          %new range string
            hw.UserData = range;            %new range values
            
            %now need to update the ui for the single value selection
            %just swap new for old but check for change of variable type
            dimtext = src.String{oldselid}; 
            %find single value ui to be updated
            asingle = findobj([allslide;allpopup],'-regexp','Tag',selected);
            if ~isempty(asingle) 
                if islist(oldrange,1) %checks for all list types
                    %set ui to popupmenu style
                    if ~strcmp(asingle.Style,'popupmenu')
                        asingle.Style = 'popupmenu';   %change to popupmenu
                        clearSliderText(obj,asingle);  %clear slider start-end text                    
                        updateCallback(obj,asingle,'popupmenu');  %update callback to new style
                    end
                    resetPopupWidget(obj,asingle,oldrange,dimtext);
                else
                    %set ui to slider style
                    if ~strcmp(asingle.Style,'slider')
                        asingle.Style = 'slider';      %change to slider
                        setslider(asingle)             %initialise slider start-end text
                        updateCallback(obj,asingle,'slider');  %update callback to new style
                    end
                    resetSliderWidget(obj,asingle,oldrange,dimtext);
                end
                %update the edit button Tag to the name of the single value uic
                updateEdButton(obj,asingle);    
            end
        end
%%
        function updateSlider(obj,src,~)
            %called from slider or edit button for slider to maintain link
            if strcmp(src.Style,'slider')
                %find the position in source data units
                newpos = getPosition(obj,src);
                slitag = src.Tag;
            else
                %find the position in source data units
                idx = str2double(src.Tag(end));
                %setup input dialogue for user to edit value
                slitag = sprintf('uic%d',idx);
                slideobj = findobj(src.Parent,'-regexp','Tag',slitag);
                oldpos = getPosition(obj,slideobj);
                
                %get an updated position. use date picker if a datetime
                if isdatetime(oldpos)
                    %uigetdate is from Matlab Forum (copyright Elmar Tarajan) 
                    answer = {datetime(uigetdate(oldpos,'Select date'),'ConvertFrom','datenum')};
                else
                    promptxt = 'Set dimension value to use';                
                    defaults = var2str(oldpos);
                    answer = inputdlg(promptxt,'inputUI',1,defaults);
                    if isempty(answer), return; end
                end
                
                %get the start and end slider values
                if iscell(slideobj.UserData)
                    svalue = slideobj.UserData{1};
                    evalue = slideobj.UserData{2};
                else %categorical data passes array of values as UserData
                    svalue = slideobj.UserData(1);
                    evalue = slideobj.UserData(end);
                end
                
                %get the format of datasets that need this
                if isduration(svalue)
                    format = svalue.Format;
                    %if user corrupts input format then str2var cannot read input
                    checkstr = split(answer{1});
                    if isduration(svalue) && length(checkstr)<2
                        answer{1} = sprintf('%s %s',answer{1},format);
                    end
                elseif isdatetime(svalue)                                     
                    format = svalue.Format;
                elseif iscategorical(svalue)
                    format = cellstr(slideobj.UserData);
                else
                    format = [];
                end
                
                %check that the new position is a valid selection
                newpos = str2var(answer{1},getdatatype(svalue),format);
                %check newpos by setting range to end value and use isvalidrange
                isvalid  = isvalidrange({newpos,evalue},{svalue,evalue});
                if ~isvalid, return; end

                %calculate the new position in slider coordinates
                if iscategorical(newpos)
                    pos = find(newpos==slideobj.UserData);
                    relpos = pos/length(slideobj.UserData)*100; 
                elseif isinteger(newpos)
                    relpos = round(double(newpos-svalue)/double(evalue-svalue)*100);
                elseif isallround(newpos) 
                    %no data to check for round number values in range vector
                    %this only forces a round value to remain round
                    relpos = round((newpos-svalue)/(evalue-svalue)*100);
                else     %numeric and datetime handled by differences                     
                    relpos = (newpos-svalue)/(evalue-svalue)*100;
                end
                slideobj.Value = relpos;                
            end
            %assign new position as text string
            uitext = findobj(src.Parent,'Tag',['slide-val',slitag(end)]);
            uitext.String = var2str(newpos);
        end
%%
        function resetSliderWidget(~,src,range,dimtext)
            %reset text and settings for the selected widget uic (src)
            
            %update text descriptor
            uinum = src.Tag(end);
            uicname = split(src.Tag,'>');
            uitext = findobj(src.Parent,'-regexp','Tag',[uicname{1},'>txt']);
            uitext.String = dimtext;

            uitext.Tag = sprintf('%s>%s%s',dimtext,'txt',uinum);
            src.Tag = sprintf('%s>%s',dimtext,uicname{2});
            
            %update range in slider
            src.UserData = range;
            
            %update slider text    
            if islist(range,3) %checks for cellstr, sting and categorical                            
                value(1) = var2str(range(1));
                value(2) = var2str(range(end));
                npt = round(length(range)/2);
                midpoint = range(npt);
            elseif iscategorical(range{1})
                value(1) = var2str(range{1});
                value(2) = var2str(range{end});
                npt = round(length(range)/2);
                midpoint = range(npt);
            else
                value(1) = var2str(range{1});
                value(2) = var2str(range{end});
                midpoint = (range{2}-range{1})/2;
                if isdatetime(range{1}) %reset duration as a datetime
                    midpoint = range{1}+midpoint;
                elseif isallround([range{:}])
                    %no data to check for round number values in range vector
                    %use range start-end values as basis for reset
                    midpoint = range{1}+round(midpoint);
                    if isduration(midpoint)
                        src.UserData = cellfun(@time2num,src.UserData,'UniformOutput',false);
                    end
                    src.UserData = cellfun(@int16,src.UserData,'UniformOutput',false);
                end
            end
            value(3) = var2str(midpoint);            
            tagname = {'slide-start','slide-end','slide-val'};
            for i=1:3
                uislidetext = findobj(src.Parent,'-regexp','Tag',[tagname{i},uinum]);
                uislidetext.String = value{i};
            end
            
            %update slider position
            src.Value = 50;
        end
%%
        function [pos,startvalue,endvalue] = getPosition(~,src)
            %update the slider position 
            %no data to check for round number values in range vector
            newpos = src.UserData;
            if islist(newpos,3) %checks for cellstr, sting and categorical 
                nrec = round((length(src.UserData)-1)*src.Value/100)+1;
                pos = src.UserData(nrec);
            elseif iscategorical(newpos{1}) 
                nrec = round((length(src.UserData)-1)*src.Value/100)+1;
                pos = src.UserData(nrec);
            else
                startvalue = src.UserData{1};
                endvalue = src.UserData{2};
                relpos = src.Value/100;
                pos = startvalue+(endvalue-startvalue)*relpos;
            end
        end
%%
        function clearSliderText(~,src)
            %when switching from slider to popupmenu need to remove slider
            %limits and selection text
            uinum = src.Tag(end);
            uislides = findobj(src.Parent,'-regexp','Tag','slide');
            uitext = findobj(uislides,'-regexp','Tag',uinum);
            delete(uitext)
        end
%%
        function resetPopupWidget(~,src,range,dimtext)
            %reset text and settings for the selected widget uic (src)
            
            %update text descriptor
            uinum = src.Tag(end);
            uicname = split(src.Tag,'>');
            uitext = findobj(src.Parent,'-regexp','Tag',[uicname{1},'>txt']);
            uitext.String = dimtext;

            uitext.Tag = sprintf('%s>%s%s',dimtext,'txt',uinum);
            src.Tag = sprintf('%s>%s',dimtext,uicname{2});

            %update range in list
            src.UserData = range;
            src.String = range;
            src.Value = 1;            
        end
%%
        function updateCallback(obj,src,style)
            %update the widget and edit button callbacks to new style selection
            uinum = src.Tag(end);
            uicname = split(src.Tag,'>');
            uibut = findobj(src.Parent,'-regexp','Tag',[uicname{1},'>but']);
            uicon = findobj(src.Parent,'-regexp','Tag',[uicname{1},'>uic']);
            switch style
                case 'slider'
                   uicon.Callback = @(src,evt)updateSlider(obj,src,evt);  
                   uibut.Callback = @(src,evt)updateSlider(obj,src,evt);                    
                case 'popupmenu'
                   uicon.Callback =  @(src,evt)editlist(src,evt);
                   uibut.Callback =  @(src,evt)editlist(src,evt);
            end
            uibut.UserData = uicon.UserData;
        end
%%
        function updateEdButton(~,src)
            %update the name of the Edit button if the variable has changed
            uinum = src.Tag(end);
            uicname = split(src.Tag,'>');
            uibut = findobj(src.Parent,'-regexp','Tag',['>but',uinum]);
            
            newname = sprintf('%s>but%s',uicname{1},uinum);
            uibut.Tag = newname;
        end
%%
        function closeuicallback(obj,~,~)
            %close callback function for inputUIfig
            obj.Action = 0;
        end
%%
        function fig = getPropertyStruct(~,nvar)
            %figdef struct containing: 
            %figtitle - title for inputedit UI
            %position - position of figure on screen (normailzed units
            %style - uicontrol style (popupmenu, edit, etc)  **Not implemented**
            %inputxt - cell array of prompts for each input option
            %butnames - cell array of button names (use '' for no button)    
            %defaultinput - cell array of default values for each input
            %%promptxt = text to prompt user on what to do

            %[0.15,0.56,0.2,0.1]
            %pos4 = 0.04*nvar+0.1;
            fig =struct('FigureTitle',{'inputgui'},...
                        'Position',{[0.15,1-0.05*nvar,0.2,0.1]},...
                        'InputFields',{repmat({''},1,nvar)},...
                        'Style',{repmat({''},1,nvar)},...                        
                        'ActionButtons',{repmat({''},1,nvar)},...
                        'ControlButtons',{repmat({''},1,nvar)},...
                        'DefaultInputs',{repmat({''},1,nvar)},...
                        'UserData',{repmat({''},1,nvar)},...
                        'PromptText',{'Edit inputs'});
        end
    end
end