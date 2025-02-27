classdef muiStats < handle
%
%-------class help---------------------------------------------------------
% NAME
%   muiStats.m
% PURPOSE
%   Class to implement running a range of statistical functions
% SEE ALSO
%   called from muiStatsUI.m, which defines the selection and settings in
%   properties UIselection and UIsettings
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2021
%--------------------------------------------------------------------------
%
    properties (Transient)
%         Stats           %struct array for 
%                         %   FigNum - index to figures created
%                         %   CurrentFig - handle to current figure
%                         %   Order - struct that defines variable order for
%                         %           stats type options (selection held in Order)
        UIsel           %structure for the variable selection made in the UI
        UIset           %structure for the plot settings made in the UI
        Data            %data to use in statistic (x,y,z)
        MetaData        %text summary of primary variable selection
        Labels          %struct for XYZ labels
        Title           %Title text
        Order           %order of variables for selected statistic
        DescOut         %structure for descriptive output tables
        ExtrOut         %structure for extremes output tables
        Taylor          %structure for parameters defined for skill score        
    end
%%    
    methods (Access=protected)  %allows muiPlot to be used as a superclass
        function obj = muiStats
            %class constructor
        end      
    end
%%    
    methods (Static)
        function getStats(gobj,src,mobj)
            %get existing instance or create new class instance
            if isa(mobj.mUI.Stats,'muiStats') && isvalid(mobj.mUI.Stats)
                obj = mobj.mUI.Stats;    %get existing instance  
                clearPreviousStatsData(obj);
            else
                obj = muiStats;                   %create new instance
            end
            obj.UIsel = gobj.UIselection;
            obj.UIset = gobj.UIsettings;

            %get the data to be used in the plot
            ok = getStatsData(obj,mobj.Cases);
            if ok<1, return; end %data not found

            if ~isempty(obj.UIset.Type) && strcmp(obj.UIset.Type.String,'User')
                user_stats(obj,src,mobj);  %pass control to user function
            else
                %generate the plot
                setStats(obj,src,mobj);
            end
        end
    end
%%
   methods 
        function tabStats(obj,src)
            %pass current statistical results held in obj.StatOut to a 
            %table on the Stats tab (if included in the main UI)
            ht = src.Children;   %clear any existing tab content
            delete(ht);
            
            switch src.Tag
                case {'Stats','Descriptive'}
                    [idx,rundesc] = selectStatOuput(obj.DescOut);
                    if isempty(idx), return; end
                    txt = obj.DescOut{idx}.Properties.Description; 
                    metatxt = sprintf('%s\n%s',rundesc,txt);
                    tablefigure(src,metatxt,obj.DescOut{idx});
                case 'Extremes'
                    [idx,rundesc] = selectStatOuput(obj.ExtrOut);
                    if isempty(idx), return; end
                    txt = obj.ExtrOut{idx}.Properties.Description; 
                    metatxt = sprintf('%s\n%s',rundesc,txt);
                    tablefigure(src,metatxt,obj.ExtrOut{idx});
            end
            %-nested function----------------------------------------------
            function [idx,rundesc] = selectStatOuput(output)
                idx = []; rundesc = '';
                
                nruns = length(output);
                if nruns>1
                    rundesc = cellfun(@(x) x.Properties.UserData,output,...
                                                    'UniformOutput',false);
                    [idx,ok] = listdlg('PromptString','Select a case:',...
                           'SelectionMode','single','ListSize',[500,100],...
                           'ListString',rundesc);
                    if ok<1, idx = 1; end
                    rundesc = rundesc{idx};
                elseif nruns==1
                    rundesc = output{1}.Properties.UserData;
                    idx = 1;
                end
            end
        end
    end  
 %%  
    methods (Access=protected)  
         function ok = getStatsData(obj,muicat)
            %get the data set and add metadata to metatxt
            %obj - DataStats UI object, muicat - instance of muiCatatalogue
            ok = 1;
            nvar = length(obj.UIsel);
            %initialise struct used in muiCatalogue.getProperty
            props(nvar) = setPropsStruct(muicat);
            xyzset = [obj.UIsel(:).caserec]==0;
            for i=1:nvar
                %get the data and labels for each variable
                if obj.UIsel(i).caserec>0
                    props(i) = getProperty(muicat,obj.UIsel(i),'dstable');
                    if isempty(props(i).data), ok = ok-1; end
                end
            end  
            if ok<=0, return; end
            props(xyzset) = [];  %remove unused selections
            %
            xyz = {'X','Y','Z'};
            for i=1:length(props)
                %assign the data to the correct axis
                %NB this assigns data in order assigned on tab. If Y and Z
                %defined on tab this is assigned as X and Y        
                if obj.UIsel(i).scale>1 %apply selected scaling to variable
                    usescale = obj.UIset.scaleList{obj.UIsel(i).scale};
                    dim = 1; %dimension to apply scaling function if matrix
                    data2use = props(i).data.DataTable{:,1};
                    data2use = scalevariable(data2use,usescale,dim);
                    props(i).data.DataTable{:,1} = data2use;
                end                
                obj.Data.(xyz{i}) = props(i).data;
                obj.Labels.(xyz{i}) = props(i).label;
                obj.MetaData.(xyz{i}) = obj.UIsel(i).desc;                
            end
            %description of selection (may need sub-selection if more than
            %one case/variable used)
            dimtxt = {props(:).desc};
            if length(dimtxt)>1
                title = sprintf('%s (',dimtxt{end});
                for j=1:length(dimtxt)-1
                    title = sprintf('%s%s, ',title,dimtxt{j});
                end
                obj.Title = sprintf('%s)',title(1:end-2));  
            else
                obj.Title = dimtxt{1};
            end
        end       
%%      
        function setStats(obj,src,mobj)
            %make use of the selection made to run stats of selected type
            srcVal = src.Parent.Tag;
            switch srcVal
                case 'General'
                    getGeneralStats(obj,mobj);
                case 'Timeseries'
                    getTimeseriesStats(obj,mobj,srcVal);
                case 'Taylor'
                    getTaylorStats(obj,src);
                case 'Intervals'
                    getIntervalStats(obj,mobj);
            end    
            %assign muiStats instance to handle
            mobj.mUI.Stats = obj;
        end
%%
%--------------------------------------------------------------------------
% General Statistics options
%--------------------------------------------------------------------------           
        function getGeneralStats(obj,mobj) 
            %call relevant functions based on user selection
            statoption = obj.UIset.Type;
            switch statoption.String
                case 'Descriptive for X'
                    getDescriptiveStats(obj,mobj)
                case 'Regression'
                    getRegressionStats(obj)
                case 'Cross-correlation'
                    getCrossCorrelationStats(obj)
                case 'User'
                    user_stats(obj,mobj,srcVal);
            end                    
        end       
%%        
%--------------------------------------------------------------------------
% Functions called to implement General Statistics options
%--------------------------------------------------------------------------
        function getDescriptiveStats(obj,mobj)
            %call descriptive_stats based on user selection  
            hw = waitbar(0,'Checking data');
            if isempty(obj.Data.X) && ~isempty(obj.Data.Y)
                %move Y to X if defined and no X defined
                obj.Data.X = obj.Data.Y;
                obj.MetaData.X = obj.MetaData.Y;
            end
            dataset = obj.Data.X.DataTable{:,1};
            if isdatetime(dataset) || isduration(dataset)
                %adjust datetime or duration to a number
                dataset = time2num(dataset);
            end
            %to assign to a tab need to define src. If src not defined 
            %(ie [])then a stand-alone figure is used
            src = getTabHandle(obj,mobj,1);
            
            waitbar(0.2,hw,'Processing')
            results = descriptive_stats(dataset,obj.MetaData.X,src);
            if isempty(results), return; end
            [idx,casedesc] = setcase(obj.DescOut,false);
            results.Properties.UserData = casedesc;
            obj.DescOut{idx} = results;
            msgtxt = sprintf('Results are displayed on the Stats>%s tab\n\nNB These are NOT saved with with project\nAll Cases of statistical analysis remain available from the Stats tab\nwhile the Statistics UI remains open',...
                                         strip(src.Title));
            getdialog(msgtxt,[],3);
            waitbar(1,hw)
            close(hw)
        end
%%
        function getRegressionStats(obj)
            %call regression_plot based on user selection
            % X taken as indpendent variable and Y as dependent variable
            regression_models = {'Linear','Power','Exponential','Logarithm'};
            [indx,ok] = listdlg('PromptString','Select a regression model:',...
                           'SelectionMode','single','ListSize',[150,60],...
                           'ListString',regression_models);
            if ok<1, return, end
            model = regression_models{indx}; %selected model type
            
            hw = waitbar(0,'Checking data');
            %check that user has correctly defined X and Y
            isvalid = isValidSelection(obj,'Regression',false);
            if ~isvalid, return; end            
            metadata = setMetaData(obj);
            
            %handle time formats
            checkDatDur(obj);
            
            waitbar(0.2,hw,'Processing')
            regression_plot(obj.Data.X,obj.Data.Y,metadata,model);
            waitbar(1,hw)
            close(hw)
        end
%%
        function getCrossCorrelationStats(obj)
            %call xcorrelation_plot based on user selection
            % X taken as reference variable and Y as the lag variable
            hw = waitbar(0,'Checking data');
            %check that user has correctly defined X and Y
            isvalid = isValidSelection(obj,'Cross-correlation',false);
            if ~isvalid, return; end
            metadata = setMetaData(obj);
            
            %handle time formats
            checkDatDur(obj)
            
            waitbar(0.2,hw,'Processing')
            xcorrelation_plot(obj.Data.X,obj.Data.Y,metadata);
            waitbar(1,hw)
            close(hw)
        end
%%
%--------------------------------------------------------------------------
% Timeseries options
%--------------------------------------------------------------------------        
         function getTimeseriesStats(obj,mobj,srcVal) 
            %retrieve selected dataset and call relevant functions 
            %based on user selection
            switch obj.UIset.Type.String
                case 'Descriptive'
                    %to assign to a tab need to define src. If src not defined 
                    %(ie [])then a stand-alone figure is used
                    src = getTabHandle(obj,mobj,1);  
                    results = descriptive_stats(obj.Data.X,obj.MetaData.X,src);
                    if isempty(results), return; end
                    [idx,casedesc] = setcase(obj.DescOut,false);
                    results.Properties.UserData = casedesc;
                    obj.DescOut{idx} = results;
                    msgtxt = sprintf('Results are displayed on the Stats>%s tab\n\nNB These are NOT saved with with project\nAll Cases of statistical analysis remain available from the Stats tab\nwhile the Statistics UI remains open',...
                                         strip(src.Title));
                    getdialog(msgtxt,[],3);
                case 'Regression'
                    obj.Data.Y = obj.Data.X;  %assign variable to Y
                    obj.Labels.Y = obj.Labels.X;
                    obj.Labels.X = 'Time';
                    %Assign the RowNames datetime to X as a dstable so that
                    %checkDatDur in getRegressionStats works
                    obj.Data.X = dstable(obj.Data.X.RowNames,'VariableNames',{'Time'});
                    obj.Data.X.VariableDescriptions = {'Time'};
                    getRegressionStats(obj);
                case 'Peaks'                    
                    getPeaksStats(obj,mobj);
                case 'Clusters'
                    getClusterStats(obj,mobj);
                case 'Extremes'
                    getExtremeStats(obj,mobj);
                case 'Poisson Stats'
                    poisson_stats(obj.Data.X,obj.MetaData.X);
                case 'Hurst Exponent'
                    hurst_exponent(obj.Data.X,obj.MetaData.X);
                case 'User'
                    user_stats(obj,mobj,srcVal);
            end
         end
%%
%--------------------------------------------------------------------------
% Functions called to implement Timeseries options
%--------------------------------------------------------------------------
        function checkDatDur(obj)
            %check whether inputs are datetime or duration
            %isdd true if datetime or duration, isdt true if datetime
            [isdd,~] = isdatdur('RowNames',obj.Data.X,obj.Data.Y);
            %isdd true if datetime or duration, isdt true if datetime

            %re-assign if one of the variables is datetime or duration, or
            %the RowNames are not datetime or duration
            %pass dstables if the RowNames are datetime or duration to 
            %allow interpolation to common time intervals.
            
            if ~all(isdd)  
                %selected datasets do not both have datetime or duration RowNames
                obj.Data.X = obj.Data.X.DataTable{:,1};
                obj.Data.Y = obj.Data.Y.DataTable{:,1};
            end
        end
%%
        function getPeaksStats(obj,mobj)
            %find peaks above a threshold and write the timeseries of peaks
            dst = obj.Data.X;
            [idpks,ops] = getpeaks(dst);
            if isempty(ops), return; end          
            dst = getDSTable(dst,idpks,':');
            %assign metadata about statistic
            dst.Source = sprintf('%s peaks using %s',dst.VariableNames{1},...
                                                        dst.Description);  
            dst.MetaData = sprintf('Peaks from %s, threshold=%.4g, method=%.4g, minimum interval=%.4g h',...
                obj.MetaData.X,ops.threshold,ops.method,ops.tint);
            %get new object based on source data class
            classname = mobj.Cases.Catalogue.CaseClass(obj.UIsel(1).caserec); 
            heq = str2func(classname);
            cobj = heq();  %instance of class object
            if isprop(cobj,'ModelType')
                cobj.ModelType = 'stats';
            end
            %save results  
            setDataSetRecord(cobj,mobj.Cases,dst,'stats');
            getdialog('Run complete');
        end         
%%
        function getClusterStats(obj,mobj)
            %find clusters above a specified threshold and save as a new
            %data record with peak values and a flag for cluster number 
            dst = obj.Data.X;
            [idcls,ops] = getclusters(dst);
            if isempty(ops), return; end
            %get subset of source timeseries using id of peaks in each
            %cluster and a flag to record cluster number
            numcluster = []; clusterdates = [];
            for i=1:length(idcls)
                numcluster = [numcluster;i*ones(length(idcls(i).pks),1)]; %#ok<AGROW>
                clusterdates = [clusterdates;idcls(i).date]; %#ok<AGROW>
            end
            dst = getDSTable(dst,clusterdates,':');
            dst = addvars(dst,numcluster,'NewDSproperties',...
                {'ClusterNumber','Cluster Numbers','-','Cluster Numbers','-'});
            %assign metadata about statistic
            dst.Source = sprintf('%s peaks using %s',dst.VariableNames{1},...
                                                        dst.Description);
            dst.MetaData = sprintf('Clusters from %s, threshold=%.4g, method=%.4g, minimum interval=%.4g h and time between clusters of %0.4g d',...
                obj.MetaData.X,ops.threshold,ops.method,ops.tint,ops.clint);
            %get new object based on source data class
            classname = mobj.Cases.Catalogue.CaseClass(obj.UIsel(1).caserec); 
            heq = str2func(classname);
            cobj = heq();  %instance of class object
            if isprop(cobj,'ModelType')
                cobj.ModelType = 'stats';
            end
            %save results  
            setDataSetRecord(cobj,mobj.Cases,dst,'stats');
            getdialog('Run complete');
        end
%%
        function getExtremeStats(obj,mobj)
            %compute extreme values for a range of return periods using GPD            
            src = getTabHandle(obj,mobj,2);%to assign to a tab need to define src
            mtxt = {sprintf('Selection used:\nX: %s',obj.MetaData.X)};
            stats = extreme_stats(obj.Data.X,mtxt,src);
            [idx,casedesc] = setcase(obj.DescOut,false);
            stats.Properties.UserData = casedesc;
            obj.ExtrOut{idx} = stats;  
            msgtxt = sprintf('Results are displayed on the Stats>%s tab',strip(src.Title));
            getdialog(msgtxt);
        end
%--------------------------------------------------------------------------
% Functions called to implement Taylor Plot 
%--------------------------------------------------------------------------
        function getTaylorStats(obj,src) 
            %call taylor_plot based on user selection
            
            %check that user has correctly defined X and Y
            isvalid = isValidSelection(obj,'Taylor Plot',true);
            if ~isvalid, return; end
            refts = obj.Data.X;
            tests = obj.Data.Y;
            metadata{1} = sprintf('%s: %s',refts.Description,refts.VariableDescriptions{1});
            metadata{2} = sprintf('%s: %s',tests.Description,tests.VariableDescriptions{1});
            if ~isempty(refts.RowNames) && length(refts.RowNames)==1
                dimtxt = var2str(refts.RowNames);
                metadata{1} = sprintf('%s, %s: %s',metadata{1},refts.RowDescription,dimtxt{1});
                dimtxt = var2str(tests.RowNames);
                metadata{2} = sprintf('%s, %s: %s',metadata{2},tests.RowDescription,dimtxt{1});
            end
            rLim = obj.UIset.Other;
            %see if user wants to include skill score
%             ok = setTaylorParams(obj);
            [obj.Taylor,ok] = setskillparameters(obj.Taylor,obj.Data.X);
            if ok<1, return; end
            
            taylor_plot(refts,tests,metadata,src.String,...
                                                        rLim,obj.Taylor);
        end
%%
%--------------------------------------------------------------------------
% Functions called to implement Interval Statistics
%--------------------------------------------------------------------------
        function getIntervalStats(obj,mobj)
            % find intervals in one timeseries and compute statistcs within each
            % interval in a second timeseries (use tsc for multiple variables
            
            %check that user has defined X and Y
            isvalid = isValidSelection(obj,'Interval statistics',false);
            if ~isvalid, return; end            
            %ensure that the two records overlap
            [ds1,ds2] = getoverlappingtimes(obj.Data.X,obj.Data.Y,true);
            
            statoptions = {'median','mean','std','var','min','max','sum'};
            txt1 = 'Define the statistical function to be used';
            txt2 = 'Select from: median, mean, std, var, min, max, sum';                                                
            inptxt = sprintf('%s\n%s',txt1,txt2);   
            selstat = {'mean'};

            ok = 1; count = 1;
            while ok>0
                selstat = inputdlg(inptxt,'Interval statistics',1,selstat);
                if isempty(selstat)       %user cancelled
                    return;
                elseif ismember(selstat{1},statoptions)
                    statxt = sprintf('@(x) %s(x)',selstat{1});
                    statfunc = str2func(statxt);         
                    [statval{1,count},numts] = getintervaldata(ds1,ds2,statfunc);  %#ok<AGROW>
                    stext{1,count} = selstat{1};             %#ok<AGROW>
                    count = count+1;

                    %
                    quest = 'Do you want to resample using a different statistcal function?';
                    answer = questdlg(quest,'Interval Statistics',...
                                        'Yes','No','No');
                    if strcmp(answer,'No'), ok = 0; end
                else
                    getdialog('Option entered is not in list')
                end
            end
            stext{1,count} = 'reclength';
            %save results as a dstable, including dates from ts1,
            %recordlength of ts2 in each interval and the selected
            %statistical functions.
            dst = dstable(statval{:},numts,'RowNames',ds1.RowNames);
            dsp = ds2.DSproperties;
            dsp.Variables = muiStats.setVariableDSP(dsp,stext);
            dst.DSproperties = dsp;
            
            %assign metadata about statistic
            dst.Source = sprintf('Interval stats for %s from %s using reference times from %s ',...
                         ds2.VariableNames{1},ds2.Description,ds1.Description);
            dst.MetaData = sprintf('Interval stats for %s using time intervals from %s',...
                            obj.MetaData.Y,obj.MetaData.X);
            %get new object based on source data class
            classname = mobj.Cases.Catalogue.CaseClass(obj.UIsel(2).caserec); 
            heq = str2func(classname);
            cobj = heq();  %instance of class object
            if isprop(cobj,'ModelType')
                cobj.ModelType = 'stats';
            end
            %save results  
            setDataSetRecord(cobj,mobj.Cases,dst,'stats');
            getdialog('Run complete');
        end
%%
%--------------------------------------------------------------------------
% Functions called by implementation functions
%--------------------------------------------------------------------------        
        function clearPreviousStatsData(obj)
            %reset the property values used to generate stats output
            obj.Data = [];            %data to use in plot (x,y,z)
            obj.Labels = [];          %struct for XYZ axis labels
            obj.MetaData = [];        %text summary of primary variable selection
            obj.Title = [];           %Title text
            obj.Order = [];           %order of variables for selected plot type
        end
%%
        function isvalid = isValidSelection(obj,fncdesc,iseq)
            %check that user has made a valid selection for function
            % fncdesc - description of function to use
            % iseq - logical flag, true if length of variables to be checked
            fnames = fields(obj.Data);
            if length(fnames)<2
                warndlg(sprintf('Select X and Y for %s',fncdesc))
                isvalid = false;
            else
                isvalid = true;
            end
            %
            if iseq && isvalid && length(obj.Data.X)~=length(obj.Data.Y)
                warndlg('Variables need to be the same length')
                isvalid = false;
            end            
        end
%%
        function metadata = setMetaData(obj)
            %define metatdata required by regression and x-correlation
            fnames = fields(obj.Data);
            metadata = struct2cell(obj.Labels);
            metadata{3} = obj.Title;           
            mtxt = 'Selection used:';
            temptxt = struct2cell(obj.MetaData);
            for j=1:length(temptxt)
                mtxt = sprintf('%s\n%s: %s',mtxt,fnames{j},temptxt{j});   
            end
            metadata{4} = mtxt;
        end
%%
        function src = getTabHandle(~,mobj,idx)
            %find the handle of the tab if there is one
            %obj - DataStats UI object, mobj - Main UI object
            %idx - index for subtab to use as Tag name or numeric index
            tabobj = findobj(mobj.mUI.Tabs.Children,'-regexp','Tag','Stat');
            %can return tab and tabgroup if both present
            if isempty(tabobj), return; end
            subtabgrp = tabobj(1).Children;  %tabgroup to use
            if isa(subtabgrp,'matlab.ui.container.TabGroup') 
                %use one of the subtabs defined by idx
                statstabs = subtabgrp.Children;
            else
                %use main tab as there are no subtabs
                statstabs = tabobj;
            end
            %
            if ischar(idx)
                idx = find(strcmp({statstabs(:).Tag},idx));
            end
            tab = statstabs(idx);            %tab to use
            %
            if isempty(tab)
                src = [];
            else
                src = tab;
                delete(src.Children);  %clear existing tab
            end
        end    
    end
%%
    methods (Static, Access=private)
        function dsp = setVariableDSP(dsp,statops)
            %assign the variable dsproperties based on user selection
            nvar = length(statops);
            varnames = cell(1,nvar); vardesc = varnames; varlabel = varnames;
            for i=1:nvar
                varnames{i} = sprintf('%s%s',statops{i},dsp.Variables.Name{1});
                vardesc{i} = sprintf('%s %s',statops{i},dsp.Variables.Description{1});
                varlabel{i} = sprintf('%s %s',statops{i},dsp.Variables.Label{1});
            end
            instruct = struct(...                       
                'Name',varnames,...
                'Description',vardesc,...
                'Unit',repmat(dsp.Variables.Unit,1,nvar),...
                'Label',varlabel,...
                'QCflag',repmat(dsp.Variables.QCflag,1,nvar));
            dsp.Variables = instruct;
        end
    end
end