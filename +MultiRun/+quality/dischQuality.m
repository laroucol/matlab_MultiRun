function [kw, val] = dischQuality(filename)

fmt = '%s\t%f';
fid = fopen(filename);

if fid == -1
    error('MultiRun:quality:dischQuality:fileError', 'Input file could not be opened.')
end

raw = textscan(fid, fmt, 'HeaderLines', 2);
kw = raw{1};
val = raw{2};

end