function mui_template_folder()
%find the location of the example folder and open it
fname = 'muiModelUI.m';
toolboxpath = which(fname);
fpath = [toolboxpath(1:end-length(fname)),'muitemplates'];
try
    winopen(fpath)
catch
    msg = sprintf('The examples can be found here:\n%s',fpath);
    msgbox(msg)
end