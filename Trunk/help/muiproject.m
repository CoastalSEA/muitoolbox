%% muiMProject
% Class to hold project details

%% Syntax
% obj = muiProject;

%% Description
% Holds details of the current project name, date the project was setup and
% details of the path and file name if the loaded from a mat file or saved
% to a mat file.

%% muiProject properties
% *PathName* - path for user selected project mat file.  <br> 
% *FileName* - user selected project mat file.  <br> 
% *ProjectName* - project name defined in model setup: File>New.  <br> 
% *ProjectDate* - date project was set up

%% muiProject methods
% *editProject* - dialog box to edit project name and date. This is called from
% Project>Project Info menu in the <matlab:doc('modelui') ModelUI> App.
%%
%   editProject(obj);

%% See Also
% <matlab:doc('muitoolbox') muitoolbox><matlab:doc('muicatalogue') muiCatalogue>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.