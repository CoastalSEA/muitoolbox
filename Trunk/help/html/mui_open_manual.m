function mui_open_manual()
%find the location of the toolbox and open the manual
fname = 'muiModelUI.m';
toolboxpath = which(fname);
fpath = [toolboxpath(1:end-length(fname)),['doc',filesep,'ModelUI_course.pdf']];
open(fpath)
