%% processing ghcnd data from dly files to netCDF outputs
% 4 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of dly files for your use
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% download ghcnd data
% 1) users can download all ghcnd data (ghcnd_all.tar.gz) 
% from:https://www.ncei.noaa.gov/pub/data/ghcn/daily/
% Then extract the files from tar into one folder, I extract the file into a
% folder called: '/share/cliprelabs/observations/ghcnd_all.tar/'
% 2) download ghcnd-inventory.txt into the same folder
% 3) download mingle-list.txt into the same folder

%% load dly format of ghcnd data (epoch length = 30 yrs, )
% read all raw ghcnd station data with start year <= startyear and
% end year >= endyear
% For epoch length of 20 years, users need to change the values of the
% follwing variables as:
% thelength=20; startyear=1955:5:1980; endyear=1998:5:2023
% For epoch length of 10 years, users need to change the values of the
% follwing variables as:
% thelength=10; startyear=1980:5:1995; endyear=2014:-5:1999

clear
clc
prfolder='/share/cliprelabs/jh2423/P1/data_process/ghcnd_pr/'; % the folder saved all initially read ghcnd data in mat format
directory='/share/cliprelabs/observations/ghcnd_all.tar/';
thelength=30; % epoch length
missrate=19; % set acceptable miss rate 

for startyear=1955:1964  % startyear: latest start year
    for endyear=2023:-1:2014  % endyear: earliest end year
        if startyear+(thelength-1) < endyear+(thelength-1)
          % dense_station_country: country id of data-dense countries
          dense_station_country={'US','RS','AS','PO','SP','FR','UK','GM','NL','NO','SW',...
    'EN','BO','IT','AU','RO','HU'}; 
    % US United States % RS Russia % AS Australia % PO Portugal % SP Spain % FR France
    % UK United kingdom % GM Germany  % NL Netherlands  % NO Norway % SW Sweden
    % EN Estonia % BO Belarus % IT Italy  % AU Austria  % RO Romania % HU Hungary
    
    % read ghcnd stations measuring 'PRCP' and with start year <= startyear & end year >= endyear
    [ghcndprcp, pnz, ghcnids, ghcnlats, ghcnlons, years ] = load_ghcnd_prcp(startyear, endyear,...
        directory, prfolder);
%     save ([prfolder,'reo_ghcnddailydata_',...
%         num2str(startyear),num2str(endyear),'.mat'], ...
%         'ghcndprcp', 'pnz', 'ghcnids', 'ghcnlats', 'ghcnlons', ...
%         'years','-v7.3'); % save intermediate process data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% quality control %%%%%%%%%%%%%%%%%%%%%%%%%%
% apply a relatively strict completeness criterion: a year is classified 
% as "missing" if it has over missrate% of missing data. 
% Stations with at most missrate% missing years for both the 
% early epoch and the late epoch are retained 
% for the subsequent analysis.
    period1=startyear:(startyear+thelength-1); % early epoch
    period2=(endyear-thelength+1):endyear; % late epoch
    [qc_prcp, qcids, qclat, qclon, years, period1, period2]=strict_qc_station(...
missrate, period1, period2, years,ghcndprcp, ghcnids,ghcnlats,ghcnlons);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% thin stations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% thin stations in station-dense countries after applying completeness criteria: 
% for stations in station-dense countries, just remain 'gsn' stations
% for stations in other countries, remain all ghcnd stations

% US United States % RS Russia % AS Australia % PO Portugal % SP Spain % FR France
% UK United kingdom % GM Germany % NL Netherlands  % NO Norway % SW Sweden
% EN Estonia % BO Belarus % IT Italy  % AU Austria % RO Romania % HU Hungary % JA Japan 
% CH China % CA Canada % RQ Puerto Rico [United States] % HR Croatia % SZ Switzerland
% thinner_id={'US','RS','AS','PO','SP','FR','UK','GM','NL','NO','SW',...
%     'EN','BO','IT','AU','RO','HU','JA','CA','RQ','CH','HR','SZ'};

[finalsta_prcp,finalids,finallat,finallon,years, gsn_jud]=thinner_stations(...
    [], qc_prcp, qcids, qclat, qclon, years);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% source check?? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minglelist='/share/cliprelabs/observations/ghcnd_all.tar/mingle-list.txt';
[theidnum]=numofsources(minglelist);
jud=ismember(theidnum(:,1),finalids);
final_sources=theidnum(jud,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(['/share/cliprelabs/jh2423/P1/data_process/ghcnd_pr/','thinner_dailypr_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat'],...
    'finalsta_prcp','finalids','finallat','finallon','years','qclat', 'qclon');


        end
        
        
    end
    
    
end



