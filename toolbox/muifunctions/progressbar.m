function prog = progressbar(prog,msgtxt,titletxt)
%
%-------function help------------------------------------------------------
% NAME
%   progressbar.m
% PURPOSE
%   displays a determinate progress dialog box in figure and returns
%   the ProgressDialog object. The figure must be created using the 
%   uifigure function.  
% USAGE
%   prog = progressbar([],msgtxt); to intialise the progress bar
%   progressbar(prog);  to close the progress bar
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
    if isempty(prog)
        if nargin<3
            msgtxt = '';
            titletxt = 'Please wait';
        elseif nargin<4
            titletxt = 'Please wait';
        end
    
        prog.hfig = uifigure;
        prog.pobj = uiprogressdlg(prog.hfig,'Title',titletxt,'Message',msgtxt,...
                                                   'Indeterminate','on'); 
        drawnow
    else
        close(prog.pobj)
        close(prog.hfig)
    end
end