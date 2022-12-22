function mui_open_manual()
%find the location of the asmita app and open the manual
fname = 'muiModelUI.m';
toolboxpath = which(fname);
fpath = [toolboxpath(1:end-length(fname)),'doc/muitoolbox manual.pdf'];
open(fpath)
