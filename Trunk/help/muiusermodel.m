%% muiUserModel
% Class for data that is derived using the muiManipUI interface included
% in  ModelUI, CoastalTools and other ModelUI apps.

%% Syntax
%%
%   obj = muiUserModel;


%% Description
% The class is used to evaluate user defined equations or functions and
% save results if required.
% Inherits from <matlab:doc('muidataset') muiDataSet> and is only
% accessible from classes that inherit <matlab:doc('muidataset') muiDataSet>, 
% or <matlab:doc('muidataui') muiDataUI>.

%% muiUserModel properties
% The class inherirs the <matlab:doc('muidataset') muiDataSet> properties 
% for Data, RunParam, MetaData and CaseIndex. In addition, the selection 
% from a <matlab:doc('muidataui') muiDataUI> derived UI are held as 
% transient properties.
%%
% * *UIsel* - structure for the variable selection made in the calling UI.
% * *UIset* - structure for the settings made in the calling UI. 

%% muiUserModel methods
% The main purpose of _muiUserModel_ is to implement the selections made in
% <matlab:doc('muinanipui') muiManipUI>. <br>
% *createVar*  evaluate the user defined equation or function and report
% single valued results or save vector and array results as either a new
% variable in an existing dataset or as a new dataset.
%%
%   createVar(obj,gobj,mobj);   %where gobj is an instance of the calling UI
%                               %and mobj is an instancec of the main UI.

%%
% *tabPlot* generates a plot for display on Q-Plot tab. Uses the default
% plotting method _tabDefaultPlot_ in <matlab:doc('muidataset') muiDataSet>.
%%
%   tabPlot(obj,src)            %abstract method required by muiDataSet

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muidataset') muiDataSet>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.
 