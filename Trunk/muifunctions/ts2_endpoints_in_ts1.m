function [idst,idnd] = ts2_endpoints_in_ts1(ts1,ts2)
%
%-------function help------------------------------------------------------
% NAME
%   ts2_endpoints_in_ts1.m
% PURPOSE
%   return indices in ts1 for end points of ts2 that fall within ts1
%   if ts2 extends beyond ts1 returns the start and/or end of ts1
% USAGE
%   [idst,idnd] = ts2_endpoints_in_ts1(ts1,ts2)
% INPUT
%   ts1 - reference dstable, using datetime or duration to define rows
%   ts2 - dstable using datetime or duration to define rows
% OUTPUT
%   idst - index of the start of ts2 in ts1
%   idnd - index of the end of ts2 in ts1
% NOTE
%   used in ctWaveModel.m
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2021
%--------------------------------------------------------------------------
%
    range1 = ts1.RowRange;  %start and end times of ts1
    range2 = ts2.RowRange;  %start and end times of ts2
    
    idst = 1; idnd = height(ts1.DataTable);  %default index for start and end
    if range1{1}<range2{1}
        idst = find(ts1.RowNames>=range2{1},1,'first'); %start of ts2 in ts1
    end
    
    if range1{2}>range2{2}
        idnd = find(ts1.RowNames<=range2{2},1,'last');  %end of ts2 in ts1
    end
    
    if range1{2}<range2{1} || range1{1}>range2{2}
        idst = []; idnd = [];        %timeseries do not overlap
    end
end