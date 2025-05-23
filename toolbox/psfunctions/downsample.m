function [tout,var] = downsample(Z,t,varargin)
%
%-------function help------------------------------------------------------
% NAME
%   downsample.m
% PURPOSE
%   wrapper to put downsample_ts, by Chad A. Greene, output into an array
% USAGE
%   [tout,var] = downsample(Z,t,varargin)
%   [tout,var] = downsample(Z,t,'month','nanmean');
% INPUT
%   Z - variable to downsample
%   t - time 
%   varargin - sampling period and method to use (eg mean)
%              %NB to omit NaNs use nanXXX as the method 
% OUTPUT
%   tout -  each value in tout is the mean time of all data contributing to 
%   the variable, var, for the sampling interval
%   var - variable at the defined sampling interval
% NOTES
%   Calls downsable_ts as a sub-function. This function was written by 
%   Chad A. Greene of the University of Texas at Austin's Insititue for 
%   Geophysics (UTIG) and downloaded from the Matlab Forum. 
%   Function modified to remove dependency on nanXXX functions and
%   Statistics Toolbox. Calls still use 'nanXXX to apply the 'omitnan' 
%   option.(May'25)
%
% Author: Ian Townend
% CoastalSEA (c)June 2015
%----------------------------------------------------------------------
%
    %t = datenum(t); %muiUserModel passes datetime
    if nargin>2
        period = varargin{1};
        if length(varargin)>1
            method = varargin{2};
            [Z_downsamp,t_downsamp] = downsample_ts(Z,t,period,method);
        else
            [Z_downsamp,t_downsamp] = downsample_ts(Z,t,period);
        end
    else
        [Z_downsamp,t_downsamp] = downsample_ts(Z,t);
    end
    %DataManip requires a matrix or cell array with time in datetime format as
    %the first variable
    % var = {datetime(t_downsamp,'ConvertFrom','datenum'),Z_downsamp'};
    var = Z_downsamp';
    tout = datetime(t_downsamp,'ConvertFrom','datenum');
end
%%
function [Z_downsamp,t_downsamp] = downsample_ts(Z,t,varargin)
% downsample_ts function downsamples 1D or 3D data to monthly, yearly, hourly,
% minutely, or secondly data. This function was originally designed to
% create monthly mean time series from daily geospatial climate data. 
% 
%% Syntax 
% 
%  Z_downsamp = downsample_ts(Z,t)
%  Z_downsamp = downsample_ts(...,'DownsamplingPeriod')
%  Z_downsamp = downsample_ts(...,'function')
%  [Z_downsamp,t_downsamp] = downsample_ts(...)
% 
%% Description 
% 
% Z_downsamp = downsample_ts(Z,t) downsamples Z, which must be 
% provided with a corresponding time vector t.  Z can be 1D if its
% length matches the length of t.  If Z is three-dimensional, the 
% length of its third dimension must match the length of t. For geospatial 
% climate data arrays, dimensions of Z might correspond to lat x lon x time or 
% lon x lat x time.  
%
% Z_downsamp = downsample_ts(...,'DownsamplingPeriod') specifies a
% downsampling period as 
% 
% * 'year' 
% * 'month' (default)  
% * 'day' 
% * 'hour' 
% * 'minute' 
% * 'second' 
% 
% Z_downsamp = downsample_ts(...,'function') specifies a function to
% perform on the data. By default, monthly averages are taken, but you may
% wish to return the monthly median or monthly standard deviation or any of
% the functions listed below.
% 
% A note on functions which ignore NaNs: To get the monthly means of data
% while ignoring NaN values, you can use the 'nanmean' option. In all, the
% following functions are available: 
% 
%     * 'mean' (default) 
%     * 'nanmean' ignores NaN values in Z. applies 'omitnan' 
%     * 'median' 
%     * 'nanmedian' ignores NaN values in Z. Requires Statistics toolbox or NaN Suite. 
%     * 'min' 
%     * 'nanmin' ignores NaN values in Z. Requires Statistics toolbox. 
%     * 'max' 
%     * 'nanmax' ignores NaN values in Z. Requires Statistics toolbox. 
%     * 'std' standard deviation. 
%     * 'nanstd' ignores NaN values in Z. Requires Statistics toolbox. 
%     * 'var' variance. 
%     * 'nanvar' ignores NaN values in Z. Requires Statistics toolbox. 
%     * 'mode'  
%     * 'sum'
%     * 'nansum'
%
% [Z_downsamp,t_downsamp] = downsample_ts(...) also returns a time array
% corresponding to Z_downsamp. If Z is 3D or, t_downsamp corresponds
% to the third dimension of Z_downsamp. Each value in t_downsamp
% represents the mean time of all data contributing to that slice of
% Z_downsamp.  
% 
%% Example: Downsample daily data to monthly means: 
% 
% t = datenum(2000,1,1:3*365); % 3 yrs of daily data
% y = 10+5*sin(t*pi/365)+rand(size(t));
% plot(t,y) 
% datetick
% hold on; box off
% 
% [y_monthlymean,t_monthly] = downsample_ts(y,t); 
% plot(t_monthly,y_monthlymean,'ro-')
% 
%% Author Info
% This function was written by Chad A. Greene of the University 
% of Texas at Austin's Insititue for Geophysics (UTIG). 
% Updated December 30, 2014 to include sum and nansum capability. 
% 
% See also mean, datenum, and accumarray. 

%% Input error checks: 

narginchk(2,4)
assert(isnumeric(Z),'Input data3D must be numeric.')
assert(isvector(t),'Input time array must be a 1D array.') 
assert(isvector(Z)|ndims(Z)==3,'Input data3D must be a 1D array or a 3D matrix.') 

Zdims = ndims(Z); 
assert(Zdims<4,'Z must be 1D or 2D.') 
if Zdims==3
    assert(size(Z,3)==length(t),'Length of t must match dimension 3 of input data matrix.')
else
    assert(length(Z)==length(t),'Length of t must match length of input data.') 
end

%% Input manipulation: 

% Convert (assumed) date strings to datenums if necessary: 
if ischar(t) || isdatetime(t)
    t = datenum(t); 
end

% Transpose t to have a consistent starting point: 
t_is_row = false; 
if isrow(t) 
    t_is_row = true; 
    t = t'; 
end

%% Parse optional inputs: 

DownsamplingPeriod = 'monthly'; % default monthly averages
if any(strncmpi(varargin,'y',1)+strncmpi(varargin,'an',2))
    DownsamplingPeriod = 'yearly'; 
end
if any(strncmpi(varargin,'da',2))
    DownsamplingPeriod = 'daily'; 
end
if any(strncmpi(varargin,'h',1))
    DownsamplingPeriod = 'hourly'; 
end
if any(strncmpi(varargin,'minute',4))
    DownsamplingPeriod = 'minutely'; 
end
if any(strncmpi(varargin,'sec',3))
    DownsamplingPeriod = 'secondly'; 
end

method = 'mean'; % mean is default. 
if any(strcmpi(varargin,'nanmean'))
    method = 'nanmean'; 
end
if any(strncmpi(varargin,'med',3))
    method = 'median'; 
end
if any(strncmpi(varargin,'nanmed',6))
    method = 'nanmedian'; 
end
if any(strncmpi(varargin,'max',3))
    method = 'max'; 
end
if any(strcmpi(varargin,'nanmax'))
    method = 'nanmax'; 
end
if any(strncmpi(varargin,'min',3))
    method = 'min'; 
end
if any(strcmpi(varargin,'nanmin'))
    method = 'nanmin'; 
end
if any(strcmpi(varargin,'std'))
    method = 'std'; 
end
if any(strcmpi(varargin,'nanstd'))
    method = 'nanstd'; 
end
if any(strncmpi(varargin,'var',3))
    method = 'var'; 
end
if any(strcmpi(varargin,'nanvar'))
    method = 'nanvar'; 
end
if any(strcmpi(varargin,'mode'))
    method = 'mode'; 
end
if any(strcmpi(varargin,'sum'))
    method = 'sum'; 
end
if any(strcmpi(varargin,'nansum'))
    method = 'nansum'; 
end

%% Begin calculations: 

[y,mo,d,h,mi,s] = datevec(t); 

switch DownsamplingPeriod
    case 'yearly'
        if max(diff(t))>367
            warning('Some time steps in input t are more than a year apart. This may cause strange results when taking yearly averages.'); 
        end
        CompArray = datenum(y,1,1); % array for comparison. Has unique values of ut and length of t.  
        
    case 'monthly'
        if max(diff(t))>60
            warning('Some time steps in input t are more than a 60 days apart. This may cause strange results when taking monthly averages.'); 
        end
        CompArray = datenum(y,mo,1); 
        
    case 'daily'
        if max(diff(t))>2
            warning('Some time steps in input t are more than a 2 days apart. This may cause strange results when taking daily averages.'); 
        end
        CompArray = datenum(y,mo,d); 
        
    case 'hourly'
        if max(diff(t))>1/12
            warning('Some time steps in input t are more than a 2 hours apart. This may cause strange results when taking hourly averages.'); 
        end
        CompArray = datenum(y,mo,d,h,1,1); 
        
    case 'minutely'
        if max(diff(t))>1/(24*30)
            warning('Some time steps in input t are more than a 2 minutes apart. This may cause strange results when taking averages of every minute.'); 
        end
        CompArray = datenum(y,mo,d,h,mi,1); 
        
    case 'secondly'
        if max(diff(t))>1/(24*30*60)
            warning('Some time steps in input t are more than a 2 seconds apart. This may cause strange results when taking averages of every second.'); 
        end
        CompArray = datenum(y,mo,d,h,mi,s); 
end

ut = unique(CompArray); % array of unique downsamplin' times. 

%% Preallocate outputs: 

if Zdims==3
    Z_downsamp = NaN(size(Z,1),size(Z,2),length(ut)); 
else
    Z_downsamp = NaN(1,length(ut)); 
end
    
if nargout==2
    if isrow(t)
        t_downsamp = NaN(1,length(ut)); 
    else
        t_downsamp = NaN(length(ut),1); 
    end
end

%% Compute means or otherwise for each unique output time: 

for k = 1:length(ut)
    switch method
        case 'mean'
            if Zdims==3
                Z_downsamp(:,:,k) = mean(Z(:,:,CompArray==ut(k)),3); 
            else
                Z_downsamp(k) = mean(Z(CompArray==ut(k))); 
            end
            
        case 'nanmean'
            if Zdims==3
                Z_downsamp(:,:,k) = mean(Z(:,:,CompArray==ut(k)),3,'omitnan'); 
            else
                Z_downsamp(k) = mean(Z(CompArray==ut(k)),'omitnan'); 
            end

        case 'median'
            if Zdims==3
                Z_downsamp(:,:,k) = median(Z(:,:,CompArray==ut(k)),3); 
            else
                Z_downsamp(k) = median(Z(CompArray==ut(k)));
            end
            
        case 'nanmedian'
            if Zdims==3
                Z_downsamp(:,:,k) = median(Z(:,:,CompArray==ut(k)),3,'omitnan'); 
            else
                Z_downsamp(k) = median(Z(CompArray==ut(k)),'omitnan'); 
            end
            
        case 'max' 
            if Zdims==3
                Z_downsamp(:,:,k) = max(Z(:,:,CompArray==ut(k)),[],3); 
            else
                Z_downsamp(k) = max(Z(CompArray==ut(k))); 
            end
            
        case 'nanmax' 
            if Zdims==3
                Z_downsamp(:,:,k) = max(Z(:,:,CompArray==ut(k)),[],3,'omitnan'); 
            else
                Z_downsamp(k) = max(Z(CompArray==ut(k)),[],'omitnan'); 
            end
            
        case 'min' 
            if Zdims==3
                Z_downsamp(:,:,k) = min(Z(:,:,CompArray==ut(k)),[],3);
            else
                Z_downsamp(k) = min(Z(CompArray==ut(k)));
            end
            
        case 'nanmin' 
            if Zdims==3
                Z_downsamp(:,:,k) = min(Z(:,:,CompArray==ut(k)),[],3,'omitnan');
            else
                Z_downsamp(k) = min(Z(CompArray==ut(k)),[],'omitnan');
            end
            
        case 'std' 
            if Zdims==3
                Z_downsamp(:,:,k) = std(Z(:,:,CompArray==ut(k)),0,3);
            else
                Z_downsamp(k) = std(Z(CompArray==ut(k)));
            end
            
        case 'nanstd' 
            if Zdims==3
                Z_downsamp(:,:,k) = std(Z(:,:,CompArray==ut(k)),0,3,'omitnan');
            else
                Z_downsamp(k) = std(Z(CompArray==ut(k)),0,'omitnan');
            end
            
        case 'var' 
            if Zdims==3
                Z_downsamp(:,:,k) = var(Z(:,:,CompArray==ut(k)),0,3);
            else
                Z_downsamp(k) = var(Z(CompArray==ut(k)));
            end
            
        case 'nanvar' 
            if Zdims==3
                Z_downsamp(:,:,k) = var(Z(:,:,CompArray==ut(k)),0,3,'omitnan');
            else
                Z_downsamp(k) = var(Z(CompArray==ut(k)),0,'omitnan');
            end
            
        case 'mode' 
            if Zdims==3
                Z_downsamp(:,:,k) = mode(Z(:,:,CompArray==ut(k)),3);
            else
                Z_downsamp(k) = mode(Z(CompArray==ut(k)));
            end
            
        case 'sum'
            if Zdims==3
                Z_downsamp(:,:,k) = sum(Z(:,:,CompArray==ut(k)),3);
            else
                Z_downsamp(k) = sum(Z(CompArray==ut(k)));
            end
            
        case 'nansum'
            if Zdims==3
                Z_downsamp(:,:,k) = sum(Z(:,:,CompArray==ut(k)),3,'omitnan');
            else
                Z_downsamp(k) = sum(Z(CompArray==ut(k)),'omitnan');
            end          
    end

    if nargout==2
        t_downsamp(k) = mean(t(CompArray==ut(k))); 
    end
end

%% Ensure direction of t_downsamp matches direction of t:  

if nargout==2 && t_is_row
    t_downsamp = t_downsamp'; 
end

end

