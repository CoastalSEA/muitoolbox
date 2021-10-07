classdef (Abstract = true) muiPropertyUI  < matlab.mixin.Copyable
%
%-------abstract class help------------------------------------------------
% NAME
%   nuiPropertyUI.m
% PURPOSE
%   Abstract class for creating graphic user interface to get and set class 
%   properties and display them on a tab
% SEE ALSO
%   muiConstants.m for example of usage
%
% Author: Ian Townend
% CoastalSEA(c) Aug 2020
%--------------------------------------------------------------------------
%
    %Interface class to hold methods used across other classes in ModelUI 
    %to get and set class properties and display them on a tab
   
	properties (Abstract, Hidden)
        %define data properties required for object
        %properties used to implement tab assignment of properties 
        PropertyLabels   %definition of labels to be used for tabular display

        TabDisplay       %structure defines how the property table is displayed 
        %   TabDisplay.Tab         %defines which tab to use
        %   TabDisplay.Position    %defines position of table on tab [top,right]
        %                          %differs from Matlab convention of
        %                          %[left,bottom] because tables vary in length                         
        %   TabDisplay.ColWidth    %default column width used in tab table
        %   TabDisplay.TableTitle  %title displayed above tab table
        %
        % some typical TabPosition definitions:
        %   top left   = [0.95,0.48];  top right   = [0.95,0.95];
        %   lower left = [0.45,0.48];  lower right = [0.45,0.95];
    end
    
    properties (Hidden)
        PropertyType     %defintion of data type for each property
                         %can be empty if only using numeric values, or if
                         %a default value if all non-numeric values are
                         %pre-assigned when defining the properties        
    end
%%
    methods 
        function obj = muiPropertyUI
        end
%%
		function displayProperties(obj,src)
			%display properties as a table on the Tab assinged in
			%TabDisplay.Tab
            colnames = {'Property','Value'};          
            cwidth = obj.TabDisplay.ColWidth;
            userdata = getInputProps(obj);
			Table = uitable('Parent',src, ...
                            'ColumnName', colnames, ...
                            'RowName', [], ....
                            'ColumnWidth', cwidth, ...
                            'Data',userdata, ...
                            'Units','normalized');
            Table.Position(3:4)=Table.Extent(3:4);
            Table.Position(1)=obj.TabDisplay.Position(2)-Table.Extent(3); %left = right - table width
            if Table.Position(1)<0 %restrict table to be on tab (forces scroll bar)
                margin = 0.02;
                Table.Position(1) = margin;
                Table.Position(3) = obj.TabDisplay.Position(2)-margin;
            end
            
            nrow = size(userdata,1);
            minheight = max(0.08*nrow,0.18);
            if Table.Position(4)<minheight &&  Table.Extent(3)>0.98 
                %minimium height for any table when horizontal scroll present
                Table.Position(2) = obj.TabDisplay.Position(1)-minheight;
                Table.Position(4) = minheight;
            else
                 Table.Position(2)=obj.TabDisplay.Position(1)-Table.Position(4); %bottom = top - table height
            end

            if Table.Position(2)<0 
                margin = 0.02;
                Table.Position(2) = margin;
                Table.Position(4) = obj.TabDisplay.Position(1)-margin;
            end 
            
            %add title if defined
            if ~isempty(obj.TabDisplay.TableTitle)
                titlepos = Table.Position;
                titlepos(2) = obj.TabDisplay.Position(1);                
                titlepos(4) = 0.04;
                uicontrol('Parent',src,'Style','text',...
                          'Units','Normalized','Position',titlepos,...
                          'HorizontalAlignment','left',...
                          'String', obj.TabDisplay.TableTitle,...
                          'Tag','TableTitle');        
            end
        end    
%%
        function vals = getProperties(obj)
            %for class obj get the current property values as a cell array
            propnames = getPropertyNames(obj);
            vals = cell(length(propnames),1);
            for k=1:length(propnames)
                vals{k} = (obj.(propnames{k}));
            end
        end
%%
		function obj = resetProperties(obj)
			%for class obj reset property values that are not Transient 
            %or Hidden to zero
            propnames = getPropertyNames(obj);
            for k=1:length(propnames)
                obj.(propnames{k}) = 0;
            end
        end    
%%
        function obj = updateProperties(obj,values)
            %update the class properties with the values that are not Transient 
            %or Hidden using values cell array
            propnames = getPropertyNames(obj);
            for k=1:length(propnames)
                obj.(propnames{k}) = values{k};
            end
        end
%%
        function propdata = getPropertiesStruct(obj)
            %get the property values and return as a struct using property names
            propnames = getPropertyNames(obj);
            vals = getProperties(obj);
            for i=1:length(propnames)
                propdata.(propnames{i}) = vals{i};
            end
        end

%%
        function obj = editPropertySubset(obj,idx)
            %create inputdlg for a subset of properties and update values
            propdesc = obj.PropertyLabels;
            propnames = getPropertyNames(obj);
            vals = getProperties(obj);
            nvars = length(idx);           
            %define default values for inputdlg
            prompt = cell(nvars,1);  defaultvalues = cell(nvars,1);
            for i=1:nvars
                prompt{i} = propdesc{idx(i)};
                defaultvalues{i} = num2str(vals{idx(i)});
            end
            %call input dlg
            numlines = 1;
            title = 'Define property values';
            useInp=inputdlg(prompt,title,numlines,defaultvalues);
            if isempty(useInp), return, end
            %update values of defined subset (use str2num to handle vectors)
            for i=1:nvars
                obj.(propnames{idx(i)}) = str2num(useInp{i}); %#ok<ST2NM>
            end 
        end         
%%
        function isvalid = isValidInstance(obj)
            %check whether the data in a single class has been added
            %input data is loaded using PropertyInterface
            localProperties = getProperties(obj);
            %originally used: localProperties = getCharProperties(obj);
            %changed to allow structs to be used (eg EqCoeffProps in Asmita)
            checkProps = cellfun(@isempty,localProperties);
            if all(~checkProps)
                isvalid = true;
            else
                isvalid = false;
            end
        end        
    end
%%
    methods (Access=protected)
        function obj = editProperties(obj,nrec)
            %for class obj get the open properties (excludes hidden and 
            %transient) and provide input dlg to allow user to edit 
            %property values. If specified, nrec limits the number of
            %variables to be shown in a single dialog.
            if nargin<2
                nrec = 12; %default number variables for input UI 
            end
            prompt = obj.PropertyLabels;
            [defaultvalues,vtype,vformat] = getCharProperties(obj);            
            numlines = 1;
            title = 'Define property values';
            %use updated properties to call inpudlg and return new values
            %small screens can only handle ~12 inputs. For input lists with
            %more than 12 values split the entry into 2 dialogues
            if length(defaultvalues)>nrec
                useInp=multiInputdlg(obj,prompt,title,numlines,...
                                                    defaultvalues,nrec);
                if isempty(useInp), return; end
            else
                useInp=inputdlg(prompt,title,numlines,defaultvalues);
                if isempty(useInp), return; end
            end
            %now save the updated values
            if ~isempty(obj.PropertyType)
                vtype = obj.PropertyType;
            end
            obj = setProperties(obj,useInp,vtype,vformat);
        end
%%
		function obj = setProperties(obj,vals,vtype,vformat)
			%for class obj update property values that are not Transient 
            %or Hidden using vals 
            % vals - cell array of values to be assigned
            % vtype - data type of the variable (see var2str)
            % vformat - input format for datetime and duration data (see var2str)
            propnames = getPropertyNames(obj);
            for k=1:length(propnames)
                if isempty(vals{k})
                    obj.(propnames{k}) = [];
                elseif length(split(vals{k}))>1 && all(~isletter(vals{k})) 
                    %catch arrays of numeric values
                    obj.(propnames{k}) = str2num(vals{k}); %#ok<ST2NM>%NB str2double does NOT work here
                else
                    %all other datatypes restored based on vtype and vformat
                    obj.(propnames{k}) = str2var(vals{k},vtype{k},vformat{k});
                end
            end
        end       
%%
        function obj = setTabProps(obj,mobj)
            %initialise structure that defines how the data is displayed 
            %on a tab
            classname = metaclass(obj).Name;
            if isempty(mobj.TabProps), return; end
            isTabPropClass = fields(mobj.TabProps);
            if any(strcmp(isTabPropClass,classname))
                tabprops = mobj.TabProps.(classname);
                obj.TabDisplay.Tab = tabprops.Tab;
                obj.TabDisplay.Position = tabprops.Position;
                obj.TabDisplay.ColWidth = tabprops.ColWidth;
                obj.TabDisplay.TableTitle = tabprops.TableTitle;
            else
                %the data class has not been assigned specific tab
                %properties. This assumes that there is an Inputs tab.
                %Should only be needed when using the core ModelUI
                obj.TabDisplay.Tab = 'Inputs';
                obj.TabDisplay.Position = [0.95,0.48];
                obj.TabDisplay.ColWidth = {180,60};
                obj.TabDisplay.TableTitle = 'Input data:';
            end
        end
    end
%%
    methods (Access=private)
        function userdata = getInputProps(obj)
            propnames = getPropertyNames(obj);
            userdata = cell(length(propnames),1);
            idx= 1;
            for k=1:length(propnames)
                userdata{idx,1} = obj.PropertyLabels{k};
                propvalue = obj.(propnames{k});
                if isdatetime(propvalue)
                    %datetime value (convert to string for display)
                    userdata{idx,2} = char(propvalue);
                elseif iscell(propvalue)
                    %multiple cell strings (concatenate to single string)
                    for j=1:length(propvalue)
                        userdata{idx,1} = obj.PropertyLabels{k};
                        userdata{idx,2} = propvalue{j};
                        idx = idx+1;
                    end
                    idx = idx-1;   %compensate for main loop addition
                elseif isnumeric(propvalue) && length(propvalue)>1
                    %numerical vector (convert to string for display)
                    userdata{idx,2} = num2str(propvalue);                    
                else
%                       || ischar(propvalue) || islogical(propvalue)  %changed for use in ASMITA                  
                    %numeric, logical, or char
                    userdata{idx,2} = propvalue;
                end
                idx = idx+1;
            end
        end
%%
        function useInp = multiInputdlg(~,prompt,title,numlines,defaultvalues,nrec)
            %split entry into two dialogues when there is more than nrec
            %entries and this becomes too long to fit on screen
            defaults1 = defaultvalues(1:nrec);
            prompt1 = prompt(1:nrec);
            useInp1 = inputdlg(prompt1,title,numlines,defaults1);
            %
            defaults2 = defaultvalues(nrec+1:end);
            prompt2 = prompt(nrec+1:end);
            useInp2 = inputdlg(prompt2,title,numlines,defaults2);
            %
            useInp = [useInp1;useInp2];
        end
%%
		function propnames = getPropertyNames(obj)
			%for class obj get the property names that are not Transient 
            %or Hidden
			mc = metaclass(obj);
			mp = mc.PropertyList;
            ms = mp(1).DefiningClass.SuperclassList;
            scnames = getSuperclassNames(obj,ms);
            count=1;
            propnames = {};
			for k=1:length(mp)
                %remove hidden, transient and constant properties
				idx = mp(k).Transient + mp(k).Hidden + mp(k).Constant +...
                                                       + mp(k).Dependent;
                %remove superclass properties
                idx = idx + any(strcmp(scnames, mp(k).Name)); 
                if idx<1
                    propnames{count,1} = mp(k).Name; %#ok<AGROW>
                    count = count+1;
                end
			end
			%
        end
%%
        function scnames = getSuperclassNames(~,ms)
            %find the property names used in the object superclasses
            count = 1; scnames = {};
            if ~isempty(ms)
                for i=1:length(ms)
                    if ~isempty(ms(i).PropertyList)
                        for j = 1:length(ms(i).PropertyList)
                            scnames{count,1} = ms(i).PropertyList(j).Name; %#ok<AGROW>
                            count = count+1;
                        end
                    end
                end
            end
        end
%%        
        function [charvals,vtype,vformat] = getCharProperties(obj)
            %get the property values in character vector format for use in
            %table dialogues
            vals = getProperties(obj);
            charvals = cell(size(vals)); vtype = charvals; vformat = vtype;
            for k=1:length(vals)
                [cval,vtype{k},vformat{k}] = var2str(vals{k});
                charvals{k} = cval{:};  %needs checking for numerical array
                if isempty(vtype{k})
                    vtype{k} = 'double';%no default value set in subclass properties
                end                     %assume that they are numeric values
            end                     
        end
    end
end