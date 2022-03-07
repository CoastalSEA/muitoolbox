%% muiPropertyUI
% Abstract class for creating graphic user interfaces to get and set class 
% properties and display them on a tab.

%% Description
% The muiPropertyUI class allows subclasses to declare a set of properties
% and for these then to be set, edited and displaye using methods defined in
% the superclass. Addtional properties set in the subclass that are
% Transient, Hidden, or Constant are not shown or editable using the 
% muiPropertyUI methods. Superclass properties are similarly excluded from
% edit dialogs, set, get and display functions. The exmple class
% demoPropsInput.m (found ), illustrates an application of the muiPropertyUI class.

%% muiPropertyUI abstract properties
% The following abstract properties are used to implement tab assignment 
% for the display of subclass properties. 
%%
% * *PropertyLabels* - definition of labels to be used for tabular display.
% * *TabDisplay* -  structure defines how the property table is displayed.
% This is set by a call to setTabProps in the data import class constructor. 
% The function setTabProps, in the parent abstract class muiPropertyUI, 
% initialises the struct using the values defined in the _TabProps_ property 
% in the abstract class muiModelUI. The _TabProps_ property is set by a 
% call to the abstract method setTabProperties, which must be defined in the 
% class that implements muiModelUI to define a bespoke UI. 
%%
% For example the definition used in the ModelUI class of the 
% <matlab:doc('modelui') ModelUI> App is as follows:
%%
%   function props = setTabProperties(~)
%       %define the tab and position to display class data tables
%       %props format: {class name, tab tag name, position, ...
%       %               column width, table title}
%       props = {...
%           'VPparam','Inputs',[0.95,0.48],{180,60},'Input parameters:'};
%   end
%%
% Upon initialisation of the main UI, the properties defined in
% setTabProperties are loaded into the _TabProps_ property of the class
% that inherits muiModelUI (ie the class that defines the main UI such as
% <matlab:doc('modelui') ModelUI>). When a class that inherits the
% muiPropertyUI class is initialised, the setting for that class are
% assigned from _TabProps_ to the class _TabDisplay_ property.
%%
%  TabDisplay.Tab           %defines which tab to use
%  TabDisplay.Position      %defines position of table on tab [top,right]            
%  TabDisplay.ColWidth      %default column width used in tab table
%  TabDisplay.TableTitle    %title displayed above tab table
%  Some typical TabPosition definitions are as follows:
%  top left   = [0.95,0.48];  top right   = [0.95,0.95];
%  lower left = [0.45,0.48];  lower right = [0.45,0.95];

%%
% * *PropertyType* - is a Hidden property to specify the data type of each
% property. The property does not need to be defined if if only using 
% numeric values or if all non-numeic values are pre-assigned when defining 
% the properties in the class definition. To use non-numeric values without
% pre-assignement, specify the PropertyType as a cell array in the class 
% constructor, e.g. for a set or properties that comprise a date, some text,
% a logical value and 8 numeric values, assign the property type as:
%%
%   obj.PropertyType = [{'datetime','string','logical'},repmat({'double'},1,8)];                                    


%% muiPropertyUI methods
% *displayProperties* - display properties as a table on the Tab assinged in
% TabDisplay.Tab, using _obj_, a class instance that inherits muiPropertyUI
% and _src_ a handle to the calling Tab.
%%
%   displayProperties(obj,src);

%%
% *getProperties* - get the current Property values as a cell array.
%%
%   values = getProperties(obj);  %obj is a class instance that inherits muiPropertyUI

%%
% *resetProperties* - reset Property values to zero (ignores Transient and
% Hidden properties).
%%
%   obj = resetProperties(obj); %obj is a class instance that inherits muiPropertyUI

%%
% *getPropertiesStruct* - get the Property values and return as a struct 
% using Property names as the field names.
%%
%   propstruct = getPropertiesStruct(obj);  %obj is a class instance that inherits muiPropertyUI

%%
% *editPropertySubset* - create inputdlg for a subset of properties and 
% update values, using a vector index list, _idx_, of the Properties to use.
%%
%   obj = editPropertySubset(obj,idx);

%% muiProprtyUI subclass methods
% The following methods in muiPropertyUI are Protected and can be accessed
% by subclass methods.

%%
% *editProperties* - for the open properties defined by the class (i.e.
% excluding Hidden and Transient properties) create an input dlg to allow 
% user to edit the property values. If specified, _nrec_ limits the number 
% of variables to be shown in a single dialog.
%%
%   obj = editProperties(obj,nrec);   %where nrec isoptional

%%
% *setProperties* - assign property values, using cell arrays of the
% _values_, the data _type_, and the data _format_. The _type_ and _format_
% can be determined from the class pre-assignment values or be defining the
% _PropertyType_ property in the class constructor. The _format_ only
% applies to datetime and duration datatypes and is determined from the
% data values input (see muifunctions *str2val* and *val2str*).
%%
%   obj = setProperties(obj,values,type,format);

%%
% *setTabProps* - initialise struct that defines how the data is displayed, 
% where _mobj_ is a handle to the main UI.
%%
%   obj = setTabProps(obj,mobj); 

%% Creating a class using muiPropertyUI
% A template to create a class that uses muiPropertyUI can be found in the
% <matlab:template_folder muitemplates folder>. The template provides the code for a subclass
% and the comments highlight where the file needs to be edited to adapt 
% the template to a new application, as explained further in the 
% <matlab:doc('muitbx_gettingstarted') Getting Started> documentation. 

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muicatalogue') muiCatalogue>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.
 