function [hashes, kw, combs, r2, status, err, runs] = dischR2(basefile, modelpath, varargin)

[runs, hashes, kw, combs, status, err] = MultiRun.modelMultiRun(modelpath, basefile, varargin{:});

nCombs = size(combs);
nCombs = nCombs(1);

r2 = zeros(1,nCombs);

for n = 1:nCombs
  perfFileName = [runs{n}.configMap('outpath') 'modelperformance.txt'];
  quality = readPerformance(perfFileName);
  r2(n) = quality('discharge_r2');
end
end

function quality = readPerformance(filename)
fmt = '%s\t%f';
fid = fopen(filename);
raw = textscan(fid, fmt, 'HeaderLines', 1);
quality = containers.Map(raw{1}, raw{2});
end