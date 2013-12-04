function [kw, val] = dischQuality(filename)

% called from function qualVals in qualityToFile.m (under /MultiRun/quality/

% Read quality metrics from modelperformance.txt (created by detim/debam).
% 
% Args: filename - String, fully-qualified filename, usually
%         <PATH_TO_FILE>/modelperformance.txt
%
% Returns: * kw - Cell-array, each entry is the name of a data-field taken
%       from <filename>.
%          * val - Cell-array. Contains the data corresonding to the
%          keyword of the corresponding entry.
%
% E.G. Suppose we call:
%   > [kw, val] = dischQuality('/home/luser/modelperformance.txt')
%
% We then get:
%
%    > kw{1}
%    ans = 'Q_r2'
%    > val(1)
%    ans = 0.96418
%
% That is, the value of 'Q_r2' is 0.96418.

fmt = '%s\t%f';
fid = fopen(filename);

if fid == -1
    error('MultiRun:quality:dischQuality:fileError', 'Input file could not be opened.')
end

raw = textscan(fid, fmt, 'HeaderLines', 2);
kw = raw{1};   %includes text (variable names) of first column of 'modelperformance.txt'
val = raw{2};  %includes values of each output variable (colum 2)

end