%% check number of sources for each station from mingle-list
% 4 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% input-----------------
% minglelist: path/of/the/minglelist/file
% output---------------------------------
% theidnum: number of sources for each station
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [theidnum]=numofsources(minglelist)

theidnum=cell(0,0);
fid=fopen(minglelist);
tline=fgetl(fid);
count=0;
    while ischar(tline)
          count=count+1;
          theid=tline(1:11);
          theidnum{count,1}=theid;
          theidnum{count,2}=str2num(tline(14));
          tline=fgetl(fid); %returns the next line of the specified file, removing the newline characters.
    end
    fclose(fid);

end