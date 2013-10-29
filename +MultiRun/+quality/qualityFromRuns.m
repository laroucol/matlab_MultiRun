function quality = qualityFromRuns(runs)
% Retrieve quality data from model output.


% get perfinfo
nCombs = size(runs);
nCombs = nCombs(1);
quality = containers.Map;

for nn = 1:nCombs
  disPerfFilename = [runs{nn}.configMap('outpath') 'modelperformance.txt'];
  [kw, val] = MultiRun.quality.dischQuality(disPerfFilename);
    
  for ii = 1:length(kw)
    key = kw{ii};
    value = val(ii);
    
    % Check to see that every key is a key in quality, if not, make itone,
    % and assign to it and empty cell array
    if not(quality.isKey(key))
      quality(key) = cell(1, nCombs);
    end
     
    % Update the value of quality(key){ii} to value.
    % Matlab's indexing sucks, for readability this makes the most sense,
    % for now
    tmp = quality(key);
    tmp{nn} = value;
    quality(key) = tmp;
  end
  
end

end