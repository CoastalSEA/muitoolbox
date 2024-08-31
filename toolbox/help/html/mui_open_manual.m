function mui_open_manual()
%find the location of the dstoolbox and the introducton pdf
fname = 'muiModelUI.m';
toolboxpath = which(fname);
fpath = [toolboxpath(1:end-length(fname)),'doc'];
fpath = [fpath,filesep,'Introduction_to_muitoolbox.pdf'];
try
    open(fpath)
catch
    msg = sprintf('Introduction to muuitoolbox file not found here:\n%s',fpath);
    msgbox(msg)
end

