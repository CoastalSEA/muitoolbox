function [idcls,options] = getclusters(ts,options)
%
%-------function help------------------------------------------------------
% NAME
%   getclusters.m
% PURPOSE
%   Identify cluster in a timeseries with options to adjust threshold, 
%   method of selection and interval between clusters
% USAGE
%   [idcls,options] = getclusters(ts)
%INPUT
%   ts - timeseries or dstable dataset
%   options - defines initial parameters used for cluster selection:
%               Threshold for peaks, 
%               Selection method, 
%               Time between peaks (hours),
%               Cluster time interval (days).
%OUTPUT
%   idcls - structure ('date','pks') containing values, the date of the 
%         cluster and the values of peaks within each cluster  
%   options - defines parameters used for cluster selection:
%               Threshold for peaks, 
%               Selection method, 
%               Time between peaks (hours),
%               Cluster time interval (days).
% SEE ALSO
%   used in muiStats and wrm_transport_plots
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%----------------------------------------------------------------------
%   
    idcls = []; 
    if nargin<2 || isempty(options)
        default = {num2str(mean(data,'omitnan')+2*std(data,'omitnan')),...
                                    num2str(3),num2str(18),num2str(15)};
    else
        default{1} = num2str(options.threshold);
        default{2} = num2str(options.method);
        default{3} = num2str(options.tint);
        default{4} = num2str(options.clint);
    end

    if isa(ts,'timeseries')
        mdate = datetime(getabstime(ts));
        data = ts.Data;
        ytxt = ts.UserData.Labels;
        figtxt = ts.Name;
    elseif isa(ts,'dstable')
        mdate = ts.RowNames;
        data = ts.(ts.VariableNames{1});
        ytxt = ts.VariableLabels{1};
        figtxt = ts.VariableNames{1};
    else
        warndlg('Data format not recognised in getpeaks')
        return;
    end
    %get plot figure with yes/no accept buttons
    figtitle = sprintf('Peaks plot for %s',figtxt);
    promptxt = 'Accept cluster definition';
    [h_plt,h_but] = acceptfigure(figtitle,promptxt,'StatFig');
    h_ax = axes(h_plt);
    plot(h_ax,mdate,data);
    xlabel('Date');
    ylabel(ytxt);
    
    prompt = {'Threshold for peaks:','Selection method (1-4)', ...
        'Time between peaks (hours)','Time between clusters (days)'};
    title = 'Cluster Statistics';
    numlines = 1;
    
    ok=0;
    while ok<1
        answer = inputdlg(prompt,title,numlines,default);
        if isempty(answer), return; end

        threshold = str2double(answer{1}); %variable threshold
        method = str2double(answer{2});    %peak selection method (see peaks.m)
        tint = str2double(answer{3});      %time interval between independent peaks
        clint = str2double(answer{4});     %time interval for clusters

        % find peaks (method 1:all peaks; 2:independent crossings; 3:timing
        % seperation of tint)
        returnflag = 0; %0:returns indices of peaks; 1:returns values       
        idpks = peaksoverthreshold(data,threshold,method,...
            mdate,hours(tint),returnflag);

        % find clusters based on results from peak selection
        pk_date = mdate(idpks);    %datetime of peak
        pk_vals = data(idpks);     %value of peak
        idcls = clusters(pk_date,pk_vals,days(clint));

        if isempty(idcls(1).pks)
            warndlg('No peaks selected. Try lower threshold');
            pause(3);
        else
            h_ax = clusterPlot(mdate,idcls,threshold,h_ax);
            waitfor(h_but,'Tag');
            if ~ishandle(h_but)   %this handles the user deleting figure window
                return;
            elseif strcmp(h_but.Tag,'Yes')
                ok=1;
                panelText(h_but,threshold,method,tint,clint) 
            else
                default{1} = num2str(threshold);
                default{2} = num2str(method);
                default{3} = num2str(tint);
                default{4} = num2str(clint);
                h_but.Tag = '';
            end
        end
    end
    options = struct('threshold',threshold,'method',method,...
        'tint',tint,'clint',clint);
end
%%       
function h_ax = clusterPlot(mdate,idcls,threshold,h_ax)
    %plot clusters with different symbol for each cluster
    symb = ['o','+','*','.','x','s','d','^','v','<','>','p','h'];
    nsymb = length(symb)-1;
    ncls = length(idcls); % number of clusters
    
    % delete any existing threshold or cluster symbols
    h_pts = findobj(h_ax,'Tag','Cluster');
    delete(h_pts)
    % plot threshold and selected subset of data    
    hold on
    plot(h_ax,[mdate(1),mdate(end)],[threshold,threshold],'-.r','Tag','Cluster'); 
    % plot(mdate(idp),h_rms(idp),'xr');
    for ij = 1:ncls
        plot(h_ax,idcls(ij).date,idcls(ij).pks,symb(mod(ij,nsymb)+1),'Tag','Cluster');
    end
    hold off
end
%%
function panelText(h_but,threshold,method,tint,clint)
    %set text to display selected parameters
    hbyn = findobj(h_but,'Tag','YesNo');
    delete(hbyn)
    h_but.Title = 'Selected parameters';
    txt1 = sprintf('Threshold for peaks = %g',threshold);
    txt2 = sprintf('Selection method = %g',method);
    txt3 = sprintf('Time between peaks = %g hours',tint);
    txt4 = sprintf('Cluster time interval = %g days',clint);
    selparams = sprintf('%s %s %s %s',txt1,txt2,txt3,txt4);            
    uicontrol('Parent',h_but,'Tag','YesNo',...
              'Style', 'text', 'String', selparams,...
              'Units','normalized', ...
              'Position', [0.01 0.01 0.99 0.8]); 
end