classdef RunStatus < int32
  % class RunStatus
  %
  % This is a config enumeration for the lockfile used by the HashedRun
  % class. Depending on the status of the run in question, one of these
  % will be set in the lockfile.
enumeration
  DOESNOTEXIST (-1)
  NOTRUN (0)
  INPROGRESS (1)
  RUNFINISHED (2)
end
end