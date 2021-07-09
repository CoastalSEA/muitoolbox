function ists = istimeseriesdst(dst)
%
%-------function help------------------------------------------------------
% NAME
%   istimeseriesdst.m
% PURPOSE
%   check whether the first variable in a dstable is a timeseries
% USAGE
%   ists = istimeseriesdst(dst)
%INPUT
%   dst - dstable dataset
%OUTPUT
%   ists - logical if data is vector and Rows are datetime
% SEE ALSO
% pused in taylor_plots.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%----------------------------------------------------------------------
%
    ists = false;
    if isa(dst,'dstable')
        if isdatetime(dst.RowNames) && isvector(dst.DataTable{:,1})
            ists = true;
        end
    end
end
    