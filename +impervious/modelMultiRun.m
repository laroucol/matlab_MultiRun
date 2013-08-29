function runs = modelMultiRun(modelpath, basefile, varargin)
% function modelMultiRun
%
% Args: modelpath - fully qualified path to a model's executeable
%       basefile - fully qualified path to a valid config file for the
%       model, this will be modified based upon the the list of key-value
%       pairs passed to varargin
%       varargin - a list of key-value pairs which are modified, e.g.
%           modelMultiRun('debam', 'input.txt', 'icekons', [5:0.1:6])
%         will run the model with icekons set to each value in [5:0.1:6]
% Returns: runs - a container.Maps indexed by hashes of HashedRun objects,
%           each corresponding to a single model run.


s = fileread(basefile);
c = impervious.lib.glazer.degreeToMaps(s);


[kw , vals] = impervious.lib.wordplay.getKwargs(varargin{:});
combs = impervious.lib.allcomb.allcomb(vals{:});
nCombs = size(combs);

runs = containers.Map();

for combo = 1:nCombs(1)
  msg = [];
  for keynum = 1:length(kw)
    msg = [msg sprintf('  %s = %g\n', kw{keynum}, combs(combo, keynum))];
    %combs(combo, keynum)
    c(kw{keynum}) = combs(combo,keynum);
  end
  
  HR = impervious.HashedRun(c, modelpath);
  header = sprintf('Base config file: %s \nNew config file: %sindex.txt\n',basefile, HR.outPath);
  msg = [header sprintf('Changes made:\n') msg];
  
  
  runs(HR.hash) = HR;
  HR.runModel();
  changefile = fopen([HR.outPath 'changes.txt'],'w');
  fprintf(changefile,'%s', msg);
  fclose(changefile);
end 
end