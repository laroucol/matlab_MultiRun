function qualityToFile(runs, kw, combs, outfilename)
%TODO: - choice of quality metrics
%      - only filenames?
%     - return value?

%open the output file.
fid = fopen(outfilename, 'w');
if fid == -1
  error('MultiRun:quality:qualityToFile:fileError', 'Outputfile could not be opened.')
end

%Figure out how many runs have taken place.
nCombs = size(runs);
nCombs = nCombs(1);

%Extract model quality info, and figure out how many columns our file will
%need.
quality = MultiRun.quality.qualityFromRuns(runs);
perfKeys = quality.keys;
nKeys = length(perfKeys);
nKw = length(kw);

%Row format: hash [perfomance_metrics] [changed_values] 
header = 'Quality metric summary for multiple runs of meltmodel.\n';
head_fmt = ['%s\t' repmat('%s\t', 1, nKw + nKeys - 1) '%s\n'];
body_fmt = ['%s\t' repmat('%g\t', 1, nKw + nKeys - 1) '%g\n'];

%Write column titles to file
fprintf(fid, header);
fprintf(fid, head_fmt, 'Hash', perfKeys{:}, kw{:});

%Helper function for refrencing elements of the keys of quality, which are
%arrays
subindex = @(M,r) M{r};

%write each row of the output file
for ii = 1:nCombs
  %get the run's hash, and parameter constellation
  hash = runs{ii}.hash;
  changed = combs(ii,:);
  
  %allocate performance array, then populate it with values from quality.
  perf = zeros(1, nKeys);
  for jj = 1:nKeys
    perf(jj) = subindex(quality(perfKeys{jj}), ii);
  end
  
  fprintf(fid, body_fmt, hash, perf(:), changed(:));
  
end

fclose(fid);

end