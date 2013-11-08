function [runs, hashes, kw, combs, status, err] = modelMultiRun(modelpath, basefile, varargin)
% function modelMultiRun
%
% Args: modelpath - fully qualified path to a model's executeable
%       basefile - fully qualified path to a valid config file for the
%       model, this will be modified based upon the the list of key-value
%       pairs passed to varargin
%       varargin - a list of key-value pairs which are modified, e.g.
%           modelMultiRun('debam', 'input.txt', 'icekons', [5:0.1:6])
%         will run the model with icekons set to each value in [5:0.1:6]
%
% Returns: 
%          runs - a container.Maps indexed by hashes of HashedRun objects,
%           each corresponding to a single model run.
%          hashes - Cell array of hashes of each run.
%          kw - Cell array containing names of modified values
%          combs - Array with values taken on by kws
%          status - staus(i) = Array of return status of run with hash hashes{i}
%          err - Error messages associated by incomplete runs
%          changes - array of changes made to input.txt
%          

s = fileread(basefile);
c = MultiRun.lib.glazer.degreeToMaps(s);

%parse keyword arguments. providing a dummy if none are provided
%this is a little kludgy and could be improved somehow
%by providing an alternative procedure to handle a single run.
if isempty(varargin)
  kw = {'none'};
  vals = {0};
else
   [kw , vals] = MultiRun.lib.wordplay.getKwargs(varargin{:});
end

%give me all permutations of parameters w/in ranges provided
combs = MultiRun.lib.allcomb.allcomb(vals{:});
%Allocate appropriately sized cell arrays to store function returns in
nCombs = size(combs);
hashes = cell(nCombs(1), 1);
status = zeros(nCombs(1), 1);
err = cell(nCombs(1), 1);
changes = cell(nCombs(1), 1);
runs = cell(nCombs(1), 1);

for combo = 1:nCombs(1)
  %construct a message telling the user which configureation arguments
  %have been set in this run
  msg = [];
  for keynum = 1:length(kw)
    msg = [msg sprintf('  %s = %g\n', kw{keynum}, combs(combo, keynum))];
    %combs(combo, keynum)
    c(kw{keynum}) = combs(combo,keynum);
  end
  
  %Build the HashedRun object, then run the model.
  HR = MultiRun.HashedRun(c, modelpath);
  [runsuccess, runerr] = HR.runModel();
  
  %print to disk messages re: changes
  %TODO: this should probably be contingent on the value of runsuccess.
  header = sprintf('Base config file: %s \nNew config file: %sindex.txt\n',basefile, HR.outPath);
  msg = [header sprintf('Changes made:\n') msg];
  changefile = fopen([HR.outPath 'changes.txt'],'w');
  fprintf(changefile,'%s', msg);
  fclose(changefile);
  
  %put data about run, including the run object, into the appropriate
  %return arrays
  hashes{combo} = HR.hash;
  status(combo) = runsuccess;
  err{combo} = runerr;
  changes{combo} = msg;
  runs{combo} = HR;
  disp('.')
end

mainOutPath = HR.originMap('outpath')
%[mainOutPath,name,ext] = fileparts(basefile);
performanceFileName = [mainOutPath 'multi_performance.txt'];
MultiRun.quality.qualityToFile(runs, kw, combs, performanceFileName);

end