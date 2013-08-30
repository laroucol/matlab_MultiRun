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
    Lock %instance of impervious.lib.padlock.LockFile
    
    runStatus % has this specific configuration been run, is it running
  end
  
  methods
    
    function hr = HashedRun(config, model)
      % Object constructor function
      % Args: config: a valid Model configuration
      %      model: the fully-qualified path for the model executable
      
      hr.originMap = copy_map(config);
      hr.model = model;
      
      confstr = impervious.lib.glazer.mapToDegrees(config);
      data = unicode2native(confstr);
      hashOpts = struct('Method', 'SHA-1', 'Format', 'hex', 'Input', 'bin');
      hr.hash = impervious.lib.DataHash(data, hashOpts);
      
      % Use a tempfile to generate the SHA-1 hash of the config
      % text, sans hash
%       tmpfid = fopen(tempname, 'w');
%       if ~(tmpfid == -1)
%         fprintf(tmpfid, impervious.lib.glazer.mapToDegrees(config));
%         tmpname = fopen(tmpfid)
%         hashOpts = struct('Method', 'SHA-1', 'Format', 'hex', 'Input', 'file');
%         hr.hash = impervious.lib.DataHash(tmpname, hashOpts);
%         tmpfid = fclose(tmpname);
%       else
%         error('HashedRun:Issue with tempfile');
%       end
      
      % set up hashed paramters, this is the stuff which will get written
      % to disk, and passed to the model
      hr.outPath = [config('outpath'),  hr.hash, '/'];
      hr.configMap = copy_map(config);
      hr.configMap('outpath') = [hr.outPath, 'outpath/'];
      
      % setup the Lock
      stats = @(x) impervious.config.RunStatus(x);
      hr.Lock = impervious.lib.padlock.LockFile([hr.outPath, 'runstatus.lock'], stats);
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
      
      success = 0;
      err = '';
      
      if ~(self.Lock.status == impervious.config.RunStatus.DOESNOTEXIST)
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
          fprintf(fid, '%s',impervious.lib.glazer.mapToDegrees(self.configMap));
          fid = fclose(fid);
          self.setStatus('NOTRUN');
        else
          success = 0;
          self.setStatus('DOESNOTEXIST');
          err = ('impervious.lib.glazer.HashedRun.genConfig:Error oening input.txt');
          return
        end
      end
    end
    
    
    function [success, err] = runModel(self)
      %Execute the model, checking to make sure that the model hasn't run
      %already.
      %Returns: - success: codes for completion are:
      %                     - 0 : an error has occured
      %                     - 2 : the lockfile indicates the model has
      %                     already run
      %          - err: error message.
      %
      %TODO: Add status code for a successfull completion
      switch self.runStatus
        case impervious.config.RunStatus.INPROGRESS
          success = 0;
          err = 'Impervious:HashedRun:runModel: Model Run is Already in Progress';
          return
        case impervious.config.RunStatus.RUNFINISHED
          success = 2;
          err = 'Impervious:HashedRun:runModel:Lockfile Indicates that model has already run';
          return
        case impervious.config.RunStatus.DOESNOTEXIST
          [s, e] = self.genConfig();
          if ~s
            success = s;
            err = ['impervious:HashedRun:runModel: Error :' err];
            return
          else
            executeModel(self);
            return
          end
        case impervious.config.RunStatus.NOTRUN
          executeModel(self);
          return
      end
      
      
      function [] = executeModel(self)
        % Shanges the working path and executes the model, then goes back.
        self.setStatus('INPROGRESS');
        oldroot = pwd();
        cd(self.outPath);
        [status,result] = system(self.model);
        self.setStatus('RUNFINISHED');
        cd(oldroot);
      end
      
    end
    
    
    function setStatus(self, status)
      %Set the lockfile's status, based on the enumeration found in
      %impervious.config.
      self.Lock.setStatus(impervious.config.RunStatus.(status));
      self.runStatus = self.Lock.status;
    end
  end
  
end