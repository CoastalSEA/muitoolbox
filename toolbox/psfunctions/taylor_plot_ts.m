function ax = taylor_plot_ts(ax,stats,skill,metatxt)
%
%-------function help------------------------------------------------------
% NAME
%   taylor_plot_ts.m
% PURPOSE
%   Add a timeseries of test points to a Taylor diagram (reference point
%   is observed value at each time step)
% USAGE
%   ax = taylor_plot_ts(ax,stats,skill,metatxt);
% INPUTS
%   ax - axes of base plot for a Taylor diagraam (taylor_plot_figure.m)
%   stats - struct array of statistics needed for Taylor diagram
%   skill - instance of muiSkill_RunParams defining skill input parameters
%   metatxt - cell array of text names for plot UserData
% OUTPUT
%   ax - axes to plot of Taylor diagram
% NOTES
%   Taylor, K, 2001, Summarizing multiple aspects of model performance 
%   in a single diagram, JGR-Atmospheres, V106, D7. 
% SEE ALSO
%   Function plot_spectrum_model_skill.m in WaveRayModel
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2025
%--------------------------------------------------------------------------
%
    hold(ax,'on')
    nrec = numel(stats);
    %plot reference point
    useref = metatxt{1};
    polarplot(ax,pi/2,1,'+','LineWidth',2.0,'ButtonDownFcn',@godisplay,...
                    'DisplayName','Reference','Tag','0','UserData',useref);

    %unpack and normalize data to be plotted
    ndteststd = [stats(:).teststd]./[stats(:).refstd]; %normalised std
    ndcrmsd = [stats(:).crmsd]./[stats(:).refstd];     %normalised centred root mean square differences
    bias = [stats(:).testmean]-[stats(:).refmean];
    corrcoefs = [stats(:).corrcoef];
    corr = corrcoefs(2,1:2:end);                       %extact [2,1] value from square matrix
    acoscorr = asin(corr);                             %acos for trig angles, asin for compass angles
    %check statistcs
    %RMSD-sqrt(testSTD^2+refSTD^2-2*testSTD*refSTD*COR)=0    (NB:refSTD=1)
    check =  (ndcrmsd-sqrt(ndteststd.^2+1-2*ndteststd.*corr));
    
    %find centroid of points
    [N,Xedges,Yedges] = histcounts2(acoscorr,ndteststd);   %acoscorr,ndteststd
    [~,idi] = max(N, [],'all');
    [idx,idy] = ind2sub(size(N),idi);
    hist.x = (Xedges(idx)+Xedges(idx+1))/2;
    hist.y = (Yedges(idy)+Yedges(idy+1))/2;
    R = sin(hist.x); sig = hist.y;
    hist.score = 4*(1+R)^skill.n/((sig+1/sig)^2*(1+skill.Ro)^skill.n);
    hist.txt = sprintf('%d points: bias= %s; corr= %.3f; ndstd= %.3f with skill S.G= %1.3g',...
                                        nrec,'n/a',sin(hist.x),hist.y,hist.score);
    %add point to plot for sample means and text to match
    mn.ndteststd = mean(ndteststd,'All','omitnan');
    mn.corr = mean(corr,'All','omitnan');    
    mn.bias = mean(bias,'All','omitnan');
    mn.gskill = mean([stats(:).global],'All','omitnan');
    mn.acoscor = asin(mn.corr);
    mn.txt = sprintf('%d points: bias= %.3f; corr= %.3f; ndstd= %.3f with skill S.G= %1.3g',...
                            nrec,mn.bias,mn.corr,mn.ndteststd,mn.gskill);

    pltstats = table(ndteststd',ndcrmsd',bias',corr',acoscorr',check');
    pltstats.Properties.VariableNames = {'ndteststd','ndcrmsd','bias','corr','acoscorr','check'}; 

    if nrec<2000
        plotPoints(ax,pltstats,hist,mn,stats,skill)
    else
        ax = plotSurface(ax,pltstats,mn,metatxt,skill);
    end
end

%%
function plotPoints(ax,ps,hist,mn,stats,skill)
    %plot the data as individual markers
    nrec = numel(stats);
    for i=1:nrec
        %check statistcs are valid 
        if ps.check(i)>0.1
            warndlg('Statistics do not agree. Error in taylor_plot_ts');
            continue;
        end    
        datetxt = string(stats(i).date);
        %user data to construct table
        restxt = sprintf('%s: bias= %.3f; corr= %.3f; ndstd= %.3f with skill S.G= %1.3g',...
                              datetxt,ps.bias(i),ps.corr(i),ps.ndteststd(i),stats(i).global);
        if ~isempty(stats(i).local)
            if skill.iter
                itxt = 'for all cells';
            else
                itxt = 'with no overlaps';
            end
            usertxt = sprintf('%s; S.L= %1.3g (Ro=%1.2g, n=%1.1g, W=%d, %s)',...
                     restxt,stats(i).local,skill.Ro,skill.n,skill.W,itxt);
        else
            usertxt = restxt;
        end
        %add point to plot
        hp = polarplot(ax,ps.acoscorr(i),ps.ndteststd(i),'+','DisplayName',num2str(i),...           
                 'ButtonDownFcn',@godisplay,'Tag',num2str(i),'UserData',usertxt);
        hp.Annotation.LegendInformation.IconDisplayStyle = 'off';  
    end

    %plot peak of 2D histogram    
    hp = polarplot(ax,hist.x,hist.y,'o',...
                'LineWidth',2.0,'MarkerSize',6,...
                'DisplayName','Histogram centroid','ButtonDownFcn',@godisplay,...           
                'Tag','Histogram marker','UserData',hist.txt);
    hp.Annotation.LegendInformation.IconDisplayStyle = 'off';


    %plot mean value of all points    
    hp = polarplot(ax,mn.acoscor,mn.ndteststd,'x',...
                'LineWidth',2.0,'MarkerSize',10,...
                'DisplayName','Sample Mean','ButtonDownFcn',@godisplay,...           
                'Tag','Mean marker','UserData',mn.txt);
    hp.Annotation.LegendInformation.IconDisplayStyle = 'off'; 

    %add legend
    hold(ax,'off')
    legend(ax,'show','Location','northeastoutside');
        % %re-impose suppression of grid lines in the Taylor diagram plot
        % hp = findobj(figax,'Type','Line');
        % hgrd = findobj(hp,'Tag','RMSgrid'); 
        % hp = findobj(hp,'-not','Tag','RMSgrid'); 
        % newhp = vertcat(hp,hgrd(1)); 
    fprintf('Mode score %.3f; Mean score %.3f\n',hist.score,mn.gskill)
end

%%
function hax = plotSurface(ax,ps,mn,metatxt,skill)
    %plot the data as a histogram surface
    delete(ax.Parent) %cannot plot a surface on a polar plot
    hf = figure('Name','Taylor Diagram','Tag','StatFig', ...
        'Units','normalized','Resize','on','HandleVisibility','on');
    hax = axes(hf);  

    R = acos(ps.corr);           %acos for trig angles, 
    sig = ps.ndteststd;

    xx = sig.*cos(R);
    yy = sig.*sin(R);
    plot(hax,xx,yy,'xk','MarkerSize',0.5,'DisplayName','Data points');
    hold(hax,'on')

    %get the histogram data
    nint = round(log10(numel(xx)))*10;
    nbins = [nint,nint];
    xy = [xx,yy];
    [Z,XY] = hist3(xy,'Nbins',nbins);
    htrec = max(length(find(~isnan(yy))),length(find(~isnan(xx))));
    Z = Z/htrec*100;                       %percentage occurrence
    
    [zmx,idz] = max(Z,[],'all');
    [ihx,ihy] = ind2sub(size(Z),idz);
    
    sigmx = sqrt((XY{1}(ihx))^2+(XY{2}(ihy))^2); 
    Rmx = XY{1}(ihx)./sigmx;
    score = 4*(1+Rmx)^skill.n/((sigmx+1/sigmx)^2*(1+skill.Ro)^skill.n);
    txt = sprintf('%d points: bias= %s; corr= %.3f; ndstd= %.3f with skill S.G= %1.3g',...
                                       numel(yy),'n/a',Rmx,sigmx,score);

    ci = [0.02,0.05,0.1,0.2,0.5,0.8]*zmx;  %contour intervals
    contourf(hax,XY{1},XY{2},Z',ci,'FaceAlpha',0.75,'DisplayName','Histogram');    
    colormap(flipud(colormap('bone')));
    cb  = colorbar;
    cb.Label.String = 'Frequency (%)';
    xmax = ceil(max(sig)); if xmax>5, xmax = 5; end
    hax.XLim = [0,xmax];
    hax.YLim = hax.XLim;
    axis square
    
    % add the Correlation radii/arcs and RMSE semi-circles
    plotNSTDarcs(hax)
    plotRMSEcircles(hax)

    %plot reference point
    dgr = mcolor('green');
    plot(hax,1,0,'+','Color',dgr,...
              'LineWidth',2.0,'MarkerSize',10,'ButtonDownFcn',@godisplay,...
              'DisplayName','Reference','Tag','0','UserData',metatxt{1});

    %plot peak of 2D histogram   
    hxx = XY{1}(ihx);
    hyy = XY{2}(ihy);    
    plot(hax,hxx,hyy,'o',...
                'LineWidth',2.0,'MarkerSize',6,'Color','r',...
                'DisplayName','Histogram centroid','ButtonDownFcn',@godisplay,...           
                'Tag','Histogram marker','UserData',txt);

    %plot mean value of all points    
    mxx = mn.ndteststd*sin(mn.acoscor);
    myy = mn.ndteststd*cos(mn.acoscor);    
    plot(hax,mxx,myy,'x',...
                'LineWidth',2.0,'MarkerSize',10,'Color','b',...
                'DisplayName','Sample Mean','ButtonDownFcn',@godisplay,...           
                'Tag','Mean marker','UserData',mn.txt); 

    
    xlabel('Normalized Std. Dev.')
    ylabel('Normalized Std. Dev.')
    %add legend
    hold(hax,'off')
    legend(hax,'show','Location','northeastoutside');
        % %re-impose suppression of grid lines in the Taylor diagram plot
        % hp = findobj(figax,'Type','Line');
        % hgrd = findobj(hp,'Tag','RMSgrid'); 
        % hp = findobj(hp,'-not','Tag','RMSgrid'); 
        % newhp = vertcat(hp,hgrd(1)); 
    fprintf('Mode score %.3f; Mean score %.3f\n',score,mn.gskill)

end
%%
function plotRMSEcircles(ax)
    %plot normalised RMSE circles at 0.5 intervals
    R = 0.25:0.25:1.0;
    tau = 0:0.05:pi;
    for ii=1:4
        theta = atan((R(ii).*sin(tau))./(1+R(ii).*cos(tau)));
        tct = 2*cos(theta);
        fac = 4*(1-R(ii)^2);
        rad1 = (tct+sqrt(tct.^2-fac))/2;
        rad2 = (tct-sqrt(tct.^2-fac))/2;                
        [~,idrad] = min(rad1);
        rad = [rad1(1:idrad),rad2(idrad+1:end)];
        xx = rad.*sin((pi/2-theta));
        yy = rad.*cos((pi/2-theta));        
        hp = plot(ax,xx,yy,'--',...
            'LineWidth',0.4,'Color',[0.8 0.8 0.8],...
            'DisplayName','RMS error','Tag','RMSgrid');
        hp.Annotation.LegendInformation.IconDisplayStyle = 'off';

        text((pi/2-theta(10)),rad(10)-0.05,num2str(R(ii)),...
            'Color',[0.82 0.82 0.82]);
    end 
end
%%
function plotNSTDarcs(ax)
    %plot the polar arcs and radii
    nrad = floor(ax.XLim(2));
    ints = [0.2,0.4,0.6,0.8,0.9,0.92,0.94,0.96,0.98,0.99];
    theta = pi/2-(asin(ints));
    rad = [0,nrad];
    
    for i=1:numel(ints)
        xx = rad.*cos(theta(i));
        yy = rad.*sin(theta(i));
        hp = plot(ax,xx,yy,'LineWidth',0.4,'Color',[0.8 0.8 0.8],...
                                'DisplayName','nSTD','Tag','NSTDgrid');
        hp.Annotation.LegendInformation.IconDisplayStyle = 'off';

        text(xx(end),yy(end),num2str(ints(i)),'Color',[0.8 0.8 0.8]);           
    end

    ang = deg2rad(linspace(0,90,30));
    for j=1:nrad
        xx = j.*cos(ang);
        yy = j.*sin(ang);
        hp = plot(ax,xx,yy,'LineWidth',0.4,'Color',[0.8 0.8 0.8],...
                                'DisplayName','nSTD','Tag','NSTDgrid');
        hp.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    tend = (nrad+0.5)*0.71;
    text(tend,tend,'Correlation Coefficient','Color',[0.8 0.8 0.8],...
        'HorizontalAlignment','center','Rotation',-45);  
end