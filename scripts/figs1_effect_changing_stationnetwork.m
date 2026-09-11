%% Figure S1 hypothetical example of the effect of changing station network.
% September 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% calculate and compare 2 hypothetical distributions of rain, one at a station and one in a gridbox.
% there are 2 types of precipitation: 
%   1. large-scale precipitation covering all points with the same precipitation
%   2. convective precipitation covering a single point. 
%   The convective precipitation is 20x heavier than the large scale
%   precipitation (on average), the upper end of the range reported for real
%   convective against stratiform rain. The frequency and variability are not
%   necessarily the same either. Log normal distributions are assumed. 
% set the mean and width of the 2 distributions - when
% it's raining. also the frequency of large scale and convective precipitation, to determine that (0:1) 
% [LS conv]
% 1 September 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
%
% The distributions are built the way makeraindist_stations does it, so that
% this illustration and the analysis in the paper report the same quantity:
%   frequency  = fraction of samples falling in each bin
%   amount     = sum of the actual precipitation values in each bin, divided
%                by the number of samples
% so that sum(amount) equals the mean daily precipitation.
%
% The probabilities of occurrence are fixed at 50% for the large-scale and
% 10% for the local-scale process. With those frequencies the contributions
% to the mean are
%   large scale  f_LS * m_LS              mm/d
%   local scale  (1-f_LS) * f_loc * m_loc  mm/d
% The (1-f_LS) factor is there because local-scale rain is suppressed on
% large-scale rain days.
%
% Rather than setting the two mean intensities directly, the target station
% mean and the share of it that comes from local-scale rain are set below and
% the intensities are derived, because with the frequencies held fixed the
% two are not independent:
%       local/large = m_loc / (10 * m_LS)
% Convective rain is typically five to twenty times heavier than stratiform,
% which bounds the local share between 33% and 67%. A larger share can only
% be obtained with an intensity ratio outside that range, so 2/3 is used
% here: it is the most local-dominated split the physics allows, and it sits
% within the 50-70% convective fraction reported for land.
%
% Two figures, one for frequency and one for amount, each with three panels:
%   left    generating distributions
%   middle  resulting distributions at a station and at grid cells
%   right   grid(6) minus grid(3), the change a growing network alone produces

clear
% %%% initial values 
rf=[.5 .1];   % precip frequency [LS conv], held fixed at 50% and 10%
ptot   = 2;   % target mean precipitation at a station, mm/d
flocal = 2/3; % share of that mean supplied by local-scale rain
%cv     = [.25 .5]; % coefficient of variation of each type, as in the original setup
cv = [.7 1.2];
% intensities implied by the targets above
m = [ptot*(1-flocal)/rf(1), ptot*flocal/((1-rf(1))*rf(2))];
s = cv.*m;
ratio = m(2)/m(1);
fprintf(['mean intensity when raining: %.2f (large scale), %.1f (local scale) mm/d\n' ...
         'intensity ratio %.1f; contributions %.2f + %.2f = %.2f mm/d\n'], ...
    m(1), m(2), ratio, rf(1)*m(1), (1-rf(1))*rf(2)*m(2), ptot);
if ratio<5 || ratio>20
    warning(['intensity ratio %.1f is outside the 5-20 range reported for ' ...
             'convective against stratiform rain; adjust flocal.'], ratio);
end

npts_p1=3; % number of points in the grid cell in epoch 1
npts_p2=6; % number of points in the grid cell in epoch 2
nsamp=10^7; % number of samples 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

v=s.^2; % variance 
mu=log(m./sqrt(1+v./m.^2));
sigma=sqrt(log(1+v./m.^2));

x0=lognrnd(mu(1),sigma(1),1,nsamp);
x1=lognrnd(mu(2),sigma(2),npts_p1,nsamp); % epoch 1
x2=lognrnd(mu(2),sigma(2),npts_p2,nsamp); % epoch 2

r0=(rand([1 nsamp])<rf(1)).*x0; 
% Local-scale events use rf(2), the convective frequency, not rf(1). With
% rf(1) the two types would occur equally often, which is neither what the
% [LS conv] labelling of rf intends nor what gives 1 mm/d from each type.
r1=(rand([npts_p1 nsamp])<rf(2)).*x1; % large scale and convective (epoch 1)
% completely independent
r1(r0>0)=0; % no convective precip during LS events

r2=(rand([npts_p2 nsamp])<rf(2)).*x2; % large scale and convective (epoch 2)
% completely independent
r2(r0>0)=0; % no convective precip during LS events

%% one set of bins for every series, so the panels are directly comparable
pointrain  = r0+r1(1,:);
gridrain_1 = r0+mean(r1,1);
gridrain_2 = r0+mean(r2,1);

allwet=[r0(r0>0) r1(1,r1(1,:)>0) pointrain(pointrain>0) ...
        gridrain_1(gridrain_1>0) gridrain_2(gridrain_2>0)];

dbin  = 0.07;                                    % ln step, as in the analysis
lo    = log(min(allwet));
hi    = log(max(allwet));
bins  = lo : dbin : hi;                          % bin centres
nbins = numel(bins);
edges = [bins-dbin/2, bins(end)+dbin/2];
fprintf('bin width %.3f (ln), %d bins over %.2f to %.2f\n', dbin, nbins, lo, hi);

% generating distributions
[fLS,  aLS ] = raindist(r0,        edges, nbins);
[fLoc, aLoc] = raindist(r1(1,:),   edges, nbins);
% resulting distributions
[fPt,  aPt ] = raindist(pointrain, edges, nbins);
[fG1,  aG1 ] = raindist(gridrain_1,edges, nbins);
[fG2,  aG2 ] = raindist(gridrain_2,edges, nbins);

% the change a growing network alone produces, with no change in climate
dfreq = fG2 - fG1;
damt  = aG2 - aG1;

% conservation check, as makeraindist_stations prints: the amount
% distribution must integrate to the mean precipitation of the series.
% The station and both grid series should all come out at 2 mm/d, since
% averaging over more points redistributes precipitation without losing any.
fprintf('%-22s %10s %10s\n','series','mean','sum(amt)');
nm={'large scale','local scale','station','grid (3 stations)','grid (6 stations)'};
sr={r0,r1(1,:),pointrain,gridrain_1,gridrain_2};
sa={aLS,aLoc,aPt,aG1,aG2};
for k=1:5
    fprintf('%-22s %10.4f %10.4f\n', nm{k}, mean(sr{k}), sum(sa{k}));
end
fprintf('\nsum(grid6 - grid3): frequency %.2e, amount %.2e\n', sum(dfreq), sum(damt));

%% common layout, three panels wide
% Wider left margins than a default subplot so the y labels clear the axes,
% and a taller figure so the legends sit above the curves rather than on them.
% Science Advances figure standards:
%   2-column width 18.4 cm; max depth 19.9 cm
%   panel letters 9 pt bold capitals; all other type 8 pt sans serif (6 pt min)
%   line weights >= 0.28 pt; sentence case for labels
fn  = 'Arial'; % sans serif equivalent of Myriad, accepted by the guidelines
fs  = 8;   % axis labels, ticks, titles
fsl = 7;   % legends, kept smaller so they fit the narrow panels
fsp = 9;   % panel letters, bold
showfreq = false; % the frequency figure is not shown; skip it rather than
                  % drawing and closing it
poss=[0.085 0.20 0.245 0.68;
      0.405 0.20 0.245 0.68;
      0.725 0.20 0.245 0.68];
grn=[0 0.5 0]; pur=[0.5 0 0.7];

%% figure 1 -- frequency
if showfreq
figure;
set(gcf,'units','centimeters','position',[1 1 18.4 7]);
set(gcf,'Color','white','Renderer','painters');
ax=gobjects(1,3);
for k=1:3; ax(k)=subplot(1,3,k); ax(k).Position=poss(k,:); end

axes(ax(1))
p=plot(bins,fLS,'-',bins,fLoc,'--','LineWidth',1.2);
p(1).Color=grn; p(2).Color=pur;
headroom([fLS;fLoc]); ratetick(bins,fs,fn);
title('Generating distributions','FontName',fn,'FontSize',fs,'FontWeight','normal')
l=legend('Large scale','Local scale','Location','northeast','FontName',fn,'FontSize',fsl); l.Box='off';
ylabel('Precipitation frequency','FontName',fn,'FontSize',fs)

axes(ax(2))
plot(bins,fPt,'k',bins,fG1,'r',bins,fG2,'b','LineWidth',1.2)
headroom([fPt;fG1;fG2]); ratetick(bins,fs,fn);
title('Resulting distributions','FontName',fn,'FontSize',fs,'FontWeight','normal')
l=legend('Station','Epoch 1 grid (3)','Epoch 2 grid (6)', ...
    'Location','northeast','FontName',fn,'FontSize',fsl); l.Box='off';
ylabel('Precipitation frequency','FontName',fn,'FontSize',fs)

axes(ax(3))
plot(bins,dfreq,'-','Color',[0.2 0.2 0.2],'LineWidth',1.2); hold on; box on
yline(0,'-','Color',[.6 .6 .6]);
symrange(dfreq); ratetick(bins,fs,fn);
title('Epoch 2 minus epoch 1','FontName',fn,'FontSize',fs,'FontWeight','normal')
ylabel('\DeltaPrecipitation frequency','FontName',fn,'FontSize',fs)
end

%% figure 2 -- amount
figure;
set(gcf,'units','centimeters','position',[1 1 18.4 7]);
set(gcf,'Color','white','Renderer','painters');
ax=gobjects(1,3);
for k=1:3; ax(k)=subplot(1,3,k); ax(k).Position=poss(k,:); end

axes(ax(1))
p=plot(bins,aLS,'-',bins,aLoc,'--','LineWidth',1.2);
p(1).Color=grn; p(2).Color=pur;
headroom([aLS;aLoc]); ratetick(bins,fs,fn);
title('Generating distributions','FontName',fn,'FontSize',fs,'FontWeight','normal')
l=legend('Large scale','Local scale','Location','northeast','FontName',fn,'FontSize',fsl); l.Box='off';
ylabel('Precipitation amount (mm d^-^1)','FontName',fn,'FontSize',fs)

axes(ax(2))
plot(bins,aPt,'k',bins,aG1,'r',bins,aG2,'b','LineWidth',1.2)
headroom([aPt;aG1;aG2]); ratetick(bins,fs,fn);
title('Resulting distributions','FontName',fn,'FontSize',fs,'FontWeight','normal')
l=legend('Station','Epoch 1 grid (3)','Epoch 2 grid (6)', ...
    'Location','northeast','FontName',fn,'FontSize',fsl); l.Box='off';
ylabel('Precipitation amount (mm d^-^1)','FontName',fn,'FontSize',fs)

axes(ax(3))
plot(bins,damt,'-','Color',[0.2 0.2 0.2],'LineWidth',1.2); hold on; box on
yline(0,'-','Color',[.6 .6 .6]);
symrange(damt); ratetick(bins,fs,fn);
title('Difference between Epoch 2 and Epoch 1','FontName',fn,'FontSize',fs,'FontWeight','normal')
ylabel('\DeltaPrecipitation amount (mm d^-^1)','FontName',fn,'FontSize',fs)

%% ------------------------------------------------------- panel labels
lbl = {'A','B','C'};
for k = 1:3
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
% Dry samples are excluded from the binning, as log(0) has no bin, but they
% are kept in the denominator so both distributions are normalised by the
% full sample and sum(amt) recovers the mean of the whole series.
    x   = x(:);
    n   = numel(x);
    wet = x(x>0);
    ib  = discretize(log(wet), edges);      % NaN for anything outside the range
    ok  = ~isnan(ib);

    freq = accumarray(ib(ok), 1,       [nbins 1]) / n;
    amt  = accumarray(ib(ok), wet(ok), [nbins 1]) / n;
end

function ratetick(bins, fs, fn)
% Label the x axis in mm/d, as Fig. 1 does. The plotted coordinate stays
% log(rain rate) -- the bins are uniform in that coordinate -- but the ticks
% are placed at round rain rates and only the decades carry a label, so the
% axis reads the same way as in the main text.
    r = [0.01:.01:.09 0.1:.1:.9 1:1:9 10:10:90 100:100:900 1000:1000:9000];
    t = log(r);
    lab = repmat({''},1,numel(r));
    for v = [0.01 0.1 1 10 100 1000]
        lab{r==v} = num2str(v);
    end
    k = t>=min(bins) & t<=max(bins);
    set(gca,'xtick',t(k),'xticklabel',lab(k),'XTickLabelRotation',0,...
        'FontName',fn,'FontSize',fs);
    xlim([min(bins) max(bins)]);
    xlabel('Precipitation rate (mm d^-^1)','FontName',fn,'FontSize',fs);
end

function headroom(y)
% Leave space above the curves for the legend, so it does not sit on them.
    ymax = max(y(isfinite(y)));
    if isempty(ymax) || ymax<=0; return; end
    ylim([0 1.45*ymax]);
end

function symrange(d)
% Symmetric limits about zero for a difference panel.
    a = max(abs(d(isfinite(d))));
    if isempty(a) || a<=0; return; end
    ylim([-1 1]*1.3*a);
end