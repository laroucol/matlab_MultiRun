function [r2, r2ln] = stakeQuality(filename)


fid = fopen(filename);
if fid == -1
    error('MultiRun:quality:Quality:fileError', 'Input file could not be opened.')
end

%Easting, Northing, elevation, measured_massbal, modeled_massbal, year 1, day 1, year2, day2
fmt = '%f %f %f %f %f %i %i %i %i';
raw = textscan(fid, fmt, 'HeaderLines', 1);

easting = raw{1};
northing = raw{2};
mBalMeas = raw{3};
mBalModel = raw{4};
year1 = raw{5};
day1 = raw{6};
year2 = raw{7};
day2 = raw{8};

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
end