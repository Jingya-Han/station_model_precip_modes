%% Figure S1: how the number of stations in a grid cell changes the
%  precipitation amount distribution
% September 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
%
% A single hypothetical process generates daily precipitation independently
% at each station. A day is wet with probability pwet, and the precipitation
% on a wet day is drawn from a lognormal distribution with mean mwet and
% coefficient of variation cv. Nothing about the process changes between
% epochs; the only thing that changes is how many stations the grid cell
% average is taken over.
%
% Because the stations are independent, averaging over more of them dilutes
% the heaviest values and raises the frequency of moderate ones, while
% leaving the mean untouched. Precipitation amount is therefore moved from
% high rain rates to moderate ones by the averaging alone.
%
% The distributions are built the way makeraindist_stations does it, so that
% this illustration and the analysis in the paper report the same quantity:
%   frequency  = fraction of samples falling in each bin
%   amount     = sum of the actual precipitation values in each bin, divided
%                by the number of samples
% so that sum(amount) equals the mean daily precipitation. The bins are the
% logarithmic 7% bins used throughout the paper, starting at 0.03 mm/d.
%
% Two panels:
%   left   amount distribution at 1, 3 and 6 stations
%   right  6 stations minus 3 stations, the change the network alone produces

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% the process %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pwet = 0.2;    % a day is wet with this probability at any one station
mwet = 10;     % mean precipitation on a wet day, mm/d
cv   = 2;    % coefficient of variation of wet-day precipitation
               % mean daily precipitation is pwet*mwet = 2 mm/d

nsta  = [1 3 6];   % stations averaged over; 3 stands for epoch 1, 6 for epoch 2
nsamp = 10^8;      % days simulated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% lognormal parameters implied by the mean and the coefficient of variation
sigma = sqrt(log(1+cv^2));
mu    = log(mwet) - sigma^2/2;
fprintf(['wet-day frequency %.2f, mean wet-day rate %.1f mm/d, cv %.1f\n' ...
         'mean daily precipitation %.2f mm/d\n'], pwet, mwet, cv, pwet*mwet);

% One draw per station per day. The sets are nested, so the grid cells
% genuinely contain the single station rather than being separate samples.
X = (rand(max(nsta),nsamp) < pwet) .* lognrnd(mu,sigma,max(nsta),nsamp);
r = cell(1,numel(nsta));
for k = 1:numel(nsta)
    r{k} = mean(X(1:nsta(k),:),1);
end

%% bins, as used throughout the analysis --------------------------------
% logarithmic, 7% increments from 0.03 mm/d, extended until the heaviest
% value falls inside, with a leading zero bin as in makeraindist_stations
allwet = X(X>0);
nb = ceil(log(max(allwet)/0.03)/log(1.07)) + 1;
bincrates = [0, 0.03*1.07.^(0:nb)];
edges = [0.03/sqrt(1.07), 0.03*1.07.^(0:nb)*sqrt(1.07)];   % bin edges in rate space
fprintf('%d bins, reaching %.0f mm/d\n', numel(bincrates), bincrates(end));

amt  = cell(1,numel(nsta));
freq = cell(1,numel(nsta));
for k = 1:numel(nsta)
    [freq{k}, amt{k}] = raindist(r{k}, edges, numel(bincrates));
end
damt  = amt{3}  - amt{2};      % 6 stations minus 3 stations
dfreq = freq{3} - freq{2};

%% conservation check ----------------------------------------------------
% The amount distribution must integrate to the mean of its series, and the
% mean must be the same however many stations are averaged: the averaging
% moves precipitation between rain rates without creating or losing any.
fprintf('\n%-14s %10s %10s %14s\n','series','mean','sum(amt)','wet-day freq');
for k = 1:numel(nsta)
    fprintf('%2d station(s) %10.4f %10.4f %14.3f\n', ...
        nsta(k), mean(r{k}), sum(amt{k}), mean(r{k}>0));
end
fprintf('\nsum(6 stations - 3 stations): amount %.2e, frequency %.2e\n', ...
    sum(damt), sum(dfreq));

%% figure ----------------------------------------------------------------
% Science Advances figure standards:
%   2-column width 18.4 cm; max depth 19.9 cm
%   panel letters 9 pt bold capitals; all other type 8 pt sans serif (6 pt min)
%   line weights >= 0.28 pt; sentence case for labels
fn  = 'Arial';
fs  = 8;    % axis labels, ticks, titles
fsl = 7;    % legends
fsp = 9;    % panel letters, bold

col = {[0 0 0], [30 144 255]/255, [220 20 60]/255};
lab = arrayfun(@(n) sprintf('%d station%s',n,repmat('s',1,n>1)), nsta, ...
               'UniformOutput', false);

% x axis exactly as in Fig. 1 of the main text
xtickrates  = [0 0.1:.1:.9 1:1:9 10:10:90 100:100:1000];
xticks      = interp1(bincrates,1:numel(bincrates),xtickrates);
xtickratesp = {0 0.1 [] [] [] [] [] [] [] [] 1 [] [] [] [] [] [] [] [] ...
               10 [] [] [] [] [] [] [] [] 100 [] [] [] [] [] [] [] [] 1000};
xtickratesp(isnan(xticks)) = [];
xticks(isnan(xticks))      = [];
xr = [0 142];               % same plotted range as Fig. 1B

figure;
set(gcf,'units','centimeters','position',[1 1 18.4 7]);
set(gcf,'Color','white','Renderer','painters');
poss = [0.085 0.20 0.375 0.70;
        0.585 0.20 0.375 0.70];
ax = gobjects(1,2);
for k = 1:2; ax(k) = subplot(1,2,k); ax(k).Position = poss(k,:); end

axes(ax(1)); hold on; box on
x = 1:numel(bincrates);
for k = 1:numel(nsta)
    plot(x, amt{k}, '-', 'Color', col{k}, 'LineWidth', 1.2);
end
set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0, ...
    'FontName',fn,'FontSize',fs);
xr1 = [0 interp1(bincrates, 1:numel(bincrates), 1000)];   % display out to 1000 mm/d
xlim(xr1);
ylim([0 1.35*max(cellfun(@max,amt))]);
xlabel('Precipitation rate (mm d^-^1)','FontName',fn,'FontSize',fs);
ylabel('Precipitation amount (mm d^-^1)','FontName',fn,'FontSize',fs);
l = legend(lab,'Location','northeast','FontName',fn,'FontSize',fsl); l.Box='off';

axes(ax(2)); hold on; box on
plot(xr,[0 0],'-','Color',[.6 .6 .6],'LineWidth',0.5);
plot(x, damt, '-', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.2);
set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0, ...
    'FontName',fn,'FontSize',fs);
xlim(xr);
ylim([-1 1]*1.3*max(abs(damt)));
xlabel('Precipitation rate (mm d^-^1)','FontName',fn,'FontSize',fs);
ylabel('\DeltaPrecipitation amount (mm d^-^1)','FontName',fn,'FontSize',fs);
% title('6 stations minus 3 stations','FontName',fn,'FontSize',fs,'FontWeight','normal');

lbl = {'A','B'};
for k = 1:2
    text(ax(k), 0.035, 0.955, lbl{k}, 'Units','normalized', ...
        'FontName',fn,'FontSize',fsp,'FontWeight','bold', ...
        'HorizontalAlignment','left','VerticalAlignment','top');
end

savefig('\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\figS1.fig');
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\figS1.pdf",...
    'ContentType','vector','BackgroundColor','white'); % .pdf vector is the preferred format
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\figS1.png",...
    'Resolution', 600); % png fallback; 600 dpi is the ceiling before downsampling

%% ------------------------------------------------------------- helpers
function [freq, amt] = raindist(x, edges, nbins)
% Frequency and amount distributions, following makeraindist_stations:
%   freq(i) = (number of samples in bin i) / (number of samples)
%   amt(i)  = (sum of the values in bin i) / (number of samples)
% Dry samples have no bin, but they stay in the denominator, so both
% distributions are normalised by the full sample and sum(amt) recovers the
% mean of the whole series. The first bin is the zero bin and is left empty,
% as in the analysis.
    x   = x(:);
    n   = numel(x);
    wet = x(x>0);
    ib  = discretize(wet, edges) + 1;       % +1 for the leading zero bin
    ok  = ~isnan(ib);

    freq = accumarray(ib(ok), 1,       [nbins 1]) / n;
    amt  = accumarray(ib(ok), wet(ok), [nbins 1]) / n;
end