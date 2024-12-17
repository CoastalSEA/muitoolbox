function Vout = editrange_ui(Vin,selist)
%
%-------function help------------------------------------------------------
% NAME
%   editrange_ui.m
% PURPOSE
%   test whether Vin is datetime and if so use datepicker otherwise use  
%   inputdlg to let user edit range values
% USAGE
%   Vout = editrange_ui(Vin,selist)
% INPUT
%   Vin - cell array of start and end values of range
%   selist - cell array of text vectors to select from (optional)
% OUTPUT
%   Vout - cell array of start and end values of range
% NOTES
%   called by editrange.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    Vout = Vin;
    if isa(Vin{1},'datetime')
        title = {'From:','To:'};
        for i=1:2
            %uigetdate is from Matlab Forum (copyright Elmar Tarajan)
            ti = datetime(uigetdate(Vin{i},title{i}),'ConvertFrom','datenum');
            ti.Format = Vin{i}.Format;
            Vout{i} = ti;
        end
    elseif nargin>1 && islist(selist,3) %3 - cellstr, string, categorical
        h_inp = inputUI('FigureTitle', 'Edit range',...
			            'PromptText','Select start and end of range:',...
			            'InputFields',{'From: ','To: '},...
                        'InputOrder',[],...
			            'Style',{'popupmenu','popupmenu'},...
			            'ControlButtons',{'',''},...
			            'DefaultInputs',{selist,selist},...
			            'ActionButtons',{'Select','Cancel'});

        waitfor(h_inp,'Action')
        if ~isempty(h_inp.UIselection)  %selection made
            Vout = selist([h_inp.UIselection{:}]);
            if ~iscell(Vout)
                Vout = {Vout(1),Vout(2)};
            end
        end
        delete(h_inp.UIfig) %delete figure even if user cancels
    else                 %otherwise use input dialogue
        dtype = getdatatype(Vin);
        if isnumeric(Vin{1}) || islogical(Vin{1})
            %replaced use of cellfun to avoid rounding error in num2str
            sp = max(getprecision([Vin{:}])); %number of significant places
            Vin{1} = num2str(Vin{1},sp);
            Vin{2} = num2str(Vin{2},sp);
        elseif ~ischar(Vin{1})
            Vin = cellfun(@cellstr,Vin);
        end
        newvalues = inputdlg({'From:','To:'},'Edit range',1,Vin);

        if ~isempty(newvalues)
            Vout = setdatatype(newvalues,dtype);
        end
    end
end