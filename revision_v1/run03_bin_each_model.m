%% Largest preci rate bin simulated by each CMIP6 model
% 9 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% Standalone diagnostic. Nothing in the analysis pipeline is modified; this
% script only reads the saved bin vectors and prints a table.
%
% Answers the reviewer's question at lines 484-485: is the wider simulated
% precipitation range common to all models, or driven by a few outliers?
%
% The value is recovered from the saved bin vectors rather than from the raw
% daily fields. cmip_bincrates builds logarithmically spaced bins, extends
% them until the largest value in the dataset falls inside, and then appends
% 20 further bins so the kernel density estimate can resolve the tail.
% bincrates(end) is therefore the dataset maximum inflated by exp(20*dbin),
% and dividing that factor out recovers the maximum to within one bin (7.7%).
%
% Note this is the GLOBAL maximum: run00_process_cmip6 passes the full global
% field to cmip_bincrates, and the co-located grid points are selected later,
% in cmip_sample_raindist.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
addpath('/share/cliprelabs/jh2423/P1/data_process/')
cmip6folder='/share/cliprelabs/jh2423/modesofchange_system/cmip6_pr_day_native/';

% same 17 models as the main analysis (table S1)
selectedmodels = {'ACCESS-CM2';'ACCESS-ESM1-5';...
    'BCC-CSM2-MR';'CanESM5';'CESM2';...
    'CMCC-CM2-SR5';'CMCC-ESM2';...
    'FGOALS-g3';'GFDL-ESM4';...
    'INM-CM4-8';'INM-CM5-0';...
    'IPSL-CM6A-LR';'MIROC6';...
    'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
    'TaiESM1'};
iex='ssp370'; % ssp used to extend the historical simulations

% members with both a historical and an ssp file, i.e. the 216 members analysed
[ensemble]=cmip_existensembles(selectedmodels,iex);

dbin=(log(1500)-log(1))/99; % log bin spacing, as set in cmip_bincrates (minp=1, firstupperp=1500, nbins=100)
nextra=20;                  % empty bins appended past the maximum for the KDE tail

nmod=length(selectedmodels);
pmax=nan(nmod,1); % recovered maximum for each model, over its members
nmem=nan(nmod,1);

for im=1:nmod
    mems=ensemble{im,1};
    if isempty(mems) || (numel(mems)==1 && isempty(mems{1}))
        fprintf('%-16s no available member\n', selectedmodels{im}); continue
    end
    nmem(im)=numel(mems);
    g=nan(nmem(im),2); % recovered maximum: col 1 historical, col 2 ssp
    for ie=1:nmem(im)
        % only 'bincrates' is loaded, so the large distribution arrays are never read
        S1=load([cmip6folder,'KDE_raindist_',selectedmodels{im},'_historical_',mems{ie},'_19552014.mat'],'bincrates');
        S2=load([cmip6folder,'KDE_raindist_',selectedmodels{im},'_',iex,'_',mems{ie},'_20152025.mat'],'bincrates');
        g(ie,1)=S1.bincrates(end)/exp(nextra*dbin); % strip the appended tail bins
        g(ie,2)=S2.bincrates(end)/exp(nextra*dbin);
    end
    pmax(im)=max(g(:));
    % member range spans both experiments, and shows how much of the spread is
    % sampling: more members means a larger drawn maximum from the same distribution
    fprintf('%-16s %2d members | global pmax %.0f mm/day (member range %.0f-%.0f)\n',...
        selectedmodels{im}, nmem(im), pmax(im), min(g(:)), max(g(:)));
end

fprintf('\n%d members in %d models | across models: max %.0f, median %.0f, min %.0f mm/day\n',...
    sum(nmem,'omitnan'), sum(~isnan(nmem)), max(pmax), median(pmax,'omitnan'), min(pmax));

%% Largest daily precipitation at station co-located gridpoints, per CMIP6 model
% Standalone diagnostic. Nothing in the analysis pipeline is modified; this
% script only reads the saved distribution files and prints a table.
%
% Purpose: answer the reviewer's question at lines 484-485. The bin range
% quoted there is built by cmip_bincrates from the FULL GLOBAL field of each
% simulation, because run00_process_cmip6 passes the whole field to it and
% the station co-located gridpoints are only selected later, in
% cmip_sample_raindist. Tropical oceanic and convective gridpoints therefore
% set the model bin range even though they are never used in the analysis.
%
% This script asks instead: over the gridpoints actually used, what is the
% heaviest precipitation rate that carries any precipitation amount? That is
% the number comparable to the station value.
%
% Caveat: this is the last bin of the SMOOTHED distribution. The kernel
% spreads each day's contribution over neighbouring bins, so this value sits
% somewhat above the largest daily value actually simulated. It is the right
% quantity to compare against the station bin range, which is constructed the
% same way, but it should not be reported as "the maximum simulated daily
% precipitation" without that qualifier.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
addpath('/share/cliprelabs/jh2423/P1/data_process/')
cmip6folder='/share/cliprelabs/jh2423/modesofchange_system/cmip6_pr_day_native/';

firstmemberonly = false; % true: one member per model (17 files, minutes)
                        % false: all 216 members (much slower, same conclusion)

% epochs and station screening, as in the main analysis
thelength=30; missrate=20;
startyear=1955; endyear=2023;
period1=startyear:(startyear+thelength-1);
period2=(endyear-thelength+1):endyear;

% same 17 models as the main analysis (table S1)
selectedmodels = {'ACCESS-CM2';'ACCESS-ESM1-5';...
    'BCC-CSM2-MR';'CanESM5';'CESM2';...
    'CMCC-CM2-SR5';'CMCC-ESM2';...
    'FGOALS-g3';'GFDL-ESM4';...
    'INM-CM4-8';'INM-CM5-0';...
    'IPSL-CM6A-LR';'MIROC6';...
    'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
    'TaiESM1'};
iex='ssp370'; % ssp used to extend the historical simulations

% station IDs and coordinates, needed to locate the co-located gridpoints
load(['/share/cliprelabs/jh2423/P1/data_process/ghcnd_pr/thinner_dailypr_',...
    num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
    num2str(period2(1)),num2str(period2(end)),'.mat'],...
    'finalids','finallat','finallon','finalsta_prcp');

% station value the model numbers are compared against
fprintf('largest daily precipitation in the station records: %.1f mm/day\n\n', ...
    max(finalsta_prcp(:)));

% row/col of the gridpoint containing each station, for every model
[~,indexofgrid,selectedmodels,finalids]=cmip_station_match_grid...
    (finalids,finallat,finallon,selectedmodels);
% re-derive after the call: cmip_station_match_grid may drop models
[ensemble]=cmip_existensembles(selectedmodels,iex);

dbin = (log(1500)-log(1))/99; % log bin spacing, as set in cmip_bincrates
nextra = 20;                  % empty bins appended past the maximum for the KDE tail

nmod   = length(selectedmodels);
colmax = nan(nmod,1); % heaviest bin used at co-located gridpoints, per model
glomax = nan(nmod,1); % same quantity over the whole globe, for comparison
nmem   = nan(nmod,1);

tstart=tic;
for im = 1:nmod
    mems = ensemble{im,1};
    if isempty(mems) || (numel(mems)==1 && isempty(mems{1}))
        fprintf('%-16s no available member\n', selectedmodels{im}); continue
    end
    if firstmemberonly; mems = mems(1); end
    nmem(im) = numel(mems);
    c = nan(nmem(im),2); % col 1 historical, col 2 ssp
    g = nan(nmem(im),2);

    for ie = 1:nmem(im)
        for k = 1:2
            if k == 1
                f = [cmip6folder,'KDE_raindist_',selectedmodels{im},'_historical_',mems{ie},'_19552014.mat'];
            else
                f = [cmip6folder,'KDE_raindist_',selectedmodels{im},'_',iex,'_',mems{ie},'_20152025.mat'];
            end

            % matfile reads only the requested slices, so the full
            % rows x cols x 300 x years array is never held in memory
            M = matfile(f);
            bincrates = M.bincrates;
            sz = size(M,'amountdist'); % [rows cols nbins nyears]

            % one gridpoint per station for this model; drop stations that
            % were never matched (indexofgrid is preallocated with NaN)
            r = indexofgrid(:,1,im);
            q = indexofgrid(:,2,im);
            ok = ~isnan(r) & ~isnan(q);
            r = r(ok); q = q(ok);
            if max(r) > sz(1) || max(q) > sz(2)
                error('indexofgrid out of range for %s (grid %dx%d)', selectedmodels{im}, sz(1), sz(2));
            end

            % highest bin holding precipitation, taken over the co-located
            % gridpoints and over all years in the file
            lastbin = 0;
            for is = 1:numel(r)
                a = squeeze(M.amountdist(r(is),q(is),:,:)); % nbins x years
                lb = find(any(a > 0, 2), 1, 'last');
                if ~isempty(lb); lastbin = max(lastbin,lb); end
            end
            if lastbin > 0; c(ie,k) = bincrates(lastbin); end

            % global bin range for reference: cmip_bincrates appends 20 empty
            % bins past the maximum for the KDE tail, so strip that factor out
            g(ie,k) = bincrates(end)/exp(nextra*dbin);
        end
    end

    colmax(im) = max(c(:));
    glomax(im) = max(g(:));
    fprintf('%-16s %2d members | co-located %6.1f | global %6.1f mm/day\n', ...
        selectedmodels{im}, nmem(im), colmax(im), glomax(im));
end

fprintf('\nacross models: co-located max %.1f, median %.1f | global max %.1f, median %.1f mm/day\n', ...
    max(colmax), median(colmax,'omitnan'), max(glomax), median(glomax,'omitnan'));
fprintf('elapsed %.1f min\n', toc(tstart)/60);