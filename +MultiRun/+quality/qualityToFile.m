function qualityToFile(runs, kw, combs, outfilename)
%  called from modelMultiRun, writes output file 'multiperformance.txt'
%  takes all info from modelperformance.txt and calls function to calculate
%  performance of point balance (stake) simulations, and puts all data in
%  right format for output

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
[perfKeys, perfVals] = qualVals(runs);
nKeys = length(perfKeys);
nKw = length(kw);

%Row format: hash [perfomance_metrics] [changed_values] 
header = 'Quality metric summary for multiple runs of meltmodel.\n';
head_fmt = ['%s\t' repmat('%s\t', 1, nKw + nKeys - 1) '%s\n'];
body_fmt = ['%s\t' repmat('%g\t', 1, nKw + nKeys - 1) '%g\n'];

%Write column titles to file
fprintf(fid, header);
fprintf(fid, head_fmt, 'Folder', perfKeys{:}, kw{:});

%Helper function for refrencing elements of the keys of quality, which are
%arrays
subindex = @(M,r) M{r};

%write each row of the output file
for ii = 1:nCombs
  %get the run's hash, and parameter constellation
  hash = runs{ii}.hash;
  changed = combs(ii,:);
  perf = perfVals(ii, :);
  
  fprintf(fid, body_fmt, hash, perf(:), changed(:));
  
end

fclose(fid);

end


function [kw, val] = qualVals(runs)
% Retrieve quality data from model output.
%
% Args: runs - Cell-Array, list of HashedRuns which have completed, usually
%   the output of having run MultiRun.modelMultiRun.
%
% Returns: kw - List of the names of the performance
%
% TODO: better handle missing keys


% get perfinfo
nCombs = size(runs);
nCombs = nCombs(1);
val = [];

for nn = 1:nCombs   %for all parameter combinations
  %Read quality values from 'modelperformance.txt' (created by detim/debam)
  disPerfFilename = [runs{nn}.configMap('outpath') 'modelperformance.txt'];
  [qkw, qval] = MultiRun.quality.dischQuality(disPerfFilename);
       %qkw contains all variable names for the discharge variables
       %(Qr2 .... nstepsdis)
       %qval=values for qkw for one run
 
  %Calculate Mass-Balance r2 and RMSE at sampled stakes
  massBalPerfFilename = [runs{nn}.configMap('outpath') 'pointbalances.txt'];
  [mbkw, mbval] = MultiRun.quality.stakeQuality(massBalPerfFilename);
      % function stakeQuality is in /MultiRun/quality/
  thisVal = [mbval' qval'];
  val = [val; thisVal];
end %loop over runs

kw = [mbkw; qkw]';
end