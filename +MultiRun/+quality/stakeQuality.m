function [kw, val] = stakeQuality(filename)
%TODO: * reformat output to be consistent w/ dischQuality
%      * Double-check that r2 and lnr2 are calulated properly.

fid = fopen(filename);
if fid == -1
    error('MultiRun:quality:Quality:fileError', 'Input file could not be opened.')
end

%Format of Stake quality files.
%TODO: can we extract this from the file itself?
%X-coord 	 Y-coord	 Elevation(m) MeasMassbal(m)  StartYear StartDay EndYear  EndDay 	 ModeledMassbal(m)
fmt = '%f %f %f %f %f %f %f %f %f';
raw = textscan(fid, fmt, 'HeaderLines', 2);

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

%calculate r^2 of ln
mbalResLn = log(mBalMeas/mBalModel);
ssResLn = sum(mbalResLn.^2);
ssTotalLn = N * var(log(mBalMeas));
r2ln = 1 - ssResLn/ssTotalLn;

kw = {'massbal_r2' 'massbal_lnr2'};
val = {r2 r2ln};

end
