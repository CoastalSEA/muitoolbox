function varargout = textfigure(figtitle,headtext,intext,butdef)
%
%-------function help------------------------------------------------------
% NAME
%   tablefigure.m
% PURPOSE
%   generate plot figure to show table with a button to copy to clipboard
% USAGE
%   varargout = tablefigure(figtitle,headtext,intext);
% INPUT
%   figtitle  - figure title - this can be a cell array where the 
%               figtitle{1} is used for the figure title and figtitle{2} is
%               used for the hidden axes plot title
%   headtext  - descriptive text that preceeds table (figtitle used as default)  
%   intext - text to be edited
%   butdef    - cell array of control button text labels.
% OUTPUT
%   varargout: user defined output 
%      1: h_fig - handle to figure (handle can be used to modify layout)
%      2: h_pan - handle to panel
%      3: ht - handle to text box
% NOTES
%  
%    
% SEE ALSO
%   
%
% Author: Ian Townend
% CoastalSEA (c) Mar 2025
%--------------------------------------------------------------------------
%
    nrows = 20;              %number of lines in text box
    nlines = 3;              %number of lines/rows in header and footer
    
    %create figure with a panel
    [h_fig,h_tab] = setFigure(figtitle);    h_fig.Visible = 'on';  
    h_fig.CloseRequestFcn= @(src,evt)closeuicallback(src,evt);   
    tabpos = h_tab.Position;
    rowheight = tabpos(2)/(nrows+2*nlines);
    headfootsize = nlines*rowheight;
    %add panel
    h_pan = uipanel('Parent',h_tab,'Units','pixels','Tag','TextFig_panel');           
    %borders = h_pan.OuterPosition(3:4)-h_pan.InnerPosition(3:4);  

    %adjust panel dimensions to correct position on figure
    h_pan.Position(1) = rowheight/2;
    h_pan.Position(3) = h_tab.Position(3)-rowheight*0.9;
    h_pan.Position(2) = headfootsize;
    h_pan.Position(4) = h_tab.Position(4)-2*headfootsize;

    ht = uicontrol('Parent',h_pan,'Tag','TextFig','Max',2,'Style','edit',...
                   'String',intext,'HorizontalAlignment','left','FontSize',9);                 
    ht.Position = [1,1,548,262];            
    % Set vertical alignment (e.g., top, center, bottom)
%     jEdit = findjobj(ht);  %Forum function: https://uk.mathworks.com/matlabcentral/fileexchange/14317-findjobj-find-java-handles-of-matlab-graphic-objects
%     jEdit.setVerticalAlignment(javax.swing.JTextField.TOP);
    
    %add header text
    headerpos = h_pan.Position(4)+headfootsize;
    headpos = [rowheight/2 headerpos h_pan.Position(3) headfootsize*0.95];   
    statictextbox(h_tab,nlines,headpos,headtext);

    %Create push button to copy data to clipboard
    hb = setButton(h_tab,h_pan,rowheight,headfootsize,figtitle,{intext});      
    h_but = setControlButtons(butdef,h_fig,hb);

    h_fig.Visible = 'on';           %make figure visible
    h_fig.Units = 'normalized'; h_pan.Units = 'normalized'; 
    [h_but(:).Units] = deal('normalized');
    if nargout==1
        varargout{1} = h_fig; %handle to tablefigure
    elseif nargout==2
        varargout{1} = h_fig; %handle to tablefigure
        varargout{2} = h_but; %handle to control buttons
    elseif nargout==3 
        varargout{1} = h_fig; %handle to table figure
        varargout{2} = h_but; %handle to control buttons
        varargout{3} = ht;    %handle to text box
    end
end

%%
function [h_fig,h_tab] = setFigure(figtitle)
    %create figure - with tabs if figure handle used in call
    if ishandle(figtitle)
        h_fig = figtitle;                                %graphic handle
        h_tabgroup = findobj(h_fig,'Type','uitabgroup');
        if isempty(h_tabgroup)                           %no tabgroup
            h_tab = h_fig; 
            isatab = findobj(h_fig,'Type','uitab');     
            if ~isempty(isatab)                          %handle is a tab
                h_fig.Units = 'pixels';                  
            end
        else
            h_tab = h_tabgroup.SelectedTab;
            h_tab.Units = 'pixels';
        end
    else
        if iscell(figtitle) 
            figt = figtitle{1};    
        else
            figt = figtitle;
        end

        h_fig = figure('Name',figt,'Tag','TextFig',...
                       'NextPlot','add','MenuBar','none',...
                       'Resize','on','HandleVisibility','on', ...
                       'NumberTitle','off',...
                       'Visible','off'); %NB should be off when not debugging   
        h_fig.Units = 'pixels';       

        if iscell(figtitle) && length(figtitle)>1  %plot title included in input            
            title(figtitle{2},'FontSize',9);
            axis off
        end
        %move figure
        screen = get(0,'ScreenSize');
        hpos = (screen(3)-h_fig.Position(3))/4;  %offcentre to left
        if hpos<1, hpos = 1; end
        vpos = (screen(4)-h_fig.Position(4))/1.5;  %middle
        if vpos<1, hpos = 1; end
        h_fig.Position(1) = hpos;
        h_fig.Position(2) = vpos;
        h_tab = h_fig;
    end
end

%% 
function hb = setButton(h_tab,h_pan,rowheight,headfootsize,figtitle,tableout)
    %create action button to copy table data to clipboard
    if ishandle(figtitle)
        pos1 = h_pan.Position(3)+rowheight-100-rowheight/2;
    else
        pos1 = h_tab.Position(3)-100-rowheight/2;
    end
    position = [pos1 rowheight/2 100 headfootsize*0.6];%same units as figure
    hb = setactionbutton(h_tab,'Copy to clipboard',position,...
               @copydata2clip,'uicopy','Copy table content to clipboard',tableout);
end

%%
function hb = setControlButtons(butdef,hf,hcopy)
    %create buttons to control actions from text figure
    bpos = hcopy.Position;    
    bpos(3) = 50;
    pos1 = 15;
    offset = 60;
    nbut = length(butdef);
    hb = gobjects(1,nbut);
    for i=1:nbut
        bpos(1) = pos1+(i-1)*offset;
        hb(i) = uicontrol('Parent',hf,'Tag','UserButton',...
            'Style','pushbutton','String',butdef{i},...
            'Units','pixels', ...
            'Position', bpos,...
            'Callback', @(src,evt)setSelection(hf,src,evt));
    end
end

%%
function setSelection(hf,src,~)
    switch src.String
        case 'Quit'
            src.UserData = -1;    %cancel and close tablefigure
        case 'Save'
            src.UserData = 1;     %close tablefigure and resume
        otherwise
            src.UserData = 0;     %do nothing
    end
    uiresume(hf);
end

%%
function closeuicallback(src,~)
    %close callback function for tablefigureUIfig
    uiresume(src);
end