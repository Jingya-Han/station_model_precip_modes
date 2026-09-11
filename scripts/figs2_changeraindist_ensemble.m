%% Supplementary Figure S2: Changes in the precipitation amount distribution in station observations and individual ensemble members from models. 
% September 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
% Science Advances figure standards:
%   2-column width 18.4 cm; max depth 19.9 cm (leaves room for the legend)
%   panel letters 9 pt bold capitals; all other type 8 pt sans serif (6 pt min)
%   symbols 5-8 pt; line weights >= 0.28 pt; no minor ticks or grid lines
fn  = 'Arial'; % falls back to the default sans serif if not installed
fs  = 8;   % all labels, ticks and legends
fsp = 9;   % panel letters, bold
ms  = 25;  % scatter area in pt^2 -> 5 pt diameter
xlab = 0.08; % panel letter, normalized x (clear of the curves in D)
figpath = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\figures\';

% MATLAB silently substitutes a font it cannot find, so check once
if ~any(strcmp(listfonts,fn))
    warning('%s not found; falling back to %s. Install Myriad Pro or set fn manually.',fn,get(0,'defaultAxesFontName'));
    fn = get(0,'defaultAxesFontName');
end

f=figure;clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 18.4 15]); 
set(f,'Color','white');
left=0.09; down= .55;width= .4;he= .4;
poss=[left down width he;
left+0.48 down width he;
left 0.1 width he;
left+0.48 0.1 width he];
% folder='/share/cliprelabs/jh2423/modesofchange_system/results_01-Feb-2025 15:39:58/';

%% settings for plot
 
% Load data
period1 = 1955:1984;
period2 = 1994:2023;
missrate=20;
path='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';

% Load station data
inc_stations=ncread([path,'stations_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_inc');
shi_stations=ncread([path,'stations_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_shift');
ao_stations=ncread([path,'stations_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_a_o'); 
bo_stations=ncread([path,'stations_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_b_o'); 

% Load CMIP6 model data
inc_MMM=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_inc');
shi_MMM=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_shift');
ao_MMM=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_a_o');
bo_MMM=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_b_o'); 
%% ---------------------------------------------------------------------
% Counts quoted in the caption: how many ensemble members reach the
% observed range? Computed against the STATION 84% interval, i.e. the
% purple box drawn in panels A and B.
%
% Note this is a different quantity from the in_inc/in_shi counts further
% down, which select members inside the MODEL ensemble's own 84% interval
% and exist only to decide which dots get plotted.
sta_all = {inc_stations, shi_stations, ao_stations, bo_stations};
mod_all = {inc_MMM,      shi_MMM,      ao_MMM,      bo_MMM};
qlab    = {'increase mode','shift mode','a_o','b_o'};

fprintf('\n%-14s %7s %11s %12s %11s\n', ...
        'Quantity','members','reach 84%','within 84%','reach 95%');
fprintf('%s\n',repmat('-',1,60));
for k = 1:4
    s = sta_all{k}(:); s = s(~isnan(s));
    m = mod_all{k}(:); m = m(~isnan(m));
    s84 = prctile(s,[8 92]);
    s95 = prctile(s,[2.5 97.5]);
    fprintf('%-14s %7d %11d %12d %11d\n', qlab{k}, numel(m), ...
        sum(m >= s84(1)), ...                        % reach the lower edge
        sum(m >= s84(1) & m <= s84(2)), ...          % fall inside the box
        sum(m >= s95(1)));                           % against the 95% CI
end
fprintf('\n');

%% name of ensembles that overlap with 84% observational interval
sfx  = '20%miss_19551984_19942023';
fgrid = [path,'cmip6_gridmodes_permember_',sfx,'.nc'];
fur   = [path,'cmip6_uncertainty_range_',sfx,'.nc'];
memmodel   = double(ncread(fgrid,'memmodel'));
model_name = ncread(fgrid,'model_name');
gridinc    = ncread(fgrid,'gridinc_mem');
UR_inc     = ncread(fur,'UR_inc');   UR_inc = UR_inc(:);
% 1. 成员总数
fprintf('members: gridmodes %d, UR_inc %d\n', numel(memmodel), numel(UR_inc));
% 2. 是否 model-major 排列(run03 按连续块取值的前提)
fprintf('memmodel non-decreasing: %d\n', all(diff(memmodel)>=0));
% 3. 每个模式的成员数
nper = accumarray(memmodel(:),1);
for im = 1:numel(model_name)
    fprintf('  %-16s %3d\n', model_name{im}, nper(im));
end
% 4. 关键检验:同一成员的局地平均模态 vs 聚合模态,应高度相关
if size(gridinc,1) == numel(memmodel); gridinc = gridinc.'; end  % -> station x member
loc = mean(gridinc,1,'omitnan').';
r = corr(loc, UR_inc, 'rows','complete');
fprintf('\ncorr(local mean, aggregated) = %.3f\n', r);

%
member_model = ncread(fgrid,'member_model');
memname      = ncread(fgrid,'memname');
UR_b_o       = ncread(fur,'UR_b_o');   UR_b_o = UR_b_o(:);
bo_stations  = ncread([path,'stations_uncertainty_range_',sfx,'.nc'],'UR_b_o');
s = bo_stations(:); s = s(~isnan(s));
lo84 = prctile(s,8);
idx  = find(UR_b_o >= lo84);
fprintf('\nb_o members reaching the observed 84%% interval (>= %.2f %%/K):\n', lo84);
for i = idx.'
    fprintf('  %-16s %-12s  %.2f %%/K\n', member_model{i}, memname{i}, UR_b_o(i));
end
% shift mode 那一个,顺带核实是不是 ACCESS-ESM1-5 r6i1p1f1
UR_shift = ncread(fur,'UR_shift'); UR_shift = UR_shift(:);
shi_stations = ncread([path,'stations_uncertainty_range_',sfx,'.nc'],'UR_shift');
s = shi_stations(:); s = s(~isnan(s));
lo84 = prctile(s,8);
for i = find(UR_shift >= lo84).'
    fprintf('  shift: %-16s %-12s  %.2f %%/K\n', member_model{i}, memname{i}, UR_shift(i));
end
%% panels A and B: modes at stations and in every ensemble member
% Both panels show, for each quantity, the 84% interval of the station
% bootstrap and of the model ensemble as a shaded box with the median as a
% black line, and every individual ensemble member as a dot. The members are
% all drawn at one x position, so they form a single column beside the model
% box rather than spreading across it and hiding the shading.
stationcolor = [138 43 226] / 255;  % purple for stations
MMMcolor     = [ 50 205  50] / 255; % green for models
bw     = 0.15;                      % half width of the boxes
dotoff = 0.28;                      % dots sit this far right of the box centre,
                                    % clear of the box edge at bw

% within each pair the station box is on the left and the model box on the right
panels = { {inc_stations, inc_MMM, shi_stations, shi_MMM}, ...
           {ao_stations,  ao_MMM,  bo_stations,  bo_MMM } };
ticklab = { {'Increase mode','Shift mode'}, {'\ita\rm_o','\itb\rm_o'} };
plab    = {'A','B'};
qlab2   = { {'increase','shift'}, {'a_o','b_o'} };

for ip = 1:2
    s=subplot(2,2,ip); s.Position=poss(ip,:);
    grp     = panels{ip};
    ismodel = [false true false true];   % order: station, model, station, model

    yline(0, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5); hold on;

    % 1) boxes, drawn first so the dots sit on top of them
    for i = 1:4
        v = grp{i}(:); v = v(~isnan(v));
        q = prctile(v,[8 92]);
        if ismodel(i); col = MMMcolor; else; col = stationcolor; end
        hp = patch([i-bw, i+bw, i+bw, i-bw], [q(1) q(1) q(2) q(2)], col, ...
                   'FaceAlpha',0.6,'EdgeColor','none');
        if ismodel(i); hMod = hp; else; hSta = hp; end
    end

    % 2) every ensemble member, in one column beside its box
    for i = find(ismodel)
        v = grp{i}(:); v = v(~isnan(v));
        hEns = scatter(repmat(i+dotoff,size(v)), v, ms, ...
                       'MarkerEdgeColor',[0.4 0.4 0.4], ...
                       'MarkerFaceColor',MMMcolor,'MarkerFaceAlpha',0.55, ...
                       'LineWidth',0.3);
    end

    % 3) medians last, so they are not hidden by the dots
    for i = 1:4
        v = grp{i}(:); v = v(~isnan(v));
        plot([i-bw, i+bw], [median(v) median(v)], 'k-', 'LineWidth', 2);
    end

    % how many members lie inside the station box, for the caption
    for k = 1:2
        t = grp{2*k-1}(:); t = t(~isnan(t));   % stations, now first in each pair
        m = grp{2*k}(:);   m = m(~isnan(m));   % models
        q = prctile(t,[8 92]);
        fprintf('panel %s, %-9s: %d of %d members reach the station 84%% interval [%.2f %.2f]\n', ...
            plab{ip}, qlab2{ip}{k}, sum(m>=q(1)), numel(m), q(1), q(2));
    end

    xlim([0.4 4.6]);                    % room for the dot column at 4+dotoff
    ylim([-2 18]);                      % same scale in A and B, so they read together
    clear xticks; xticks([1.5 3.5]);
    xticklabels(ticklab{ip});
    set(gca,'fontsize',fs,'XTickLabelRotation',0,'FontName',fn);
    ylabel('Magnitude of modes (% K^-^1)', 'FontName',fn,'fontsize',fs);
    box on;
    text(xlab,0.94,plab{ip},'Units','normalized','FontWeight','bold', ...
        'FontName',fn,'fontsize',fsp);

    if ip==1
        legend([hSta hMod hEns], ...
            {'Station (84% interval)','Model ensemble (84% interval)','Ensemble member'}, ...
            'FontName',fn,'fontsize',fs,'Location','northeast');
        legend('boxoff')
    end
end

%% rain amount distribution
% preliminary items

%folder='/share/cliprelabs/jh2423/modesofchange_system/results_01-Feb-2025 15:39:58/';
mmm_dpamt1=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'mmm_dpamt1');
mmm_pamtshiftinc=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'mmm_pamtshiftinc'); 
KDEMMMpamt1=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'KDEMMMpamt1');   
mmm_dfreq=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'mmm_dfreq');  
mmm_dfreqshiftinc=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'mmm_dfreqshiftinc'); 
  
cmip_dfreq=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_dfreq');
cmip_dfreqshiftinc=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_dfreqshiftinc');
cmip_dpamt1=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_dpamt1');
cmip_pamt1=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_pamt1');
cmip_pamtshiftinc=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_pamtshiftinc');
bincrates=ncread([path,'way1_stations_',num2str(missrate),'%miss_',num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'bincrates'); 

 
db=(bincrates(3)-bincrates(2))./bincrates(2);% bin width
% colors 
stationobscolor=[0 0 0]/255;
stationspicolor=[138 43 226]/255;
MMMsimcolor=[255 140 0]/255;
MMMspicolor=[50 205 50]/255;
ensem_simcolor=[255 140 0 30]/255;
ensem_spicolor=[50 205 50 30]/255;

% x-axis label data
xtickrates=[0 0.1:.1:.9 1:1:9 10:10:90 100:100:1000]; % rain rates in mm/d for x axis 
xticks=interp1(bincrates,1:length(bincrates),xtickrates); % bin numbers associated with nice number rain rate 
xtickratesp={0 0.1 [] [] [] [] [] [] [] [] 1 [] [] [] [] [] [] [] [] 10 [] [] [] [] [] [] [] [] 100 [] [] [] [] [] [] [] [] 1000}; % rain rates with white space in between 
pbinm=(1-10.^(-.1:-.1:-4)); % percentile bins for calculations 
xtickpercent=[30:10:90 91:99 99.1:.1:99.9 99.91:.01:99.99]/100; % percentiles for x-axes of percentile plots 
xticks99=interp1(pbinm,1:length(pbinm),xtickpercent); % bin numbers of percentiles for plotting
xtickratesp(isnan(xticks))=[];
xticks(isnan(xticks))=[];

s=subplot(2,2,3); s.Position=poss(3,:); 
% start the rain-rate axis at 0.1 mm/day, the reporting resolution of GHCNd
x01=interp1(bincrates,1:length(bincrates),0.1);
% plot ensembles
for ie=1:length(cmip_dpamt1(1,:))
 nb=length(cmip_dpamt1);
 p1=line(1:nb,cmip_dpamt1(:,ie),'Color',ensem_simcolor,'CreateFcn', @(l, e) set(l, 'Color', ensem_simcolor));
 set(p1,'HandleVisibility', 'off')
 hold on;
 p2=line(1:nb,(cmip_pamtshiftinc(:,ie)-cmip_pamt1(:,ie))*1./db,'Color',ensem_spicolor,'CreateFcn', @(l, e) set(l, 'Color', ensem_spicolor));
 set(p2,'HandleVisibility', 'off')
 hold on;
 l=line([0 130],[0 0]);set(l,'color',[1 1 1]*.5,'HandleVisibility', 'off') % add a zero line 
 ylim([-.02 0.13]); % choose y-axes
 xlim([x01 130]) % start at 0.1 mm/day, drop the last few bins where little should be happening.
 set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0,...
     'FontName',fn,'fontsize',fs) % make x-axes show rain rate in mm/d
 hold on;
end

% plot the line
dpamtplot(mmm_dpamt1(:),MMMsimcolor,(mmm_pamtshiftinc(:)-KDEMMMpamt1(:))*1./db,MMMspicolor,xticks,xtickratesp);
xlim([x01 130]) % override the default set inside dpamtplot
legend({'Model','Increase + Shift modes'},'FontName',fn,'fontsize',fs); legend('boxoff'); hold on;
set(gca,'fontsize',fs,'XTickLabelRotation',0,'FontName',fn);
ylabel('\DeltaPrecipitation amount (mm d^-^1 K^-^1)','FontName',fn,'fontsize',fs);% If you wanted to be precise, the y-axis label is in mm/d/K/\Delta bin
text(xlab,0.94,'C','Units','normalized','FontWeight','bold','FontName',fn,'fontsize',fsp);
box on;


% percentile
s=subplot(2,2,4); s.Position=poss(4,:);
% plot ensembles
for ie=1:length(cmip_dfreq(1,:))
    p1=line(1:length(pbinm),cmip_dfreq(1:40,ie),'Color',ensem_simcolor,'CreateFcn', @(l, e) set(l, 'Color', ensem_simcolor));
    set(p1,'HandleVisibility', 'off')
    hold on;
    p2=line(1:length(pbinm),cmip_dfreqshiftinc(1:40,ie),'Color',ensem_spicolor,'CreateFcn', @(l, e) set(l, 'Color', ensem_spicolor));
    set(p2,'HandleVisibility', 'off')
    hold on;

    l=line([2 length(pbinm)],[0 0]);set(l,'color',[1 1 1]*.5) % add zero line 
    hold on;
end
%plot the line
drpercentileplot(mmm_dfreq,MMMsimcolor,mmm_dfreqshiftinc,MMMspicolor,pbinm,xticks99);
set(gca,'fontsize',fs,'XTickLabelRotation',0,'FontName',fn); % match A-C
ylabel('\DeltaPrecipitation rate (% K^-^1)','FontName',fn,'fontsize',fs);
text(xlab,0.94,'D','Units','normalized','FontWeight','bold','FontName',fn,'fontsize',fsp);
box on;

savefig([figpath,'figS2.fig']);
exportgraphics(gcf,[figpath,'figS2.png'],...
    'Resolution', 600); % png fallback; 600 dpi is the ceiling before downsampling
exportgraphics(gcf,[figpath,'figS2.pdf'],...
    'ContentType','vector','BackgroundColor','white'); % .pdf vector is the preferred format
% % pdf version
% addpath(genpath('C:\Program Files\MATLAB\altmany-export_fig-d5538e9'));
% export_fig(gcf,'-eps', '-r300', '-painters', [figpath,'figS1.eps']);
% export_fig(gcf,'-pdf', '-r300', '-painters', [figpath,'figS1.pdf']);

% %%  Intervals for the fitted modes (increase, shift) and the directly
% %   calculated modes (a_o, b_o), stations and CMIP6
% %   Jingya Han, Cornell University, jh2423@cornell.edu added on Aug 2026
% %
% %   Reads the arrays that figs1_changeraindist_ensemble.m plots in panels
% %   A and B:
% %     stations : UR_inc, UR_shift, UR_a_o, UR_b_o  (500 bootstrap resamples
% %                over stations -> a sampling distribution, so 95% CI)
% %     models   : UR_inc, UR_shift, UR_a_o, UR_b_o  (individual ensemble
% %                members -> a spread, so 95% range, NOT a CI)
% %
% %   Two widths are reported, used for different purposes:
% %     95% (2.5-97.5) : quoted in the text for a single quantity
% %     84% (8-92)     : plotted as error bars ONLY, so that non-overlap of a
% %                      station-model pair indicates a difference with 95%
% %                      confidence (Payton et al., ref 48). The 84% rule is
% %                      derived for pairwise comparison and has no meaning
% %                      when reporting one quantity on its own.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% clear
% 
% period1  = 1955:1984;
% period2  = 1994:2023;
% missrate = 20;
% path     = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';
% 
% suffix = [num2str(missrate),'%miss_', ...
%           num2str(period1(1)),num2str(period1(end)),'_', ...
%           num2str(period2(1)),num2str(period2(end)),'.nc'];
% 
% fsta = [path,'stations_uncertainty_range_',suffix];
% fmod = [path,'cmip6_uncertainty_range_',suffix];
% 
% vars = {'UR_inc','UR_shift','UR_a_o','UR_b_o'};
% lab  = {'increase','shift','a_o','b_o'};
% 
% sta = struct(); mod = struct();
% for k = 1:4
%     sta.(lab{k}) = ncread(fsta,vars{k});
%     mod.(lab{k}) = ncread(fmod,vars{k});
% end
% 
% %% -------------------------------------------------------- sanity on sizes
% nsta = numel(sta.increase(~isnan(sta.increase)));
% nmod = numel(mod.increase(~isnan(mod.increase)));
% fprintf('\nStations: %d bootstrap resamples.  Models: %d ensemble members.\n', nsta, nmod);
% if nmod < 20
%     warning(['Only %d model members: prctile(2.5) and prctile(97.5) return ' ...
%              'min and max, so a "95%% range" is not meaningful.'], nmod);
% end
% if nsta < 100
%     warning('Only %d station resamples; check that UR_* holds bootstrap samples.', nsta);
% end
% 
% %% ------------------------------------------------------------ 95% and 84%
% q95 = [2.5 97.5];
% q84 = [8 92];
% 
% fprintf('\n%-22s %8s %20s %20s\n','Quantity','median','95%% (2.5-97.5)','84%% (8-92)');
% fprintf('%s\n',repmat('-',1,74));
% 
% S95 = nan(4,2); S84 = nan(4,2); M95 = nan(4,2); M84 = nan(4,2);
% for k = 1:4
%     x = sta.(lab{k})(:); x = x(~isnan(x));
%     y = mod.(lab{k})(:); y = y(~isnan(y));
%     S95(k,:) = prctile(x,q95);  S84(k,:) = prctile(x,q84);
%     M95(k,:) = prctile(y,q95);  M84(k,:) = prctile(y,q84);
%     fprintf('%-22s %8.2f   [%6.2f, %6.2f]     [%6.2f, %6.2f]\n', ...
%         ['stations ',lab{k}], median(x), S95(k,1),S95(k,2), S84(k,1),S84(k,2));
%     fprintf('%-22s %8.2f   [%6.2f, %6.2f]     [%6.2f, %6.2f]\n', ...
%         ['models   ',lab{k}], median(y), M95(k,1),M95(k,2), M84(k,1),M84(k,2));
% end
% 
% %% -------------------------------------------------- overlap of each pair
% % The visual test in the figures: do the 84% intervals of a station-model
% % pair overlap? Non-overlap indicates a difference with 95% confidence.
% % Also checked at 95% width, which is the more conservative criterion.
% fprintf('\nPairwise overlap (station vs model)\n');
% for k = 1:4
%     ov84 = ~(S84(k,1) > M84(k,2) || M84(k,1) > S84(k,2));
%     ov95 = ~(S95(k,1) > M95(k,2) || M95(k,1) > S95(k,2));
%     fprintf('  %-9s  84%% intervals %s;  95%% intervals %s\n', lab{k}, ...
%         ternary(ov84,'OVERLAP','do not overlap'), ...
%         ternary(ov95,'OVERLAP','do not overlap'));
% end
% 
% %% ------------------------------------------------- text for the manuscript
% % Point estimates are the values already quoted in the manuscript; the
% % intervals come from the arrays above.
% fprintf('\n--- fitted modes ---\n');
% fprintf(['In observations, ... an increase mode of 10.16%%K-1 (95%% confidence ' ...
%     'interval %.2f-%.2f%%K-1) and a shift mode of 9.83%%K-1 (%.2f-%.2f%%K-1). ' ...
%     'In CMIP6 models, the multi-model mean is approximately 3.2%%K-1 for both ' ...
%     'modes, and individual ensemble members span %.2f-%.2f%%K-1 for the increase ' ...
%     'mode and %.2f-%.2f%%K-1 for the shift mode (2.5th to 97.5th percentiles ' ...
%     'across %d ensemble members).\n'], ...
%     S95(1,1),S95(1,2), S95(2,1),S95(2,2), M95(1,1),M95(1,2), M95(2,1),M95(2,2), nmod);
% 
% fprintf('\n--- directly calculated modes ---\n');
% fprintf(['In station observations, a_o is 9.30%%K-1 (95%% confidence interval ' ...
%     '%.2f-%.2f%%K-1) and b_o is 9.43%%K-1 (%.2f-%.2f%%K-1). In CMIP6 models, the ' ...
%     'multi-model mean a_o is 3.06%%K-1 and b_o is 3.15%%K-1, with individual ' ...
%     'ensemble members spanning %.2f-%.2f%%K-1 and %.2f-%.2f%%K-1 respectively.\n'], ...
%     S95(3,1),S95(3,2), S95(4,1),S95(4,2), M95(3,1),M95(3,2), M95(4,1),M95(4,2));
% 
% fprintf('\n--- 84%% intervals: for the error bars only, not for the text ---\n');
% for k = 1:4
%     fprintf('  %-9s stations [%.2f, %.2f]   models [%.2f, %.2f]\n', ...
%         lab{k}, S84(k,1),S84(k,2), M84(k,1),M84(k,2));
% end
% 
% %% ---------------------------------------------------- consistency check
% quoted_sta = [10.16 9.83 9.30 9.43];
% quoted_mod = [3.20 3.20 3.06 3.15];
% fprintf('\nQuoted point estimates vs the ensembles they are paired with:\n');
% for k = 1:4
%     if quoted_sta(k) < S95(k,1) || quoted_sta(k) > S95(k,2)
%         warning('stations %s: quoted %.2f lies outside its 95%% CI.', lab{k}, quoted_sta(k));
%     end
%     if quoted_mod(k) < M95(k,1) || quoted_mod(k) > M95(k,2)
%         warning('models %s: quoted %.2f lies outside the member range.', lab{k}, quoted_mod(k));
%     end
%     fprintf('  %-9s stations quoted %.2f vs bootstrap median %.2f;  models quoted %.2f vs member median %.2f\n', ...
%         lab{k}, quoted_sta(k), median(sta.(lab{k})(~isnan(sta.(lab{k})))), ...
%         quoted_mod(k), median(mod.(lab{k})(~isnan(mod.(lab{k})))));
% end
% 
% function out = ternary(c,a,b)
%     if c, out = a; else, out = b; end
% end



%% plotting functions 
    function []=dpamtplot(dpamt1,color1,dpamt2,color2,xticks,xtickratesp)
        fs=8; fn='Myriad Pro'; % local functions do not inherit the script workspace
        if ~any(strcmp(listfonts,fn)); fn=get(0,'defaultAxesFontName'); end
        % plot the change in rain amount distribution.  two curves in two
        % different colors.  
        nb=length(dpamt1);
        p=plot(1:nb,dpamt1,'-k',1:nb,dpamt2,'-r');
        set(p(1),'color',color1)
        set(p(2),'color',color2)
        set(p,'linewidth',1.2)
        
        l=line([0 130],[0 0]);set(l,'color',[1 1 1]*.5) % add a zero line 
        ylim([-.02 0.13]); % choose y-axes
        xlim([4 130]) % exclude the zero bin and also the last few, where little should be happening. 
        set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0) % make x-axes show rain rate in mm/d
        
        %  ylabel('\DeltaRain amount (mm/d/K)');% If you wanted to be precise, the y-axis label is in mm/d/K/\Delta bin
        xlabel('Precipitation rate (mm d^-^1)','FontName',fn,'fontsize',fs);
    end

    function []=dppdfplot(dppdf1,color1,dppdf2,color2,xticks,xtickratesp)
        fs=8; fn='Myriad Pro'; % local functions do not inherit the script workspace
        if ~any(strcmp(listfonts,fn)); fn=get(0,'defaultAxesFontName'); end
        % plot the change in rain frequency distribution.  two curves in two
        % different colors.  
        
        nb=length(dppdf1);
        p=plot(1:nb,100*dppdf1,'-k',1:nb,100*dppdf2,'-r');
        set(p(1),'color',color1)
        set(p(2),'color',color2)
        set(p,'linewidth',1.2)
        
        l=line([0 130],[0 0]);set(l,'color',[1 1 1]*.5) % add a zero line 
        xlim([4 130]); % exclude the zero bin (which will throw off y-axis) and also the last few, where little should be happening. 
        set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0) % make x-axes show rain rate in mm/d
        
        ylim([-.2 .1]) % choose y-axes 
        
        % add the changes in dry-day frequency at the top left of the plot
        a=axis;
        t1=text(100,-0.1,[' ' num2str(100*dppdf1(1),2)],'horizontalalignment','left','verticalalignment','top','color',color1,'fontsize',fs);
        t4=text(100,-0.13,[' ' num2str(100*dppdf2(1),2)],'horizontalalignment','left','verticalalignment','top','color',color2,'fontsize',fs);
        
        %  ylabel('\DeltaFrequency (%/K)'); % If you wanted to be precise, the y-axis label is in mm/d/K/\Delta bin
        xlabel('Precipitation rate (mm d^-^1)','FontName',fn,'fontsize',fs);
                
    end

    function []=drpercentileplot(dfreq1,color1,dfreq2,color2,pbinm,xticks99)
        fs=8; fn='Myriad Pro'; % local functions do not inherit the script workspace
        if ~any(strcmp(listfonts,fn)); fn=get(0,'defaultAxesFontName'); end
        % plot the change in rain rate as a function of percentile.  two curves in two
        % different colors.  
        
        p=plot(1:length(pbinm),dfreq1,'-k',1:length(pbinm),dfreq2,'-m');
        set(p(1),'color',color1)
        set(p(2),'color',color2)
        set(p,'linewidth',1.2)
        
        ylim([-5 17]) % choose y-axes
        
        % minor ticks removed: Science Advances does not allow minor tick
        % marks or grid lines in scales

        set(gca,'xtick',10:10:length(pbinm),'xticklabel',{90 99 99.9 99.99},'XTickLabelRotation',0) % make x-axes show percentile
        
        l=line([2 length(pbinm)],[0 0]);set(l,'color',[1 1 1]*.5) % add zero line 
        xlim([1 length(pbinm)])
        
        % ylabel('\DeltaRain rate (%/K)')
        xlabel('Percentile','FontName',fn,'fontsize',fs)
    end