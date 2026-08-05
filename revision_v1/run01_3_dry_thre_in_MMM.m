%% change non-zero precipitation threshod into 1 mm/day and repeat the whole calculation
% August 2026. Changes are made in line 46-62

%% calculate the amount distributions and modes of change for models
% 28 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of files for your use.
% You will need to change the epoch length, start year, end year to get
% results for different endpoints and epoch length.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
clc
addpath('/share/cliprelabs/jh2423/P1/data_process/')
cmip6folder='/share/cliprelabs/jh2423/P1/revision_v1/cmip6_pr_day_native'; % output folder
path='/share/cliprelabs/jh2423/P1/revision_v1/';% the path saved data for plotting
thelength=30; % epoch length
missrate=20; % set acceptable miss rate
startyear=1955; % startyear: latest start year
endyear=2023; % endyear: earliest end year
period1=startyear:(startyear+thelength-1); % early epoch
period2=(endyear-thelength+1):endyear; % late epoch
load(['/share/cliprelabs/jh2423/P1/data_process/ghcnd_pr/',...
    'thinner_dailypr_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat']);

%% cmip6: load annual temp and station match grid

modelsy=1955; % model rain dist start year (extend with ssp)
modeley=2025; % model rain dist end year (extend with ssp)
selectedmodels = {'ACCESS-CM2';'ACCESS-ESM1-5';...
    'BCC-CSM2-MR';'CanESM5';'CESM2';...
    'CMCC-CM2-SR5';'CMCC-ESM2';...
    'FGOALS-g3';'GFDL-ESM4';...
    'INM-CM4-8';'INM-CM5-0';...
    'IPSL-CM6A-LR';'MIROC6';...
    'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
    'TaiESM1'};
%   selectedmodels ={'CESM2';...
%     'CMCC-CM2-SR5';'CMCC-ESM2';...
%     'FGOALS-g3';'GFDL-ESM4';...
%     'INM-CM4-8';'INM-CM5-0';...
%     'IPSL-CM6A-LR';...
%     'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
%     'TaiESM1'};
experiments={'ssp370'}; 
iex=experiments{1,1};% extend historical simu with a ssp
[ensemble]=cmip_existensembles(selectedmodels,iex); % name of members with both historical simu and the assigned ssp

% Normalize the distribution by annual temperature change (%/K)
% mmmT is already the ensemble mean of meanT for each model
[meanT, mmmT]=cmip_mmm_tas(selectedmodels,iex, ensemble,period1,period2); % meanT for each model each member in period1 and 2
dt=mean(mmmT(:,2)-mmmT(:,1)); % dt for each model

%cmip_station_match_grid
[latlongrid,indexofgrid,selectedmodels,finalids]=cmip_station_match_grid...
    (finalids,finallat,finallon,selectedmodels);
% re-derive: cmip_station_match_grid may drop models, ensemble has to stay aligned
[ensemble]=cmip_existensembles(selectedmodels,iex);
disp('model samples for freq and amount distribution')

%% cmip6: Shift and increase modes over aggregation of co-located grids -- Way1
% Smoothed (P2) – Smoothed (P1)

% tic
% [ksfreqmodelsample,ksamountmodelsample,~,BINCRATES]=cmip_sample_raindist...
%     (finalids,indexofgrid,cmip6folder,'KDE',selectedmodels,iex,ensemble,modelsy, modeley);
% toc
% [KDEMMMppdf1,KDEMMMpamt1,KDEMMMppdf2,KDEMMMpamt2,...
%  gridppdf1,gridppdf2,gridpamt1,gridpamt2]=cmip_MMMraindistp1p2(ksfreqmodelsample,ksamountmodelsample,modelsy:modeley,period1,period2);

% freqmodelsample / amountmodelsample from the non0thre_1_KDE files
% (lens, length(selectedmodels), length(BINCRATES), 2)   dim4: 1=period1, 2=period2

lens = length(finalids);
nmod = length(selectedmodels);
suf  = ['_',num2str(period1(1)),num2str(period1(end)),'_',...
            num2str(period2(1)),num2str(period2(end)),'.mat'];
for im = 1:nmod
    mems = ensemble{im};
    nmem = numel(mems);
    fsum = 0; asum = 0;
    for ie = 1:nmem
        ien = mems{ie};
        S = load([cmip6folder,'/non0thre_1_KDE_raindist_',selectedmodels{im},'_',iex,'_',ien,suf],...
            'freqdist','amountdist','bincrates');
        if im == 1 && ie == 1
            BINCRATES = S.bincrates(:);
            nb = length(BINCRATES);
            freqmodelsample   = zeros(lens,nmod,nb,2);
            amountmodelsample = zeros(lens,nmod,nb,2);
        end
        [rows,cols,nbmax,~] = size(S.freqdist);
        % indexofgrid: stations * [row col lat lon] * models
        lin = sub2ind([rows cols], indexofgrid(:,1,im), indexofgrid(:,2,im));
        F = reshape(S.freqdist,   rows*cols,nbmax,2);
        A = reshape(S.amountdist, rows*cols,nbmax,2);
        f = F(lin,1:nb,:); f(isnan(f)) = 0; % lens x nb x 2
        a = A(lin,1:nb,:); a(isnan(a)) = 0;
        fsum = fsum + f;
        asum = asum + a;
    end
    % mean across members, so every model carries the same weight
    freqmodelsample(:,im,:,:)   = reshape(fsum/nmem,lens,1,nb,2);
    amountmodelsample(:,im,:,:) = reshape(asum/nmem,lens,1,nb,2);
    fprintf('%-16s %d members\n', selectedmodels{im}, nmem);
end

% cmip_MMMraindistp1p2, with the year averaging replaced by the epoch index
ksmodelppdf1=freqmodelsample(:,:,:,1);
ksmodelpamt1=amountmodelsample(:,:,:,1);
ksmodelppdf2=freqmodelsample(:,:,:,2);
ksmodelpamt2=amountmodelsample(:,:,:,2);
% mean across all co-located grids
mppdf1=mean(ksmodelppdf1,1);
mppdf2=mean(ksmodelppdf2,1);
mpamt1=mean(ksmodelpamt1,1);
mpamt2=mean(ksmodelpamt2,1);
% MMM of freq and amount dist for period1 and period2
KDEMMMppdf1=mean(mppdf1,2);  KDEMMMppdf1=squeeze(KDEMMMppdf1);
KDEMMMppdf2=mean(mppdf2,2);  KDEMMMppdf2=squeeze(KDEMMMppdf2);
KDEMMMpamt1=mean(mpamt1,2);  KDEMMMpamt1=squeeze(KDEMMMpamt1);
KDEMMMpamt2=mean(mpamt2,2);  KDEMMMpamt2=squeeze(KDEMMMpamt2);
% MMM of spatial pattern of rain distributions
gridppdf1=mean(ksmodelppdf1,2); gridppdf1=squeeze(gridppdf1);
gridppdf2=mean(ksmodelppdf2,2); gridppdf2=squeeze(gridppdf2);
gridpamt1=mean(ksmodelpamt1,2); gridpamt1=squeeze(gridpamt1);
gridpamt2=mean(ksmodelpamt2,2); gridpamt2=squeeze(gridpamt2);


[mmmshift_w1,mmminc_w1,mmmerr_w1,mmm_dpamt1,mmm_pamtshift,mmm_pamtinc,mmm_pamtshiftinc,mmm_dppdf1,mmm_ppdfshift,mmm_ppdfinc,...
    mmm_ppdfshiftinc,mmm_dfreq,mmm_dfreqshift,mmm_dfreqinc,mmm_dfreqshiftinc]=makeshiftinc_stations...
    (KDEMMMppdf1(:), KDEMMMpamt1(:), KDEMMMppdf2(:), KDEMMMpamt2(:),dt,BINCRATES);

[MMM_a_o, MMM_b_o]=calc_ao_bo_raindist(KDEMMMpamt1(:),KDEMMMpamt2(:),BINCRATES);
MMM_a_o=MMM_a_o./dt;
MMM_b_o=MMM_b_o./dt;

save( [path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat'],'KDEMMMppdf1','KDEMMMpamt1','mmmshift_w1','mmminc_w1','mmmerr_w1','mmm_dpamt1','mmm_pamtshift','mmm_pamtinc',...
    'mmm_pamtshiftinc','mmm_dppdf1','mmm_ppdfshift','mmm_ppdfinc','mmm_ppdfshiftinc','mmm_dfreq','mmm_dfreqshift','mmm_dfreqinc',...
    'mmm_dfreqshiftinc','MMM_a_o','MMM_b_o','BINCRATES','dt');
% save as .nc file
filename=[path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.mat'];
fileinfo=matfile(filename);
ncfile=([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc']);
vars = who(fileinfo);
for i = 1:length(vars) % Loop through variables and load them one by one
    varname = vars{i};       
    tmp = load(filename, varname); % Load the variable into current workspace  
    data = tmp.(varname); % Extract the variable by its name
    data = single(data);
    nccreate(ncfile, varname,'Dimensions',{varname, length(data)});
    ncwrite(ncfile, varname,data);    
    
end
ncwriteatt(ncfile, '/', 'title', 'modes and distributions over aggregation of gridpoints for MMM');
% Add global attributes (metadata)
[ncfile]=nc_metadata(ncfile);

clear ksfreqmodelsample ksamountmodelsample

% %% cmip6: Shift and increase modes over aggregation of co-located grids -- Way0
% % original method
% for i=1:length(selectedmodels)
%     oldensemble(i,1)=ensemble(end);
% end
% tic
% [oldfreqmodelsample,oldamountmodelsample,~,oldBINCRATES]=cmip_sample_raindist...
%     (finalids,indexofgrid,cmip6folder,'old',selectedmodels,iex,oldensemble,modelsy, modeley);
% toc
% oldfreqmodelsample(:,:,1:48,:)=0;
% oldamountmodelsample(:,:,1:48,:)=0;
% 
% [oldMMMppdf1,oldMMMpamt1,oldMMMppdf2,oldMMMpamt2,...
%  gridppdf1,gridppdf2,gridpamt1,gridpamt2]=cmip_MMMraindistp1p2(oldfreqmodelsample,oldamountmodelsample,modelsy:modeley,period1,period2);
% 
% save( [path,'way0_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
%     num2str(period2(1)),num2str(period2(end)),'.mat'],'oldMMMppdf1','oldMMMpamt1','oldBINCRATES','dt');
% % save as .nc file
% filename=[path,'way0_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
%     '_',num2str(period2(1)),num2str(period2(end)),'.mat'];
% fileinfo=matfile(filename);
% ncfile=([path,'way0_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
%     '_',num2str(period2(1)),num2str(period2(end)),'.nc']);
% vars = who(fileinfo);
% for i = 1:length(vars) % Loop through variables and load them one by one
%     varname = vars{i};       
%     tmp = load(filename, varname); % Load the variable into current workspace  
%     data = tmp.(varname); % Extract the variable by its name
%     data = single(data);
%     nccreate(ncfile, varname,'Dimensions',{varname, length(data)});
%     ncwrite(ncfile, varname,data);    
%     
% end
% ncwriteatt(ncfile, '/', 'title', 'way0 distributions over aggregation of gridpoints for MMM');
% % Add global attributes (metadata)
% [ncfile]=nc_metadata(ncfile);


%% spatial pattern of modes in cmip6-mmm
% rain distribtions over each grid

gridinc=nan(length(gridppdf1(:,1)),1);
gridshift=nan(length(gridppdf1(:,1)),1);
grid_a_o=nan(length(gridppdf1(:,1)),1);
grid_b_o=nan(length(gridppdf1(:,1)),1);
for ig=1:length(gridppdf1(:,1))
    [mmmshift,mmminc,mmmerr,~,~,~,~,~,~,~,...
     ~,~,~,~,~]=makeshiftinc_stations...
    (gridppdf1(ig,:)', gridpamt1(ig,:)', gridppdf2(ig,:)', gridpamt2(ig,:)',dt,BINCRATES);
    gridinc(ig,1)=mmminc;
    gridshift(ig,1)=mmmshift;  
    [a_o, b_o]=calc_ao_bo_raindist(gridpamt1(ig,:)',gridpamt2(ig,:)',BINCRATES);
    a_o=a_o./dt;
    grid_a_o(ig,1)=a_o;
    b_o=b_o./dt;
    grid_b_o(ig,1)=b_o;
    

end
save([path,'cmip6_modes_spatial_dist_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat'],'gridinc','gridshift','grid_a_o','grid_b_o');

filename=[path,'cmip6_modes_spatial_dist_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.mat'];
fileinfo=matfile(filename);
ncfile=([path,'cmip6_modes_spatial_dist_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
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
ncwriteatt(ncfile, '/', 'title', 'spatial pattern of modes for MMM');
% Add global attributes (metadata)
[ncfile]=nc_metadata(ncfile);