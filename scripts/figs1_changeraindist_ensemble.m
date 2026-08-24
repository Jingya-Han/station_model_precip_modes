%% Supplementary Figure 1: Changes in the precipitation amount distribution in station observations and individual ensemble members from models. 
% 1 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
f=figure;clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 18 15]); 
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

%% box plot of two modes and a_o, b_o
s=subplot(2,2,1); s.Position=poss(1,:);
% Combine only `inc` and `shi` data into a single vector
data = [inc_stations(:); nan(length(inc_MMM),1); shi_stations(:); nan(length(inc_MMM),1)];

% Create grouping variables
grouping1 = [repmat({'Increase'}, length(inc_stations), 1); ...
             repmat({'Increase'}, length(inc_MMM), 1); ...
             repmat({'Shift'}, length(shi_stations), 1); ...
             repmat({'Shift'}, length(shi_MMM), 1)];

grouping2 = [repmat({'Stations'}, length(inc_stations), 1); ...
             repmat({'Models'}, length(inc_MMM), 1); ...
             repmat({'Stations'}, length(shi_stations), 1); ...
             repmat({'Models'}, length(shi_MMM), 1)];

% Convert grouping variables to categorical
group1 = categorical(grouping1);
group2 = categorical(grouping2);

% Calculate percentiles and median values
percentile8 = grpstats(data, {group1, group2}, @(x) prctile(x, 8));
percentile92 = grpstats(data, {group1, group2}, @(x) prctile(x, 92));
medianVals = grpstats(data, {group1, group2}, @median);

% Sort order: inc_MMM, inc_stations, shi_MMM, shi_stations
perc8 = [percentile8(1:2,:); percentile8(3:4,:)];
perc92 = [percentile92(1:2,:); percentile92(3:4,:)];
mediv = [medianVals(1:2,:); medianVals(3:4,:)];
perc8
perc92
mediv


% Define colors
stationcolor = [138 43 226] / 255; % Purple for stations
MMMcolor = [50 205 50] / 255; % Green for models

% Plot reference line at y=0
yline(0, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);

% Plot custom boxes for each group
for i = 1:numel(perc8)
    x = i; % X position
    color = stationcolor;
    if mod(i,2) == 1
        color = MMMcolor;
    end

    % Draw percentile box
    patch([x-0.15, x+0.15, x+0.15, x-0.15], ...
          [perc8(i), perc8(i), perc92(i), perc92(i)], ...
          color, 'FaceAlpha', 0.6, 'EdgeColor', 'none');
    hold on;

    % Draw median line
    plot([x-0.15, x+0.15], [mediv(i), mediv(i)], 'k-', 'LineWidth', 2);
end

% Customize axes
xlim([0 5]);
ylim([-2 18]);
clear xticks; xticks([1.5 3.5]);
xticklabels({'Increase mode', 'Shift mode'});
set(gca,'fontsize',9,'XTickLabelRotation',0,'FontName','Arial');
ylabel('Magnitude of modes (% K^-^1)', 'FontName','Arial','fontsize',9');
box on;
text(0.6,16,'a','FontWeight','bold','FontName','Arial','fontsize',9');

% scatter ensembles
for ie=1:length(inc_MMM)
    theinc=inc_MMM(ie);
    scatter(1, theinc, 15,'MarkerEdgeColor',[0.4 .4 .4],'MarkerFaceColor',MMMcolor);
    hold on;

    theshi=shi_MMM(ie);
    scatter(3, theshi, 15,'MarkerEdgeColor',[0.4 .4 .4],'MarkerFaceColor',MMMcolor);
    
end
legend({'','','','Station','','','','','','Ensemble member'},...
    'FontName','Arial','fontsize',9');
legend('boxoff')

s=subplot(2,2,2); s.Position=poss(2,:);
% Combine only `inc` and `shi` data into a single vector
data = [ao_stations(:); nan(length(ao_MMM),1); bo_stations(:); nan(length(bo_MMM),1)];

% Create grouping variables
grouping1 = [repmat({'Increase'}, length(ao_stations), 1); ...
             repmat({'Increase'}, length(ao_MMM), 1); ...
             repmat({'Shift'}, length(bo_stations), 1); ...
             repmat({'Shift'}, length(bo_MMM), 1)];

grouping2 = [repmat({'Stations'}, length(ao_stations), 1); ...
             repmat({'Models'}, length(ao_MMM), 1); ...
             repmat({'Stations'}, length(bo_stations), 1); ...
             repmat({'Models'}, length(bo_MMM), 1)];

% Convert grouping variables to categorical
group1 = categorical(grouping1);
group2 = categorical(grouping2);

% Calculate percentiles and median values
percentile8 = grpstats(data, {group1, group2}, @(x) prctile(x, 8));
percentile92 = grpstats(data, {group1, group2}, @(x) prctile(x, 92));
medianVals = grpstats(data, {group1, group2}, @median);

% Sort order: inc_MMM, inc_stations, shi_MMM, shi_stations
perc8 = [percentile8(1:2,:); percentile8(3:4,:)];
perc92 = [percentile92(1:2,:); percentile92(3:4,:)];
mediv = [medianVals(1:2,:); medianVals(3:4,:)];
perc8
perc92
mediv


% Define colors
stationcolor = [138 43 226] / 255; % Purple for stations
MMMcolor = [50 205 50] / 255; % Green for models

% Plot reference line at y=0
yline(0, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);

% Plot custom boxes for each group
for i = 1:numel(perc8)
    x = i; % X position
    color = stationcolor;
    if mod(i,2) == 1
        color = MMMcolor;
    end

    % Draw percentile box
    patch([x-0.15, x+0.15, x+0.15, x-0.15], ...
          [perc8(i), perc8(i), perc92(i), perc92(i)], ...
          color, 'FaceAlpha', 0.6, 'EdgeColor', 'none');
    hold on;

    % Draw median line
    plot([x-0.15, x+0.15], [mediv(i), mediv(i)], 'k-', 'LineWidth', 2);
end

% Customize axes
clear xticks; xticks([1.5 3.5]);
xlim([0 5]);
ylim([-1.5 18]);
xticklabels({'a_o', 'b_o'});
set(gca,'fontsize',9,'XTickLabelRotation',0,'FontName','Arial');
ylabel('Magnitude of modes (% K^-^1)', 'FontName','Arial','fontsize',9');
box on;
text(0.6,16,'b','FontWeight','bold','FontName','Arial','fontsize',9');

% scatter ensembles
for ie=1:length(ao_MMM)
    theao=ao_MMM(ie);
    scatter(1, theao, 20,'MarkerEdgeColor',[0.4 .4 .4],'MarkerFaceColor',MMMcolor);
    hold on;

    thebo=bo_MMM(ie);
    scatter(3, thebo, 20,'MarkerEdgeColor',[0.4 .4 .4],'MarkerFaceColor',MMMcolor);
    
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
 xlim([4 130]) % exclude the zero bin and also the last few, where little should be happening. 
 set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0,...
     'FontName','Arial','fontsize',7') % make x-axes show rain rate in mm/d
 hold on;
end

% plot the line
dpamtplot(mmm_dpamt1(:),MMMsimcolor,(mmm_pamtshiftinc(:)-KDEMMMpamt1(:))*1./db,MMMspicolor,xticks,xtickratesp);
legend({'Model','Increase + Shift modes'},'FontName','Arial','fontsize',9'); legend('boxoff'); hold on;
set(gca,'fontsize',9,'XTickLabelRotation',0,'FontName','Arial');
ylabel('\DeltaPrecipitation amount (mm d^-^1K^-^1)','FontName','Arial','fontsize',9');% If you wanted to be precise, the y-axis label is in mm/d/K/\Delta bin
text(20,0.115,'c','FontWeight','bold','FontName','Arial','fontsize',9');
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
ylabel('\DeltaPrecipitation rate (% K^-^1)','FontName','Arial','fontsize',9');
text(5,15,'d','FontWeight','bold','FontName','Arial','fontsize',9');
box on;

% savefig('/share/cliprelabs/jh2423/P1/figures/Figs1.fig');
% exportgraphics(gcf,"/share/cliprelabs/jh2423/P1/figures/Figs1.png",...
%     'Resolution', 300);

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
        xlabel('Precipitation rate (mm d^-^1)','FontName','Arial','fontsize',9');
    end

    function []=dppdfplot(dppdf1,color1,dppdf2,color2,xticks,xtickratesp)
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
        t1=text(100,-0.1,[' ' num2str(100*dppdf1(1),2)],'horizontalalignment','left','verticalalignment','top','color',color1,'fontsize',10);
        t4=text(100,-0.13,[' ' num2str(100*dppdf2(1),2)],'horizontalalignment','left','verticalalignment','top','color',color2,'fontsize',10);
        
        %  ylabel('\DeltaFrequency (%/K)'); % If you wanted to be precise, the y-axis label is in mm/d/K/\Delta bin
        xlabel('Precipitation rate (mm d^-^1)','FontName','Arial','fontsize',9');
                
    end

    function []=drpercentileplot(dfreq1,color1,dfreq2,color2,pbinm,xticks99)
        % plot the change in rain rate as a function of percentile.  two curves in two
        % different colors.  
        
        p=plot(1:length(pbinm),dfreq1,'-k',1:length(pbinm),dfreq2,'-m');
        set(p(1),'color',color1)
        set(p(2),'color',color2)
        set(p,'linewidth',1.2)
        
        ylim([-5 17]) % choose y-axes
        
        % add minor ticks. without forcing them to have labels.  Code from
        % matlab central. 
        % grid on
        xg = xticks99;
        xx = reshape([xg;xg;NaN(1,length(xg))],1,length(xg)*3);
        a=axis;
        mth=(a(4)-a(3))/100;
        yg = a(3)+[0 mth];
        yy = repmat([yg NaN],1,length(xg));
        yg2 = a(4)+[0 -mth];
        yy2 = repmat([yg2 NaN],1,length(xg));
        hold on
        h_minorgrid = plot(xx,yy,'k',xx,yy2,'k');
        hold off

        set(gca,'xtick',10:10:length(pbinm),'xticklabel',{90 99 99.9 99.99},'XTickLabelRotation',0) % make x-axes show percentile
        
        l=line([2 length(pbinm)],[0 0]);set(l,'color',[1 1 1]*.5) % add zero line 
        xlim([1 length(pbinm)])
        
        % ylabel('\DeltaRain rate (%/K)')
        xlabel('Percentile','FontName','Arial','fontsize',9')
    end
