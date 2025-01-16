%% Plotting and statistical functions
% Summary of the functions available in the _psfunctions_ folder. Use the Matlab(TM)
% help function in the command window to get further details of each
% function.

%%
% * *addgeodata.m*
% - add data to an existing figure from a shape file, geospatial table file, 
% or raster image file
%
% * *annual_polar_plot.m*
% - plot the monthly or seasonal values of a timeseries variable
%
% * *clusters.m*
% - function to find clusters of peaks over a threshold
%
% * *cmap_selection.m*
% - select a color map definition from Matlab(TM) default list and cbrewer
% generated mat files
%
% * *complex_vector_plot.m*
% - creates a polar plot of the movement at each interval from one position
% to the next
%
% * *conditional_subsample.m*
% - subsample input variable based on a condition set by another variable
% * *general_logisitic.m*
% - function to return a curve defined by the generalised logisitc equation
%
% * *descriptive_stats.m*
% - generate descriptive stats table for timeseries or table of a variable
%
% * *diffpadded.m*
% - differences and approximate derivatives, padded to be same length as
% input variable
%
% * *display_selection.m*
% - callback function to display text from a uicontrol in a dialog box
%
% * *downsample.m*
% - wrapper to put downsample_ts, output into an array. From Matlab(TM) Forum, 
% by Chad A. Greene (c) 2014, 
%
% * *extreme_stats.m*
% - compute extreme values for a range of return periods using the GPD
% method (General Pareto Distrtibution)
%
% * *fittedtitle.m*
% - fit title text to the width of a figure (handles title and sgtitle).
%
% * *frequencyanalysis.m*
% - generate a range of plots of frequency, probability of exceedance and
% duration of exceedance for a timeseries of data
%
% * *genhurstw.m*
% - calculates the weighted generalized Hurst exponent H(q) from 
% the scaling of the renormalized q-moments of the distribution 
% From Matlab(TM) Forum (c) Tomaso Aste (2022). Weighted generalized Hurst 
% exponent (https://www.mathworks.com/matlabcentral/fileexchange/36487-weighted-generalized-hurst-exponent)
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
% * *gram_charlier_pdf.m*
% - estimates the Probability Density Function of the Gram Charlier Distribution 
% for a series of x values, given the mean, variance, skewness and kurtosis 
% parameters (or a timeseries of values).
%
% * *hurst_aalok_ihlen.m*
% - estimate the Hurst exponent of a timeseries, using the method proposed
% by Aalok based on method proposed by Ihlen
%
% * *hurst_exponent.m*
% - estimate the Hurst exponent of a timeseries, using one of a a number of
% methods available from the Matlab Forum, including:
% https://www.mathworks.com/matlabcentral/fileexchange/70192-hurst-exponent   
% https://www.mathworks.com/matlabcentral/fileexchange/39069-hurst-exponent-estimation 
% https://www.mathworks.com/matlabcentral/fileexchange/100988-hurst-exponent
% https://www.mathworks.com/matlabcentral/fileexchange/36487-weighted-generalized-hurst-exponent
%
% * *interpwithnoise.m*
% - insert additional records into a timeseries interpolating between 
% existing values and adding noise to the values added
%
% * *mcolor.m*
% - select a default Matlab(TM) color definition from table
%
% * *mgpdfit.m*
% - maximum likelihood estimate of the fit parameters for a GPD and compute return period
% estimates and confidence intervals (user prompt for plotted output)
%
% * *moving.m*
% - computes moving averages of order n (best taken as odd)
%
% * *movingtime.m*
% - computes moving averages for a window of tint duration
%
% * *my_mui_plot.m*
% - generate a plot by calling muiPlots. Example produces an animation 
% from a 3D dstable passed as a class object that inherits DGinterface 
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
% * *polarplot3D.m*
% - plot a 3D surface from polar coordinate data. Function from Matlab(TM)
% Forum by Ken Garrard:
% https://www.mathworks.com/matlabcentral/fileexchange/13200-3d-polar-plot.
%
% * *r_squared.m*
% - compute the R-squared value a measure of goodness of fit between the 
% observed data and its estimation (may be from a regression or other
% model). Function by Shoaibur Rahman:
% https://www.mathworks.com/matlabcentral/fileexchange/55128-calculate-r-squared-value
%
% * *recursive_plot.m*
% - plot a variable against itself with a step interval of nint
%
% * *regression_model.m*
% - transform data for selected regression model and return regression
% coefficients and sample values
%
% * *regression_plot.m*
% - generate regression plot for 2-D data and fitted regression model
%
% * *saveanimation2file.m*
% - saves movie to selected file type
%
% * *setaxis_yearsbp.m*
% - adjust the x-axis to display years Before Present (BP), reverse
% the axis tick labels and add new axis label
%
% * *setfigslider.m*
% - initialise a slider on a figure with the option to include text 
% displaying the current slider value and an action button
%
% * *setlog.m*
% - callback function for button to set XY plot to have log/linear y-axis
%
% * *setskillparameters.m*
% - initialise the skill properties used for Taylor plot and local skill
% score plots. Skill score requires correlation coefficient and exponent.
% Other parameters relate to local skill score
%
% * *sortplots.m*
% - reorder plot handles so that the legend plots in sequence added
%
% * *stderror.m*
% - compute the standard error of a data set relative to a fitted
% regression line
%
% * *subsample_ts.m*
% - create a timeseries by interpolating one time time series to the times
% of another timeseries
%
% * *tabfigureplot*
% - generate axes on Q-Plot tab including '>Figure' and 'Rotate'
% buttons (Rotate is optional), or as a standalone figure
%
% * *target_marker.m*
% - add one or more target symbols to a plot
%
% * *taylor_plot.m*
% - create plot of Taylor diagram and, optionally, plot compute skill score
% and a skill map (2 or 3D depending on data)
%
% * *user_model.m*
% - function to run a user class defined using the Model_template.m
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
