function [tpad,vpad] = interpwithnoise(v,t,npad,scale,method,ispos)
%-------header-------------------------------------------------------------
% NAME
% interpwithnoise.m
% PURPOSE
%   Insert additional records into a timeseries interpolating between 
%   existing values and adding noise to the values added
% USAGE
%   ts = interpwithnoise(v,t,npad,scale,method,ispos)
% INPUT
%   v - data variable
%   t - time
%   npad - number of records to insert in each existing interval
%   scale - magnitude of the random noise (eg =0.5: -0.5 to +0.5)
%   method - interpolation method used in interp1 (optional, default = linear)
%   ispos - negative values set to zero if true (optional, default=false)
% OUTPUT
%   tpad - time for the interpolated variable
%   vpad - interpolated values with noise
% 
% Author: Ian Townend
% CoastalSEA (c)June 202
%--------------------------------------------------------------------------
%
    if nargin<5
        method = 'linear';
        ispos = false;
    elseif nargin<6
        ispos = false;
    elseif isempty(method)
        method = 'linear';
    end
    newreclen = (npad+1)*(length(t)-1)+1;
    idpad = 1:npad+1:newreclen;
    idx = 1:newreclen;
    tpad = interp1(idpad',t,idx',method);
    vpad = interp1(idpad',v,idx',method);
    %add some gaussian noise
    ins = 1:newreclen;
    ins(idpad)=[];
    rnums = -scale + 2*scale*rand(length(ins),1);
    delv = diff(v);
    dvpad = zeros(newreclen,1);
    for i=1:npad
        dvpad(i+1:npad+1:newreclen-1-(npad-i)) = delv;
    end
    dvpad(idpad) = [];
    vpad(ins) = vpad(ins)+dvpad.*rnums;
    %if variable can only be positive, trap negative values produced by
    %addition of noise
    if ispos
        vpad(vpad<0) = 0;
    end
end
