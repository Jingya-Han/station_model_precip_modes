%% This script is processing AMIP data
% 29 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu

%% check nc info and print in a file
clear
mkdir('amip_pr_day');
folder='/share/cliprelabs/jh2423/modesofchange_system/amip_pr_day/'; % output folder
iex='amip';
nameoffile='amip_info';
modelsnm = {'ACCESS-CM2';'ACCESS-ESM1-5';...
    'BCC-CSM2-MR';'CanESM5';'CESM2';...
    'CMCC-CM2-SR5';'CMCC-ESM2';...
    'FGOALS-g3';'GFDL-ESM4';...
    'INM-CM4-8';'INM-CM5-0';...
    'IPSL-CM6A-LR';'MIROC6';...
    'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
    'TaiESM1'}; 
path = '/share/cliprelabs/amip/pr/day/'; % raw amip data path
% ncdisp([path,'pr_day_ACCESS-CM2_amip_r1i1p1f1_gn_19790101-20141231.nc'])
% ncdisp([path,'pr_day_E3SM-2-0_amip_r1i1p1f1_gr_18700101-18791231.nc'])

%% select all available amip ensemble members for both pr and tas variables
[ensemble]=cmip_existensembles(modelsnm,iex);
for im=1:length(modelsnm) % each model
    imodel=modelsnm{im};
    ensemb=ensemble{im};
    for themem=1:length(ensemb) % each ensemble member
        ien=ensemb{themem};
        fstart=['pr_day_',imodel,'_',iex,'_',ien,'_'];
        fname=[fstart,'*.nc'];
        allfiles=dir([path,fname]); % judge if the ensemble member for amip exists or not
        if length(allfiles)==1 % means there is one file for each member
           filenm1=allfiles(1).name; % name of first file
           pr=ncread([path,filenm1],'pr'); 
           pr = permute(pr,[2,1,3]); % rows should be lat; cols should be lon       
           pr = double(pr)*86400; % kg m-2 s-1 to mm/day
           pr(pr<0)=nan;% set tiny negative values into nan!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

           lat=ncread([path,filenm1],'lat');
           lon=ncread([path,filenm1],'lon');
           time=ncread([path,filenm1],'time');
           save([folder,filenm1(1:end-3),'.mat'],'pr','lat','lon','time');
        elseif length(allfiles)>1 % means there are multiple files representing diff years for each member
               nt=length(allfiles); % merge data
               pr=[];
               for i=1:nt
                   thename=allfiles(i).name;
                   subpr=ncread([path,thename],'pr');
                   pr=cat(3,pr,subpr);
               end
              pr = permute(pr,[2,1,3]); % rows should be lat; cols should be lon       
              pr = double(pr)*86400; % kg m-2 s-1 to mm/day
              pr(pr<0)=nan;% set tiny negative values into nan!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
              lat=ncread([path,thename],'lat');
              lon=ncread([path,thename],'lon');
              time=ncread([path,thename],'time');
              filenm1=allfiles(1).name; % name of first file
              filenme=allfiles(end).name; % name of last file

              save([folder,thename(1:end-20),filenm1(end-19:end-12),'-',filenme(end-10:end-3),'.mat'],...
                  'pr','lat','lon','time');
        end

    end
end

%% This script is processing AMIP tas data
% merge seperate time period into one file each model each ensemble member
% check nc info and print in a file
clear
mkdir('amip_pr_day');
folder='/share/cliprelabs/jh2423/modesofchange_system/amip_pr_day/'; % output folder
iex='amip';
nameoffile='amip_info';
modelsnm = {'ACCESS-CM2';'ACCESS-ESM1-5';...
    'BCC-CSM2-MR';'CanESM5';'CESM2';...
    'CMCC-CM2-SR5';'CMCC-ESM2';...
    'FGOALS-g3';'GFDL-ESM4';...
    'INM-CM4-8';'INM-CM5-0';...
    'IPSL-CM6A-LR';'MIROC6';...
    'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
    'TaiESM1'}; 
path = '/share/cliprelabs/amip/tas/mon/'; % raw amip data path
% ncdisp([path,'tas_Amon_ACCESS-CM2_amip_r1i1p1f1_gn_197901-201412.nc'])
% ncread([path,'tas_Amon_ACCESS-CM2_amip_r1i1p1f1_gn_197901-201412.nc'],'time');
%% select all available amip ensemble members for both pr and tas variables
[ensemble]=cmip_existensembles(modelsnm,iex);
for im=1:length(modelsnm) % each model
    imodel=modelsnm{im};
    ensemb=ensemble{im};
    for themem=1:length(ensemb) % each ensemble member
        ien=ensemb{themem};
        fstart=['tas_Amon_',imodel,'_',iex,'_',ien,'_'];
        fname=[fstart,'*.nc'];
        allfiles=dir([path,fname]); % judge if the ensemble member for amip exists or not
        if length(allfiles)==1 % means there is one file for each member
           filenm1=allfiles(1).name; % name of first file
           tas=ncread([path,filenm1],'tas'); 
           tas = permute(tas,[2,1,3]); % rows should be lat; cols should be lon     
           lat=ncread([path,filenm1],'lat');
           lon=ncread([path,filenm1],'lon');
%            time=ncread([path,filenm1],'time');
%            % Interpret the time variable
%            timeUnits = ncreadatt([path,filenm1], 'time', 'units'); % Get units of time
%            timeRefStr = regexp(timeUnits, '\d{4}-\d{2}-\d{2}', 'match', 'once'); % Extract reference date
%            timeRef = datetime(timeRefStr, 'InputFormat', 'yyyy-MM-dd'); % Convert to datetime
%            dates = timeRef + days(time); % Convert time to MATLAB datetime format
           save([folder,filenm1(1:end-3),'.mat'],'tas','lat','lon');

        elseif length(allfiles)>1 % means there are multiple files representing diff years for each member
               nt=length(allfiles); % merge data
               tas=[];
               for i=1:nt
                   thename=allfiles(i).name;
                   subtas=ncread([path,thename],'tas');
                   tas=cat(3,tas,subtas);
               end
              tas = permute(tas,[2,1,3]); % rows should be lat; cols should be lon       
              lat=ncread([path,thename],'lat');
              lon=ncread([path,thename],'lon');
              
              filenm1=allfiles(1).name; % name of first file
              filenme=allfiles(end).name; % name of last file

              save([folder,thename(1:end-16),filenm1(end-15:end-10),'-',filenme(end-8:end-3),'.mat'],...
                  'tas','lat','lon');
        end

    end
end

%% cal annual mean temp
for im=1:length(modelsnm) % each model
    imodel=modelsnm{im};
    files=dir([folder,'tas_Amon_',imodel,'_',iex,'*.mat']);
    ensem=1:length(files); %{'r1i1p1f1'};    
   for iensemble=1:length(ensem)
       thename=files(iensemble).name;
       k = strfind(thename,'_');
       ien=thename(k(4)+1 : k(5)-1); % name of ensemble member
       modeleym=(thename(end-9:end-4)); % end ym
       modelsym=(thename(end-16:end-11));% start ym 
       startDate = datetime(modelsym, 'InputFormat', 'yyyyMM');
       endDate = datetime(modeleym, 'InputFormat', 'yyyyMM');
       dateSeries = startDate:calmonths(1):endDate;

       % Reshape and calculate annual mean
       years = year(dateSeries); % Extract years from dates
       uniqueYears = unique(years); % Get unique years
       annMeanTemp = zeros(length(uniqueYears), 1); % Initialize result array
        for i = 1:length(uniqueYears)
            % Find indices corresponding to the current year
            idx = (years == uniqueYears(i));
            % Calculate the mean for the year
            annMeanTemp(i) = mean(tas(idx), 'omitnan'); % Handle NaNs if any
        end
        startyear=str2double(modelsym(1:4));
        endyear=str2double(modeleym(1:4));

        save([folder,'tas_ann_',imodel,'_',iex,'_',ien,'_',...
            num2str(startyear),num2str(endyear),'.mat'],'annMeanTemp','startyear','endyear');
   end

end

%% way1 for precip distribution for each native grid each year in amip
% cal freq distribution and amount distribution for each grid each year
clear
folder='/share/cliprelabs/jh2423/modesofchange_system/amip_pr_day/'; % output folder
iex='amip';
modelsnm = {'ACCESS-CM2';'ACCESS-ESM1-5';...
    'BCC-CSM2-MR';'CanESM5';'CESM2';...
    'CMCC-CM2-SR5';'CMCC-ESM2';...
    'FGOALS-g3';'GFDL-ESM4';...
    'INM-CM4-8';'INM-CM5-0';...
    'IPSL-CM6A-LR';'MIROC6';...
    'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
    'TaiESM1'}; 

% BINCRATES=nan(200,length(modelsnm),length(experiment),length(ensemble));% all bincrates, 200 is estimated max length of bins 
for im=1:length(modelsnm)
    imodel=modelsnm{im};
    files=dir([folder,'pr_day_',imodel,'_',iex,'*.mat']);
    ensemble=1:length(files); %{'r1i1p1f1'};     
   for iensemble=1:length(ensemble)
       thename=files(iensemble).name;
       k = strfind(thename,'_');
       ien=thename(k(4)+1 : k(5)-1); % name of ensemble member
       modeley=str2double(thename(end-11:end-8)); % end year for this member
       modelsy=str2double(thename(end-20:end-17));% start year for this member      
       % judge if there is already the results
       ans = exist([folder,'amip_KDE_raindist_',imodel,'_',iex,'_',ien,'_',...
           num2str(modelsy),num2str(modeley),'.mat']);
       if ans == 0 % 0 means the variable did not exit             
          load([folder,thename],'pr','lat','lon','time');
          modelyr=modelsy:modeley;                
          [bincrates, binl, dbin, binr]=cmip_bincrates(pr); % bincrates for specific model, specfic experiment, specific ensemble member
          [rows,cols,~]=size(pr); % 3d data
          freqdist=nan(rows,cols,300,modeley-modelsy+1); % 300 is estimated max length of bins           
          amountdist=freqdist;

        if ~contains(imodel,'CESM2')
          for irow=1:rows
              for icol=1:cols            
                for iy=1:length(modelyr)
                    iyear=modelyr(iy);
                    pdata1=squeeze(pr(irow, icol, :)); % all daily pr in this grid                          
                    [ppdf1d, pamt1d, ~, ~, ~, ~, ~]=...
                    KDE_makeraindist_cmip(pdata1, modelyr, iyear, iyear);
                    freqdist(irow,icol,1:length(ppdf1d),iy)=ppdf1d;
                    amountdist(irow,icol,1:length(pamt1d),iy)=pamt1d;

                end
                      
              end
          end
           save([folder,'amip_KDE_raindist_',imodel,'_',iex,'_',ien,'_',...
              num2str(modelsy),num2str(modeley),'.mat'],...
              'freqdist','amountdist','bincrates', 'binl','-v7.3');         

        else % for CESM2 (19500101 to 20150101) not 20151231!!
          for irow=1:rows
              for icol=1:cols            
                for iy=1:length(modelyr)-1 % enyear as 2014
                    iyear=modelyr(iy);
                    pdata1=squeeze(pr(irow, icol, :)); % all daily pr in this grid 
                    % extract prcp1 and prcp2
                    srow = 1+365*(iyear(1)-modelyr(1));
                    erow = 365*(iyear(end)-modelyr(1)+1);
                    prcp1=pdata1(srow:erow,:);

                    [ppdf1d, pamt1d, ~, ~, ~, ~, ~]=...
                    KDE_makeraindist_i_station(prcp1,prcp1);

                    freqdist(irow,icol,1:length(ppdf1d),iy)=ppdf1d;
                    amountdist(irow,icol,1:length(pamt1d),iy)=pamt1d;

                end
                      
              end
          end            
              save([folder,'amip_KDE_raindist_',imodel,'_',iex,'_',ien,'_',...
              num2str(modelsy),num2str(modeley-1),'.mat'],...
              'freqdist','amountdist','bincrates', 'binl','-v7.3'); 

        end
      


                imodel
                iex
                ien
      end
    end

end


%%                cal uncertainty range for amip                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make a folder for results
clear
updatetime=datetime('now');
% folder=['/share/cliprelabs/jh2423/modesofchange_system/results_',char(updatetime)];
% mkdir(folder)
folder='/share/cliprelabs/jh2423/modesofchange_system/results_01-Feb-2025 15:39:58/';

%% load ghcnd data

%%%%%%%%%%%%%%%%%%%%%%%%% ghcnd data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read all raw ghcnd station data with start year <= startyear and
% end year >= endyear and plot shift-inc modes
directory='/share/cliprelabs/observations/ghcnd_all.tar/'
missrate=19; % set acceptable miss rate 
thelength=10;

for startyear=1980:5:1995 % startyear: latest start year
    for endyear=2014:-5:1999 % endyear: earliest end year
        if startyear+9 < endyear-9
        disp(['startyear = ', num2str(startyear), ' endyear = ', num2str(endyear)]);
        period1=startyear:(startyear+thelength-1);
        period2=(endyear-thelength+1):endyear;
           answ = exist([folder,'/','amip_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat']);
%         if answ == 0 % 0 means the variable did not exit 
 load([folder,'/thinner_dailypr_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cmip6 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% amip: load annual temp and station match grid
% clearvars -except period1 period2 finalids finallat finallon folder missrate values2...
%     filename startyear endyear period_length period1 period2 years ghcndprcp ghcnids...
%     ghcnlats ghcnlons values thelength count
modelsy=1979; % model rain dist start year (extend with ssp)
modeley=2014; % model rain dist end year (extend with ssp)
selectedmodels = {'ACCESS-CM2';'ACCESS-ESM1-5';...
    'BCC-CSM2-MR';'CanESM5';'CESM2';...
    'CMCC-CM2-SR5';
    'FGOALS-g3';
    'INM-CM4-8';'INM-CM5-0';...
    'IPSL-CM6A-LR';'MIROC6';...
    'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
    'TaiESM1'};
% amip pr and tas does not involve:  'CMCC-ESM2';'GFDL-ESM4';...
amipfolder='/share/cliprelabs/jh2423/modesofchange_system/amip_pr_day/'; % output folder
experiments={'amip'}; 
iex=experiments{1,1};% extend historical simu with a ssp
[ensemble]=cmip_existensembles(selectedmodels,iex); % name of members with both historical simu and the assigned ssp
nonEmptyIdx = ~cellfun('isempty', ensemble);
ensemble = ensemble(nonEmptyIdx);
selectedmodels=selectedmodels(nonEmptyIdx);

% Normalize the distribution by annual temperature change (%/K)
[meanT, mmmT]=cmip_mmm_tas(selectedmodels,iex, ensemble,period1,period2); % meanT for each model each member in period1 and 2
%dt=mean(mmmT(:,2)-mmmT(:,1)); % dt for each model

%cmip_station_match_grid
[latlongrid,indexofgrid,selectedmodels,finalids]=cmip_station_match_grid...
    (finalids,finallat,finallon,selectedmodels);

%% uncertainty range of shift,inc,ao,bo in cmip6 over aggregation of co-located grids

% rain distributions for each model each ensemble member in period 1 and 2
disp('cal rain distributions for each model each ensemble member in period 1 and 2');
tic
[modelsampleraindist,BINCRATES]=cmip_im_ien_raindist(indexofgrid,amipfolder,'KDE',selectedmodels,...
    iex,ensemble,modelsy,modeley,period1,period2);
save([folder,'/way1_amip_im_ien_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat'],'modelsampleraindist','selectedmodels','ensemble');
toc

% uncertainty range
[UR_inc,UR_shift,UR_err,UR_a_o,UR_b_o,UR_pamt1,UR_ppdf1,UR_dpamt1,UR_pamtshiftinc,UR_dppdf1,UR_ppdfshiftinc,...
    UR_dfreq,UR_dfreqshiftinc]=cmip_UR (modelsampleraindist,BINCRATES,selectedmodels,...
    ensemble,meanT);
save([folder,'/','amip_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
     num2str(period2(1)),num2str(period2(end)),'.mat'],'UR_inc', 'UR_shift', 'UR_err', 'UR_a_o', 'UR_b_o', 'UR_pamt1',...
     'UR_ppdf1','UR_dpamt1','UR_pamtshiftinc','UR_dppdf1','UR_ppdfshiftinc','UR_dfreq','UR_dfreqshiftinc');

%         end
        end
    end
end