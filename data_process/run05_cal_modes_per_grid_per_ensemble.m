%% Local modes of change at each co-located gridpoint, for each ensemble member
% 30 August 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% Produces the input for the revised Fig. 3 E,F, in which every individual
% simulation is shown rather than the multi-model mean, so that the model
% points carry internal variability in the same way the station points do.
%
% Output: gridinc_mem, gridshift_mem  (nstations x nmembers, % K^-1)
%         memmodel (nmembers x 1)     model index of each column
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
% unicorn path
addpath('/share/cliprelabs/jh2423/P1/data_process/')
cmip6folder='/share/cliprelabs/jh2423/modesofchange_system/cmip6_pr_day_native/';
outpath='/share/cliprelabs/jh2423/P1/dataforplot/';

% % local path
% addpath('\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\')
% cmip6folder='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\cmip6_pr_day_native\';
% outpath='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';

thelength=30; missrate=20;
startyear=1955; endyear=2023;
period1=startyear:(startyear+thelength-1);
period2=(endyear-thelength+1):endyear;
modelsy=1955; modeley=2025; % year axis of the saved distributions

selectedmodels = {'ACCESS-CM2';'ACCESS-ESM1-5';...
    'BCC-CSM2-MR';'CanESM5';'CESM2';...
    'CMCC-CM2-SR5';'CMCC-ESM2';...
    'FGOALS-g3';'GFDL-ESM4';...
    'INM-CM4-8';'INM-CM5-0';...
    'IPSL-CM6A-LR';'MIROC6';...
    'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
    'TaiESM1'};
iex='ssp370';

load(['/share/cliprelabs/jh2423/P1/data_process/ghcnd_pr/thinner_dailypr_',...
    num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat'],'finalids','finallat','finallon'); % station network

%cmip_station_match_grid
[~,indexofgrid,selectedmodels,finalids]=cmip_station_match_grid...
    (finalids,finallat,finallon,selectedmodels);
lens=length(finalids);
[ensemble]=cmip_existensembles(selectedmodels,iex); % name of members with both historical simu and the assigned ssp
[meanT,~]=cmip_mmm_tas(selectedmodels,iex,ensemble,period1,period2); % meanT for each model each member in period1 and 2

%% flat list of (model, member) pairs, so the loop can be parallelised
pairs=[];
for im=1:length(selectedmodels)
    mems=ensemble{im,1};
    if isempty(mems) || (numel(mems)==1 && isempty(mems{1})); continue; end
    pairs=[pairs; repmat(im,numel(mems),1) (1:numel(mems))'];
end
npair=size(pairs,1);
fprintf('%d station x %d member combinations\n', lens, npair);

%% longest bincrates across models, as in cmip_sample_raindist
BINCRATES=[];
for im=1:length(selectedmodels)
    mems=ensemble{im,1};
    if isempty(mems) || (numel(mems)==1 && isempty(mems{1})); continue; end
    S1=load([cmip6folder,'KDE_raindist_',selectedmodels{im},'_historical_',mems{1},'_19552014.mat'],'bincrates');
    S2=load([cmip6folder,'KDE_raindist_',selectedmodels{im},'_',iex,'_',mems{1},'_20152025.mat'],'bincrates');
    b=S1.bincrates; if length(S2.bincrates)>length(b); b=S2.bincrates; end
    if length(b)>length(BINCRATES); BINCRATES=b; end
end
nb=length(BINCRATES);

%% year indices of the two epochs within the saved arrays
years=modelsy:modeley;
ihist=years<=2014;                    % which of the saved years come from historical
p1h=find(ismember(years(ihist),period1));
p2h=find(ismember(years(ihist),period2));
p2s=find(ismember(years(~ihist),period2));

%% modes at each gridpoint, for each member
gridinc_mem   = nan(lens,npair);
gridshift_mem = nan(lens,npair);
memmodel      = pairs(:,1);

ncpu=str2double(getenv('SLURM_CPUS_PER_TASK'));
if isnan(ncpu)||ncpu<1; ncpu=feature('numcores'); end
if isempty(gcp('nocreate')); parpool('local',ncpu); end

tstart=tic;
parfor ip=1:npair
    im=pairs(ip,1); ie=pairs(ip,2);
    mems=ensemble{im,1};
    ien=mems{ie};

    Mh=matfile([cmip6folder,'KDE_raindist_',selectedmodels{im},'_historical_',ien,'_19552014.mat']);
    Ms=matfile([cmip6folder,'KDE_raindist_',selectedmodels{im},'_',iex,'_',ien,'_20152025.mat']);

    % temperature change of this member, falling back to the model mean
    dt=meanT{im,1}(ie,2)-meanT{im,1}(ie,1);
    if isnan(dt); dt=mean(meanT{im,1}(:,2)-meanT{im,1}(:,1),'omitnan'); end

    r=indexofgrid(:,1,im); q=indexofgrid(:,2,im);
    inc=nan(lens,1); shi=nan(lens,1);

    for is=1:lens
        if isnan(r(is))||isnan(q(is)); continue; end
        % one gridpoint, all bins, all years: a small read
        fh=squeeze(Mh.freqdist(r(is),q(is),1:nb,:));   ah=squeeze(Mh.amountdist(r(is),q(is),1:nb,:));
        fs=squeeze(Ms.freqdist(r(is),q(is),1:nb,:));   as=squeeze(Ms.amountdist(r(is),q(is),1:nb,:));
        fh(isnan(fh))=0; ah(isnan(ah))=0; fs(isnan(fs))=0; as(isnan(as))=0;

        % epoch means; period 2 spans the end of historical and the start of the ssp
        ppdf1=mean(fh(:,p1h),2);              pamt1=mean(ah(:,p1h),2);
        ppdf2=mean([fh(:,p2h) fs(:,p2s)],2);  pamt2=mean([ah(:,p2h) as(:,p2s)],2);

        [shift,increase,~,~,~,~,~,~,~,~,~,~,~,~,~]=...
            makeshiftinc_stations(ppdf1,pamt1,ppdf2,pamt2,dt,BINCRATES);
        inc(is)=increase; shi(is)=shift;
    end

    gridinc_mem(:,ip)=inc;
    gridshift_mem(:,ip)=shi;
    fprintf('%s %s done\n', selectedmodels{im}, ien);
end
fprintf('elapsed %.1f min\n', toc(tstart)/60);

memname = cell(npair,1); %name of ensemble member
for ip=1:npair
    memname{ip} = ensemble{pairs(ip,1),1}{pairs(ip,2)};
end
save([outpath,'cmip6_gridmodes_permember_',num2str(missrate),'%miss_',...
    num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat'],...
    'gridinc_mem','gridshift_mem','memmodel','selectedmodels','ensemble',...
    'finalids','memname','-v7.3');

delete(gcp('nocreate'));

%% also save as a netCDF file
% Cell arrays cannot go into netCDF directly, so the string variables are
% written with the netcdf4 'string' datatype and 'ensemble' is dropped: it is
% fully reconstructable from memname together with memmodel.
clear
outpath='/share/cliprelabs/jh2423/P1/dataforplot/';
thelength=30; missrate=20;
startyear=1955; endyear=2023;
period1=startyear:(startyear+thelength-1);
period2=(endyear-thelength+1):endyear;
modelsy=1955; modeley=2025; % year axis of the saved distributions
iex='ssp370';
load([outpath,'cmip6_gridmodes_permember_',num2str(missrate),'%miss_',...
    num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat']);
lens=length(finalids);
load(['/share/cliprelabs/jh2423/P1/data_process/ghcnd_pr/thinner_dailypr_',...
    num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat'],'finalids','finallat','finallon'); % station network

% flat list of (model, member) pairs, so the loop can be parallelised
pairs=[];
for im=1:length(selectedmodels)
    mems=ensemble{im,1};
    if isempty(mems) || (numel(mems)==1 && isempty(mems{1})); continue; end
    pairs=[pairs; repmat(im,numel(mems),1) (1:numel(mems))'];
end
npair=size(pairs,1);

ncfile=[outpath,'cmip6_gridmodes_permember_',num2str(missrate),'%miss_',...
    num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.nc'];
if isfile(ncfile); delete(ncfile); end

% station IDs may be stored as a cell of char or as a char matrix
if ischar(finalids); ids=string(cellstr(finalids)); else; ids=string(finalids); end

% model name of each member, so the file is self-contained
modelofmem=string(selectedmodels(memmodel));

% modes, station x member
nccreate(ncfile,'gridinc_mem','Dimensions',{'station',lens,'member',npair},...
    'Datatype','single','Format','netcdf4');
ncwrite(ncfile,'gridinc_mem',single(gridinc_mem));
ncwriteatt(ncfile,'gridinc_mem','long_name','increase mode at the gridpoint co-located with each station, for each ensemble member');
ncwriteatt(ncfile,'gridinc_mem','units','% K-1');

nccreate(ncfile,'gridshift_mem','Dimensions',{'station',lens,'member',npair},'Datatype','single');
ncwrite(ncfile,'gridshift_mem',single(gridshift_mem));
ncwriteatt(ncfile,'gridshift_mem','long_name','shift mode at the gridpoint co-located with each station, for each ensemble member');
ncwriteatt(ncfile,'gridshift_mem','units','% K-1');

% station coordinates, so the file can be mapped on its own
nccreate(ncfile,'lat','Dimensions',{'station',lens},'Datatype','single');
ncwrite(ncfile,'lat',single(finallat)); ncwriteatt(ncfile,'lat','units','degrees_north');
nccreate(ncfile,'lon','Dimensions',{'station',lens},'Datatype','single');
ncwrite(ncfile,'lon',single(finallon)); ncwriteatt(ncfile,'lon','units','degrees_east');

nccreate(ncfile,'station_id','Dimensions',{'station',lens},'Datatype','string');
ncwrite(ncfile,'station_id',ids);

% which model and which member each column belongs to
nccreate(ncfile,'memmodel','Dimensions',{'member',npair},'Datatype','int32');
ncwrite(ncfile,'memmodel',int32(memmodel));
ncwriteatt(ncfile,'memmodel','long_name','index into model_name of the model each member belongs to');

nccreate(ncfile,'memname','Dimensions',{'member',npair},'Datatype','string');
ncwrite(ncfile,'memname',string(memname));
ncwriteatt(ncfile,'memname','long_name','CMIP6 ensemble member identifier');

nccreate(ncfile,'member_model','Dimensions',{'member',npair},'Datatype','string');
ncwrite(ncfile,'member_model',modelofmem);
ncwriteatt(ncfile,'member_model','long_name','model name of each ensemble member');

nccreate(ncfile,'model_name','Dimensions',{'model',length(selectedmodels)},'Datatype','string');
ncwrite(ncfile,'model_name',string(selectedmodels));

ncwriteatt(ncfile,'/','title','local modes of change at station co-located gridpoints, for each CMIP6 ensemble member');
ncwriteatt(ncfile,'/','epoch1',[num2str(period1(1)),'-',num2str(period1(end))]);
ncwriteatt(ncfile,'/','epoch2',[num2str(period2(1)),'-',num2str(period2(end))]);
ncwriteatt(ncfile,'/','scenario',iex);
[ncfile]=nc_metadata(ncfile);