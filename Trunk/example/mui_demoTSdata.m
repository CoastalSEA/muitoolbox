classdef mui_demoTSdata < muiDataSet
%
%-------class help------------------------------------------------------===
% NAME
%   mui_demoTSdata.m
% PURPOSE
%   Class to illustrate importing a data set, adding the results to dstable
%   and a record in a dscatlogue with a method to plot the output
% USAGE
%   obj = mui_demoTSdata.loadData(catobj) %where is a handle to a dscatalogue
% SEE ALSO
%   inherits muuiDataSet and uses dstable and dscatalogue
%
% Author: Ian Townend
% CoastalSEA (c)Nov 2020
%--------------------------------------------------------------------------
%    
    properties  
        %inherits Data, RunParam, MetaData and CaseIndex from muiDataSet
        %Additional properties:  
    end
    
    methods (Access = private)
        function obj = mui_demoTSdata()
            %class constructor
        end
    end
%%    
    methods (Static)
        function loadData(mobj)
            %read and load a data set from a file
            obj = mui_demoTSdata;               %initialise class object
            [data,~,filename] = readInputData(obj);             
            if isempty(data), return; end
            dsp = dataDSproperties(obj);  %initialise dsproperties for data
            
            %load the data
            [data,time] = getData(obj,data,dsp);
            %load the results into a dstable            
            dst = dstable(data{:},'RowNames',time,'DSproperties',dsp);
            %assign metadata about dagta
            dst.Source = filename;
            %setDataRecord classobj, muiCatalogue obj, dataset, classtype
            setDataSetRecord(obj,mobj.Cases,dst,'data');           
        end 
    end
%%
    methods
        function tabPlot(obj,src)
            %generate plot for display         
            if nargin<2
                src = figure;
            end
            
            %get data for variables u10 and dir and dimension t
            dst = obj.Data.Dataset;
            t = dst.RowNames;
            u10 = dst.Speed10min;      
            dir = dst.Dir10min;
            %metatdata for model and run case description
            filename = regexp(dst.Source,'\\','split');
            titletext = sprintf('%s\nfile: %s',dst.Description,filename{end});
            
            %generate plot            
            yyaxis left
            plot(t,u10);
            ylabel(dst.VariableLabels{1})
            yyaxis right
            plot(src,t,dir);
            ylabel(dst.VariableLabels{2})
            title(titletext)
        end   
    end
%%
    methods (Access = private)
        function [data,header,filename] = readInputData(~)
            %read wind data (read format is file specific).
            [fname,path,~] = getfiles('FileType','*.txt');
            filename = [path fname];
            dataSpec = '%d %d %s %s %s %s'; 
            nhead = 1;     %number of header lines
            [data,header] = readinputfile(filename,nhead,dataSpec);
        end     
%%        
        function [varData,myDatetime] = getData(~,data,dsp)
            %format data from file
            mdat = data{1};       %date
            mtim = data{2};       %hour 24hr clock
            idx = mtim==24;
            mdat(idx) = mdat(idx)+1;
            mtim(idx) = 0;
            mdat = datetime(mdat,'ConvertFrom','yyyymmdd');
            mtim = hours(mtim);
            % concatenate date and time
            myDatetime = mdat + mtim;            %datetime for rows
            myDatetime.Format = dsp.Row.Format;
            %remove text string flags
            data(:,3:6) = cellfun(@str2double,data(:,3:6),'UniformOutput',false);
            %reorder to be speed direction speed direction
            temp = data(:,3);
            data(:,3) = data(:,4);
            data(:,4) = temp;
            temp = data(:,5);
            data(:,5) = data(:,6);
            data(:,6) = temp;
            varData = data(1,3:end);             %sorted data to be loaded
        end  
%%        
        function dsp = dataDSproperties(~)
            %define the metadata properties for the demo data set
            dsp = struct('Variables',[],'Row',[],'Dimensions',[]);           
            dsp.Variables = struct(...   %cell arrays can be column or row vectors
                'Name',{'Speed10min','Dir10min','Speed1hr','Dir1hr'},...
                'Description',{'Mean wind speed 10min','Mean wind direction 10min',...
                   'Mean wind speed 1hr','Mean wind direction 1hr'},...
                'Unit',{'m/s','deg','m/s','deg'},...
                'Label',{'Wind speed (m/s)','Wind direction (deg)',...
                   'Wind speed (m/s)','Wind direction (deg)'},...
                'QCflag',{'raw','raw','raw','raw'}); 
            dsp.Row = struct(...
                'Name',{'Time'},...
                'Description',{'Time'},...
                'Unit',{'h'},...
                'Label',{'Time'},...
                'Format',{'dd-MM-uuuu HH:mm:ss'});        
            dsp.Dimensions = struct(...    
                'Name',{''},...
                'Description',{''},...
                'Unit',{''},...
                'Label',{''},...
                'Format',{''});  
        end
    end
end