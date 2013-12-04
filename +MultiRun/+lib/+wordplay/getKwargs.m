function [keys, vals] = getKwargs(varargin)

% called from modelMultiRun
% checking if arguments given by user for paramters to be calibrated in call of multiRun makes sense
% and reformats paramters

nVargs = length(varargin);
if (mod(nVargs, 2) ~= 0)
  err = MException('inputChk:oddLengthInupt', 'Key-Value pairs should result in an even-length list, this one is odd.');
  errCause = MException('inputChk:inputLength','Length of varargin list is %i .', nVargs);
  err = addCause(err, errCause);
  throw(err);
end
  

keys = {varargin{1:2:end}};    %parameter names
vals = {varargin{2:2:end}};    %values of calibration parameters

end