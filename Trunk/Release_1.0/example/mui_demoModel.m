classdef mui_demoModel < muiDataSet
%
%-------class help------------------------------------------------------===
% NAME
%   mui_demoModel.m
% PURPOSE
%   Class to illustrate running a model, adding the results to dstable and
%   a record in a dscatlogue with a method to plot the output
% USAGE
%   obj = mui_demoModel.runModel(catobj) %where is a handle to a muiCatalogue
% SEE ALSO
%   uses diffusion2Dmodel.m based on code by Suraj Shanka, (c) 2012,
%   (fileexchange/diffusion-in-1d-and-2d)
%   inherits dscollection and uses dstable and dscatalogue
%
% Author: Ian Townend
% CoastalSEA (c)Nov 2020
%--------------------------------------------------------------------------
%         
    properties  
        %inherits Data, RunProps, MetaData and CaseIndex from dscollection
        VersionNo = 1.0
    end  
    
    methods (Access = private)
        function obj = mui_demoModel()
            %class constructor
        end
    end
%%    
    methods (Static)
        function obj = runModel(mobj)
            %initialise class object
            obj = mui_demoModel;
            dsp = modelDSproperties(obj);
            muicat = mobj.Cases;
             %get input parameters
            if isempty(mobj.Inputs)             %mui_usage call
                [inp,run] = mui_demo_inputprops();  
            else                                %mui_demoUI call
                run = mobj.Inputs.mui_demoPropsInput;
                inp = run;  %duplicate to save splitting struct
            end
            %run the diffusion2Dmodel
            [ut,xy,modeltime] = diffusion2Dmodel(inp,run);  %call model
            modeltime = seconds(modeltime);  %durataion data for rows
            %load the results into a dstable            
            dst = dstable(ut,'RowNames',modeltime,'DSproperties',dsp);
            dst.Dimensions.X = xy{:,1};   %grid x-coordinate
            dst.Dimensions.Y = xy{:,2};   %grid y-coordinate
            %assign metadata about model
            dst.Source = 'diffusion2Dmodel';
            d = cellstr(datetime(now,'ConvertFrom','datenum'));
            dst.MetaData = sprintf('Run on %s, using v%.1f',d{1},obj.VersionNo);
            %save results
            setDataSetRecord(obj,muicat,dst,'model');
            getdialog('Run complete');
        end 
    end
%%
    methods
        function tabPlot(obj,src)
            %generate plot for display
            if nargin<2
                src = figure;
            end
            %get data for variable and dimensions x,y,t
            dst = obj.Data.Dataset;
            t = dst.RowNames;
            u = dst.u;            
            x = dst.Dimensions.X;
            y = dst.Dimensions.Y;
            %metatdata for model and run case description
            txt1 = sprintf('%s using %s',dst.Description,dst.Source);
            
            %generate base plot
            ax = axes('Parent',src,'Tag','Surface');
            ui = squeeze(u(1,:,:))';
            h = surf(ax,x,y,ui,'EdgeColor','none'); 
            shading interp
            axis ([0 max(x) 0 max(y) 0 max(u,[],'all')])
            h.ZDataSource = 'ui';
            xlabel('X co-ordinate'); 
            ylabel('Y co-ordinate');  
            zlabel('Transport property') 
           
            %animate plot as a function of time
            hold(ax,'on')
            ax.ZLimMode = 'manual';
            for i=2:length(t)
                ui = squeeze(u(i,:,:))'; %#ok<NASGU>
                refreshdata(h,'caller')
                txt2 = sprintf('Time = %s', string(t(i)));
                title(sprintf('%s\n %s',txt1,txt2))
                drawnow; 
            end
            hold(ax,'off')
        end          
    end  
%%    
    methods (Access = private)
        function dsp = modelDSproperties(~)
            dsp = struct('Variables',[],'Row',[],'Dimensions',[]);           
            dsp.Variables = struct(...   %cell arrays can be column or row vectors
                'Name',{'u'},...
                'Description',{'Transport property'},...
                'Unit',{'m/s'},...
                'Label',{'Transport property'},...
                'QCflag',{'model'}); 
            dsp.Row = struct(...
                'Name',{'Time'},...
                'Description',{'Time'},...
                'Unit',{'s'},...
                'Label',{'Time (s)'},...
                'Format',{'s'});        
            dsp.Dimensions = struct(...    
                'Name',{'X','Y'},...
                'Description',{'X co-ordinate','Y co-ordinate'},...
                'Unit',{'m','m'},...
                'Label',{'X co-ordinate (m)','Y co-ordinate (m)'},...
                'Format',{'-','-'});  
        end
    end
end