function datapath = getGoldPath()
thisFileName = mfilename('fullpath');
datapath = [fileparts(thisFileName) '/gold'];
end