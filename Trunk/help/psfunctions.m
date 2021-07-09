%% Plotting and statistical functions
% Summary of the functions available in the _psfunctions_ folder. Use the Matlab(TM)
% help function in the command window to get further details of each
% function.

%%
% * *clusters.m*
% - function to find clusters of peaks over a threshold
%
% * *cmap_selection.m*
% - select a color map definition from Matlab(TM) default list and cbrewer
% generated mat files
%
% * *complex_vectors.m*
% - creates a polar plot of the movement at each interval from one position
% to the next
%
% * *descriptive_stats.m*
% - generate descriptive stats table for timeseries or table of a variable
%
% * *extreme_stats.m*
% - compute extreme values for a range of return periods using the GPD
% method (General Pareto Distrtibution)
%
% * *fittedtitle.m*
% - fit title text to the width of a figure (handles title and sgtitle).
%
% * *getclusters.m*
% - identify cluster in a timeseries with options to adjust threshold, 
% method of selection and interval between clusters
%
% * *getpeaks.m*
% - find peak in a timeseries with options to adjust threshold, 
% method of selection and interval between peaks
% 
% * *godisplay.m*
% - display the legend name or DisplayName of the selected graphical object
% 
% * *mcolor.m*
% - select a default Matlab(TM) color definition from table
%
% * * mgpdfit.m*
% - maximum likelihood estimate of the fit parameters for a GPD and compute return period
% estimates and confidence intervals (user prompt for plotted output)
%
% * *peakseek.m* 
% - alternative to the findpeaks function. From Matlab(TM) Forum, 
% Peter O'Connor, (c) 2010.
%
% * *peaksoverthreshold.m*
% - function to find the peaks over a threshold, v_thr, and return 
% these values, or the index of the these values, for the vector, var. 
%
% * *phaseplot.m*
% - variation of x and y with time. e.g. centroid of beach profiles or 
% recursive plots such as x = x(t) v  y = x(t+1)  
%
% * *poisson_stats.m*
% - compute the inter-arrival time, magnitude and duration of
% events assuming that they are a Poisson process
% fitting an exponential pdf and plotting 
%
% * *regression_model.m*
% - transform data for selected regression model and return regression
% coefficients and sample values
%
% * *regression_plot.m*
% - generate regression plot for 2-D data and fitted regression model
%
% * *set_time_units.m*
% - convert datetimes to durations with selected time units and an
% optional offset from zero
%
% * *stderror.m*
% - compute the standard error of a data set relative to a fitted
% regression line
%
% * *taylor_plot.m*
% - create plot of Taylor diagram and, optionally, plot compute skill score
% and a skill map (2 or 3D depending on data)
%
% * *user_plot.m*
% - function to allow user to implement own plotting function
%
% * *user_stats.m*
% - function to allow user to implement own statistical function
%
% * *wind_rose.m* 
% - plot wind/wave rose to show direction and intensity of variable. 
% From Matlab(TM) Forum (c) MMA 26-11-2007, Instituto Español de Oceanografía
% La Coruña, España)
%
% * *xcorrelation_plot.m*
% - generate a cross-correlation plot for user selected data and model
% timeseries data are interpolated to a common time over shortest record,
% all other data have to be the same length vectors 
%
% * *zero_crossing.m*
% - Function to calculate the zero-crossing. Used to calculate the up and
% down crossings of a threshold for time series data
