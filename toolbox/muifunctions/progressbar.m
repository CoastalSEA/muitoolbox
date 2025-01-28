function pobj = progressbar(mobj,pobj,msgtxt,titletxt)
%
%-------function help------------------------------------------------------
% NAME
%   progressbar.m
% PURPOSE
%   displays a determinate progress dialog box in figure and returns
%   the ProgressDialog object. The figure must be created using the 
%   uifigure function.  
% USAGE
%   pobj = progressbar([],msgtxt); to intialise the progress bar
%   progressbar(pobj);  to close the progress bar
% INPUTS
%   pobj = empty to initialise and the ProgressDialogue dialog object to delete
%   msgtxt - message text to be displayed in dialog box (optional) 
%   titletxt - dialog box title - default is 'Please wait' (optional)
% OUTPUT
%   pobj - ProgressDialogue object (see uiprogressdlg for details)
% SEE ALSO
%   alternative to waitbar where number of iterations are not explicit in
%   code
%   
% Author: Ian Townend
% CoastalSEA (c) Jan 2025
%--------------------------------------------------------------------------
%
    if isa(pobj,'matlab.ui.dialog.ProgressDialog')
        close(pobj)
        delete(mobj.mUI.Figure.UserData)
        mobj.mUI.Figure.UserData = [];
    else
        if nargin<3
            msgtxt = '';
            titletxt = 'Please wait';
        elseif nargin<4
            titletxt = 'Please wait';
        end
    
        hfig = uifigure('Tag','ProgressBarFigure');
        mobj.mUI.Figure.UserData = hfig;
        pobj = uiprogressdlg(hfig,'Title',titletxt,'Message',msgtxt,...
                                                   'Indeterminate','on'); 
        drawnow
    end
end
