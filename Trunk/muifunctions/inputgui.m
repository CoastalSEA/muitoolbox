function selection = inputgui(varargin)
%
%-------function help------------------------------------------------------
% NAME
%   inputgui.m
% PURPOSE
%   provides access to the inputUI class to generate a mutli control input
%   user interface and return the selections made
% USAGE
%   selection = inputgui(varargin)
% INPUTS
%   Defined using varargin for the following fields
%    FigTitle        - title for the UI figure
%    Position        - position and size of figure (normalized units)
%    InputFields     - text prompt for input fields to be displayed
%    Style           - uicontrols for each input field (same no. as input fields)
%    ActionButtons   - text for buttons to take action based on selection
%    ControlButtons  - text for buttons to edit or update selection 
%    DefaultInputs   - default text or selection lists
%    UserData        - data assigned to UserData of uicontrol
%    PromptText      - text to guide user on selection to make
%    DataObject      - data object to use for selection
% OUTPUT
%   selection - selected Values or Strings depending on the uicontrol
%   specified in the input
% SEE ALSO
%   inputUI.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    obj = inputUI(varargin{:});
    waitfor(obj,'Action')
    selection = obj.UIselection;
    delete(obj.UIfig)  
end