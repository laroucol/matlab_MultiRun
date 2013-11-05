function qualityToFile(runs, kw, combs, outfilename)
% Summarize the quality metrics from the output of MultiRun.modelMultiRun,
% and writes them to an external, tab-seperated-value file.
%
% Args: * runs - a cell array of MultiRun.HashedRun objects
%       * kw - A cell array containing the model paramters which have been
%       changed by modelMultiRun
%       * combs - A matrix wherein combs(m,n) is the value which kw{n}
%       takes on for runs{m}.
%       * outfilename - String containing the filename to write the output
%       to.
%
%
% The outpus is a tab seperated file, which summarizes the performance data
% from 'modelperformance.txt' as well as the r2 ans lnr2 of the individual
% stake outputs.
%
%
%
% E.G. 
% > [runs, hashes, kw, combs, status, err] = MultiRun.modelMultiRun(modelpath, basefile, 'icekons', [5:0.5:6.0], 'firnkons', [350:0.5:351]);
% > MultiRun.quality.qualityToFile(runs, kw, comb, 'qualitySummary.tsv');
%
% This runs the models, changing the values of icekons and firnkons to the
% values given by the function call, then takes the output of the model
% runs, and writes a summary of the quality statistict to a file
% 'qualitySummary.tsv'
%
%
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