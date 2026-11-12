%%  Uncertainty range for the change in precipitation rate at the 90th and
%   99.99th percentiles, station observations
%   Jingya Han, Cornell University, jh2423@cornell.edu
%
%   Uses the same arrays as fig4.m:
%     dfreq     : best estimate, change in rain rate (%/K) vs percentile bin
%     UR_dfreq  : ensemble, [bins x members]. fig4.m shades its 2.5-97.5
%                 percentile range; this script reports the same two numbers.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

missrate = 20;
path     = '/share/cliprelabs/jh2423/P1/dataforplot/';
epochs   = '19551984_19942023';

fsta = [path,'way1_stations_',num2str(missrate),'%miss_',epochs,'.nc'];
fur  = [path,'stations_uncertainty_range_',num2str(missrate),'%miss_',epochs,'.nc'];

dfreq    = ncread(fsta,'dfreq');      % best estimate
UR_dfreq = ncread(fur,'UR_dfreq');    % ensemble, bins x members

% For the models, swap in:
%   ncread([path,'way1_MMM_...'],'mmm_dfreq')  and
%   ncread([path,'cmip6_uncertainty_range_...'],'UR_dfreq')

fprintf('\nUR_dfreq is %d bins x %d members.\n', size(UR_dfreq,1), size(UR_dfreq,2));
fprintf(['Check that the member count matches what you expect ' ...
         '(resamples vs stations vs models).\n']);

%% ------------------------------------------------- locate the percentiles
pbinm   = (1-10.^(-.1:-.1:-4));       % percentile bins, as in fig4.m
targets = [0.90 0.9999];              % 90th and 99.99th

[dmin,idx] = min(abs(pbinm(:) - targets(:)'), [], 1);
if any(dmin > 1e-9)
    warning('Requested percentile not exactly on a bin; using nearest (max offset %.2e).', max(dmin));
end

%% ---------------------------------------------------- range at each point
fprintf('\nStation observations, change in precipitation rate (%%/K)\n');
fprintf('%-12s %10s %22s %8s\n','Percentile','Estimate','2.5-97.5%% range','n');

est = nan(size(targets));
rng = nan(numel(targets),2);
for k = 1:numel(targets)
    i        = idx(k);
    smp      = UR_dfreq(i,:);
    smp      = smp(~isnan(smp));
    est(k)   = dfreq(i);
    rng(k,:) = prctile(smp,[2.5 97.5]);
    fprintf('%-12.4g %10.2f   [%7.2f, %7.2f]   %6d\n', ...
        100*pbinm(i), est(k), rng(k,1), rng(k,2), numel(smp));
end

% sanity check: the 90th-percentile estimate should reproduce the value
% already quoted in the manuscript
fprintf('\nEstimate at the 90th percentile is %.2f %%/K (manuscript quotes 10.78).\n', est(1));

%% ------------------------------- optional: is the decline itself resolved?
% ASSUMES columns of UR_dfreq are paired across rows, i.e. that member j at
% one percentile bin corresponds to member j at another. True for resample
% or per-model ensembles; verify before relying on it.
%
% Interpretation also depends on the ensemble type. For a bootstrap this is
% an inference about sampling uncertainty in the decline; for a per-station
% or per-model ensemble it only describes how much members disagree.
d90   = UR_dfreq(idx(1),:);
d9999 = UR_dfreq(idx(2),:);
good  = ~isnan(d90) & ~isnan(d9999);
decl  = d90(good) - d9999(good);

fprintf('\nDecline from the 90th to the 99.99th percentile\n');
fprintf('  estimate %.2f %%/K,  2.5-97.5%% range [%.2f, %.2f] %%/K\n', ...
    est(1)-est(2), prctile(decl,2.5), prctile(decl,97.5));
fprintf('  members with a positive decline: %.1f%% of %d\n', ...
    100*mean(decl > 0), numel(decl));
