function ok = initialise_mui_app(appname,msgtxt,varargin)
%
%-------function help------------------------------------------------------
% NAME
%   initialise_mui_app.m
% PURPOSE
%   intiailise paths for a mui App and supporting functions
% USAGE
%   initialise_mui_app(appname,msgtxt,varargin)
% INPUTS
%   modelname - name of mui App to be initialised
%   msgtxt - message to use if App is not found
%   varargin - additional sub-folders to include (eg for functions)
% NOTES
%   only handles sub-folders so cannot include generic class or function folders
% SEE ALSO
%   used in Asmita and ChannelForm
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2022
%--------------------------------------------------------------------------
%
    appinfo = matlab.apputil.getInstalledAppInfo;
    if isempty(appinfo), ok = 0; warndlg(msgtxt); return; end

    idx = find(strcmp({appinfo.name},appname));
    path{1} = appinfo(idx(1)).location;
    path{2} = [path{1},'/doc'];
    path{3} = [path{1},'/help/html'];
    path{4} = [path{1},'/example'];
    for i=1:length(varargin)
        path{4+i} = [path{1},'/',varargin{i}];
    end

    addpath(path{:});

    clear path

    ok = 1;
end