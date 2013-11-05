function quality = qualityFromRuns(runs)
% Retrieve quality data from model output.


% get perfinfo
nCombs = size(runs);
nCombs = nCombs(1);
quality = containers.Map;

for nn = 1:nCombs
  
  %Read discharge quality from 'modelperformance.txt'
  disPerfFilename = [runs{nn}.configMap('outpath') 'modelperformance.txt'];
  [qkw, qval] = MultiRun.quality.dischQuality(disPerfFilename);
  %Add values to quality Map
  for ii = 1:length(qkw)
    key = qkw{ii};
    value = qval(ii);
    
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
  end %discharge
  
  %Read Mass-Balance r2 andr2ln at sampled stakes
  massBalPerfFilename = [runs{nn}.configMap('outpath') 'pointbalances.txt'];
  [mbkw, mdval] = MultiRun.quality.stakeQuality(massBalPerfFilename);
  for ii = 1:length(mbkw)
    key = mbkw{ii};
    value = qval(ii);
    
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
  end %massbal
    
end %loop over runs

end