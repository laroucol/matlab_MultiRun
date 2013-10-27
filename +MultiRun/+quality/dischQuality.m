function [r2, r2ln] = dischQuality(filename)
fmt = '%s\t%f';
fid = fopen(filename);
raw = textscan(fid, fmt, 'HeaderLines', 1);
quality = containers.Map(raw{1}, raw{2});
r2 = quality('discharge_r2');
r2ln = quality('discharge_r2ln');
end