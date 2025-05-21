function res = phaseplot(x,y,t,labels)
%
%-------function help------------------------------------------------------
% NAME
%   phaseplot.m
% PURPOSE
%   variation of x and y with time. e.g. centroid of beach profiles or 
%   recursive plots such as x = x(t) v  y = x(t+1)  
% USAGE
%   res = phaseplot(x,y,t,labels)
% INPUTS
%   x - value to be plotted on x-axis e.g. x-centroid
%   y - value to be plotted on y-axis e.g. z-centroid
%   t - time cell array of date strings used as a time stamp (can be empty)
%   labels - struct containing:   (optional)
%       title - plot title text
%       xlabel  - label for x-axis
%       ylabel  - label for y-axis
% OUTPUT
%   line plot of (x,y) points over time
%   res - dummy text so that function can be called from Derive Output UI
% SEE ALSO
%   recursive_plot.m to plot x v x+nint
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
    res = 'no output'; %null ouput required for exit in muiUserModel.setEqnData
    %check input includes labels
    template = struct('title','Phase plot','xlabel','Xvar',...
             'ylabel','Yvar','tformat','dd-mm-yyyy','pname','Data points');
    if nargin<3
        t = []; labels = template;
    elseif nargin<4 || isempty(labels)
        labels = template;
    end
    
    if isdatetime(t) %pass formated date strings to plots
        t = cellstr(t,'dd-MM-yyyy');
    end
    
    %create figure and axes
    h_f = figure('Name','Results Plot','Units','normalized',...                
                'Resize','on','HandleVisibility','on','Tag','PlotFig');
    %move figure to top right
    h_f.Position(1) = 1-h_f.Position(3)-0.01;
    h_f.Position(2) = 1-h_f.Position(4)-0.12;    
    h_ax = axes('Parent',h_f,'Tag','PlotFigAxes');  
    hold(h_ax,'on')
    
    %prompt user to select plot type
    if isempty(t)
        answer = 'Numbered';
    else
        answer = questdlg('Select type of plot','Centroid plot',...
                                    'Numbered','Time stamped','Time stamped');
    end
    %
    if strcmp(answer,'Numbered')
        XYplot(h_ax,x,y,labels.pname);
    else
        XYTplot(h_ax,x,y,t,labels.pname);
        labels.title =sprintf('%s (date format %s)',labels.title,labels.tformat);
    end

    %find first and last valid point (only checks x)
    idx = find(~isnan(x));       
    st = idx(1);
    nd = idx(end);

    plot(h_ax,x(st),y(st),'or','LineWidth',1.1,'MarkerSize',8,'DisplayName','Start')
    plot(h_ax,x(nd),y(nd),'+r','LineWidth',1.1,'MarkerSize',8,'DisplayName','End')
    xlabel(labels.xlabel)
    ylabel(labels.ylabel)
    title(labels.title);
    legend('Location','best')
    hold(h_ax,'off')        
end
%%
function XYplot(figax,x,y,pname)  
    %plot centroid time series with simple numeric (order) labels
    plot(figax,x,y,'.-','MarkerSize',8,'DisplayName',pname,'Tag','1');    
    nint = 2;
    txtnum = nint:nint:length(x);
    txt = num2str(txtnum');
    text(x(txtnum),y(txtnum),txt,'FontSize',8)
    XYaxislimits(x,y)    
end
%%
function ok = XYTplot(figax,x,y,tlist,pname)
    %select sub-sets of data to plot centroid as a time vector
    nrec = length(tlist);
    ok = 1;
    button = 'Reject';
    pstring = sprintf('User cancelled\nUse Ctrl for multiple selections\nAccept with default selection if no intervals required');
    while strcmp(button,'Reject')    %user selects date intervals
        [h_dlg,ok] = listdlg('Name','Centroid date intervals', ...
                        'PromptString','Select dates for intervals', ...
                        'SelectionMode','multiple', ...
                        'ListString',tlist);
        if ok<1, msgbox(pstring); return; end
        qstring = 'Dates selected:';
        nint = length(h_dlg);
            if nint<20
            for i=1:nint
                qstring = sprintf('%s\n%s',qstring,tlist{h_dlg(i),:});
            end
            else 
                qstring = sprintf('%d dates selected',nint);
            end
            button = questdlg(qstring,'Date selection',...
                'Accept','Reject','Accept');
    end
    %user defines the number of points between date markers
    val = inputdlg('Marker interval (0 for defined intervals):','Centroid plot',1,{'0'});
            if isempty(val), ok=0; return; end
    
    if nint<2 && h_dlg==1  %no intervals, date markers at specified interval
        hp = plot(figax,x,y,'.-','MarkerSize',8,...
                                'DisplayName',pname,'Tag','1');
        txtnum = [1,nrec];
    else                   %intervals plotted and labelled with markers
        if h_dlg(1)~=1     %add start and end dates
            h_dlg = [1,h_dlg];
        end
        if h_dlg(end)~=nrec
            h_dlg = [h_dlg,nrec];
        end
        %
        for j=1:length(h_dlg)-1
            st = h_dlg(j);
            ed = h_dlg(j+1);
            hp = plot(figax,x(st:ed),y(st:ed),'.-','MarkerSize',8,...
                        'DisplayName',pname,'Tag','1');
            if j>1
                set(get(get(hp,'Annotation'),'LegendInformation'),...
                                                'IconDisplayStyle','off'); 
            end                    
        end
        txtnum = h_dlg;
    end
    % add date markers
    if ~strcmp(val,'0')
        nint = str2double(val);        
        txtnum = [1,nint:nint:nrec];        
    end
    text(x(txtnum),y(txtnum),tlist(txtnum,:),'FontSize',8)
    XYaxislimits(x,y)
end
%%
function XYaxislimits(x,y)
    %set the limits of the x and y axes to be symmetric
    mxxy = max([x;y])+0.01; 
    mnxy = min([x;y])-0.01;
    %user defines the maximum range for both axes (force to be the same)
    val = inputdlg({'Min axis range:';'Max axis range:'},'Centroid plot',1,...
        {num2str(mnxy),num2str(mxxy)});
    if isempty(val)
        return;
    else
        mnxy = str2double(val{1}); 
        mxxy = str2double(val{2});
    end
    xlim([mnxy,mxxy]);
    ylim([mnxy,mxxy]);  
end