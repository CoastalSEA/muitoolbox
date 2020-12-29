classdef muiDataUI < handle %replaces DataGUIUinterface
%
%-------abstract class help------------------------------------------------
% NAME
%   muiDataUI.m
% PURPOSE
%   Abstract class for creating graphic user interface to select data
%   and pass selection to applications
% NOTES
%   Typically called by class implementation of muiModelUI
% SEE ALSO
%   ModelPlots.m amd DataStats for examples of usage
%
% Author: Ian Townend
% CoastalSEA (c) Dec 2020
%--------------------------------------------------------------------------
%     
    properties (Transient)
        DataGuiFigure        %handle for GUI figure
        DataGuiTabs          %handle for GUI tabs
%         SelectedTab        %tag for data selection tab requested
       UIsettings            %struct of UI settings
       UIselection           %struct array UI selections (1:n)
    end

    properties (Abstract)  %properties that all subclasses must include
        TabOptions         %names of tabs providing different data accces options
    end

    methods (Abstract,Access=protected) %methods that all subclasses must define

    end
%--------------------------------------------------------------------------
% initialise figure and tabs
%--------------------------------------------------------------------------
    methods (Access=protected)       %methods common to all uses
        function setDataGuiFigure(obj,mobj,GuiTitle)
            if isempty(obj)
                error('No input')
            end
            obj.UIsettings = muiDataUI.uisel;  %initialise struct for settings
            obj.UIselection = muiDataUI.uisel; %initialise struct array for selections
            %initialise UI figure
            obj.DataGuiFigure = figure('Name',GuiTitle, ...
                'NumberTitle','off', ...
                'MenuBar','none', ...
                'Units','normalized', ...
                'CloseRequestFcn',@(src,evt)exitDataGui(obj,src,evt,mobj),...
                'Resize','on','HandleVisibility','on', ...
                'Tag','DataGUI');
            obj.DataGuiFigure.Position(1:2)=[0.16 0.3]; 
            axes('Parent',obj.DataGuiFigure, ...
                'Color',[0.94,0.94,0.94], ...
                'Position',[0 0.002 1 1], ...
                'XColor','none', ...
                'YColor','none', ...
                'ZColor','none', ...
                'Tag','DataGUIaxes');
        end
 %%
        function setDataGuiTabs(obj,mobj)
            if isempty(obj.TabOptions)
                return;
            end
            obj.DataGuiTabs = uitabgroup(obj.DataGuiFigure, ...
                'Tag','DataGuiTabs');
            obj.DataGuiTabs.Position = [0 0 1 1];
            %
            if isempty(obj.NumTabs) %defined in Model and passed to Results
                ntab = length(obj.TabOptions);
            else
                ntab = obj.NumTabs;
            end
            %
            for i=1:ntab
                tabname = obj.TabOptions{i};
                tabtitle = sprintf('  %s  ',tabname);
                ht = uitab(obj.DataGuiTabs,'Title',tabtitle,...
                    'Tag',tabname,'ButtonDownFcn', ...
                    @(src,evd)obj.setTabActions(src,evd,mobj));
                uipanel('Parent',ht,'Units','normalized',...
                    'Position',[.01 .01 0.98 0.98],'Tag',[tabname,'Panel']);
                %now add controls to tab
                setTabContent(obj,ht);             %defines what controls to use                
                setDataOptionControls(obj,ht,mobj);%selection controls
                setVariableLists(obj,ht,mobj);     %assign values to variables
                setXYZpanel(obj,ht,mobj);          %XYZ button panel
                setAdditionalButtons(obj,ht,mobj); %addtional action buttons
                setTabControlButtons(obj,ht,mobj); %tab control buttons                 
            end
            ht = findobj(obj.DataGuiTabs,'Tag',obj.TabOptions{1});
            initialiseXYZoptions(obj,ht,mobj);     %initialise date selection
            obj.SelectedTab = obj.TabOptions{1};
            setTabActions(obj,ht,[],mobj);    %tab specific actions
        end       
        
        
%%
%--------------------------------------------------------------------------
% initialise data selection options for each tab
%--------------------------------------------------------------------------        
        
    end    

    methods (Static, Access = protected)
        function settings = uiset()
            %return a default struct for UI settings
            settings = struct('polar',false,'swap',false);
        end  
%%
        function selection = uisel()
            %return a default struct for UI selection definition
            %caseid or caserec??
            selection = struct('caseid',0,varname,'','ivar','');
        end 
    end
    
end