% Amount distributions and modes of change at REGEN grid cells co-located
%  with the GHCNd station network, for REGEN-All and REGEN-Long
%  3 Sept 2026, Jingya Han, Cornell University, jh2423@cornell.edu
% 
%  Mirrors run01_cal_modes_in_stations.m. The only structural difference is
%  the front end: instead of reading station time series, daily series are
%  extracted at the REGEN grid cells that contain each station. Everything
%  downstream -- QC, KDE distributions, shift/increase modes, directly
%  calculated modes, per-cell spatial pattern, bootstrap uncertainty -- is
%  identical to the station pipeline, so the outputs drop into the Fig. 1-4
%  scripts.
% 
%  DATA: native REGEN v1-2019 (NCI), not the FROGS repackaging. Precipitation
%  is variable 'p'; 's' holds the number of gauges located inside each REGEN grid cell
% on each day. Coverage is 1950-2016, so the late epoch of the main analysis cannot be reproduced and
%  period2 is set to the last 30 years available.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc
thelength = 30;
missrate  = 20;                  % apply the same QC criteria as GHCNd station network
period1   = 1955:1984;           % unchanged from the main analysis
period2   = 1987:2016;           % last 30 years of REGEN v1-2019 (ends 2016)
% KDE smoothing widths, in units of the bin width. The aggregated
% distribution and the individual-cell distributions may use different
% values; set these to whatever run01_cal_modes_in_stations.m passes to
% KDE_makeraindist_i_station for the aggregate and for the per-station loop
% respectively, so the REGEN cells are smoothed exactly like the stations.
nbin = 5;  mbin = 3;             % aggregated distribution
nbin_cell = nbin;  mbin_cell = mbin;   % individual grid cells
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% unicorn path
addpath('/share/cliprelabs/jh2423/P1/data_process/')
dir_all  = '/share/cliprelabs/jh2423/P1/data_process/REGEN/REGEN_All/v1-2019/';
dir_long = '/share/cliprelabs/jh2423/P1/data_process/REGEN/REGEN_Long/v1-2019/';
outdir   = '/share/cliprelabs/jh2423/P1/data_process/REGEN/REGEN_outputs/';
if ~exist(outdir,'dir'); mkdir(outdir); end
noaa_path     = '/share/cliprelabs/jh2423/P1/data_process/tas/aravg.ann.land_ocean.90S.90N.v6.0.0.202401.asc.txt';
berkeley_path = '/share/cliprelabs/jh2423/P1/data_process/tas/global_land_and_ocean_annual_temp.txt';
GISS_path     = '/share/cliprelabs/jh2423/P1/data_process/tas/GLB.Ts+dSST.csv';
load(['/share/cliprelabs/jh2423/P1/data_process/ghcnd_pr/thinner_dailypr_', ...
    num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat'], ...
    'finalids','finallat','finallon'); % station network of the main analysis, used only to locate the grid cells

% % local path
% addpath('\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\')
% dir_all  = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\REGEN\REGEN_All\v1-2019\';
% dir_long = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\REGEN\REGEN_Long\v1-2019\';
% outdir   = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\REGEN\REGEN_outputs\';
% if ~exist(outdir,'dir'); mkdir(outdir); end
% noaa_path     = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\tas\aravg.ann.land_ocean.90S.90N.v6.0.0.202401.asc.txt';
% berkeley_path = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\tas\global_land_and_ocean_annual_temp.txt';
% GISS_path     = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\tas\GLB.Ts+dSST.csv';
% load(['\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\ghcnd_pr\thinner_dailypr_', ...
%     num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
%     num2str(period2(1)),num2str(period2(end)),'.mat'], ...
%     'finalids','finallat','finallon'); % station network of the main analysis, used only to locate the grid cells

% % 1 -- locate the files and report the coverage found -------------------
% Filenames are parsed for a trailing _YYYY.nc rather than matched against a
% prefix guessed from the first file, so a stray netCDF in either folder
% cannot silently empty the file list.
mapA = yearmap(dir_all);
mapL = yearmap(dir_long);
% yrsA = sort(cell2mat(keys(mapA)));
% yrsL = sort(cell2mat(keys(mapL)));
% 
% if isempty(yrsA) || isempty(yrsL)
%     if isempty(yrsA); d = dir_all; else; d = dir_long; end
%     fprintf('\nContents of %s:\n', d); ls_report(d);
%     error('No files matching *_YYYY.nc in one of the folders; check the paths above.');
% end
% 
% yrs = intersect(yrsA, yrsL);
% fprintf('common coverage: %d-%d (%d years)\n', min(yrs), max(yrs), numel(yrs));
% 
% need = [period1 period2];
% if ~all(ismember(need, yrs))
%     latest = max(yrs);
%     fprintf(['\nThe requested epochs are not covered.\nMissing: %s\n' ...
%              'With coverage %d-%d, the latest usable 30-year late epoch is %d:%d.\n'], ...
%              mat2str(setdiff(need,yrs)), min(yrs), max(yrs), latest-29, latest);
%     error('Set period2 = %d:%d and rerun.', latest-29, latest);
% end

% precipitation variable: 'p' in the native REGEN files, 'rain' in FROGS
vinfo = ncinfo(mapL(period1(1)));
vnames = {vinfo.Variables.Name};
if     any(strcmp(vnames,'p'));    pvar = 'p';
elseif any(strcmp(vnames,'rain')); pvar = 'rain';
else;  error('No precipitation variable found. Variables: %s', strjoin(vnames,', '));
end
% hasgauge = any(strcmp(vnames,'s'));
hasgauge = false;   % section 6 only: do not read 's'. Restore the line above for a full run.
% fprintf('precipitation variable: ''%s''; gauge count %s\n', pvar, ...
%     ternary(hasgauge,'present (''s'')','absent'));

[dt_noaa,dt_berkeley, dt_gistemp] = obs_temp_anomaly(noaa_path,berkeley_path,GISS_path,period1,period2);
fprintf('dT over %d-%d vs %d-%d: %.3f K\n', ...
    period1(1),period1(end),period2(1),period2(end),dt_noaa);

% 2 -- station -> grid cell, the REGEN analogue of cmip_station_match_grid
f0  = mapL(period1(1));
lon = double(ncread(f0,'lon'));   nlon = numel(lon);
lat = double(ncread(f0,'lat'));   nlat = numel(lat);

slon = double(finallon(:));  
slon(slon>180) = slon(slon>180)-360; % transfer longtitude from 0~360 to -180~180
slat = double(finallat(:));
[~,ix] = min(abs(lon.' - slon),[],2);
[~,iy] = min(abs(lat.' - slat),[],2);
gridlon = lon(ix);  gridlat = lat(iy); % the center coordinates of the REGEN grid cell containing / nearest to the station
lin = sub2ind([nlon nlat], ix, iy);
ncell = numel(lin);
fprintf('%d stations mapped onto %d distinct grid cells\n', ncell, numel(unique(lin)));

% 3 -- daily series at those cells, both products ----------------------
% Read a CONTINUOUS span of years, not just the two epochs. The station
% pipeline passes a continuous year vector, and strict_qc_station indexes it
% by calendar position; a gap between the epochs would misalign it.
allyrs = period1(1):period2(end);
[prcpA, gaugeA, yearvec] = readcells(mapA, allyrs, lin, nlon, nlat, pvar, hasgauge);
[prcpL, gaugeL, ~      ] = readcells(mapL, allyrs, lin, nlon, nlat, pvar, hasgauge);

% m1 = ismember(yearvec, period1);   % epoch masks, used throughout
% m2 = ismember(yearvec, period2);

% 3b -- quality control, identical to the GHCNd station network ---------
% strict_qc_station indexes the daily series by calendar position, so the
% REGEN record must be continuous and handle leap days the same way as
% make_ymd. Verify before relying on it: a mismatch would shift every row.
ymdchk = make_ymd(period1(1), period2(end));
assert(size(ymdchk,1) == numel(yearvec), ...
    ['REGEN gives %d days over %d-%d but the calendar has %d rows. ' ...
     'Leap days differ; strict_qc_station would misalign.'], ...
    numel(yearvec), period1(1), period2(end), size(ymdchk,1));

% A year counts as missing when more than missrate%% of its days are absent;
% a cell is retained when at most missrate%% of years are missing, in both
% epochs. Passing the column index as the identifier recovers which cells
% survive, since strict_qc_station returns filtered arrays rather than a mask.
idx = (1:ncell).';
[~, keepA] = strict_qc_station(missrate, period1, period2, yearvec, prcpA, ...
                               idx, gridlat, gridlon);
[~, keepL] = strict_qc_station(missrate, period1, period2, yearvec, prcpL, ...
                               idx, gridlat, gridlon);

% The two versions have to be compared over the same cells, otherwise the
% difference between them is confounded with a difference in sample.
keep = intersect(keepA, keepL);
fprintf(['\ncells passing the %d%% criterion: All %d, Long %d, both %d ' ...
         '(of %d co-located cells)\n'], missrate, numel(keepA), numel(keepL), ...
         numel(keep), ncell);
assert(~isempty(keep), 'No grid cell passes the completeness criterion.');

% prcpA = prcpA(:,keep);   prcpL = prcpL(:,keep);
% gaugeA = gaugeA(:,keep); gaugeL = gaugeL(:,keep);
% gridlon = gridlon(keep); gridlat = gridlat(keep);
% ix = ix(keep);  iy = iy(keep);  lin = lin(keep);
% cellids   = finalids(keep);
% cell_slat = double(finallat(keep));  cell_slon = double(finallon(keep));
% ncell = numel(keep);

% % -- how much does the contributing network change? ------------------
% % Direct evidence for the response: 's' is the number of gauges informing
% % each grid cell, so the change between epochs is measurable rather than
% % inferred from the difference between the two products.
% if hasgauge
%     ngA1 = mean(gaugeA(m1,:),1,'omitnan').';  ngA2 = mean(gaugeA(m2,:),1,'omitnan').';
%     ngL1 = mean(gaugeL(m1,:),1,'omitnan').';  ngL2 = mean(gaugeL(m2,:),1,'omitnan').';
% 
%     fprintf('\ngauges per co-located cell (mean over cells)\n');
%     fprintf('  REGEN-All : %.2f (%d-%d) -> %.2f (%d-%d), change %+.1f%%\n', ...
%         mean(ngA1,'omitnan'),period1(1),period1(end), ...
%         mean(ngA2,'omitnan'),period2(1),period2(end), ...
%         100*(mean(ngA2,'omitnan')/mean(ngA1,'omitnan')-1));
%     fprintf('  REGEN-Long: %.2f (%d-%d) -> %.2f (%d-%d), change %+.1f%%\n', ...
%         mean(ngL1,'omitnan'),period1(1),period1(end), ...
%         mean(ngL2,'omitnan'),period2(1),period2(end), ...
%         100*(mean(ngL2,'omitnan')/mean(ngL1,'omitnan')-1));
%     fprintf('  cells whose gauge count changes by >20%%: All %.0f%%, Long %.0f%%\n', ...
%         100*mean(abs(ngA2./ngA1-1)>0.2,'omitnan'), ...
%         100*mean(abs(ngL2./ngL1-1)>0.2,'omitnan'));
% 
%     SG = struct('ngauge_all_p1',ngA1,'ngauge_all_p2',ngA2, ...
%                 'ngauge_long_p1',ngL1,'ngauge_long_p2',ngL2, ...
%                 'gridlat',gridlat(:),'gridlon',gridlon(:));
%     writenc([outdir,'regen_gaugecounts_',esuffix(missrate,period1,period2),'.nc'], SG, ...
%         'mean number of contributing gauges per co-located grid cell, by epoch');
% end


% %% 4 -- everything below is the station pipeline, run twice --------------
% products = {'all','long'};
% data     = {prcpA, prcpL};
% 
% for ip = 2 % only regen long
%     tag  = products{ip};
%     prcp = data{ip};
%     fprintf('\n===== REGEN-%s =====\n', upper(tag));
% 
%     % Equivalent to extract_data, but selected by year rather than by a
%     % contiguous row range, so it does not depend on how the year vector
%     % is laid out.
%     p1 = prcp(m1,:);
%     p2 = prcp(m2,:);
% 
%     % --- aggregated distributions, smoothed (way1) and raw (way0) -------
%     [kdeppdf1,kdepamt1,kdeppdf2,kdepamt2,bincrates,~,~] = ...
%         KDE_makeraindist_i_station(p1, p2, nbin, mbin);
%     [oldppdf1,oldpamt1,oldppdf2,oldpamt2,oldbincrates,~,~] = ...
%         makeraindist_stations(prcp, yearvec, period1, period2);
% 
%     % --- modes over the aggregated distribution ------------------------
%     [shift_w1,inc_w1,err_w1,dpamt1,pamtshift,pamtinc,pamtshiftinc, ...
%      dppdf1,ppdfshift,ppdfinc,ppdfshiftinc,dfreq,dfreqshift,dfreqinc, ...
%      dfreqshiftinc] = makeshiftinc_stations( ...
%         kdeppdf1(:),kdepamt1(:),kdeppdf2(:),kdepamt2(:),dt_noaa,bincrates);
% 
%     [shift_w0,inc_w0,err_w0] = makeshiftinc_stations( ...
%         oldppdf1(:),oldpamt1(:),oldppdf2(:),oldpamt2(:),dt_noaa,oldbincrates);
% 
%     [global_a_o, global_b_o] = calc_ao_bo_raindist(kdepamt1(:),kdepamt2(:),bincrates);
%     global_a_o = global_a_o/dt_noaa;
%     global_b_o = global_b_o/dt_noaa;
% 
%     fprintf('increase %.2f  shift %.2f  err %.2f  a_o %.2f  b_o %.2f  (%%/K)\n', ...
%         inc_w1, shift_w1, err_w1, global_a_o, global_b_o);
% 
%     % --- Fig. 1B and Fig. 2A,B ----------------------------------------
%     S = struct('kdeppdf1',kdeppdf1(:),'kdepamt1',kdepamt1(:), ...
%         'kdeppdf2',kdeppdf2(:),'kdepamt2',kdepamt2(:),'bincrates',bincrates(:), ...
%         'shift_w1',shift_w1,'inc_w1',inc_w1,'err_w1',err_w1, ...
%         'dpamt1',dpamt1(:),'pamtshift',pamtshift(:),'pamtinc',pamtinc(:), ...
%         'pamtshiftinc',pamtshiftinc(:),'dppdf1',dppdf1(:), ...
%         'ppdfshiftinc',ppdfshiftinc(:),'dfreq',dfreq(:), ...
%         'dfreqshift',dfreqshift(:),'dfreqinc',dfreqinc(:), ...
%         'dfreqshiftinc',dfreqshiftinc(:), ...
%         'global_a_o',global_a_o,'global_b_o',global_b_o,'dt_noaa',dt_noaa,...
%         'dt_berkeley',dt_berkeley, 'dt_gistemp',dt_gistemp);
%     writenc([outdir,'way1_regen_',tag,'_',esuffix(missrate,period1,period2),'.nc'], S, ...
%         ['modes and distributions over aggregation of REGEN-',tag,' grid cells']);
% 
%     S0 = struct('oldbincrates',oldbincrates(:),'oldpamt1',oldpamt1(:), ...
%         'oldpamt2',oldpamt2(:),'shift_w0',shift_w0,'inc_w0',inc_w0,'err_w0',err_w0);
%     writenc([outdir,'way0_regen_',tag,'_',esuffix(missrate,period1,period2),'.nc'], S0, ...
%         ['raw precip amount distribution, REGEN-',tag,' grid cells']);
% 
%     % --- Fig. 3: modes at each individual cell -------------------------
%     nb = numel(bincrates);
%     ks_ppdf1s = zeros(ncell,nb); ks_ppdf2s = ks_ppdf1s;
%     ks_pamt1s = ks_ppdf1s;       ks_pamt2s = ks_ppdf1s;
%     shiftincerr_way1 = nan(ncell,3);
%     all_a_o = nan(ncell,1);  all_b_o = nan(ncell,1);
% 
%     nfail = 0;
%     for ic = 1:ncell
%         q1 = prcp(m1,ic);  q2 = prcp(m2,ic);
%         [a,b,c,d,ksBINCRATES,~,~] = KDE_makeraindist_i_station(q1,q2,nbin_cell,mbin_cell);
%         a=a(:); b=b(:); c=c(:); d=d(:); ksBINCRATES=ksBINCRATES(:);
% 
%         % One cell yields a shorter bin axis than the aggregate, and its KDE
%         % can be non-finite beyond the wettest day it saw. Padding those into
%         % the aggregate axis and fitting there pushes NaN through the CDF in
%         % ratefunpercentile, where interp1 rejects non-finite sample points.
%         % Fit on the cell's own all-finite block; pad only for storage.
%         okall = isfinite(a) & isfinite(b) & isfinite(c) & isfinite(d) & isfinite(ksBINCRATES);
%         last  = find(~okall,1,'first') - 1;
%         if isempty(last); last = numel(a); end
%         if last < 10 || sum(b(1:last)) <= 0 || sum(d(1:last)) <= 0
%             nfail = nfail + 1; continue
%         end
%         k = 1:last;
% 
%         L = min(last, nb);
%         ks_ppdf1s(ic,1:L)=a(1:L); ks_pamt1s(ic,1:L)=b(1:L);
%         ks_ppdf2s(ic,1:L)=c(1:L); ks_pamt2s(ic,1:L)=d(1:L);
% 
%         try
%             [sh,in,er] = makeshiftinc_stations(a(k),b(k),c(k),d(k),dt_noaa,ksBINCRATES(k));
%             h=gcf; close(h);
%             shiftincerr_way1(ic,:) = [sh in er];
% 
%             [ao,bo] = calc_ao_bo_raindist(b(k),d(k),ksBINCRATES(k));
%             all_a_o(ic) = ao/dt_noaa;  all_b_o(ic) = bo/dt_noaa;
%         catch ME
%             nfail = nfail + 1;
%             fprintf('  cell %d (%.1f, %.1f) skipped: %s\n', ...
%                 ic, gridlon(ic), gridlat(ic), ME.message);
%         end
%     end
%     if nfail > 0
%         fprintf('  %d of %d cells produced no modes and are left as NaN\n', nfail, ncell);
%     end
% 
%     S3 = struct('ks_ppdf1s',ks_ppdf1s,'ks_ppdf2s',ks_ppdf2s, ...
%         'ks_pamt1s',ks_pamt1s,'ks_pamt2s',ks_pamt2s,'bincrates',bincrates(:), ...
%         'shiftincerr_way1',shiftincerr_way1,'all_a_o',all_a_o,'all_b_o',all_b_o, ...
%         'gridlat',gridlat(:),'gridlon',gridlon(:),'dt_noaa',dt_noaa);
%     writenc([outdir,'regen_',tag,'_modes_spatial_dist_',esuffix(missrate,period1,period2),'.nc'], ...
%         S3, ['spatial pattern of modes, REGEN-',tag,' grid cells']);
% 
%     % --- Fig. 2C and Fig. 4: bootstrap over grid cells -----------------
%     tic
%     % Argument order follows run01_cal_modes_in_stations.m; if that script
%     % passes them differently, match it here.
%     [UR_pamt1,UR_ppdf1,UR_dpamt1,UR_pamtshiftinc,UR_dppdf1,UR_ppdfshiftinc, ...
%      UR_dfreq,UR_dfreqshiftinc,UR_shift,UR_inc,UR_err,UR_a_o,UR_b_o] = ...
%         bootstrap_UR(p1, p2, 500, dt_noaa, nbin, mbin);
%     toc
%     UR_a_o = UR_a_o./dt_noaa;  UR_b_o = UR_b_o./dt_noaa;
% 
%     SU = struct('UR_pamt1',UR_pamt1,'UR_ppdf1',UR_ppdf1,'UR_dpamt1',UR_dpamt1, ...
%         'UR_pamtshiftinc',UR_pamtshiftinc,'UR_dppdf1',UR_dppdf1, ...
%         'UR_ppdfshiftinc',UR_ppdfshiftinc,'UR_dfreq',UR_dfreq, ...
%         'UR_dfreqshiftinc',UR_dfreqshiftinc,'UR_shift',UR_shift,'UR_inc',UR_inc, ...
%         'UR_err',UR_err,'UR_a_o',UR_a_o,'UR_b_o',UR_b_o, ...
%         'shift_w1',shift_w1,'inc_w1',inc_w1,'err_w1',err_w1);
%     writenc([outdir,'regen_',tag,'_uncertainty_range_',esuffix(missrate,period1,period2),'.nc'], ...
%         SU, ['bootstrap uncertainty over REGEN-',tag,' grid cells']);
%  end
% 
% %% 5 -- the sample of cells, shared by both products ---------------------
% SN = struct('gridlat',gridlat(:),'gridlon',gridlon(:), ...
%     'stationlat',cell_slat(:),'stationlon',cell_slon(:));
% writenc([outdir,'regen_gridcells_',esuffix(missrate,period1,period2),'.nc'], SN, ...
%     'REGEN grid cells co-located with the GHCNd network, after QC');
% fprintf('\nOutputs written to %s\n', outdir);
%% 6 -- GHCNd stations on the REGEN network ------------------------------
% Same aggregated calculation as run01_cal_modes_in_stations.m (way1), but
% over only the stations whose REGEN cell passes QC in both products.
% Column j of prcpA/prcpL is the cell holding station j, so keep indexes the
% station network directly and the stations pair one to one with the cells.
load(['/share/cliprelabs/jh2423/P1/data_process/ghcnd_pr/thinner_dailypr_', ...
    num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat'], ...
    'finalsta_prcp','years');
finalsta_prcp = finalsta_prcp(:,keep);
nsta = size(finalsta_prcp,2);
fprintf('\n===== %d GHCNd stations on the REGEN network =====\n', nsta);

% smoothed precip amount distribution over aggregation of stations
[prcp1, prcp2]=extract_data(finalsta_prcp,years,period1,period2);
[kdeppdf1, kdepamt1, kdeppdf2, kdepamt2, bincrates, ~, ~]=...
    KDE_makeraindist_i_station(prcp1, prcp2, nbin, mbin);

% shift and increase modes -- way1
[shift_w1,inc_w1,err_w1,dpamt1,pamtshift,pamtinc,pamtshiftinc,dppdf1,ppdfshift,ppdfinc,...
    ppdfshiftinc,dfreq,dfreqshift,dfreqinc,dfreqshiftinc]=makeshiftinc_stations...
    (kdeppdf1(:), kdepamt1(:), kdeppdf2(:), kdepamt2(:),dt_noaa,bincrates);

% a_o, b_o over the aggregation of stations
[global_a_o, global_b_o]=calc_ao_bo_raindist(kdepamt1(:),kdepamt2(:),bincrates);
global_a_o = global_a_o/dt_noaa; % unit:%/K
global_b_o = global_b_o/dt_noaa; % unit:%/K
fprintf('increase %.2f  shift %.2f  err %.2f  a_o %.2f  b_o %.2f  (%%/K)\n', ...
    inc_w1, shift_w1, err_w1, global_a_o, global_b_o);

% same variables as way1_stations_*.nc in run01
SS = struct('shift_w1',shift_w1,'inc_w1',inc_w1,'err_w1',err_w1, ...
    'kdepamt1',kdepamt1(:),'kdepamt2',kdepamt2(:), ...
    'kdeppdf1',kdeppdf1(:),'kdeppdf2',kdeppdf2(:),'dpamt1',dpamt1(:), ...
    'pamtshift',pamtshift(:),'pamtinc',pamtinc(:),'pamtshiftinc',pamtshiftinc(:), ...
    'dfreq',dfreq(:),'dfreqshift',dfreqshift(:),'dfreqinc',dfreqinc(:), ...
    'dfreqshiftinc',dfreqshiftinc(:),'bincrates',bincrates(:), ...
    'global_a_o',global_a_o,'global_b_o',global_b_o);
writenc([outdir,'way1_',num2str(nsta),'stations_',esuffix(missrate,period1,period2),'.nc'], SS, ...
    ['modes and distributions over aggregation of ',num2str(nsta), ...
     ' GHCNd stations co-located with REGEN grid cells']);
% bootstrap uncertainty over the same stations, as in run01 (500 resamples)
[UR_pamt1,UR_ppdf1,UR_dpamt1,UR_pamtshiftinc,UR_dppdf1,UR_ppdfshiftinc, ...
 UR_dfreq,UR_dfreqshiftinc,UR_shift,UR_inc,UR_err,UR_a_o,UR_b_o] = ...
    bootstrap_UR(prcp1, prcp2, 500, dt_noaa, nbin, mbin);
UR_a_o = UR_a_o./dt_noaa;  UR_b_o = UR_b_o./dt_noaa;
SU = struct('UR_pamt1',UR_pamt1,'UR_ppdf1',UR_ppdf1,'UR_dpamt1',UR_dpamt1, ...
    'UR_pamtshiftinc',UR_pamtshiftinc,'UR_dppdf1',UR_dppdf1, ...
    'UR_ppdfshiftinc',UR_ppdfshiftinc,'UR_dfreq',UR_dfreq, ...
    'UR_dfreqshiftinc',UR_dfreqshiftinc,'UR_shift',UR_shift,'UR_inc',UR_inc, ...
    'UR_err',UR_err,'UR_a_o',UR_a_o,'UR_b_o',UR_b_o, ...
    'shift_w1',shift_w1,'inc_w1',inc_w1,'err_w1',err_w1);
writenc([outdir,num2str(nsta),'stations_uncertainty_range_',esuffix(missrate,period1,period2),'.nc'], ...
    SU, ['bootstrap uncertainty over ',num2str(nsta),' GHCNd stations co-located with REGEN grid cells']);
% ------------------------------------------------------------- helpers
function M = yearmap(d)
% Map year -> full path, for every *.nc whose name ends in _YYYY.nc.
% Falls back to one level of subdirectories if the folder itself has none.
    M = scan(d);
    if isempty(M.keys)
        sub = dir(d);
        sub = sub([sub.isdir] & ~startsWith({sub.name},'.'));
        for k = 1:numel(sub)
            M2 = scan(fullfile(d,sub(k).name));
            if ~isempty(M2.keys)
                fprintf('  (using subdirectory %s)\n', sub(k).name);
                M = M2; return
            end
        end
    end
end

function M = scan(d)
    f = dir(fullfile(d,'*.nc'));
    M = containers.Map('KeyType','double','ValueType','char');
    for k = 1:numel(f)
        t = regexp(f(k).name,'_(\d{4})\.nc$','tokens','once');
        if isempty(t); continue; end
        M(str2double(t{1})) = fullfile(f(k).folder, f(k).name);
    end
end

function ls_report(d)
    f = dir(d);
    f = f(~startsWith({f.name},'.'));
    for k = 1:min(numel(f),15)
        if f(k).isdir; fprintf('  [dir] %s\n', f(k).name);
        else;          fprintf('        %s\n', f(k).name); end
    end
    if numel(f) > 15; fprintf('        ... %d entries total\n', numel(f)); end
end

function [X, G, yearvec] = readcells(M, yrs, lin, nlon, nlat, pvar, hasgauge)
% Daily precipitation and gauge count at the requested grid cells,
% concatenated over years. Only the selected cells are kept, so memory
% stays at ndays x ncell rather than the full global field.
    nd = 0;
    for y = yrs; nd = nd + numel(ncread(M(y),'time')); end
    X = nan(nd, numel(lin));  G = nan(nd, numel(lin));  yearvec = nan(nd,1);

    i0 = 1;
    for y = yrs
        r = ncread(M(y), pvar);               % lon x lat x time
        r(r < -1e4) = NaN;                    % _FillValue = -99999.9922
        nt = size(r,3);
        r = reshape(r, nlon*nlat, nt);
        X(i0:i0+nt-1,:) = double(r(lin,:)).';

        if hasgauge
            g = ncread(M(y),'s');
            g(g < -1e4) = NaN;
            g = reshape(g, nlon*nlat, nt);
            G(i0:i0+nt-1,:) = double(g(lin,:)).';
        end

        yearvec(i0:i0+nt-1) = y;
        i0 = i0 + nt;
    end
end

function s = esuffix(missrate,p1,p2)
    s = [num2str(missrate),'%miss_',num2str(p1(1)),num2str(p1(end)), ...
         '_',num2str(p2(1)),num2str(p2(end))];
end

function out = ternary(c,a,b)
    if c; out = a; else; out = b; end
end

function writenc(ncfile, S, titlestr)
% Write every field of S, following the convention used elsewhere in the
% pipeline: one dimension per variable, single precision.
    if isfile(ncfile); delete(ncfile); end
    fn = fieldnames(S);
    for i = 1:numel(fn)
        data = single(S.(fn{i}));
        dim  = size(data);
        if isvector(data) || isscalar(data)
            nccreate(ncfile, fn{i}, 'Dimensions', {fn{i}, numel(data)});
        else
            nccreate(ncfile, fn{i}, 'Dimensions', ...
                {[fn{i},'_row'], dim(1), [fn{i},'_col'], dim(2)});
        end
        ncwrite(ncfile, fn{i}, data);
    end
    ncwriteatt(ncfile,'/','title',titlestr);
    nc_metadata(ncfile);
end