function [zp,paramEsts,parmci] = mgpdfit(tspks,u,RecDur,varargin)
%
%-------function help------------------------------------------------------
% NAME
%   mgpdfit.m
% PURPOSE
%   Maximum likelihood estimate of the fit parameters for a GPD and compute 
%   return period estimates and confidence intervals (user prompt for plotted output).
% USAGE
%   [zp,paramEsts,parmci] = mgpdfit(tspks,u,RecDur,varargin)
% INPUTS
%   tspks  - full time series or peaks over threshold vector (detrended and iid)
%   u      - chosen threshold
%   RecDur - duration of record (in years)
% Additional variables called as Name,Value pairs:
%   NumRec   = total number of records from which peaks were selected
%             (if empty the length of tspks is used assuming this is full
%              time series)
%   FigType = 'N' - no figures, or  (default value)
%             'H' - Haigh figure, or 
%             'C' - Coles (2001) figure
%   VarName - variable name for inclusion on plots (default = 'Variable') 
% OUTPUT
%   zp - 4-col array: return period, lower confidence limit, estimate,
%                     upper confidence limit
%   paramEsts - parameter estimates for the GPD fit. parmEsts(1) is the 
%   tail index (shape) parameter, k and parmEsts(2) is the scale parameter,
%   sigma
%   parmci - 95% confidence intervals for the GPD parameter estimates
% NOTES
%   Requires the Matlab Statistics and Machine Learning Toolbox
% EXAMPLES
%   Call passing just the peak values and defining nrec
%       [zp,paramEsts,parmci] = mgpdfit(tsData(idpks),u,RecDur,...
%                'NumRec',nrec,'FigType',fig,'VarName',varname);
%   Call passing full timeseries as TS, threshold and record duration only
%       [zp,paramEsts,parmci] = mgpdfit(TS,u,RecDur);     
%
% Ivan Haigh - March 2007
%--------------------------------------------------------------------------
% Modified to work within CoastalTools where peaks are passed to function
%--------------------------------------------------------------------------
%
inp.NumRec = [];
inp.FigType = 'N';
inp.VarName = 'Variable';
% Check input
if nargin>3
    %assign additional variables based on user supplied properties
    for k=1:2:length(varargin)
        inp.(varargin{k}) = varargin{k+1};
    end
end
 
if isempty(inp.NumRec)
    inp.NumRec = length(tspks);  %assumes that tspks is full time series
end

NumRec = inp.NumRec; FigType = inp.FigType; VarName=inp.VarName;

%% Step 1: GP fit using Maximum likelihood
y = tspks(tspks>u); %in CoastalTools tspks are >u so this just assigns to y

[paramEsts,parmci] = gpfit(y-u);

%Mean and Variance
% [Mm,Vv] = gpstat(paramEsts);

%Negative log likelihood and variance-covariance matrix of (mu, sigma, k)
[NLOGN,ACOV] = gplike(paramEsts,y-u);

%Calculate standard errors
paramSEs = sqrt(diag(ACOV))';
%------------------------------

%% Step 2: Return Levels and Confidence Intervals (for plot);

%Return priods for which the return levels will be obtained
RP = [0.4:0.1:0.9 1 2 5 10 20 50 100 250 1000];

numrecsperyear = NumRec/RecDur;
numpeaks = length(y);
apeakprob = numpeaks/NumRec;
numpeaksperyear = numpeaks/RecDur;

la = apeakprob;
m = RP*numrecsperyear;
P = 1./(m*la);
%RETURN LEVELS
%Could use following equation:
%zp = u + ( paramEsts(2)./paramEsts(1) )*((m*(length(y)/length(DD))).^paramEsts(1) -1)
%but matlab function is available for task
zp(:,1) = RP;
zp(:,3) = gpinv(1-P,paramEsts(1),paramEsts(2),u);
%zp(:,3) = u + (paramEsts(2).*((P).^(-paramEsts(1)) - 1))./paramEsts(1);     %ismev - gpdq
%zp(:,3) = u + (paramEsts(2) .* ((m .* la).^(paramEsts(1)) - 1))./paramEsts(1); %isemv - gpdg2


%CONFINDENCE INTERVAL
%The approach used here is taken from Coles (2001) page 56 - the Delta
%method

%Matlab returns the opposite covarinace matrix
V(1,:) = [la*(1 - la)./NumRec 0 0];

V(2,:) = [0 ACOV(2,2) ACOV(2,1)];
V(3,:) = [0 ACOV(1,2) ACOV(1,1)];

a = paramEsts(2).*m.^paramEsts(1).*la.^(paramEsts(1)-1);
b = (paramEsts(1).^(-1)).*((m.*la).^paramEsts(1) - 1);
c = (-paramEsts(2).*paramEsts(1).^(-2))*(((m*la).^paramEsts(1))-1) + ... 
    (paramEsts(2).*paramEsts(1).^(-1)).*((m.*la).^paramEsts(1)).*(log(m*la));

%Loop through each chosen return period and find corresponding delta method
for i = 1:length(P)
    A = [a(i),b(i),c(i)];   %transpose (hence ; instead of ,)
    B = [a(i);b(i);c(i)];
    VV(i) = A*V*B;          %Delta method: Car(zp) ~ GRAD(zp)'*V*GRAD(zp)
    clear A B
end

%Confidence limit
zp(:,2) = zp(:,3) - 1.96.*sqrt(VV');
zp(:,4) = zp(:,3) + 1.96.*sqrt(VV');
%------------------------------

%% Step 3: Empirical Model

%Information on the Empirical model is found in Coles(2001) page 43
P_em = [1:length(y)]/(length(y)+1);

%Calculate inverse GEV for empirical model
zp_em = gpinv(P_em,paramEsts(1),paramEsts(2),u);
%zp_em = u + (paramEsts(2).*((1-P_em).^(-paramEsts(1)) - 1))./paramEsts(1);     %ismev - gpdq

%Calculate GEV model for data points
P_data = gpcdf(sort(y),paramEsts(1),paramEsts(2),u);
%P_data = 1 - (1 + (paramEsts(1).*(sort(y) - u))./paramEsts(2)).^(-1./paramEsts(1))     %ismev - gpdf
%------------------------------


%% Step 4: Plot Data
switch FigType
    case 'N'        
        %No Figure
    case 'C'  %All four output plots
        figure('Name','Extremes plot',...
            'units','normalized','position',[0.2 0.2 0.6 0.6],...
            'Tag','StatFig');
        A1 = axes('units', 'normalized', 'position', [0.07    0.56    0.4    0.39]);
        plot(P_em,P_data, 'ok', 'markersize',3,'markerfacecolor','r');
        hold on
        plot([-0.02 1.02],[-0.02 1.02], 'k','linewidth',1)
        grid on
        xlabel('Empirical');
        ylabel('Model');
        title('Probability plot','fontweight','bold');

        A2 = axes('units', 'normalized', 'position', [0.57    0.56    0.4    0.39]);
        plot(zp_em,sort(y), 'ok', 'markersize',3,'markerfacecolor','r');
        hold on
        plot([0:max(y)+10],[0:max(y)+10], 'k','linewidth',1)
        grid on
        xlabel('Model');
        ylabel('Empirical');
        title('Quantile plot','fontweight','bold');

        A3 = axes('units', 'normalized', 'position', [0.07    0.07    0.4    0.39]);
        semilogx(RP,zp(:,3), '-k', 'linewidth', 1);
        hold on
        semilogx(RP,zp(:,2),'-.k', 'linewidth', 1);
        semilogx(RP,zp(:,4),'-.k', 'linewidth', 1);
        semilogx((1./(1-P_em)./numpeaksperyear),sort(y), 'ok', 'markersize',5,'markerfacecolor','r');
        grid on
        xlabel('Return Period')
        ylabel(VarName);
         set(gca, 'xlim', [0.1 1000], 'xticklabel', {'0.1','1','10','100','1000'});
        title('Return Period','fontweight','bold');

        A4 = axes('units', 'normalized', 'position',[0.57    0.07    0.4    0.39]);
        grid
        hold on
        [F,X] = ecdf(y,'Function','cdf');  % compute empirical cdf
        Bin.rule = 1;
        [C,E] = dfswitchyard('dfhistbins',y,[],[],Bin,F,X);
        [N,C] = ecdfhist(F,X,'edges',E); % empirical pdf from cdf
        h = bar(C,N,'hist');
        set(h,'FaceColor',[0.9 0.9 0.9],'EdgeColor','k',...
            'LineStyle','-', 'LineWidth',1);
        xlabel(VarName);
        ylabel('Density')
        xlim = get(gca,'XLim');
        X = linspace(xlim(1),xlim(2),100);
        Y = gppdf(X,paramEsts(1),paramEsts(2),u);
        h = plot(X,Y,'k','LineWidth',1,'MarkerSize',6);
        plot(y,0,'ok','markersize', 5, 'markerfacecolor','r');
        if all(isfinite(xlim))
            set(gca,'XLim',[xlim + [-1 1] * 0.01 * diff(xlim)])
        end
        title('Density plot','fontweight','bold');
        
        
    case 'H'        %Just GPD return period plot
        figure('Name','Extremes plot',...
            'units','normalized','position',[0.2 0.2 0.6 0.6],...
            'Tag','PlotFig');
        semilogx(RP,zp(:,3), '-k', 'linewidth', 2);
        hold on
        semilogx(RP,zp(:,2),'-.k', 'linewidth', 2);
        semilogx(RP,zp(:,4),'-.k', 'linewidth', 2);
        semilogx((1./(1-P_em)./numpeaksperyear),sort(y), 'ok', 'markersize',5,'markerfacecolor','r');
        grid on
        xlabel('Return Period')
        ylabel('Return level (m)');
        axis([0.1 1000 min(y)-0.05 max(y)+0.05]);
        set(gca, 'xlim', [0.1 1000], 'xticklabel', {'0.1','1','10','100','1000'});
        title('Return Period','fontweight','bold');

end
