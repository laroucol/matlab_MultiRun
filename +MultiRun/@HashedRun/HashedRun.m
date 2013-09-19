classdef HashedRun < handle
  %HashedRun: Manages a single run of Debam/Detim, whose output is sorted
  %into folders deterministically via SHA-1.

  
  properties
    originMap %Map which is hashed
    configMap %Map conainer containing info for the model run
    %configText % Text which will be written 
    hash % hash of input.txt from config
    model % fully qualified path ot model executeable
    outPath % Path where model will be outputing
    Lock %instance of MultiRun.lib.padlock.LockFile
    
    runStatus % has this specific configuration been run, is it running
  end
  
  methods
    
    function hr = HashedRun(config, model)
      % Object constructor function
      % Args: config: a valid Model configuration
      %      model: the fully-qualified path for the model executable
      
      hr.originMap = config;
      hr.model = model;
      
      confstr = MultiRun.lib.glazer.mapToDegrees(config);
      data = unicode2native(confstr);
      hashOpts = struct('Method', 'SHA-1', 'Format', 'hex', 'Input', 'bin');
      hr.hash = MultiRun.lib.DataHash(data, hashOpts);
            
      % set up hashed paramters, this is the stuff which will get written
      % to disk, and passed to the model
      hr.outPath = [config('outpath'),  hr.hash, '/'];
      hr.configMap = copy_map(config);
      hr.configMap('outpath') = [hr.outPath, 'outpath/'];
      
      % setup the Lock
      stats = @(x) MultiRun.config.RunStatus(x);
      hr.Lock = MultiRun.lib.padlock.LockFile([hr.outPath, 'runstatus.lock'], stats);
      hr.runStatus = hr.Lock.status();
      
      
      % Make a copy of a handle object.
      function new = copy_map(this)
      % Instantiate new object of the same class.
        new = feval(class(this));
 
        % Copy all non-hidden properties.
        p = keys(this);
        for i = 1:length(p)
          new(p{i}) = this(p{i});
         end
       end
    end
    
    
    function [success, err] = genConfig(self)
      % Generate this run's input.txt, and write it to disk.
      % Returns: success : success code is
      %                      - 0 something has gone wrong
      %                      - 1 config has been generated
      %                      - 2 config already existed
      %          err: error message, if empty everything is fine
      
      success = 0;
      err = '';
      
      if ~(self.Lock.status == MultiRun.config.RunStatus.DOESNOTEXIST)
        success = 2;
        err = 'HashedRun:genConfig:Lockfile Indicated config file exists.';
        return
      else
        self.setStatus('NOTRUN');

        p = self.configMap('outpath');

        %make sure the output directory exists
        if ~(exist(p, 'dir'))
          [s, e] = mkdir(p);
          if ~s
            success = s;
            err = e;
            self.setStatus('DOESNOTEXIST');
            return
          end
        end

        fileName = [self.outPath, 'input.txt'];
        
        %open our input.txt and write to disk
        [fid, msg] = fopen(fileName, 'w');
        if ~(fid == -1)
          success = 1;
          str = MultiRun.lib.glazer.mapToDegrees(self.configMap);
          fprintf(fid, '%s', str);
          fid = fclose(fid);
          self.setStatus('NOTRUN');
        else
          success = 0;
          self.setStatus('DOESNOTEXIST');
          err = ('MultiRun.lib.glazer.HashedRun.genConfig:Error opening input.txt');
          return
        end
      end
    end
    
    
    function [success, err] = runModel(self)
      %Execute the model, checking to make sure that the model hasn't run
      %already.
      %Returns: - success: codes for completion are:
      %                     - 0 : an error has occured
      %                     - 1 : The model has been run successfully
      %                     - 2 : the lockfile indicates the model has
      %                     already run
      %          - err: error message.
      %
      %TODO: Add status code for a successful completion
      
      switch self.runStatus
        case MultiRun.config.RunStatus.INPROGRESS
          success = 0;
          err = 'MultiRun:HashedRun:runModel: Model Run is Already in Progress';
          return
        case MultiRun.config.RunStatus.RUNFINISHED
          success = 2;
          err = 'MultiRun:HashedRun:runModel:Lockfile indicates that model has already run';
          return
        case MultiRun.config.RunStatus.EXECUTIONERROR
          success = 0;
          err = 'MultiRun:HashedRun:runModel:Lockfile indicates that the model exited early. Check input.txt.';
        case MultiRun.config.RunStatus.DOESNOTEXIST
          [s, e] = self.genConfig();
          if ~s
            success = s;
            err = ['MultiRun:HashedRun:runModel: Error :' e];
            return
          else
            [model_stat, res] = executeModel(self);
            if ~model_stat
              success = 1;
              err = '';
            else
              success = 0;
              err = ['MultiRun:HashedRun:runModel:ExecutionError: Model exited early citing:' res];
            return
            end
          end
        case MultiRun.config.RunStatus.NOTRUN
          executeModel(self);
          return
      end
      
      
      function [status, result] = executeModel(self)
        % Shanges the working path and executes the model, then goes back.
        self.setStatus('INPROGRESS');
        oldroot = pwd();
        cd(self.outPath);
        [status,result] = system(self.model);
        if ~status
          self.setStatus('RUNFINISHED');
        else
          self.setStatus('EXECUTIONERROR');
        end
        cd(oldroot);
      end
      
    end
    
    
    function setStatus(self, status)
      %Set the lockfile's status, based on the enumeration found in
      %MultiRun.config.
      self.Lock.setStatus(MultiRun.config.RunStatus.(status));
      self.runStatus = self.Lock.status;
    end
  end
  
end