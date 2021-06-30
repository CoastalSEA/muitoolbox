
function [up,down] = zero_crossing(v,vthr)
%
%-------function help------------------------------------------------------
% NAME
%   zero_crossing.m
% PURPOSE
%   Function to calculate the zero-crossing. Used to calculate the up and
%   down crossings of a threshold for time series data
% USAGE
%   [up,down] = zero_crossing(v,vthr)
% INPUTS
%   v - timeseries
%   vthr - thresold to use for find up and down-crossings  
% OUTPUT
%   up and down are the index of the records for the up and down-crossing
%   of the threshold
% NOTES
%   
% SEE ALSO
%   getpeaks.m, getclusters.m, peakseek.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2018
%--------------------------------------------------------------------------
%
v0 = v-vthr+eps;   %adjust variable so that threshold is zero-crossings are
                   %missed for values where v=vthr because sign(v=0)
                   %returns zero. Hence eps added to avoid this problem
ups = diff(sign(v0))==2;     %zero-upcrossing
downs = diff(sign(v0))==-2;  %zero-downcrossing

%gaps mean that up and down may not be paired. Create a map +1 and -1 of
%ups and downs. Add NaN for where there is a missing member. Does NOT
%account for long gaps of multiple ups and downs. Just ensures that ups and
%downs are a set of ordered couples.
mask = zeros(length(v),1);
mask(ups) = 1;
mask(downs) = -1;
ud = find(abs(mask)>0);
for i=1:length(ud)-1
    if (mask(ud(i))+mask(ud(i+1)))~=0
        mask(ud(i)+1) = -sign(mask(ud(i)))*9;
    end
end
up = find(mask>0);     
down = find(mask<-0);

idup = find((mask(up)>1));
idwn = find(mask(down)<-1);
idx = sort([idup;idwn]);
up(idx) = [];
down(idx) = [];

if length(up)>length(down)  %this works for PoT because gaps do not matter
    up = up(1:end-1);
elseif length(up)<length(down)
    down = down(2:end);
end
