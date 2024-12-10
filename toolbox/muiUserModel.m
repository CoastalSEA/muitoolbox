classdef muiUserModel < muiDataSet 
%
%-------class help------------------------------------------------------
% NAME
%   muiUserModel.m
% PURPOSE
%    Class for data that is derived using the muiManipUI interface included
%    in  ModelUI, CoastalTools and other ModelUI apps
%    
% SEE ALSO
%   muiDataSet, muiDataUI, muiManipUI
%
% Author: Ian Townend
% CoastalSEA (c) March 2021
%--------------------------------------------------------------------------
%     
    properties
        %inherits Data, RunParam, MetaData and CaseIndex from muiDataSet
        %Additional properties:   
    end
    
    properties (Transient)
        UIsel           %structure for the variable selection made in the UI
        UIset           %structure for the settings made in the UI        
    end
    
    methods
        function obj = muiUserModel()                    
            %class constructor
        end
    end      
%%      
%--------------------------------------------------------------------------
% Model implementation
%--------------------------------------------------------------------------
    methods
        function createVar(obj,gobj,mobj)
            %for selected data evaluate user equation/function 
            %convention is use T,X,Y,Z to represent input variables and 
            %use t,x,y,z to represent the input to the equation after
            %bounds and scaling has been applied 
            usereqn = gobj.UIsettings.Equation;
            if isempty(usereqn)
                warndlg('No equation defined in Data Manipulation UI')
                return;
            end
            hw = waitbar(0, 'Loading data. Please wait');
            obj.UIsel = gobj.UIselection;
            obj.UIset = gobj.UIsettings;
            
            %extract variables and text strings included in the eqn/call 
            %(eg 'period'). NB: 'inp' has fields utext, for all strings in 
            %the call, and comtxt, for any comment text which are assigned 
            %in parseEquation but not currently used
            inp = parseEquation(obj,usereqn);
            isvalid = isValidEqnSelection(obj,inp);
            if ~isvalid,  close(hw); return; end
            
            waitbar(0.2)
            [XYZT,props,ok] = getData(obj,mobj.Cases);
            if ok<1, close(hw); return; end 
            waitbar(0.8)
            %use t,x,y,z variables to evaluate user equation
            %NB: any Scaling selected will have been applied      ??????????????
            if inp.isdst
                varout = callfcn_dst(obj,props,mobj,inp,hw);
            else
                varout = callfcn_var(obj,XYZT,mobj,inp,hw);
            end
            
            if isempty(varout)    %quit if no data returned
                warndlg('No results from function used in Derive output')
                close(hw); return; 
            end
            
            if any(strcmp(inp.comtxt,{'time','rows'})) && ~isempty(XYZT{4})
                %user specified that rownames should be added to output
                varout{end+1} = XYZT{4};
            end
            waitbar(1)    
            %
            %var is matrix with datenum(time) in first column and variable in column 2
            close(hw)
            
            setEqnData(obj,mobj,varout,props);            
        end  
%%
        function tabPlot(obj,src) %abstract method required by muiDataSet
            %generate plot for display on Q-Plot tab

            %add code to define plot format or call default tabplot using:
            tabDefaultPlot(obj,src);
        end          
    end
%%
    methods (Access=private)  
        function inp = parseEquation(~,usereqn)
            %extract variables, user text and instructions from usereqn
            %string. 'inp' is a struct with fields:
            % isdst - logical true if eqn references dst
            % idm - loigcal true if eqn references model instance, mobj
            % utext - for all strings in the call
            % comtxt - for any comment text which are assigned in 
            %         parseEquation but not currently used
            % varsused - list of whether x,y,z,t or dst are used in equation
            % fcn - function name in equation (if used)
            % eqn - input usereqn forced to lower case
            inp = struct('isdst',[],'idm',[],'utext',[],'comtxt',[],... 
                                        'varsused',[],'fcn',[],'eqn',[]);
            %find whether user is passing 'dst' to the function
            inp.isdst = contains(usereqn,'dst','IgnoreCase',true);
            %find whether user is passing 'mobj' to the function
            inp.idm = contains(usereqn,'mobj','IgnoreCase',true);
            
            %find any char in '' or string in ""             
            idchar = sort([regexpi(usereqn,''''),regexpi(usereqn,'"')]);
            usertxt = usereqn;
            count = 1;
            if ~isempty(idchar)                
                for i=1:2:length(idchar)
                    %commented text stores all values in quotes before
                    %applying mask
                    try
                        utext = usereqn(idchar(i):idchar(i+1));
                    catch
                        errordlg('Unable to parse input equation. Check equation definition')
                        return;
                    end
                    if strcmp(utext(1),'''')    %character vector
                        inp.utext{count} = strip(utext,'''');
                    else                        %string
                        inp.utext{count} = strip(utext,'"');
                    end
                    %create mask to hide input text so variables can be found 
                    nchar = idchar(i+1)-idchar(i)+1;
                    usertxt(idchar(i):idchar(i+1)) = repmat('u',1,nchar);
                    count = count+1;
                end
            end

            %strip out input variables: x,y,z,t.
            usertxt = sprintf('(%s)',upper(usertxt)); 
            if inp.isdst            %dstables to be used
                inp.varsused = 'dst';
            else                    %xyzt expression defined
                %need to find x,y,z that are variables and not part of a function name
                %txyz with non-alphanumeric values behind
                posnvars1 = regexpi(usertxt,'[txyz](?=\W)'); 
                %txyz with non-alphanumeric values in front
                posnvars2 = regexpi(usertxt,'(?<=\W)[txyz]');  
                %values that belong to both
                varsusedidx = intersect(posnvars1,posnvars2);
                %variable can be used more than once in equation
                inp.varsused = unique(usertxt(varsusedidx)); 
            end

            %use upper case for input variables T,X,Y,Z but lower case for
            %equations so all Matlab functions can be called.
            inp.eqn = lower(usereqn);
            %extract the function name
            if strcmp(inp.eqn(1),'[') && strcmp(inp.eqn(end),']')
                %matlab expresions with a single output ar wrapped in [...]
                inp.fcn = [];
            else
                posnstvars = regexpi(inp.eqn,'(');
                inp.fcn = inp.eqn(1:posnstvars-1);
            end

            %handle comment strings that give supplementary instructions
            posncom = regexp(inp.eqn,'%', 'once');
            inp.comtxt = [];              
            if ~isempty(posncom)
                inp.comtxt = inp.eqn(posncom+1:end);              
                inp.eqn = inp.eqn(1:posncom-1); 
            end            
        end
%%
        function isvalid = isValidEqnSelection(obj,inp)
            %check equation is defined and all variables needed are defined   
            isvalid = false;
            if isempty(inp.eqn)
                %check that equation has been defined
                warndlg('No equation defined to manipulate data');
                return;
            end
            %check that all variables used in equation have been defined
            XYZTxt = {'X','Y','Z','T'};
            inp.isXYZT = false(1,4);
            for i=1:3  
                %inp.isXYZT is true if an XYZT variable is used in the inp.eqn
                inp.isXYZT(i) = contains(inp.varsused,XYZTxt{i});
                if inp.isXYZT(i) && obj.UIsel(i).caserec<1
                    %check that variable in eqn has also been selected
                    warndlg(sprintf('%s variable is not defined',XYZTxt{i}));
                    return;
                end
            end
            %checkif time is used in inp.eqn
            inp.isXYZT(4) = contains(inp.varsused,XYZTxt{4});

            if all(~inp.isXYZT) || sum(inp.isXYZT)~=length(inp.varsused) 
                %valid equation variables have not been defined
                if all(~inp.isXYZT) && ~isempty(inp.idm)
                    %exclude case when no xyzt but is mobj being passed
                else
                    warndlg('Equation can only use t, x, y and/or z as variables');
                    return;
                end
            end 
            isvalid = true;
        end
%%
        function [XYZT,props,ok] = getData(obj,muicat)
            %get the data to be used in the equation or function
            ok = 1;
            nvar = length(obj.UIsel);
            %initialise struct used in muiCatalogue.getProperty
            props(nvar) = setPropsStruct(muicat);
            XYZT{1,nvar+1} = [];
            range{nvar,2} = [];
            for i=1:nvar                
                %get the data and labels for each variable
                %NB this assigns data in order assigned on tab. eg If Y and
                %Z defined on tab, this is assigned as X and Y 
                if obj.UIsel(i).caserec>0  %case assigned in selection
                    props(i) = getProperty(muicat,obj.UIsel(i),'dstable');
                    XYZT{i} = props(i).data.DataTable{:,1}; %first variable
                    if isempty(props(i).data)
                        ok = ok-1; 
                    else
                        if ~isempty(props(i).data.RowRange)
                            range(i,:) = props(i).data.RowRange;
                        end
                    end
                end
            end 
            if ok<=0, return; end
            %handle inc/exc NaNs
            if obj.UIset.ExcNaN
                [XYZT,props] = removeNaNs(obj,XYZT,props);
            end
                        
            isrowdata = ~cellfun(@isempty,range(:,1));  %variables with row data
            if any(isrowdata)
                %at least one variable has row data defined
                idx = find(isrowdata,1,'first');
                issame1 = cellfun(@(x) range{idx,1}==x,range(isrowdata,1));
                issame2 = cellfun(@(x) range{idx,2}==x,range(isrowdata,2));

                if all(issame1) && all(issame2)
                    %all records have same start and end range values
                    %assume they are the same and return the rows of first
                    XYZT{4} = props(idx).data.RowNames;
                else
                    %may need to prompt user to select if they are not same
                    warndlg('Multiple records with RowNames defined but with different ranges')
                end
            else
                %no row data - return empty struct
            end
        end  
%%
        function [XYZT,props] = removeNaNs(~,XYZT,props)
            %remove the NaN values from the selected variables
            idx = find(~cellfun(@isempty,XYZT));
            for i=1:length(idx)
                j = idx(i);
                props(j).data.DataTable = rmmissing(props(j).data.DataTable);
                XYZT{j} = rmmissing(XYZT{j});
            end            
        end
%%
        function varout = callfcn_dst(~,props,mobj,inp,hw)
            %call function passing dstables of selected variables as a cell 
            %array, any user text, handle to main UI and the inp selection
            %struct with both the user equation and the function name
            idx = ~cellfun(@isempty,{props(:).case});  %index for used XYZ variables
            dst = props(idx); %to just pass dstables use props(idx).data
            try
                %handle to anonymous function based on user equation
                heq = str2func(['@(dst,mobj) ',inp.eqn]);
                if isempty(inp.fcn)
                    maxnargout = 1;
                else
                    maxnargout = nargout(inp.fcn);
                end
                varout = cell(1, maxnargout);
                [varout{:}] = heq(dst,mobj);
            catch ME
                errormsg = sprintf('Invalid expression\n%s',ME.message);
                warndlg(errormsg);
                delete(hw)
                rethrow(ME)      %return;          
            end
        end
%%
        function varout = callfcn_var(~,XYZT,mobj,inp,hw)
            %call function passing selected variables, any user text,
            %handle to main UI and the inp selection struct with both
            %the user equation and the function name
            x = XYZT{1};  %extracted variables
            y = XYZT{2};
            z = XYZT{3};
            t = XYZT{4};
            try
                %handle to anonymous function based on user equation
                heq = str2func(['@(t,x,y,z,mobj) ',inp.eqn]);
                if isempty(inp.fcn) || length(inp.fcn)==1
                    maxnargout = 1;
                else
                    maxnargout = nargout(inp.fcn);
                end                 
                varout = cell(1, maxnargout);
                [varout{:}] = heq(t,x,y,z,mobj);
           catch ME
                errormsg = sprintf('Invalid expression\n%s',ME.message);
                warndlg(errormsg);
                delete(hw)
                rethrow(ME)      %return;          
            end
        end
%%
        function setEqnData(obj,mobj,var,props)
            %add the data generated by CreateVar to a class instance
            %var is a cell array with length determined by user function            
            eqn = obj.UIset.Equation;
            if (isscalar(var{1}) && isnumeric(var{1})) || ischar(var{1})
                %post result if single valued or text
                if ~strcmp(var{1},'no output')
                    displaySingleResult(obj,var{1},eqn)
                end
            elseif isa(var{1},'dstable') || isstruct(var{1})  %not tested for struct of dstables     
                    inputxt = setMetaData(obj,eqn);
                    save2obj(obj,mobj,var{1},inputxt);
            else
                inputxt = setMetaData(obj,eqn);
                setdsp2save(obj,mobj,var,props,inputxt);
            end
            %--------------------------------------------------------------
            function inputxt = setMetaData(obj,eqn)
                %set metadata for output
                idx = find([obj.UIsel.caserec]~=0);  %index to used XYZ variables
                inputxt = sprintf('Used: %s with inputs:',eqn);
                for j=1:length(idx)
                    inputxt = sprintf('%s\n%s',inputxt,(obj.UIsel(idx(j)).desc));
                end
            end
        end
%%                
        function setdsp2save(obj,mobj,var,props,inputxt)
            %save results in a dstable and add record to catalogue  
            %Uses first variable only, or multple variables with
            %first variable defining row dimension to enable passing of
            %multiple variables (not implemented in current version).
            if length(var)==1                  %only one variable returned
                isrows = false;
                rowdata = [];
                results = var;
            else                              %row vector is 1st variable
                isrows = ~isempty(var{1});    %or is empty and isrows = false
                rowdata = var{1};
                results = var(2:end);
                if isrows && length(rowdata)~=length(results{1})
                    warndlg('Row and variable length not the same. Data not saved')
                    return;
                end
            end
            
            %set the metadata for the new variable  
            ressze = size(results{1});
            sz = ressze>1;   %dimensions with more than single value
            ndim = sum(sz(2:end));     %number of dimensions excluding rows
            nvar = length(results);
            istime = isa(rowdata,'datetime') || isa(rowdata,'duration');
            dspstruct = blank_dsp(obj,nvar,ndim,istime);
            %load empty dsp struct directly, including description
            dsp = dsproperties(dspstruct,'Derived data set');             
            setDSproperties(dsp,[],'Derived data set',true); 

            %assign model output to a dstable using the defined dsproperties 
            %metadata. Each variable should be an array in the 'results' 
            %cell array. If model returns single variable as array of 
            %doubles, use {results}            
            if isrows   %rows defined in output - save as new dataset
                %call ui to edit - repeat description to prevent user prompt                
                dst = dstable(results{:},'RowNames',rowdata,'DSproperties',dsp);
                dst = addDims(obj,dst,props,ndim,ressze);
            else        %only variable(s) returned - prompt user
                answer = questdlg('Save the results to an existing case or as a new dataset?',...
                                  'Derive output','Input Case','New Case','Existing','New Case');
                if strcmp(answer,'New Case')
                    %call ui to edit - repeat description to prevent user prompt 
                    dst = dstable(results{:},'DSproperties',dsp);
                    
                    if ressze(1)>1
                        dst.RowNames = 1:ressze(1);  %default numbered rows
                        for i=1:length(props)
                            if obj.UIsel(i).caserec>0 
                                %try to use input row names
                                lengthrows = length(props(i).data.RowNames);
                                if lengthrows==ressze(1)
                                    dst.RowNames = props(i).data.RowNames;
                                    break
                                end
                            end
                        end                        
                    end
                    dst = addDims(obj,dst,props,ndim,ressze);
                elseif strcmp(answer,'Input Case')
                    %need to find which input dataset to add the new variable to
                    muicat = mobj.Cases;
                    caserec = [obj.UIsel.caserec];
                    caserec = unique(caserec(caserec>0));
                    if length(caserec)>1  %more than one so need to select
                        catrecs = getRecord(muicat,caserec);
                        casedesc = catrecs.CaseDescription;
                        [idx,ok] = listdlg('PromptString','Select a Case',...
                                   'SelectionMode','single',...
                                   'ListSize',[300,100],'ListString',casedesc);                    
                        if ok<1, return; end
                        caserec = caserec(idx);
                    end
                    addVariable2CaseDS(muicat,caserec,results,dsp);
                    return;
                else
                    muicat = mobj.Cases;
                    casedesc = muicat.Catalogue.CaseDescription;
                    [caserec,ok] = listdlg('PromptString','Select a Case (must be same number of rows)',...
                                   'SelectionMode','single',...
                                   'ListSize',[300,100],'ListString',casedesc); 
                    if ok<1, return; end
                    addVariable2CaseDS(muicat,caserec,results,dsp);
                    return;
                end
            end
            save2obj(obj,mobj,dst,inputxt) 
        end
%%
        function dst = addDims(~,dst,props,ndim,ressze)
            %add dimensions if there is a match with values in one of the 
            %props.data datasets            
            if ndim>0 
                for i=1:length(props)
                    dims = props(i).data.Dimensions;
                    lengthdims = structfun(@length,dims);
                    if all(sort(lengthdims)'-sort(ressze(2:end))==0)
                        break
                    end
                end
                dst.Dimensions = dims;
                dst.DimensionNames = props(i).data.DimensionNames;
                dst.DimensionDescriptions = props(i).data.DimensionDescriptions;
                dst.DimensionUnits = props(i).data.DimensionUnits;
                dst.DimensionLabels = props(i).data.DimensionLabels;
                dst.DimensionFormats = props(i).data.DimensionFormats;
            end
        end
%%
        function save2obj(obj,mobj,dst,inputxt)        
            %save results as record in catalogue
            type = 'derived'; %assign metadata about model
            source = sprintf('Class %s, using %s',metaclass(obj).Name,type);                                                         
            if isa(dst,'dstable')
                dst.Source = source;
                dst.MetaData = inputxt;   
            else
                dsnames = fieldnames(dst);
                for i=1:length(dsnames)
                    dst.(dsnames{i}).Source = source;
                    dst.(dsnames{i}).MetaData = inputxt; 
                end
            end
            %save results
            setDataSetRecord(obj,mobj.Cases,dst,type);
            getdialog('Run complete');                
        end
%%
        function displaySingleResult(~,var,usereqn)
            %post result if single valued or text
            if  isnumeric(var)
                msg1 = sprintf('Single value result of equation = %g',var);
                msg = sprintf('%s\nFor equation: %s',msg1,usereqn);
            elseif ischar(var) || iscell(var)
                msg = var;
            end
            msgbox(msg,'Derived Ouutput Result');
        end  
%%
function dsp = blank_dsp(~,nvar,ndim,istime)
            %populate only the variable names of a DSproperties struct
            varnames = cell(1,nvar); vardesc = varnames;
            for i=1:nvar
                varnames{i} = sprintf('Var%d',i); %variable names and
                vardesc{i} = sprintf('desc%d',i); %descriptions must be 
            end                                   %unique for dsproperties
            %initialise DSproperties struct
            dsp = struct('Variables',[],'Row',[],'Dimensions',[]);           
            dsp.Variables = struct(...
                'Name',varnames,...
                'Description',vardesc,...
                'Unit',repmat({'?'},1,nvar),...
                'Label',repmat({'plot label'},1,nvar),...
                'QCflag',repmat({'derived'},1,nvar));           
            dsp.Dimensions = struct(...
                'Name',repmat({''},1,ndim),...
                'Description',repmat({''},1,ndim),...
                'Unit',repmat({''},1,ndim),...
                'Label',repmat({''},1,ndim),...
                'Format',repmat({''},1,ndim)); 
            %
            if istime
                dsp.Row = struct(...
                    'Name',{'Time'},...
                    'Description',{'Time'},...
                    'Unit',{'h'},...
                    'Label',{'Time'},...
                    'Format',{'dd-MM-yyyy HH:mm:ss'});     
            else
                dsp.Row = struct(...
                    'Name',{''},...
                    'Description',{''},...
                    'Unit',{''},...
                    'Label',{''},...
                    'Format',{''});   
            end
        end
    end
end