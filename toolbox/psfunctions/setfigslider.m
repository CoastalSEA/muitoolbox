function hm = setfigslider(hfig,invar)
%
%-------function help------------------------------------------------------
% NAME
%   setfigslider.m
% PURPOSE
%   initialise a slider on a figure with the option to include text
%   displaying the current slider value and an action button
% USAGE
%   setfigslider(varargin)
% INPUTS
%   hfig - handle to figure or graphic object such as panel or tab
%   invar - stuct to define inputs and format of slider
%           invar.sval = ;     %initial value for slider 
%           invar.smin = ;     %minimum slider value
%           invar.smax = ;     %maximum slider value
%           invar.size = ;     %stepsize for slider eg[0.1,0.1] (optional)
%           invar.callback = ; %callback function for slider to use
%           invar.userdata = ; %pass userdata if required
%           invar.position = ; %position of slider
%           invar.stext = ;    %text to display with slider value, if included
%           invar.butxt = ;    %text for button if included
%           invar.butcback = ; %callback for button
% OUTPUT
%   creates slider on graphical object defined by hfig
%   hm - handle to the unicontrols initialised 
% NOTES
%   deleted any existing figslider when called
%   defaults struct is
%   invar = struct('sval',[],'smin',[],'smax',[],'size', [],...
%                  'callback','','userdata',[],'position',[],...
%                  'stxext','','butxt','','butcback','');
%          default position = [0.15,0.005,0.64,0.04]; 
% to include graphics on the figure with a slider in the default position
% reposition the axes using: ax.Position = [0.16,0.18,0.65,0.75]; assuming
% normalized units are being used
% SEE ALSO
%   used in CSTrunmodel, CSTdataimport, CSThydraulics, River
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
%
    %check if a figslider already exists and delete if it does
    hm1 = findobj(hfig,'Tag','figslider');
    hm2 = findobj(hfig,'Tag','figslidertxt');
    hm3 = findobj(hfig,'Tag','figsliderval');
    hm4 = findobj(hfig,'Tag','figsliderbut');
    delete([hm1,hm2,hm3,hm4])
    
    %check whether default slider position is being used
    if isempty(invar.position)
        invar.position = [0.15,0.005,0.64,0.04];
    end
    
    if isdatetime(invar.sval) || isduration(invar.sval)
        invar = convertTime(invar);
    end   
    
    %add stepsize if not defined
    if isempty(invar.size)
        stepsize = [1 1]/(invar.smax-invar.smin);
    else
        stepsize = invar.size;
    end
    
    %add slider to figure
    hm(1) = uicontrol('Parent',hfig,...
            'Style','slider','Value',invar.sval,... 
            'Min',invar.smin,'Max',invar.smax,'sliderstep',stepsize,...
            'Callback', invar.callback,'UserData',invar.userdata,...            
            'Units','normalized', 'Position',invar.position,...
            'Tag','figslider');
    count = 2;
    
    %add slider text if included
    if ~isempty(invar.stext)
        valtxt = num2str(invar.sval);
        if length(valtxt)>length(invar.stext)
            tlen = 0.4;  %weighting if value text is longer
        else
            tlen = 0.6;  %weighting if description text is longer
        end
        p1 = invar.position(1)+invar.position(3);
        pend = 1-p1;
        p2 = invar.position(2)-0.002;
        txtpos = [p1,p2,pend*tlen,0.045];
        valpos = [p1+pend*tlen,p2,pend*(1-tlen),0.045];
        hm(count) = uicontrol('Parent',hfig,...
            'Style','text','String',invar.stext,'FontSize',10,...
            'Units','normalized','Position',txtpos,... 
            'HorizontalAlignment','right','Tag','figslidertxt');
        hm(count+1) = uicontrol('Parent',hfig,...
            'Style','text','String',num2str(invar.sval),'FontSize',10,...
            'Units','normalized','Position',valpos,... 
            'HorizontalAlignment','left','Tag','figsliderval'); 
        count = 4;
    end
    
    %add button if included
    if ~isempty(invar.butxt)
        butpos(1) = invar.position(1)-0.12;
        butpos(2) = invar.position(2);
        butpos(3:4) = [0.1,0.05];
        hfig.Units = 'normalized';
        hm(count) = setactionbutton(hfig,invar.butxt,butpos,...
                                   invar.butcback,'figsliderbut');                        
    end
end
%%
function invar = convertTime(invar)
    %adjust the input parameters that are datetime or duration
    invar.sval = time2num(invar.sval);
    invar.smin = time2num(invar.smin);
    invar.smax = time2num(invar.smax);
end

%% sample code to call sefigslider and update a plot
%%
%         function hm = setSlideControl(obj,hfig,qmin,qmax,qin)
%             %intialise slider to set different values   
%             invar = struct('sval',[],'smin',[],'smax',[],'size', [],...
%                            'callback','','userdata',[],'position',[],...
%                            'stxext','','butxt','','butcback','');            
%             invar.sval = qin;      %initial value for slider 
%             invar.smin = qmin;     %minimum slider value
%             invar.smax = qmax;     %maximum slider value
%             invar.callback = @(src,evt)updateAplot(obj,src,evt); %callback function for slider to use
%             invar.userdata = qin;  %pass userdata if required 
%             invar.position = [0.15,0.005,0.45,0.04]; %position of slider
%             invar.stext = 'River discharge = ';   %text to display with slider value, if included          
%             invar.butxt =  'Save';    %text for button if included
%             invar.butcback = @(src,evt)saveanimation2file(obj.ModelMovie,src,evt); %callback for button
%             hm = setfigslider(hfig,invar);   
%         end   
%%
%         function updateAplot(obj,src,~)
%             %use the updated slider value to adjust the plot
%             stxt = findobj(src.Parent,'Tag','figsliderval');
%             Q = round(src.Value);
%             stxt.String = num2str(Q);     %update slider text
% 
%             sldui = findobj(src.Parent,'Tag','figslider');
%             sldata = sldui.UserData;     %recover userdata
% 
%             %figure axes and update plot
%             figax = findobj(src.Parent,'Tag','PlotFigAxes'); 
%             somePlot(obj,figax,Q,sldata)
%         end