function qualityToFile(runs, kw, combs, filename)

fid = fopen(filename, 'w');
% TODO: error out when file don't open

% get perfinfo
nCombs = size(runs);
nCombs = nCombs(1);

quality = MultiRun.quality.qualityFromRuns(runs);
keys = quality.keys;
nKeys = length(keys);
nKw = length(kw);

% format: hash [changed_values] [perfomance_metrics]
head_fmt = ['%s ' repmat('%s ', 1, nKw + nKeys - 1) '%s\n'];
body_fmt = ['%s ' repmat('%g ', 1, nKw + nKeys - 1) '%g\n'];

fprintf(fid, head_fmt, 'Hash', kw{:}, keys{:});

subindex = @(M,r) M{r};

for ii = 1:nCombs
  hash = runs{ii}.hash;
  changed = combs(ii,:);
  
  perf = zeros(1, nKeys);
  for jj = 1:nKeys
    perf(jj) = subindex(quality(keys{jj}), ii);
  end
  
  fprintf(fid, body_fmt, hash, changed(:), perf(:));
  
end

fclose(fid);

end