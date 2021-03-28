%% muiUserData
% Class to import data sets, adding the results to dstable
% and a record in the muiCatalogue.

%% Syntax
%%
%   obj = muiUserData;

%% Description
% The class is used for importing _ad hoc_ datasets using a format file,
% details of which are provided below.

%% muiDataSet properties
% The class inherirs the <matlab:doc('muidataset') muiDataSet> properties 
% for Data, RunParam, MetaData and CaseIndex. Importing data requires 
% muiDataSet properties _DataFormats_ and _FileSpec_, which are defined in 
% the class constructor by prompting the user to select a format file.

%% muiDataSet methods
% Methods for loading, adding, deleting and applying quality to control to
% datasets are inherited from the muitoolbox <matlab:doc('muidataset') muiDataSet>
% abstract class.

%%
% *tabPlot* generates a plot for display on Q-Plot tab. Uses the default
% plotting method _tabDefaultPlot_ in <matlab:doc('muidataset') muiDataSet>.

%% muiUserData format file
% Data import into a _muitoolbox_ UI using _muiUserData_ and classes that
% inherit <matlab:doc('muidatadet') muiDataSet> requires a format file to
% be created. A template is provided in the muiTemplates folder, which sets 
% out the code for each of the functions requied, with comments to
% highlight where the files need to be edited to adapt the templates to 
% a different application. The format file has the following form:

% <include>../muiTemplates/dataimport_format_template.m</include>

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muidatadet') muiDataSet>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>,
 