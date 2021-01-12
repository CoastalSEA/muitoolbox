classdef muiManipUI < muiDataUI
%
%-------class help------------------------------------------------------
% NAME
%   muiManipUI.m
% PURPOSE
%   Class implements the muiDataUI class to access data and derive new
%   variables
% SEE ALSO
%   muiDataUI.m
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
% 
    properties (Transient)
        %Abstract variables for DataGUIinterface---------------------------        
        %names of tabs providing different data accces options
        TabOptions = {'Calc'};       
        %Additional variables for application------------------------------
        GuiChild         %handle for muiManip to track output generated 
        Tabs2Use         %number of tabs to include  (set in getPlotGui)
    end  
%%  
    methods (Access=protected)
        function obj = muiManipUI(mobj)
            %initialise standard figure and menus
            guititle = 'Derive output';
            setDataUIfigure(obj,mobj,guititle);    %initialise figure     
        end
    end
%%    
    methods (Static)
        function obj = getManipUI(mobj)
            %this is the function call to initialise the Plot GUI.
            %the input is a handle to the data to be plotted  
            %the options for plot selection are defined in setTabContent
            if isempty(mobj.Cases.Catalogue.CaseID)
                warndlg('No data available to manipulate');
                obj = [];
                return;
            elseif isa(mobj.mUI.Manip,'muiManipUI')
                obj = mobj.mUI.Manip;
                if isempty(obj.dataUI.Figure)
                    obj = obj.setDataUIfigure(mobj);    %initialise figure 
                    setDataUItabs(obj,mobj); %add tabs 
                else
                    getDialog('Derive Output UI is open');
                end
            else
                obj = muiManipUI(mobj);
                obj.Tabs2Use = {'Calc'};
                setDataUItabs(obj,mobj); %add tabs                
            end                
        end
    end
%%
%--------------------------------------------------------------------------
% Abstract methods required by muiDataUI to define tab content
%--------------------------------------------------------------------------
    methods (Access=protected) 
        function setTabContent(obj,src)
            %setup default layout options for individual tabs
            %Abstract function required by DataGUIinterface
            itab = find(strcmp(obj.Tabs2Use,src.Tag));
            obj.TabContent(itab) = muiDataUI.defaultTabContent;
            
            %customise the layout of each tab. Overload the default
            %template with a function for the tab specific definition
            setCalcTab(obj,src)            
        end                
%%
        function setVariableLists(obj,src,mobj)
            %Abstract function required by DataGUIinterface
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            sel_uic = S.Selections;
            cobj = getCase(mobj.Cases,1);
            for i=1:length(sel_uic)                
                switch sel_uic{i}.Tag
                    case 'Case'
                        muicat = mobj.Cases.Catalogue;
                        sel_uic{i}.String = muicat.CaseDescription;
                    case 'Dataset'
                        if isempty(cobj.MetaData)
                            sel_uic{i}.String = {'Dataset'};
                        else
                            sel_uic{i}.String = cobj.MetaData;
                        end
                    case 'Variable'     
                        sel_uic{i}.String = cobj.Data{1}.VariableDescriptions;
                    case 'Type'
                        sel_uic{i}.String = S.Type;
                end
            end        
            obj.TabContent(itab).Selections = sel_uic;
        end
%%       
        function setTabActions(obj,src,~,~) 
            %actions needed when activating a tab
            %Abstract function required by DataGUIinterface
            initialiseUIselection(obj,src);
            initialiseUIsettings(obj,src);
            resetVariableSelection(obj,src);
            clearXYZselection(obj,src);
        end         
%%        
        function UseSelection(obj,src,mobj)  
            %make use of the selection made to create a plot of selected type
            %Abstract function required by DataGUIinterface
            switch src.String
                case 'Calculate'    %calculate result
                    createVar(obj,src,mobj);
                 case 'Function'
                    selectFunction(obj,mobj);   
            end 
        end           
    end
%%
%--------------------------------------------------------------------------
% Additional methods used to select functions for use in UI
%--------------------------------------------------------------------------
    methods (Access=private)
        function selectFunction(obj,mobj)
            %allow user to select a function from a defined list of available
            %functions (specified in functionlibrarylist)
            fn = functionlibrarylist(mobj);
            if isempty(fn.fname)
                warndlg('No functions defined (see functionlibrarylist.m)');
                return; 
            end
            ok = 1;
            while ok>0
                [idx,ok] = listdlg('Name','Function options', ...
                        'PromptString','Select a function:', ...
                        'ListSize',[350,200],...
                        'SelectionMode','single', ...
                        'ListString',fn.fdesc);
                if ok<1, return, end

                qtxt = sprintf('Selected:  %s\nFunction:  %s\nVariables: %s',...
                                 fn.fdesc{idx},fn.fname{idx},fn.fvars{idx});
                answer = questdlg(qtxt,'Selected function','Use','Change','Quit','Use');
                switch answer
                    case 'Use'
                        ok = 0;  %use selection
                    case 'Change'
                        %return to list
                    case 'Quit'
                        return;
                end
            end
            heq = findobj(obj.dataUI.Tabs,'Tag','UserEqn');
            heq.String = fn.fname{idx};
        end   
%%
%--------------------------------------------------------------------------
% Additional methods used to define tab content
%--------------------------------------------------------------------------
        function setCalcTab(obj,src)
            %customise the layout of the Calc tab
            %overload defaults defined in DataGUIinterface.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.8,0.14]; %vertical position and height of header
            txt1 = 'Select the variables to be used and assign to X Y Z buttons.';
            txt2 = '?';
            txt3 = 'You may be prompted to sub-sample the data if multi-dimensional.';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            
            %Specification of uicontrol for each selection variable  
            S.Titles = {'Case','Datset','Variable'};            
            S.Style = {'popupmenu','popupmenu','popupmenu'};
            S.Order = {'Case','Dataset','Variable'};
            S.Scaling = {};  %options for ScaleVariable - exclude option
            
            %Tab control button options
            S.TabButText = {'Calculate','Function','Clear'}; %labels for tab button definition
            S.TabButPos = [0.1,0.03;0.3,0.03;0.5,0.03]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 1;                        %minimum number of buttons to use
            S.XYZmxvar = [inf,inf,inf];           %maximum number of dimensions per selection
            S.XYZpanel = [0.05,0.30,0.9,0.3];     %position for XYZ button panel
            S.XYZlabels = {'X','Y','Z'};          %default button labels
            
            %Action button specifications
            S.ActButNames = {'Refresh','IncNaN'}; %names assigned selection struct
            S.ActButText = {char(174),'+N'};      %labels for additional action buttons
            % Negative values in ActButPos indicate that a
            % button is alligned with a selection option numbered in the 
            % order given by S.Titles
            S.ActButPos = [0.86,-1;0.86,-3];      %positions for action buttons   
            % action button callback function names
            S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)',...
                            '@(src,evt)setIncNaN(src,evt)'};
            % tool tips for buttons             
            S.ActButTip = {'Refresh data list',...%tool tips for buttons
                           'Include NaNs in output'};         
            obj.TabContent(itab) = S;             %update object
            setEquationBox(obj,src);
        end    
%%
%--------------------------------------------------------------------------
% Additional methods create new variable
%--------------------------------------------------------------------------        
        function createVar(obj,src,mobj)
            %for selected data evaluate user equation/function 
            %convention is use T,X,Y,Z to represent input variables and 
            %use t,x,y,z to represent the input to the equation after
            %bounds and scaling has been applied
            textobj = findobj(src.Parent,'Tag','UserEqn'); 
            usereqn = textobj.String;
            if isempty(usereqn)
                warndlg('No equation defined in Data Manipulation UI')
                return;
            end
            hw = waitbar(0, 'Loading data. Please wait');
            utext = [];
            idstring = regexpi(usereqn,'''');
            if ~isempty(idstring)
                utext = usereqn(idstring(1):idstring(2));
                usereqn = replace(usereqn,utext,'utext');
                idstring = regexpi(utext,'''');
                if ~isempty(idstring)
                    utext = utext(idstring(1)+1:idstring(2)-1);
                end
            end
            TXTeqn = upper(usereqn);
            %strip out input variables: x,y,z,t.
            usertxt = sprintf('(%s)',TXTeqn);
            %need to find x,y,z that are variables and not part of a function name
            %txyz with non-alphanumeric values behind
            posnvars1 = regexpi(usertxt,'[txyz](?=\W)'); 
            %txyz with non-alphanumeric values in front
            posnvars2 = regexpi(usertxt,'(?<=\W)[txyz]');
            %values that belong to both
            varsused = intersect(posnvars1,posnvars2);
            %variable can be used more than once in equation
            numvars = unique(usertxt(varsused)); 
            
            %use upper case for input variables T,X,Y,Z but lower case for
            %equations so all Matlab functions can be called.
            inp.eqn = lower(textobj.String);
            
            %handle comment strings that give supplementary instructions
            posncom = regexp(inp.eqn,'%', 'once');
            if ~isempty(posncom)
                comtxt = inp.eqn(posncom+1:end);
                switch comtxt
                    case 'time'
                        istimevar = true;
                end                
                inp.eqn = inp.eqn(1:posncom-1);
            else
                istimevar = false;
            end

            if isempty(inp.eqn)
                %check that equation has been defined
                warndlg('No equation defined to manipulate data');
                return;
            end
            %find whether user is passing 'mobj' to the function
            idm = ~isempty(regexpi(usertxt,'mobj','once'));
            
            XYZTxt = {'X','Y','Z','T'};
            inp.isXYZT = false(1,4);
            for i=1:3  
                %inp.isXYZT is true if an XYZT variable is used in the inp.eqn
                inp.isXYZT(i) = ~isempty(regexpi(usertxt(varsused),XYZTxt{i}));
                if inp.isXYZT(i) && strcmp(obj.DataSelection.(XYZTxt{i}){2,1},'None') 
                    %check that variable in eqn has also been selected
                    warndlg(sprintf('%s variable is not defined',XYZTxt{i}));
                    return;
                end
            end
            %checkif time is used in inp.eqn
            inp.isXYZT(4) = ~isempty(regexpi(usertxt(varsused),XYZTxt{4}));
            
            if all(~inp.isXYZT) || sum(inp.isXYZT)~=length(numvars) 
                %valid equation variables have not been defined
                if all(~inp.isXYZT) && ~isempty(idm)
                    %exclude case when no xyzt but is mobj being passed
                else
                    warndlg('Equation can only use t, x, y and/or z as variables');
                    return;
                end
            end     
            waitbar(0.2)
            [XYZT,xyzt,metatxt] = getData(obj,mobj,inp);
            if isempty(xyzt) && isempty(idm), return; end 
            waitbar(0.8)
            %use t,x,y,z variables to evaluate user equation
            %NB: any Scaling selected will have been applied in getVatiable 
            %called by getData (getVariable is in DataGuiInterface).
            t = XYZT{4};
            x = XYZT{1};
            y = XYZT{2};
            z = XYZT{3};
            try
                heq = str2func(['@(t,x,y,z,utext,mobj) ',inp.eqn]); %handle to anonymous function
                if istimevar                
                    [var,t] = heq(t,x,y,z,utext,mobj);
                else
                    var = heq(t,x,y,z,utext,mobj);
                end
            catch ME
                errormsg = sprintf('Invalid expression\n%s',ME.message);
                warndlg(errormsg);
                close(hw)
                return;
            end
            waitbar(1)    
            
            if istimevar && length(t)~=length(xyzt{4})
                %user specified that length of timeseries can change
                xyzt{4} = t;
            end
            %
            %var is matrix with datenum(time) in first column and variable in column 2
            setEqnData(obj,mobj,xyzt,var,metatxt)
            close(hw)
        end        
        
    end
end