function template_folder()
%find the location of the example folder and open it
fname = 'muiModelUI.m';
toolboxpath = which(fname);
fpath = [toolboxpath(1:end-length(fname)),'muitemplates'];
open(fpath)