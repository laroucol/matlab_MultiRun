function multiQuality(modelpath, basefile, varargin)

[runs, hashes, kw, combs, status, err] = MultiRun.modelMultiRun(modelpath, basefile, varargin{:});


nCombs = size(combs);
nCombs = nCombs(1);

dischR2 = zeros(1, nCombs);
dischR2Ln = zeros(1, nCombs);
stakeR2 = zeros(1, nCombs);
stakeR2Ln = zeros(1, nCombs);

for n = 1:nCombs
  disPerfFilename = [runs{n}.configMap('outpath') 'modelperformance.txt'];
  [dischR2(n), dischR2Ln(n)] = dischQuality(disPerfFilename);
  
  stakeFileName = [runs{n}.configMap('outpath') 'stakeperformance.txt'];
  [stakeR2(n), stakeR2Ln(n)] = stakeQuality(stakeFileName);
end

end


function [r2, r2ln] = dischQuality(filename)
fmt = '%s\t%f';
fid = fopen(filename);
raw = textscan(fid, fmt, 'HeaderLines', 1);
quality = containers.Map(raw{1}, raw{2});
r2 = quality('discharge_r2');
r2ln = quality('discharge_r2ln');
end


function [r2, r2ln] = stakeQuality(filename)

%Easting, Northing, elevation, measured_massbal, modeled_massbal, year 1, day 1, year2, day2
fmt = '%f %f %f %f %f %i %i %i %i';
fid = fopen(filename);
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