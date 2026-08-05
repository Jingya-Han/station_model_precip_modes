%% change non-zero precipitation threshod into 1 mm/day and repeat the whole calculation
% August 2026.
% Reads the non0thre_1_KDE files, which hold ONE pooled distribution per
% epoch (dim4: 1=period1, 2=period2) instead of a year axis. The inline
% block below replaces cmip_im_ien_raindist.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cal confidence interval for modes in cmip6
% 28 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of files for your use.
% You will need to change the epoch length, start year, end year to get
% results for different endpoints and epoch length.

clear
addpath('/share/cliprelabs/jh2423/P1/data_process/')
folder='/share/cliprelabs/jh2423/P1/revision_v1/'; % the path saved data for plotting

%% load ghcnd data
missrate=20; % set acceptable miss rate
thelength=30;
startyear=1955; % startyear: latest start year
endyear=2023;   % endyear: earliest end year
period1=startyear:(startyear+thelength-1);
period2=(endyear-thelength+1):endyear;

load(['/share/cliprelabs/jh2423/P1/data_process/ghcnd_pr/thinner_dailypr_',num2str(missrate),'%miss_',...
    num2str(period1(1)),num2str(period1(end)),'_',num2str(period2(1)),num2str(period2(end)),'.mat'])

%% cmip6: load annual temp and station match grid
selectedmodels = {'ACCESS-CM2';'ACCESS-ESM1-5';...
    'BCC-CSM2-MR';'CanESM5';'CESM2';...
    'CMCC-CM2-SR5';'CMCC-ESM2';...
    'FGOALS-g3';'GFDL-ESM4';...
    'INM-CM4-8';'INM-CM5-0';...
    'IPSL-CM6A-LR';'MIROC6';...
    'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
    'TaiESM1'};
cmip6folder='/share/cliprelabs/jh2423/P1/revision_v1/cmip6_pr_day_native/'; % where run01_2 writes
experiments={'ssp370'};
iex=experiments{1,1};% extend historical simu with a ssp
[ensemble]=cmip_existensembles(selectedmodels,iex); % name of members with both historical simu and the assigned ssp

% Normalize the distribution by annual temperature change (%/K)
[meanT, mmmT]=cmip_mmm_tas(selectedmodels,iex, ensemble,period1,period2); % meanT for each model each member in period1 and 2
dt=mean(mmmT(:,2)-mmmT(:,1)); % dt for each model

%cmip_station_match_grid
[latlongrid,indexofgrid,selectedmodels,finalids]=cmip_station_match_grid...
    (finalids,finallat,finallon,selectedmodels);
% re-derive: cmip_station_match_grid may drop models, ensemble has to stay aligned
[ensemble]=cmip_existensembles(selectedmodels,iex);

%% uncertainty range of shift,inc,ao,bo in cmip6 over aggregation of co-located grids

% rain distributions for each model each ensemble member in period 1 and 2
% modelsampleraindist{im,1}: nmem x nbins x 4  (ppdf1, ppdf2, pamt1, pamt2)
disp('cal rain distributions for each model each ensemble member in period 1 and 2');
tic
suf = ['_',num2str(period1(1)),num2str(period1(end)),'_',...
           num2str(period2(1)),num2str(period2(end)),'.mat'];
modelsampleraindist = cell(length(selectedmodels),1);
for im = 1:length(selectedmodels)
    mems = ensemble{im};
    nmem = numel(mems);
    for ie = 1:nmem
        ien = mems{ie};
        S = load([cmip6folder,'non0thre_1_KDE_raindist_',selectedmodels{im},'_',iex,'_',ien,suf],...
            'freqdist','amountdist','bincrates');
        if im == 1 && ie == 1
            BINCRATES = S.bincrates(:);
            nb = length(BINCRATES);
        end
        [rows,cols,nbmax,~] = size(S.freqdist);
        % indexofgrid: stations * [row col lat lon] * models
        lin = sub2ind([rows cols], indexofgrid(:,1,im), indexofgrid(:,2,im));
        F = reshape(S.freqdist,   rows*cols,nbmax,2);
        A = reshape(S.amountdist, rows*cols,nbmax,2);
        f = F(lin,1:nb,:); f(isnan(f)) = 0; % lens x nb x 2
        a = A(lin,1:nb,:); a(isnan(a)) = 0;
        if ie == 1
            modelsampleraindist{im,1} = nan(nmem,nb,4);
        end
        % mean across all co-located grids
        modelsampleraindist{im,1}(ie,:,1) = mean(f(:,:,1),1); % ppdf1
        modelsampleraindist{im,1}(ie,:,2) = mean(f(:,:,2),1); % ppdf2
        modelsampleraindist{im,1}(ie,:,3) = mean(a(:,:,1),1); % pamt1
        modelsampleraindist{im,1}(ie,:,4) = mean(a(:,:,2),1); % pamt2
    end
    fprintf('%-16s %d members\n', selectedmodels{im}, nmem);
end
save([folder,'way1_cmip6_im_ien_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat'],'modelsampleraindist','selectedmodels','ensemble','BINCRATES');
toc

% uncertainty range
[UR_inc,UR_shift,UR_err,UR_a_o,UR_b_o,UR_pamt1,UR_ppdf1,UR_dpamt1,UR_pamtshiftinc,UR_dppdf1,UR_ppdfshiftinc,...
    UR_dfreq,UR_dfreqshiftinc]=cmip_UR (modelsampleraindist,BINCRATES,selectedmodels,...
    ensemble,meanT);
save([folder,'cmip6_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
     num2str(period2(1)),num2str(period2(end)),'.mat'],'UR_inc', 'UR_shift', 'UR_err', 'UR_a_o', 'UR_b_o', 'UR_pamt1',...
     'UR_ppdf1','UR_dpamt1','UR_pamtshiftinc','UR_dppdf1','UR_ppdfshiftinc','UR_dfreq','UR_dfreqshiftinc');

%% 19551984_19942023 -- save as nc file
clear
period1=1955:1984;
period2=1994:2023;
missrate=20;
path='/share/cliprelabs/jh2423/P1/revision_v1/'; % the path saved data for plotting
filename=[path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.mat'];
fileinfo=matfile(filename);
ncfile=([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc']);
vars = who(fileinfo);
for i = 1:length(vars) % Loop through variables and load them one by one
    varname = vars{i};
    tmp = load(filename, varname); % Load the variable into current workspace
    data = tmp.(varname); % Extract the variable by its name
    data = single(data);
    dim=size(data);
    nccreate(ncfile, varname,'Dimensions',{[varname,'_row'], dim(1),[varname,'_col'],dim(2)});
    ncwrite(ncfile, varname,data);

end