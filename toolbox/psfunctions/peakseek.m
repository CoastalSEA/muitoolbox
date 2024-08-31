function [locs,pks]=peakseek(x,minpeakdist,minpeakh)
%
%-------function help------------------------------------------------------
% NAME
%   peakseek.m
% PURPOSE
%   Alternative to the findpeaks function.  
% USAGE
%   [locs,pks]=peakseek(x,minpeakdist,minpeakh)
% INPUTS
%   x - a vector input (generally a timecourse)
%   minpeakdist - the minimum desired distance between peaks (optional, defaults to 1)
%   minpeakh - the minimum height of a peak (optional)   
% OUTPUT
%   locs - index of the peaks in x
%   pks - the values of the peaks
% NOTES
%   This function runs much much faster. It also can handle ties between
%   peaks.  Findpeaks just erases both in a tie.
% SEE ALSO
%   findpeak.m, peaksoverthreshold.m
%
% (c) 2010
% Peter O'Connor
% peter<dot>ed<dot>oconnor .AT. gmail<dot>com
%--------------------------------------------------------------------------
%
    if size(x,2)==1, x=x'; end

    % Find all maxima and ties
    locs=find(x(2:end-1)>=x(1:end-2) & x(2:end-1)>=x(3:end))+1;

    if nargin<2, minpeakdist=1; end % If no minpeakdist specified, default to 1.

    if nargin>2 % If there's a minpeakheight
        locs(x(locs)<=minpeakh)=[];    %remove peaks that are below threshold
    end
    %
    if minpeakdist>1   %check the distance beteen peaks using index spacing
        while 1
            del=diff(locs)<minpeakdist;

            if ~any(del), break; end

            pks=x(locs);

            [garb,mins]=min([pks(del) ; pks([false del])]); %#ok<ASGLU>

            deln=find(del);

            deln=[deln(mins==1) deln(mins==2)+1];

            locs(deln)=[];
        end
    end
    %
    if nargout>1       %second output, the peaks, if requested
        pks=x(locs);
    end
end