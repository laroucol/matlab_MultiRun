function genInput(configMap)

      [hash, newConfigMap] = genHash(configMap);
      
      fileName = [configMap('outpath'), hash, '/' 'input.txt'];
      
      mkdir(newConfigMap('outpath'));
      
      fid = fopen(fileName, 'w');
      if ~(fid == -1)
        fprintf(fid, '%s', glazer.mapToDegrees(newConfigMap));
        fid = fclose(fid);
      else
        error('glazer.HashedRun.genConfig:Error oening input.txt');
      end
end
    
function [hash, newConfigMap] = genHash(config)
% Object constructir function
      % Args: config: a valid Model configuration 
      
      tmpFile = tempname();
      tmpfid = fopen(tmpFile, 'w');
      if ~(tmpfid == -1)
        fprintf(tmpfid, '%s', glazer.mapToDegrees(config));
        tmpfid = fclose(tmpfid);
        
        hashOpts = struct('Method', 'SHA-1', 'Format', 'hex', 'Input', 'file');
        hash = glazer.DataHash.DataHash(tmpFile, hashOpts);
      else
        error('HashedRun:Issue with tempfile');
      end
      
      outPath = [config('outpath'), hash, '/'];
      
      newConfigMap = containers.Map(config.keys, config.values);
      newConfigMap('outpath') = [outPath, 'outpath/'];
end