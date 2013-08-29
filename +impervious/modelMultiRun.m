function runs = modelMultiRun(modelpath, basefile, varargin)


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
  changefile = fopen([HR.outPath 'chages.txt'],'w');
  fprintf(changefile,'%s', msg);
  fclose(changefile);
end 
end