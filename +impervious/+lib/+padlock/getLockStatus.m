function status = getLockStatus(filename, statCodes)
% getLockStatus - Get the status of a lockfile
%
% Args - filename: lockfile location
%        statCodes: enumeration type with codes for the lockfile
% Returns - status: enumeration of type <statCodes>, with the status of
%                   lockfile

if ~(exist(filename, 'file'))
  status = statCodes(-1);
else
  status = statCodes(textread(filename, '%d'));
end
end