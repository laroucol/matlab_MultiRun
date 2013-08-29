function status = getStatus(config)
% getStatus - Get the status of model run
%
% Args - config: a Map object for a model run
% Returns - status: an enumeration with vaule of the model run,
%                   if the lockfile hasn't been created, returns


[hash, newConfigMap] = genHash(config);
lockfileName = [config('outpath'), hash, 'status.lockfile'];
stats = @(x)impervious.config.RunStatus(x);
Lock = padlock.LockFile(lockfilename, stats);

status = Lock.status;
end