function [kw, val] = dischQuality(filename)

fmt = '%s\t%f';
fid = fopen(filename);
raw = textscan(fid, fmt, 'HeaderLines', 1);
kw = raw{1};
val = raw{2};

end