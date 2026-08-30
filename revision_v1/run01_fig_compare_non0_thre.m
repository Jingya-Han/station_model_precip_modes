%% Comparison figure: 0.03 mm/day vs 1 mm/day non-zero threshold
% A: station-observed change in the amount distribution, both thresholds
% B: CMIP6 MMM change in the amount distribution, both thresholds
% Black solid = 0.03 mm/day, red dashed = 1 mm/day.
% 95% CI drawn as thin light lines (light gray / light red) instead of shading.
%
% Curves are drawn against the actual rain rate (log axis) using each run's
% own bincrates, because the two thresholds do not necessarily produce the
% same bin vector -- plotting both against bin index 1:nb would silently
% misalign them.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
period1 = 1955:1984;
period2 = 1994:2023;
missrate = 20;

path_n = '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\revision_v1\';    % 1 mm/day threshold
path_o = '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\dataforplot\';    % 0.03 mm/day threshold
figdir = '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\revision_v1\figs\';

ep = [num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),'_',...
      num2str(period2(1)),num2str(period2(end)),'.nc'];

%% load -- 0.03 mm/day threshold
bincrates_o = ncread([path_o,'way1_stations_',ep],'bincrates');
dpamt1_o    = ncread([path_o,'way1_stations_',ep],'dpamt1');
staUR_o     = ncread([path_o,'stations_uncertainty_range_',ep],'UR_dpamt1');

BINCRATES_o  = ncread([path_o,'way1_MMM_',ep],'BINCRATES');
mmm_dpamt1_o = ncread([path_o,'way1_MMM_',ep],'mmm_dpamt1');
cmipUR_o     = ncread([path_o,'cmip6_uncertainty_range_',ep],'UR_dpamt1');

%% load -- 1 mm/day threshold
bincrates_n = ncread([path_n,'way1_stations_',ep],'bincrates');
dpamt1_n    = ncread([path_n,'way1_stations_',ep],'dpamt1');
staUR_n     = ncread([path_n,'stations_uncertainty_range_',ep],'UR_dpamt1');

BINCRATES_n  = ncread([path_n,'way1_MMM_',ep],'BINCRATES');
mmm_dpamt1_n = ncread([path_n,'way1_MMM_',ep],'mmm_dpamt1');
cmipUR_n     = ncread([path_n,'cmip6_uncertainty_range_',ep],'UR_dpamt1');

%% colors
color_o = [0 0 0];          % 0.03 mm/day: black
color_n = [220 20 60]/255;  % 1 mm/day: red
tint = @(c,a) 1-(1-c)*a;    % blend towards white
ci_o = tint(color_o,0.45);  % light gray
ci_n = tint(color_n,0.45);  % light red

f = figure; clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 20 8]);
set(f,'Color','white','Renderer','painters');
left=0.075; down=.17; width=.40; he=.74;
poss=[left down width he;
      left+0.49 down width he];

% keep the same rain-rate window as Fig. 2 (bins 4 to 130 of the 0.03 mm/day run)
xl = [bincrates_o(4) bincrates_o(min(130,length(bincrates_o)))];

%% A: stations
s=subplot(1,2,1); s.Position=poss(1,:); hold on;
[xo,yo,lo_o,hi_o] = prepcurve(bincrates_o, dpamt1_o, staUR_o, 'station 0.03');
[xn,yn,lo_n,hi_n] = prepcurve(bincrates_n, dpamt1_n, staUR_n, 'station 1.0 ');

c1=plot(xo,[lo_o hi_o],'-','Color',ci_o,'LineWidth',0.7);
c2=plot(xn,[lo_n hi_n],'--','Color',ci_n,'LineWidth',0.7);
p1=plot(xo,yo,'-','Color',color_o,'LineWidth',1.2);
p2=plot(xn,yn,'--','Color',color_n,'LineWidth',1.2);
axisstyle(xl);
ylabel('\DeltaP (mm d ^-^1 K ^-^1)','FontName','Arial','FontSize',9);
l1=legend([p1 c1(1) p2 c2(1)], 'Station observations (0.03 mm d^{-1} threshold)', ...
    '95% CI (0.03 mm d^{-1} threshold)', ...
    'Station observations (1 mm d^{-1} threshold)', ...
    '95% CI (1 mm d^{-1} threshold)','FontName','Arial','FontSize',8);
set(l1,'box','off','Location','northwest');
text(0.03,0.95,'A','Units','normalized','FontName','Arial','FontSize',9,'FontWeight','bold');

%% B: CMIP6 MMM
s=subplot(1,2,2); s.Position=poss(2,:); hold on;
[xo,yo,lo_o,hi_o] = prepcurve(BINCRATES_o, mmm_dpamt1_o, cmipUR_o, 'cmip6   0.03');
[xn,yn,lo_n,hi_n] = prepcurve(BINCRATES_n, mmm_dpamt1_n, cmipUR_n, 'cmip6   1.0 ');

c1=plot(xo,[lo_o hi_o],'-','Color',ci_o,'LineWidth',0.7);
c2=plot(xn,[lo_n hi_n],'--','Color',ci_n,'LineWidth',0.7);
p1=plot(xo,yo,'-','Color',color_o,'LineWidth',1.2);
p2=plot(xn,yn,'--','Color',color_n,'LineWidth',1.2);
axisstyle(xl);
ylabel('\DeltaP (mm d ^-^1 K ^-^1)','FontName','Arial','FontSize',9);
l2=legend([p1 c1(1) p2 c2(1)], 'CMIP6 models (0.03 mm d^{-1} threshold)', ...
    '95% CI (0.03 mm d^{-1} threshold)', ...
    'CMIP6 models (1 mm d^{-1} threshold)', ...
    '95% CI (1 mm d^{-1} threshold)','FontName','Arial','FontSize',8);
set(l2,'box','off','Location','northwest');
text(0.03,0.95,'B','Units','normalized','FontName','Arial','FontSize',9,'FontWeight','bold');

savefig([figdir,'Fig_threshold_compare.fig']);
exportgraphics(gcf,[figdir,'Fig_threshold_compare.png'],'Resolution',300);

%% helpers
function [x,y,lo,hi] = prepcurve(bincrates, curve, UR, tag)
    % UR should be (bins x samples). ncread can hand it back transposed,
    % which would make prctile(...,2) average over bins and collapse the band.
    nbc = length(bincrates);
    if size(UR,1) < nbc && size(UR,2) >= nbc
        UR = UR.';
    end
    n  = min([nbc, length(curve), size(UR,1)]);
    x  = bincrates(1:n); x = x(:);
    y  = curve(1:n);     y = y(:);
    lo = prctile(double(UR(1:n,:)), 2.5,  2); lo = lo(:);
    hi = prctile(double(UR(1:n,:)), 97.5, 2); hi = hi(:);
    fprintf('%s : UR %d x %d, %d bins used, widest 95%% CI = %.4f\n', ...
        tag, size(UR,1), size(UR,2), n, max(hi-lo));
end

function axisstyle(xl)
    set(gca,'XScale','log','FontName','Arial','FontSize',8);
    l=line(xl,[0 0]); set(l,'color',[1 1 1]*.5); % zero line
    xlim(xl);
    ylim([-.02 0.25]);
    set(gca,'xtick',[0.1 1 10 100 1000],'xticklabel',{'0.1','1','10','100','1000'},...
        'XTickLabelRotation',0);
    xlabel('Precipitation rate (mm d ^-^1)','FontName','Arial','FontSize',9);
    box on;
end