function output = tablefigureUI(figtitle,headtext,atable,isedit,butdef,figpos)
%
%-------function help------------------------------------------------------
% NAME
%   tablefigureUI.m
% PURPOSE
%   generate tablefigure and add buttons and controls to edit and return
%   updated table
% USAGE
%   h_fig = tablefigureUI(figtitle,headtext,tableout,isedit,butdef)  
%   e.g.   tablefigureUI('Title','Descriptive text',atable,true,butdef)
% INPUT
%   figtitle  - handle to figure/tab, or the figure title
%   headtext  - descriptive text that preceeds table (figtitle used as default)  
%   atable    - a table with rows and column names or cell array input
%               of row names. If rownames empty then numbered sequentially            
%   isedit    - flag to allow table cells to be edited - default is false
%   butdef    - struct for button definition but only butdef.Text used
%               cell array of text labels. Options are
%               Cancel to abort
%               Add to add a row to the table
%               Save, Close or any other text to return the current table
%   figpos    - position of figure on screen, [left,bottom] in normalized values (optional)
% OUTPUT
%   output    - table with same attributes as atable with any changes
%               made to data
% SEE ALSO
%   tablefigure.m and tabtablefigure.m. Used in muiEditUI
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2021
%--------------------------------------------------------------------------
%
    if nargin<6
        figpos = [];
    end
    
    h_fig = tablefigure(figtitle,headtext,atable);
    h_fig.CloseRequestFcn= @(src,evt)closeuicallback(src,evt);    
    if ~isempty(figpos)
        h_fig.Units = 'normalized';
        h_fig.Position(1:2) = figpos;      %user defined position for figure
        h_fig.Units = 'pixels';
    end
    
    ht = findobj(h_fig.Children,'Type','uitable');
    if isedit        
        ht.ColumnEditable = true;
        ht.ButtonDownFcn =  @(src,evt)delRow(src,evt);
    end
    %
    if nargin>4 && ~isempty(butdef)
        ok = 0;
        nbut = length(butdef.Text);
        hbut = findobj(h_fig.Children,'Tag','uicopy');
        hbut.Units = 'pixels';
        bpos = hbut.Position; 
        fpos = h_fig.Position;
        pos1 = fpos(3)-bpos(1)-bpos(3); %left/right margin width
        
        %set figure to minimum size if button defined        
        if fpos(3)<bpos(3)*(nbut+1)  
            h_fig.Position(3) = bpos(3)+bpos(3)*nbut*0.8 + pos1*(nbut+2);  
            copypos1 = h_fig.Position(3)-bpos(3)-pos1;
            hbut.Position(1) = copypos1;  %move copy button
        end
        %match buttons to size and position of Copy to Cliboard button       
        bpos(3) = bpos(3)*0.8;  %make width of additional buttons smaller
        offset = bpos(3)+pos1;
        
        %add control buttons to tablefigureUI
        hb = gobjects(1,nbut);
        for i=1:nbut
            bpos(1) = pos1+(i-1)*offset;
            hb(i) = uicontrol('Parent',h_fig,'Tag','UserButton',...
                'Style','pushbutton','String',butdef.Text{i},...
                'Units','pixels', ...
                'Position', bpos,...   
                'UserData',ok,...
                'Callback', @(src,evt)setSelection(h_fig,src,evt)); 
        end
        
        %resize panel text if panel wider than table
        htxt = findobj('Parent',h_fig,'Tag','statictextbox');
        hpan = findobj('Parent',h_fig,'Tag','TableFig_panel');
        if hpan.Position(3)>htxt.Position(3)
            htxt.Position(3)=hpan.Position(3);
            boxpos = htxt.Position;
            boxtext = sprintf('%s ',htxt.String{:});
            boxunits = htxt.Units;
            delete(htxt);
            statictextbox(h_fig,3,boxpos,boxtext,boxunits);
        end
        
        uiwait(h_fig)  
         
        %assign data from tablefigture to output table
        if any([hb(:).UserData]==1)
            rownames = atable.Properties.RowNames;
            varnames = atable.Properties.VariableNames;
            output = cell2table(ht.Data,'RowNames',rownames,...
                                        'VariableNames',varnames);
        else
            output = [];
        end
        delete(h_fig)
    else
        output = h_fig; %no control buttons so return figure handle
    end
end        
%%
function setSelection(h_fig,src,~)
    switch src.String
        case 'Cancel'
            src.UserData = -1;    %cancel and close tablefigure
        case 'Add'
            src.UserData = 0;     %do nothing
        otherwise
            src.UserData = 1;     %close tablefigure and resume
    end
    %
    if strcmp(src.String,'Add')
        addRow(h_fig);
    else
        uiresume(h_fig);
    end
end
%%
function closeuicallback(src,~)
    %close callback function for tablefigureUIfig
    uiresume(src);
end
%%
function addRow(h_fig)
    %add blank row to the table
    lobj = findobj(h_fig,'Tag','uitablefigure');
    temptable = cell2table(lobj.Data);
    temptable = [temptable;temptable(1,:)];

    for i=1:width(temptable)
        if iscell(temptable{end,i})
            %if cell, should be a character vector
            temptable{end,i}{1} = '';
        else
            %missing only works for numeric, datetime, categorical, string
            temptable{end,i} = missing;
        end
    end
    lobj.Data = table2cell(temptable);
    drawnow;
end
%%
function delRow(src,~)
    %delete row in tablefigureUI when mouse right button is clicked on
    %table. Make cell callback active to select row and call deleteRow
    src.CellSelectionCallback =  @(src,evt)deleteRow(src,evt);
    getdialog('Select row in table');
end
%%
function deleteRow(src,evt)
    %delete row selected using left mouse click to select a cell
    %then make cell selection call back inactive so that new right button
    %click required to re-activate
    selrow = evt.Indices(1);
    questxt = sprintf('Delete row %d',selrow);
    answer = questdlg(questxt,'Delete','Yes','No','No');
    if strcmp(answer,'Yes')
        src.Data(selrow,:) = [];
    end
    src.CellSelectionCallback = '';
end