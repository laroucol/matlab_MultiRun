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
  [dischR2(n), dischR2Ln(n)] = MultRun.quality.dischQuality(disPerfFilename);
  
  stakeFileName = [runs{n}.configMap('outpath') 'stakeperformance.txt'];
  [stakeR2(n), stakeR2Ln(n)] = MultiRun.quality.stakeQuality(stakeFileName);
end

end