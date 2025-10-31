function H = hurst_exponent(ts,metatxt,method)
%
%-------function help------------------------------------------------------
% NAME
%   hurst_exponent.m
% PURPOSE
%  Estimate the Hurst exponent of a timeseries, using one of a a number of
%  methods available from the Matlab Forum (credits given in-line with use)
% USAGE
%   H = hurst_exponent(ts,metadata)
% INPUTS
%   ts - timeseries variable, timeseries, or dstable dataset
%   metatxt - description of case and variable selected (optional)
%   method - use 1=Chiarello code, 2=Abramov code, 3 = Aalok code, 
%            4=Antoniades & Brandi, (optional, default = 2)
% OUTPUT
%   H - Hurst exponent
% NOTES
%   The Hurst parameter H is a measure of the extent of long-range dependence
%   in a time series (while it has another meaning in the context of self-similar 
%   processes). H takes on values from 0 to 1. A value of 0.5 indicates the 
%   absence of long-range dependence. The closer H is to 1, the greater 
%   the degree of persistence or long-range dependence. H less that 0.5 
%   corresponds to a lack of persistence, which as the opposite of LRD indicates 
%   strong negative correlation so that the process fluctuates violently.
%   H is also directly related to fractal dimension, D, where 1 < D < 2, such 
%   that D = 2 - H.
% SEE ALSO
%   called from muiStats
%
% Author: Ian Townend
% CoastalSEA (c) Aug 2022
%--------------------------------------------------------------------------
%
    if nargin<3
        method = [];
    elseif nargin<2
        method = [];
        metatxt = 'Hurst Exponent';
    end
    
    H = []; 
    if isa(ts,'timeseries')
        x = ts.Data;
        labeltxt = ts.UserData.Labels;
    elseif isa(ts,'dstable')
        x = ts.(ts.VariableNames{1});
        labeltxt = ts.VariableLabels{1};
    elseif isvector(ts)
        x = ts;
        labeltxt = 'variable';
    else
        warndlg('Data format not recognised in poisson_stats')
        return;
    end
    
    %remove any NaNs from start of record
    if isnan(x(1))
        idx = find(~isnan(x),1,'first');
        x = x(idx:end);
    end
    
    if isempty(method)
        listxt = {'1 = Chiarello matrix','2 = Abramov loop','3 = Aalok-Ihlen',...
                                        '4 = Aste - unweighted'};
        method = listdlg('PromptString','Select method to use:',...
                         'SelectionMode','single','ListSize',[160,180],...
                         'ListString',listxt);
        if isempty(method), return; end
    end
    
    %x = x(1:length(x)/20); %experiment with shortemning record length
    Nvar=length(x);        
    utime = 2:Nvar;              %unit-time vector
    
    switch method
        case 1
            % Source: https://www.mathworks.com/matlabcentral/fileexchange/70192-hurst-exponent   
            % Author: Conrado Chiarello
            % Date: 02.01.2019
            % NUEM - Multiphase flow research center
            % UTFPR - Technological University of Parana
            % Modification suggested by Louis Jader on 20 Aug 2019
            user = memory;
            nsze = length(x)^2*8;
            if nsze>user.MaxPossibleArrayBytes
                warndlg(sprintf('Array exceeds maximum array size preference\nRequires: %g GB, Available %g GB',...
                            nsze/1e9,user.MaxPossibleArrayBytes/1e9));
                return;
            end
            
            if iscolumn(x), x = x'; end  %ensure that variable is a row vector    
            X = tril(repmat(x, length(x), 1))+triu(NaN(length(x),length(x)),1);
            X(1,:) = [];                 %remove first row
            
            % Range (relative to mean of each row) and Std Dev
            range = cumsum(X - mean(X,2,'omitnan'),2,'omitnan');
            R = max(range,[],2) - min(range,[],2);
            S = std(X,0,2,'omitnan');           
        case 2
            % Source: https://www.mathworks.com/matlabcentral/fileexchange/39069-hurst-exponent-estimation    
            % Author: Vilen Abramov
            % Date: 02.02.2018
            % Modified to handle NaN data and omit zeros in power law estimate
            R = zeros(1,Nvar-1); S = R;
            for n=2:Nvar
                % Calculate R statistic
                Deviation=cumsum(x(1:n),'omitnan')-cumsum(ones(n,1))*sum(x(1:n),'omitnan')/n;
                R(n-1)=max(Deviation)-min(Deviation);
                % Calculate S statistic
                S(n-1)=sqrt(sum(x(1:n).^2,'omitnan')/n-(sum(x(1:n),'omitnan')/n)^2);
                %S(n-1) = std(x(1:n),0,1,'omitnan'); %provides closer cf with Chiarello method
            end 
        case 3
            % https://www.frontiersin.org/articles/10.3389/fphys.2012.00141/full
            % Source: https://www.mathworks.com/matlabcentral/fileexchange/100988-hurst-exponent)
            % Author: atharva aalok
            % Date: unknown - downloaded 2022
            nrec = sum(isfinite(x));
            listprompt = sprintf('Number of valid data records = %d\nTotal Number of cycles?',nrec);
            listxt = {listprompt,'Minimum Number of Cycles'};
            ok = 0;
            while ok<1
                answer = inputdlg(listxt,'Hurst',1,{'100','10'});
                if isempty(answer), return; end
                ncycles = str2double(answer{1});
                min_cycles = str2double(answer{2});
                if ncycles>=min_cycles, ok=1; end
            end

            nsteps = length(x);
            one_cycle_points = nsteps/ncycles;
            scale_min = floor(log2(one_cycle_points*min_cycles));
            % For max scale we all the data.
            %scale_max = floor(log2(one_cycle_points*ncycles));
            scale_max = floor(log2(nsteps));
            scale = 2.^(scale_min:1:scale_max);
            m = 2;
            H = hurst_aalok_ihlen(x, scale, m, metatxt);
            fprintf('Final H = %.3g\n',H)
            return
        case 4
            % "The use of scaling properties to detect relevant changes in financial time series: A new visual warning tool", I.P. Antoniades, Giuseppe Brandi, L. Magafas, T.Di Matteo, Physica A, 565 (2021), DOI: 10.1016/j.physa.2020.125561.
            % Source: https://uk.mathworks.com/matlabcentral/fileexchange/98829
            % Author: Ioannis Antoniades, Giuseppe Brandi
            % Date: 2021
            % This uses the genhurstw function which is also available from
            % Morales, R., T. Di Matteo, R. Gramatica, and T. Aste (2012), Dynamical generalized Hurst exponent as a tool to monitor unstable periods in financial time series, Physica A: Statistical Mechanics and its Applications, 391(11), 3180-3189, doi:https://doi.org/10.1016/j.physa.2012.01.004.
            % Source: https://www.mathworks.com/matlabcentral/fileexchange/36487
            % Author: Tomaso Aste 
            % Date: 2013
     
            if iscolumn(x), x = x'; end  %ensure that variable is a row vector   
            [H,sH] = genhurstw(x);
            fprintf('Unweighted generalized Hurst exponent\nH(for q=1) and (std.dev.) = %0.3f (%0.3f)\n',H,sH)
            return
    end
    
    Q = R./S;
    % Power law fitting (Polynomial curve fitting of degree 1 in log-log space)
    idx = R>0 & S>0;  %exclude R=0 values from power law estimate
    powerLaw = polyfit(log(utime(idx)), log(Q(idx)), 1);

    % Hurst exponent
    H = powerLaw(1);   

    % Plot for visualization (modified to be same as Abramov version of Hurst.m)
    hf = figure('Name','Hurst Plot','Tag','StatFig');
    ax = axes(hf);
    if Nvar>100
        plot(ax,log(utime), log(Q),'b.','MarkerSize',8)
    else
        plot(ax,log(utime), log(Q),'bo')
    end
    
    hold on
    plot(ax,log(utime),polyval(powerLaw,log(utime)),'r-',log(utime),.5*log(utime),'g--','LineWidth',2)
    hold off
    xlabel('log(unit-time)')
    ylabel(['log(R/S) for ',labeltxt])

    exponent = sprintf('Hurst Line (exponent = %0.3f)',H);
    legend('R/S',exponent,'Normal Line (exponent = 0.5)','Location','NorthWest')
    fittedtitle(hf,metatxt,false,0.68);
end