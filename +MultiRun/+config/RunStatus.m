classdef RunStatus < int32
  % class RunStatus
  %
  % This is a config enumeration for the lockfile used by the HashedRun
  % class. Depending on the status of the run in question, one of these
  % will be set in the lockfile.
  
  % defines constant (status codes)for checking status of current run
  % These are the numbers that will occur in the output file
  % 'runstatus.lock'
enumeration
  DOESNOTEXIST (-1)
  NOTRUN (0)         %0=parameter combination has not been run yet
  INPROGRESS (1)
  RUNFINISHED (2)
  EXECUTIONERROR (3)
end
end