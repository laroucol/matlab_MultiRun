function qualityToFile(runs, kw, combs, filename)
%TODO: - choice of quality metrics
%      - only filenames?


fid = fopen(filename, 'w');
% TODO: error out when file don't open
if fid == -1
  error('MultiRun:quality:qualityToFile:fileError', 'Outputfile could not be opened.')
end

% get perfinfo
nCombs = size(runs);
nCombs = nCombs(1);

quality = MultiRun.quality.qualityFromRuns(runs);
perfKeys = quality.keys;
nKeys = length(perfKeys);
nKw = length(kw);

% format: hash [changed_values] [perfomance_metrics]
head_fmt = ['%s\t' repmat('%s\t', 1, nKw + nKeys - 1) '%s\n'];
body_fmt = ['%s\t' repmat('%g\t', 1, nKw + nKeys - 1) '%g\n'];

fprintf(fid, head_fmt, 'Hash', perfKeys{:}, kw{:});

subindex = @(M,r) M{r};

for ii = 1:nCombs
  hash = runs{ii}.hash;
  changed = combs(ii,:);
  
  perf = zeros(1, nKeys);
  for jj = 1:nKeys
    perf(jj) = subindex(quality(perfKeys{jj}), ii);
  end
  
  fprintf(fid, body_fmt, hash, perf(:), changed(:));
  
end

fclose(fid);

end