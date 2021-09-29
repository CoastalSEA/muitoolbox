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
%   figpos    - position offigure on screen, [left,bottom] in normalized values (optional)
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

        uiwait(h_fig)  
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
    %
    lobj = findobj(h_fig,'Tag','uitablefigure');
    temptable = cell2table(lobj.Data);
    temptable = [temptable;temptable(1,:)];
    temptable{end,:} = missing;
    lobj.Data = table2cell(temptable);
%     [nrow,ncol] = size(lobj.Data);
%     if iscell(lobj.Data)
%         newrow = repmat({''},[1,ncol]);
%     else
%         newrow = zeros(1,ncol);
%     end
%     lobj.Data(nrow+1,:) = newrow;
    drawnow;
end