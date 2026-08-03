%% change non-zero precipitation threshod into 1 mm/day and repeat the whole calculation
% August 2026.
% pr(pr<1)=0 is applied to the raw daily field (mm/day) immediately after
% reading, i.e. BEFORE cmip_bincrates and BEFORE any KDE, so it is the same
% operation as finalsta_prcp(finalsta_prcp<1)=0 on the station side.
%
% Restructured: instead of one KDE per grid point per YEAR, this computes
% ONE pooled distribution per EPOCH per grid point, exactly as the station
% script does with prcp1 / prcp2. One call to KDE_makeraindist_i_station
% returns both epochs on a common set of bins.
%   freqdist / amountdist : rows x cols x nbmax x 2   (index 4: 1=period1, 2=period2)
%% calculate the amount distributions and modes of change for cmip6

% 23 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of files for your use.
% You will need to change the epoch length, start year, end year to get
% results for different endpoints and epoch length.

%% setup
clear
addpath('/share/cliprelabs/jh2423/P1/data_process/') % so parfor workers inherit the path

folder='/share/cliprelabs/jh2423/P1/revision_v1/cmip6_pr_day_native'; % output folder
if ~exist(folder,'dir'); mkdir(folder); end

srcdir='/share/cliprelabs/cmip6-ng/pr/day/native/';

thelength=30;   % epoch length
startyear=1955; % startyear: latest start year
endyear=2023;   % endyear: earliest end year
period1=startyear:(startyear+thelength-1);      % early epoch  1955-1984
period2=(endyear-thelength+1):endyear;          % late epoch   1994-2023

sspname='ssp370'; % scenario used to extend historical past 2014
histend=2014;     % last year available in the historical experiment

modelsnm = {'ACCESS-CM2';'ACCESS-ESM1-5';...
    'BCC-CSM2-MR';'CanESM5-1';'CanESM5';'CESM2';...
    'CMCC-CM2-SR5';'CMCC-ESM2';...
    'FGOALS-g3';'GFDL-ESM4';...
    'INM-CM4-8';'INM-CM5-0';...
    'IPSL-CM6A-LR';'MIROC6';...
    'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
    'TaiESM1'};
% notes:AWI-CM-1-1-MR  #no historical
%       CanESM5-1  #no historical
% ICON-ESM-LR  # vertices_latitude? pr dimension: i, time
% 'KACE-1-0-G' # time dimension is not equal to 1955 to 2014
% BCC-ESM1: no ssp
% CESM2-FV2: no ssp
% CMCC-CM2-HR4: no ssp
% E3SM-1-0, E3SM-2-0:no ssp
% 'IITM-ESM': no ssp
% 'KIOST-ESM'; no ssp
% 'NESM3'; no ssp
% 'EC-Earth3';'EC-Earth3-AerChem';'EC-Earth3-Veg': out of memory

nbin=5;    % the smoother, controls the smoothness of distribution for *one* station
mbin=3;    % the smoother, controls the smoothness of distribution for *multiple* stations
nbmax=300; % estimated max length of bins

% split period2 into its historical part and its ssp part
p2h=period2(period2<=histend);
p2s=period2(period2> histend);

%% start the parallel pool, sized from SLURM
ncpu = str2double(getenv('SLURM_CPUS_PER_TASK'));
if isnan(ncpu) || ncpu < 1; ncpu = feature('numcores'); end
pc = parcluster('local');
jsl = getenv('MATLAB_JOBDIR'); % set by the .sub file; keeps concurrent jobs from clashing
if isempty(jsl); jsl = fullfile(tempdir,['mljob_',num2str(feature('getpid'))]); end
if ~exist(jsl,'dir'); mkdir(jsl); end
pc.JobStorageLocation = jsl;
pc.NumWorkers = ncpu;
if isempty(gcp('nocreate')); parpool(pc,ncpu); end
fprintf('parallel pool: %d workers\n', ncpu);

%% pooled epoch distributions for each native grid point
for im=1:length(modelsnm)
    imodel=modelsnm{im};

    % the ensemble member has to exist in BOTH historical and the ssp
    fh=dir([srcdir,'pr_day_',imodel,'_historical_*.nc']);
    fs=dir([srcdir,'pr_day_',imodel,'_',sspname,'_*.nc']);
    if isempty(fh) || isempty(fs)
        fprintf('skip (missing historical or %s): %s\n', sspname, imodel); continue
    end
    mem_h=cell(numel(fh),1);
    for q=1:numel(fh)
        k=strfind(fh(q).name,'_'); mem_h{q}=fh(q).name(k(4)+1:k(5)-1);
    end
    mem_s=cell(numel(fs),1);
    for q=1:numel(fs)
        k=strfind(fs(q).name,'_'); mem_s{q}=fs(q).name(k(4)+1:k(5)-1);
    end
    common=intersect(unique(mem_h),unique(mem_s));
    if isempty(common)
        fprintf('skip (no member in both experiments): %s\n', imodel); continue
    end
    if ismember('r1i1p1f1',common); ien='r1i1p1f1'; else; ien=common{1}; end

    % judge if there is already the results
    % (the checked name MUST be the same name that is saved below)
    outfile=[folder,'/non0thre_1_KDE_raindist_',imodel,'_',sspname,'_',ien,'_',...
        num2str(period1(1)),num2str(period1(end)),'_',...
        num2str(period2(1)),num2str(period2(end)),'.mat'];
    if exist(outfile,'file')==2
        fprintf('skip (already done): %s\n', outfile); continue
    end

    fprintf('--- %s | %s | %d-%d vs %d-%d ---\n', imodel, ien, ...
        period1(1), period1(end), period2(1), period2(end));
    tstart=tic;

    % ---- read period1 (entirely inside historical) ----
    [pr1, lat, lon]=cmip_read_histssp_data(imodel,'historical',ien,period1(1),period1(end));
    pr1(pr1<1)=0; % non-zero precip threshold = 1 mm/day (pr must ALREADY be mm/day here)

    % ---- read period2 (historical part + ssp part) ----
    if isempty(p2s)
        [pr2,~,~]=cmip_read_histssp_data(imodel,'historical',ien,p2h(1),p2h(end));
    elseif isempty(p2h)
        [pr2,~,~]=cmip_read_histssp_data(imodel,sspname,ien,p2s(1),p2s(end));
    else
        [ah,~,~]=cmip_read_histssp_data(imodel,'historical',ien,p2h(1),p2h(end));
        [as,~,~]=cmip_read_histssp_data(imodel,sspname,   ien,p2s(1),p2s(end));
        pr2=cat(3,ah,as);
        ah=[]; as=[]; % free memory
    end
    pr2(pr2<1)=0;

    [rows,cols,nd1]=size(pr1);
    nd2=size(pr2,3);
    fprintf('grid %d x %d | period1 %d days | period2 %d days\n', rows, cols, nd1, nd2);
    if ~isequal(size(pr2,1),rows) || ~isequal(size(pr2,2),cols)
        error('grid mismatch between the two epochs for %s', imodel);
    end

    % ---- model-wide common bins ----
    % bins are a fixed geometric sequence, so the longer vector contains the
    % shorter one as a prefix; take the longer and verify that.
    [bc1,bl1,db1,br1]=cmip_bincrates(pr1);
    [bc2,bl2,db2,br2]=cmip_bincrates(pr2);
    ns=min(length(bc1),length(bc2));
    if max(abs(bc1(1:ns)-bc2(1:ns))) > 1e-9*max(abs(bc1(1:ns)))
        error('bincrates from the two epochs are not on a common grid for %s', imodel);
    end
    if length(bc1) >= length(bc2)
        bincrates=bc1; binl=bl1; dbin=db1; binr=br1;
    else
        bincrates=bc2; binl=bl2; dbin=db2; binr=br2;
    end
    if length(bincrates) > nbmax
        error('length(bincrates)=%d exceeds nbmax=%d for %s', length(bincrates), nbmax, imodel);
    end

    % ---- one pooled KDE per grid point, both epochs in a single call ----
    freqdist=nan(rows,cols,nbmax,2);   % index 4: 1=period1, 2=period2
    amountdist=freqdist;
    ndry=0; % grid points with an epoch that has no day >= 1 mm/day

    parfor irow=1:rows
        r1=squeeze(pr1(irow,:,:)); % sliced input: cols x nd1
        r2=squeeze(pr2(irow,:,:)); % sliced input: cols x nd2
        fr=nan(cols,nbmax,2);
        am=nan(cols,nbmax,2);
        ndry_row=0;
        for icol=1:cols
            prcp1=r1(icol,:)';
            prcp2=r2(icol,:)';
            if all(isnan(prcp1)) && all(isnan(prcp2)); continue; end
            if ~any(prcp1>0) || ~any(prcp2>0)
                ndry_row=ndry_row+1; % an epoch with no rain >= 1 mm/day
                continue             % leave as NaN
            end
            [ppdf1d, pamt1d, ppdf2d, pamt2d, ~, ~, ~]=...
                KDE_makeraindist_i_station(prcp1, prcp2, nbin, mbin);
            L=length(ppdf1d);
            fr(icol,1:L,1)=ppdf1d;  am(icol,1:L,1)=pamt1d;
            fr(icol,1:L,2)=ppdf2d;  am(icol,1:L,2)=pamt2d;
        end
        freqdist(irow,:,:,:)=reshape(fr,1,cols,nbmax,2);
        amountdist(irow,:,:,:)=reshape(am,1,cols,nbmax,2);
        ndry=ndry+ndry_row;
    end

    fprintf('grid points with an all-dry epoch: %d of %d (%.2f%%)\n', ...
        ndry, rows*cols, 100*ndry/(rows*cols));

    save(outfile,'freqdist','amountdist','bincrates','binl','dbin','binr',...
        'lat','lon','period1','period2','ien','sspname','ndry',...
        '-v7.3','-nocompression');

    fprintf('done %s in %.1f min\n', imodel, toc(tstart)/60);

    pr1=[]; pr2=[]; freqdist=[]; amountdist=[]; % free before the next model
end

delete(gcp('nocreate'));