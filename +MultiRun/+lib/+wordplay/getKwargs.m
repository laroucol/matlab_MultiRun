function [keys, vals] = getKwargs(varargin)


nVargs = length(varargin);
if (mod(nVargs, 2) ~= 0)
  err = MException('inputChk:oddLengthInupt', 'Key-Value pairs should result in an even-length list, this one is odd.');
  errCause = MException('inputChk:inputLength','Length of varargin list is %i .', nVargs);
  err = addCause(err, errCause);
  throw(err);
end
  

keys = {varargin{1:2:end}};
vals = {varargin{2:2:end}};

end