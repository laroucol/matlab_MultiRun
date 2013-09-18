classdef LockFile < handle
  properties
    STATUSCODES
    codeType
    defaultStatus
    status
    
    filename
  end
  
  methods
    function lf = LockFile(filename, statusCodes)
      % LockFile - Constructor for LockFile class
      % 
      % Args - filename : lockfile filename
      %       - statusCodes : enumeration class of status codes
      %       - defualtStatus: default status, to be set on construction
      
      lf.STATUSCODES = statusCodes;
     
      lf.filename = filename;
      lf.status = MultiRun.lib.padlock.getLockStatus(filename, lf.STATUSCODES);
      
    end
    
    
    function deleteLock(self)
      delete(self.filename);
      self.status = self.STATUSCODES(-1);
    end
    
    
    function [success, errmsg, oldStatus] = setStatus(self, status)
      % setStatus - Set the status of lockfile, if no lockfile exists,
      % create one.
      
      % Args - status: desired status
      % Returns - success: code for change success
      %   -errmsg: an error message describing any failures
      %   - oldStatus: the status changed from,
      
      success = 0;
      oldStatus = self.status;
      errmsg = '';
      
      p = fileparts(self.filename);
      if ~(exist(p))
        [s, e] = mkdir(p);
        if ~s
          success = s;
          errmsg = e;
          return
        end
      end
      
      [fid, msg] = fopen(self.filename, 'w');
      if ~(fid == -1)
        fprintf(fid, '%d', int32(self.STATUSCODES(status)));
        fclose(fid);
        self.status = self.STATUSCODES(status);
        success = 1;
        return
      else
        success = 0;
        errmsg = msg;
        return;
      end
    end
  end
  
end