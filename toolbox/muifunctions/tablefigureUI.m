function output = tablefigureUI(figtitle,headtext,atable,isedit,butdef,...
                                                              figpos)
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
%               if figure title option this can be a cell array where the 
%               figtitle{1} is used for the figure title and figtitle{2} is
%               used for the hidden axes plot title
%   headtext  - descriptive text that preceeds table (figtitle used as default)  
%   atable    - a table with rows and column names           
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
    
    [hf,hp,ht] = tablefigure(figtitle,headtext,atable);
    hf.CloseRequestFcn= @(src,evt)closeuicallback(src,evt);    
    if ~isempty(figpos)
        hf.Units = 'normalized';
        hf.Position(1:2) = figpos;      %user defined position for figure
        hf.Units = 'pixels';
    end

    %
    if nargin>4 && ~isempty(butdef)
        ok = 0;
        nbut = length(butdef.Text);
        hbut = findobj(hf.Children,'Tag','uicopy');
        hbut.Units = 'pixels';
        bpos = hbut.Position; 
        fpos = hf.Position;
        pos1 = fpos(3)-bpos(1)-bpos(3); %left/right margin width
        
        %set figure to minimum size if button defined        
        if fpos(3)<bpos(3)*(nbut+1)  
            hf.Position(3) = bpos(3)+bpos(3)*nbut*0.8 + pos1*(nbut+2);  
            copypos1 = hf.Position(3)-bpos(3)-pos1;
            hbut.Position(1) = copypos1;  %move copy button
        end
        %match buttons to size and position of Copy to Cliboard button       
        bpos(3) = bpos(3)*0.8;  %make width of additional buttons smaller
        offset = bpos(3)+pos1;
        
        %resize panel text if panel wider than table
        hm = findobj('Parent',hf,'Tag','statictextbox');
        if hp.Position(3)>hm.Position(3)
            hm.Position(3)=hp.Position(3);
            boxpos = hm.Position;
            boxtext = sprintf('%s ',hm.String{:});
            boxunits = hm.Units;
            delete(hm);
            hm = statictextbox(hf,3,boxpos,boxtext,boxunits);
        end

        %handle to table components (does NOT include buttons)
        hf.UserData = atable;
        hands = struct('hf',hf','hp',hp,'ht',ht,'hm',hm); 
        if isedit        
            ht.ColumnEditable = true;
            ht.ButtonDownFcn =  @(src,evt)delRowCol(hands,src,evt);
        end

        %add control buttons to tablefigureUI
        hb = gobjects(1,nbut);
        for i=1:nbut
            bpos(1) = pos1+(i-1)*offset;
            hb(i) = uicontrol('Parent',hf,'Tag','UserButton',...
                'Style','pushbutton','String',butdef.Text{i},...
                'Units','pixels', ...
                'Position', bpos,...   
                'UserData',ok,...
                'Callback', @(src,evt)setSelection(hands,src,evt)); 
        end
        
        uiwait(hf)  
         
        %assign data from tablefigure to output table
        if any([hb(:).UserData]==1)
            atable = hands.hf.UserData;
            if isa(atable,'dstable')
                rownames = atable.DataTable.Properties.RowNames; %strings
                varnames = atable.VariableNames;
            else
                rownames = atable.Properties.RowNames;
                varnames = atable.Properties.VariableNames;
            end
            output = cell2table(hands.ht.Data,'RowNames',rownames,...
                                        'VariableNames',varnames);

            if isa(atable,'dstable')
                varnames = atable.VariableNames;
                for i=1:width(output)
                    atable.DataTable.(varnames{i}) = output.(varnames{i});
                end
                output = atable;
            end
        else
            output = [];
        end
        delete(hf)
    else
        output = hf; %no control buttons so return figure handle
    end
end

%%
function setSelection(hands,src,~)
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
        answer = questdlg('Delete Row or Column?','Edit table','Row','Column','Quit','Row');
        if strcmp(answer,'Row')      
            addRow(hands);
        elseif strcmp(answer,'Column')
            addCol(hands);
        end
        % src.Callback = @(src,evt)setSelection(hands,src,evt); %update hands in callback
    else
        uiresume(hands.hf);
    end
end

%%
function closeuicallback(src,~)
    %close callback function for tablefigureUIfig
    uiresume(src);
end

%%
function hds = addRow(hds)
    %add blank row to the table - hds struct contains handles: hf-figure;
    %hp-panel; ht-table; and hm-panel text
    temptable = cell2table(hds.ht.Data);
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

    nrows = height(temptable);
    if ~isempty(hds.ht.RowName)
        %get user to add rowname if in use
        if strcmp(hds.ht.RowName{1},'1')
            inp{1} = num2str(nrows);
        else
            default = {sprintf('RowName %d',nrows)};
            inp = inputdlg('Set row name:','Edit table',1,default);
            if isempty(inp), inp = ''; end
        end
        hds.ht.RowName{nrows} = inp{1};
    end
    hds.ht.Data = table2cell(temptable);
    atable = hds.hf.UserData;
    if isa(atable,'dstable')
        hds.hf.UserData = addrows(atable,inp,temptable(end,:));
    else
        hds.hf.UserData = hds.hf.UserData; %still to do *************************
    end

    %adjust size of figure
    hds.ht.Units = 'pixels'; hds.hp.Units = 'pixels'; hds.hm.Units = 'pixels';
    tableheight = hds.ht.Position(4);
    rowheight = hds.ht.Position(4)/(nrows+1);  %offset for header and footer is 2 but nrow already has added row
    newheight = tableheight+rowheight;    %add a row to height
    delheight = (newheight-tableheight);
    hds.ht.Position(4) = newheight;
    hds.hf.Position(4) = hds.hf.Position(4)+delheight;%adjust figure height    
    hds.hp.Position(4) = hds.hp.Position(4)+delheight;%adjust panel height    
    hds.hm.Position(2) = hds.hm.Position(2)+delheight;%adjust panel text vertical position  
    hds.ht.Units = 'normalized'; hds.hp.Units = 'normalized'; hds.hm.Units = 'normalized';
    drawnow;
end

%%
function hds = addCol(hds)
    %add column to table - hds struct contains handles: hf-figure;
    %hp-panel; ht-table; and hm-panel text
    temptable = cell2table(hds.ht.Data);
    
    ncols = width(temptable);
    default = {sprintf('Var%d',ncols+1)};
    varname = inputdlg('Set variable name:','Edit table',1,default);
    if isempty(varname), varname = default; end

    answer = questdlg('Text or Numeric?','Edit table','Text','Numeric','Text');
    nrows = height(temptable);
    if strcmp(answer,'Text')
        %if cell, should be a character vector
        newvar = repmat({''},nrows,1);
    else
        %missing only works for numeric, datetime, categorical, string
        newvar = NaN(nrows,1);
    end
    temptable = addvars(temptable,newvar,'NewVariableNames',varname);
    atable = hds.hf.UserData;
    hds.hf.UserData = addvars(atable,newvar,'NewVariableNames',varname);
    hds.ht.Data = table2cell(temptable);
    hds.ht.ColumnName{ncols+1} = varname{1}; 
end

%%
function delRowCol(hds,src,~)
    %delete row in tablefigureUI when mouse right button is clicked on
    %table. Make cell callback active to select row and call deleteRow 
    % hds is handles struct: hf-figure; hp-panel; ht-table; and hm-panel text
    answer = questdlg('Delete Row or Column?','Edit table','Row','Column','Quit','Row');
    if strcmp(answer,'Row')
        src.CellSelectionCallback =  @(src,evt)deleteRow(hds,src,evt);
        getdialog('Select row in table');
    elseif strcmp(answer,'Column')
        src.CellSelectionCallback =  @(src,evt)deleteCol(hds,src,evt);
        getdialog('Select column in table');
    else
        src.CellSelectionCallback =  '';
    end
end

%%
function deleteRow(hds,src,evt)
    %delete row selected using left mouse click to select a cell
    %then make cell selection call back inactive so that new right button
    %click required to re-activate
    % hds is handles struct: hf-figure; hp-panel; ht-table; and hm-panel text
    selrow = evt.Indices(1);
    src.CellSelectionCallback = '';  %prevent a callback loop when deleteing from table
    rowname =  hds.ht.RowName{selrow};
    questxt = sprintf('Delete row %s',rowname);
    answer = questdlg(questxt,'Delete','Yes','No','No');
    if strcmp(answer,'No'), return; end
    
    hds.ht.RowName(selrow) = [];
    hds.ht.Data(selrow,:) = [];
    atable = hds.hf.UserData;
    if isa(atable,'dstable')
        hds.hf.UserData = removerows(atable,selrow);
    else
        hds.hf.UserData = hds.hf.UserData; %still to do *************************
    end

    %adjust size of figure 
    hds.ht.Units = 'pixels'; hds.hp.Units = 'pixels'; hds.hm.Units = 'pixels';
    nrows = size(hds.ht.Data,1);
    tableheight = hds.ht.Position(4);  
    rowheight = hds.ht.Position(4)/(nrows+3);  %offset for header and footer is 2
    newheight = tableheight-rowheight;    %add a row to height
    hds.ht.Position(4) = newheight;
    delheight = (tableheight-newheight);
    hds.hf.Position(4) = hds.hf.Position(4)-delheight;%adjust figure height 
    hds.hp.Position(4) = hds.hp.Position(4)-delheight;%adjust panel height   
    hds.hm.Position(2) = hds.hm.Position(2)-delheight;%adjust panel text vertical position   
    hds.ht.Units = 'normalized'; hds.hp.Units = 'normalized'; hds.hm.Units = 'normalized';   
    drawnow
end

%%
function deleteCol(hds,src,evt)
    %delete column selected using left mouse click to select a cell
    %then make cell selection call back inactive so that new right button
    %click required to re-activate
    % hds is handles struct: hf-figure; hp-panel; ht-table; and hm-panel text
    selcol= evt.Indices(2);
    src.CellSelectionCallback = '';  %prevent a callback loop when deleteing from table
    colname = hds.ht.ColumnName{selcol};
    questxt = sprintf('Delete column %s',colname);
    answer = questdlg(questxt,'Delete','Yes','No','No');
    if strcmp(answer,'No'), return; end
    
    varname = hds.ht.ColumnName(selcol);
    hds.ht.ColumnName(selcol) = [];
    hds.ht.Data(:,selcol) = [];
    hds.hf.UserData = removevars(hds.hf.UserData,varname);
    %adjust size of figure - not needed?    
    drawnow  
end