function lib = functionlibrarylist(mobj)
%
%-------function help------------------------------------------------------
% NAME
%   functionlibrarylist.m
% PURPOSE
%   Lists available functions for use in DataManip
% USAGE
%   lib = functionlibrarylist(mobj)
%INPUT
%   mobj - handle to calling model - use to subselect
%OUTPUT
%   lib - structure with library listings contains:
%       fname - function names
%       fvars - function input variables
%       fdesc - short description of function
%       nfunc - function id number
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
fname = {'moving(x,n)';... 
         'downsample(x,t,''period'',''method'')';...  
         'interpwithnoise(x,t,npad,scale,method,ispos) %time';...
         'subsample_ts(x,t,mobj) %time';...
         'conditional_subsample(x,t,thr,mobj) %time';...
         'phaseplot(x,y,t)';...
         'recursive_plot(x,''varname'',nint)';...         
         'addslrtotides(x,t,delta,exp-rate,pivot-year)';...
         'tidalrange(x,t,issave,isplot)';...
         'waterlevelfreqplots(x,t)';...
         'beachtransportratio(x,theta)';...
         'littoraldriftstats(x,t,''period'')';...  
         'posneg_dv_stats(x,t,''varname'')';...
         'userderivedoutput(t,x,y,z,flag)';...
         'z.*repmat(1,1,length(x),length(y))';...
         'z.*repmat(1,length(t)),length(x),length(y))';...
         '[Nan;diff(x,n,dim)]';...
         '[diff(x,n,dim);NaN]'};
 
fvars = {'Any variable, number of points to average over';...
         'Any variable, Time, period (year,month,day,hour,sec), method (eg mean)';...
         'Variable, Time, No of records, Noise scale factor, Interpolation method, +ve flag (true/false)';...
         'Variable, Time, mobj';...
         'Variable, Time, Threshold, mobj';...
         'Any variable, Any variable, time (optional)';...
         'Any variable, Name of variable, offset interval';...         
         'WaterLevels, Time, slr in 1900, exponential rate, pivot year';... 
         'WaterLevels, Time';...
         'WaterLevels, Time';...
         'Wave direction (degTN), Beach angle (degTN)';...         
         'Littoral drift, Time, period';...
         'Any +/-ve Variable, Time, variable name (optional)';...
         'Time,X,Y,Z, flag (''integral'' or ''gradient'')';...
         'X and Y are dimension variables and Z is Array variable (no rows)';...
         'X and Y are dimension variables, Z is Array variable and T is time';...
         'Variable to be differenced, nth difference, dimension to use';...
         'Variable to be differenced, nth difference, dimension to use'};        
       
fdesc = {'Moving average';...
         'Down-sample some function of a time series over defined interval';... 
         'Infill record by interpolating and adding noise';...
         'Subsample record at time intervals defined by another record';...
         'Subsample record based on threshold defined by another record';...
         'Phase plot of two variables as numbered or time-stamped sequence';...
         'Plot of a variable against an offset of itself';...        
         'Add sea level rise to a water level time series (uses exp fun)';...
         'Derive tidal range and mean values from water level timeseries';...
         'Selection of plots for water level frequency and duration';... 
         'Ratio of alongshore to cross-shore transport';...
         'Annual and monthly mean plots of littoral drift';... 
         'Rate of change of volume + plot erosion and accretion histograms';...
         'Compute the volume under surface at each time step';...
         'Sub-sample an array variable';...
         'Sub-sample a time dependent array variable';...
         'Differences assigned to the end of the difference interval';...
         'Differences assigned to the beginning of the difference interval'};

classmeta = metaclass(mobj);
classname = classmeta.Name;

%now define any subselection so that only valid functions are displayed
switch classname
    case 'InWave'
        idinc = [1:10,15:18];
    case 'CoastalTools'
        idinc = [1:13,15:18];
    case 'SpitDeltaSEM'
        idinc = [1:13,15:18];
    case 'Diffusion'
        idinc = [1,14:18];
    otherwise
        idinc = [1,15:18];
end

lib.fname = fname(idinc);
lib.fvars = fvars(idinc);
lib.fdesc = fdesc(idinc);
lib.nfunc = (1:size(lib.fname,1))'; 