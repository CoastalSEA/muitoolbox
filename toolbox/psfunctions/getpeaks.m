function [idpks,options] = getpeaks(ts)
%
%-------function help------------------------------------------------------
% NAME
%   getpeaks.m
% PURPOSE
%   Find peak in a timeseries with options to adjust threshold, 
%   method of selection and interval between peaks
% USAGE
%   [idpks,options] = getpeaks(ts)
%INPUT
%   ts - timeseries or dstable dataset
%OUTPUT
%   idpks - array containing indices of peaks
%   options - defines parameters used for cluster selection:
%       Threshold for peaks,
%       Selection method, 
%       Time between peaks (hours)
% SEE ALSO
% peaksoverthreshold.m, peakseek.m, acceptfigure.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%----------------------------------------------------------------------
%
    idpks = []; options = [];
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
    %plot time series
    figtitle = sprintf('Peaks plot for %s',figtxt);
    promptxt = 'Accept peaks definition';
    [h_plt,h_but] = acceptfigure(figtitle,promptxt,'StatFig');
    axes(h_plt);
    %wave height
    plot(mdate,data);
    xlabel('Date');
    ylabel(ytxt);

    %prompt user for input values
    prompt = {'Threshold for peaks:','Selection method', ...
                                        'Time between peaks (hours)'};
    title = 'Peak Selection';
    numlines = 1;
    default = {num2str(mean(data,'omitnan')+2*std(data,'omitnan')),...
                                            num2str(3),num2str(18)};
    %loop while selection is made
    h2 = []; h3 = [];
    ok = 0;
    while ok<1
        answer = inputdlg(prompt,title,numlines,default);
        if isempty(answer), return; end

        threshold = str2double(answer{1});   %wave height threshold
        method = str2double(answer{2});      %peak selection method (see peaksoverthreshold.m)
        tint = str2double(answer{3}); %time interval between independent peaks
        % find peaks (method 1:all peaks; 2:independent crossings; 3:timing
        % seperation of tint)
        returnflag = 0; %0:returns indices of peaks; 1:returns values
        idpks = peaksoverthreshold(data,threshold,method,...
            mdate,hours(tint),returnflag);
        if isempty(idpks)
            warndlg('No peaks selected. Try lower threshold');
            pause(3);
        else
            %produce plot of selected peaks
            delete(h2)
            delete(h3)
            hold on
            h2 = plot([mdate(1),mdate(end)],[threshold,threshold],'-.r');
            h3 = plot(mdate(idpks),data(idpks),'xr');
            hold off
            waitfor(h_but,'Tag');
            if ~ishandle(h_but)   %this handles the user deleting figure window
                return;
            elseif strcmp(h_but.Tag,'Yes')
                ok=1;
                panelText(h_but,threshold,method,tint);
            else
                default{1} = num2str(threshold);
                default{2} = num2str(method);
                default{3} = num2str(tint);
                h_but.Tag = '';
            end
        end                
    end
    options = struct('threshold',threshold,'method',method,'tint',tint);
end
%%
function panelText(h_but,threshold,method,tint)
    %set text to display selected parameters
    hbyn = findobj(h_but,'Tag','YesNo');
    delete(hbyn)
    h_but.Title = 'Selected parameters';
    txt1 = sprintf('Threshold for peaks = %g',threshold);
    txt2 = sprintf('Selection method = %g',method);
    txt3 = sprintf('Time between peaks = %g hours',tint);
    selparams = sprintf('%s %s %s',txt1,txt2,txt3);            
    uicontrol('Parent',h_but,'Tag','YesNo',...
              'Style', 'text', 'String', selparams,...
              'Units','normalized', ...
              'Position', [0.01 0.01 0.99 0.8]); 
end