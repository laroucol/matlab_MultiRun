function [kw, val] = stakeQuality(filename)
% Compuet r2 and rmse stake mass-balance quality metrics from model files.
% 
% Args: filename - String, fully-qualified filename, usually
%         <PATH_TO_FILE>/pointoutputs.txt
%
% Returns: * kw - Cell-array, each entry is the name of a data-field taken
%       from <filename>.
%          * val - Cell-array. Contains the data corresonding to the
%          keyword of the corresponding entry.
%
% E.G. Suppose we call:
%   > [kw, val] = dischQuality('/home/luser/pointoutputs.txt')
%
% We then get:
%
%    > kw{1}
%    ans = 'massbal_r2'
%    > val(1)
%    ans = 0.96418
%
% That is, the value of 'massbal_r2' is 0.96418.
%
%TODO: * Double-check that r2 and rmse are calulated properly.

fid = fopen(filename);
if fid == -1
    error('MultiRun:quality:Quality:fileError', 'Input file could not be opened.')
end

%Format of Stake quality files.
%TODO: can we extract this from the file itself?
%X-coord 	 Y-coord	 Elevation(m) MeasMassbal(m)  StartYear StartDay EndYear  EndDay 	 ModeledMassbal(m)
fmt = '%f %f %f %f %f %f %f %f %f';
raw = textscan(fid, fmt, 'HeaderLines', 2);
fclose(fid);

% We don't use all of these, but we might in the future.
xCord = raw{1};
yCord = raw{2};
elevation = raw{3};
mBalMeas = raw{4};
year1 = raw{5};
day1 = raw{6};
year2 = raw{7};
day2 = raw{8};
mBalModel = raw{9};

%TODO: abstract this out ot its own file
%calculate R^2
N = length(mBalMeas) - 1;
mbalRes= mBalMeas - mBalModel;
ssRes = sum(mbalRes.^2);
ssTotal = N * var(mBalMeas);
r2 = 1 - ssRes/ssTotal;

%calulate rmse
rmse = sqrt(mean((mBalModel - mBalMeas).^2));

kw = {'massbal_r2'; 'massbal_rmse'};
val = [r2; rmse];

end
