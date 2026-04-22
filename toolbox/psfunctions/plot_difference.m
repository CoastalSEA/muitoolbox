function res = plot_difference(dstruct,isangle,method)
%
%-------function help------------------------------------------------------
% NAME
%   plot_difference.m
% PURPOSE
%   find the difference between two variables interpolating one of them if
%   they are not at the same datetimes and plot the result
% USAGE
%   res = plot_difference(dstruct,method); 
%   or: plot_difference(dst,'method') when using Run>Derive Ouput menu option
% INPUTS
%   dstruct - struct array with a dstable for each of the variables to be
%             differenced. The difference uses 1st-2nd element of array.
%             or: when called from Derive Output menu UI assign X and Y 
%             variables that are to be differenced and use 
%             plot_difference(dst) in the UI equation box
%   isangle - true if datasets are directions or angles
%   method - interpolation method - linear, pchip, makima, etc 
%            (optional - default is linear)
% OUTPUT
%   res - silent output when called from muiManipUI class
% NOTES
%   suitable for use in Derive Output UI
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2026
%--------------------------------------------------------------------------
%
    res = 'no output';
    if nargin<3, method = 'linear'; end      %default interpolation method

    dst1 = dstruct(1).data;
    time1 = dst1.RowNames; 
    var1 = dst1.(dst1.VariableNames{1});
    dst2 = dstruct(2).data;
    time2 = dst2.RowNames;
    var2 = dst2.DataTable.(dst2.VariableNames{1});
    seltime = time1;
    if ~isequal(time1,time2)
        %datetimes do not match. Select which to use for interpolation
        txt1 = '           Timeseries are different';
        txt2 = 'Choose timeseries to use for interpolation:';
        txt3 = sprintf('1st - %s',dst1.VariableDescriptions{1});
        txt4 = sprintf('2nd - %s',dst2.VariableDescriptions{1});
        question = sprintf('%s\n%s\n%s\n%s',txt1,txt2,txt3,txt4);
        interpdst = questdlg(question,'Difference','1st','2nd','1st');
        if strcmp(interpdst,'1st')
            var2 = interp1(time2,var2,time1,method);
            seltime = time1;
        else
            var1 = interp1(time1,var1,time2,method);
            seltime = time2;
        end
    end
    diffvar = var1(:)-var2(:);            %force column vectors
    if isangle
        [~,diffvar] = wrap_angle(diffvar,[],[-180,180],0); %var,tin=[],varRange,israd=0
    end

    hf = figure('Tag','PlotFig');
    ax = axes(hf);
    s1 = subplot(2,1,1,ax);
    plot(s1,seltime,diffvar)
    ylabel(dst1.VariableLabels{1})
    
    bs = mean(diffvar,'omitnan');
    mn = mean(abs(diffvar),'omitnan');
    stdv =std(abs(diffvar),'omitnan');
    mnmx = minmax(diffvar);
    legtxt = sprintf('Bias=%.2f; abs.mean=%.2f; abs.std=%.2f; min=%.2f; max=%.2f',...
                                              bs,mn,stdv,mnmx(1),mnmx(2));
    legend(legtxt,'Location','northeast')

    s2 = subplot(2,1,2);
    var1(abs(var1)<0.1) = NaN;
    reldiff = abs(diffvar)./abs(var1(:));
    plot(s2,seltime,reldiff);
    xlabel(dst1.RowDescription)
    ylabel('Relative difference to Var1')
    sgtitle(sprintf('Diff: %s - %s',dst1.Description,dst2.Description))
    mnreldiff = mean(reldiff,'omitnan');
    mnvar = mean(abs(var1(:)),'omitnan');
    legtxt = sprintf('Mean relative diff=%.2f; Mean Var1=%.2f',mnreldiff,mnvar);
    legend(legtxt,'Location','northeast')
end
