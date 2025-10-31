function isok = initialise_mui_app(appname,msgtxt,varargin)
%
%-------function help------------------------------------------------------
% NAME
%   initialise_mui_app.m
% PURPOSE
%   intiailise paths for a mui App and supporting functions or check if on
%   the environment path if not installed
% USAGE
%   isok = initialise_mui_app(appname,msgtxt,varargin)
% INPUTS
%   modelname - name of mui App to be initialised
%   msgtxt - message to use if App is not found
%   varargin - additional sub-folders to include (eg for functions)
% OUTPUTS
%   isok - true if App successfully initialised or on path, false otherwise
% NOTES
%   only handles sub-folders so cannot include generic class or function folders
%   uses filesep to set file separator for current platform
% SEE ALSO
%   used in Asmita and ChannelForm
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2022
%--------------------------------------------------------------------------
%
    appinfo = matlab.apputil.getInstalledAppInfo;
    if isempty(appinfo)
        %check if on the environment path
        isok = exist(appname,'file')==2;
        if ~isok, warndlg(msgtxt); end
        return;         
    end

    idx = find(strcmp({appinfo(:).name},appname));
    if isempty(idx)
        %check if on the environment path
        isok = exist(appname,'file')==2;
        if ~isok, warndlg(msgtxt); end
        return;         
    end
    
    path{1} = appinfo(idx(1)).location;
    if isfolder([path{1},filesep,appname])
        %Matlab installs the App as a subfolder of the App folder if there
        %are folders included that are on the same level (ie not subfolders)
        path{1} = [path{1},filesep,appname,filesep,'app'];
    end
    
    path{2} = [path{1},filesep,'doc'];
    path{3} = [path{1},filesep,'help',filesep,'html'];
    path{4} = [path{1},filesep,'example'];
    for i=1:length(varargin)
        path{4+i} = [path{1},filesep,varargin{i}];
    end

    addpath(path{:});

    clear path

    isok = true;

    
end