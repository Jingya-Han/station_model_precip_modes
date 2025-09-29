function [pr, lat, lon]=cmip_read_histssp_data(model,experiment, ensemble, startyear, endyear)
%%%%%%%%%% input %%%%%%%%%%%%%%%%%%
% 28 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu

% model: name of the model
% ensemble: emsemble member
% startyear: start year of the whole two periods
% endyear: end year of the whole two periods

%%%%%%%%%% output %%%%%%%%%%%%%%%%%
% pr: daily precipitation accumulation from startyear to endyear
% lat, lon: assumed to be regular

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path = (['/share/cliprelabs/cmip6-ng/pr/day/native/','pr_day_',model,'_',experiment,'_',ensemble,'_native.nc']);
% extract data from startyear to endyear
switch experiment
    case 'historical'
         SY=1850; EY=2014;% accroding to metadata of nc file, time is days since 1850-01-01
    otherwise
         SY=2015; EY=2100;
end
       YMD = make_ymd(SY,EY);
       itime = ncread(path,'time');
    if length(itime)==length(YMD) % judge natural year
       [srow,~]=find(YMD(:,1)==startyear & YMD(:,2)==1 & YMD(:,3)==1); % row where startyear-01-01 appears
       [erow,~]=find(YMD(:,1)==endyear & YMD(:,2)==12 & YMD(:,3)==31); % row where endyear-01-01 appears
    elseif length(itime)==365*(EY-SY+1) % judge all 365 days each month 
           srow = 1+365*(startyear-SY);
           erow = 365*(endyear-SY+1);
    elseif length(itime)==366*(EY-SY+1) % judge all 366 days each month
           srow = 1+366*(startyear-SY);
           erow = 366*(endyear-SY+1);
    end

    dlength=erow-srow+1;
    pr = ncread(path,'pr',[1,1,srow],[Inf,Inf,dlength]);
    pr = permute(pr,[2,1,3]); % rows should be lat; cols should be lon       
    pr = double(pr)*86400; % kg m-2 s-1 to mm/day
    pr(pr<0)=nan;% set tiny negative values into nan!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    lat = ncread(path,'lat');
    lon = ncread(path,'lon');

end


