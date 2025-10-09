function selectedFig = select_figure(validTags,invalidTags)
%
%-------function help------------------------------------------------------
% NAME
%   select_figure.m
% PURPOSE
%   allow the user to interactively select an existing figure and control
%   the selection using valid Tags
% USAGE
%   selectedFig = select_figure(validTags,invalidTags)
% INPUTS
%   validTags - cell array of strings, e.g. {'PlotFig','TargetFig'}
%               optional - if not included in call or empty, selects any figure
%   invalidTags - cell array of strings, e.g. {'MainFig','UnwantedFig'}
%               optional - if not included in call, no figures are excluded
% OUTPUT
%   selectedFig - handle to the selected figure with a valid Tag
% NOTES
%    modified from code suggested by Smart(GPT-5)
% SEE ALSO
%   called in ctBeachProfileData when plotting profile locations onto an
%   existing figure
%
% Author: Ian Townend
% CoastalSEA (c) Oct 2025
%--------------------------------------------------------------------------
%
    if nargin<1        
        validTags = [];
        invalidTags = [];
    elseif nargin<2
        invalidTags = [];    
    end

    figs = findall(0,'Type','figure');  %all open figures
    if ~isempty(invalidTags)            %remove invlid figures
        idx = matches({figs(:).Tag},invalidTags);
        figs(idx) = [];
    end
    if isempty(figs), return; end      %no figures available

    prmptxt = 'Select figure to use';
    hd = setdialog(prmptxt);     
    % Assign a temporary callback to each figure
    for f = figs'
        oldFcn = get(f,'WindowButtonDownFcn');
        setappdata(f,'OldWBDFcn',oldFcn);   % store old callback
        f.WindowButtonDownFcn = @(src,evt) localClickCallback(src,evt,hd,validTags);
    end
    
    uiwait(hd);  % Block until uiresume is called in callback
    
    % Retrieve the selected object from appdata
    selectedFig = getappdata(0,'SelectedObj');
    
    % Clean up
    rmappdata(0,'SelectedObj');
    delete(hd)
    for f = figs'
        if isappdata(f,'OldWBDFcn') % Restore original callbacks
            f.WindowButtonDownFcn = getappdata(f,'OldWBDFcn');
            rmappdata(f,'OldWBDFcn');
        end
    end    
end

%%
function localClickCallback(src,~,hd,validTags)
    %callback function assigned to figures when targetted for selection
    clickedObj = src;
    if isempty(clickedObj) || ~isgraphics(clickedObj)
        return
    end
    %check that figure has a valid Tag
    if isempty(validTags) 
        %user has not defined a valid tag so return selected figure
        setappdata(0,'SelectedObj',clickedObj);
        uiresume(hd);
    elseif any(strcmp(get(clickedObj,'Tag'),validTags))
        setappdata(0,'SelectedObj',clickedObj);
        uiresume(hd);
    end
end

