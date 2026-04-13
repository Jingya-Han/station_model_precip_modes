%%  Fig. 1: Map for stations excluding Russia
% 12 April 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
period1=1955:1984;
period2=1994:2023; %1995:2024;
missrate=20;
path='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';

finallat=ncread([path,'stationslatlon.nc'],'finallat');
finallon=ncread([path,'stationslatlon.nc'],'finallon');
ghcnlats=ncread([path,'stationslatlon.nc'],'ghcnlats');
ghcnlons=ncread([path,'stationslatlon.nc'],'ghcnlons');
% remove RU
% those stations in Russia do not have data from 2020 to 2023
exclude=58:152;
finallat(exclude)=[];
finallon(exclude)=[];
% Load station data
load([path,'xRU_stations_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.mat']);
inc_stations=UR_inc;
shi_stations=UR_shift;
load([path,'xRU_way1_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.mat'],'inc_w1','shift_w1');

% Load CMIP6 model data
load([path,'xRU_cmip6_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.mat']);
inc_MMM=UR_inc;
shi_MMM=UR_shift;
load([path,'xRU_way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.mat'],'mmminc_w1','mmmshift_w1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f=figure; clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 18 16]); 
set(f,'Color','white');
poss=[0.005 0.6 .8 .4;
    0.1 0.22 0.6 0.35];
% plot station map
s=subplot(2,1,1); s.Position=poss(1,:);

axesm('MapProjection', 'robinson', 'MapLatLimit',[-60 85],'Frame', 'on', 'Grid', 'off', ...
      'MeridianLabel', 'off', 'ParallelLabel', 'off');
setm(gca,'FLineWidth',1);
axis off;
scatterm(ghcnlats, ghcnlons,4, [222 184 135]/255,"filled",'DisplayName', 'Original stations'); % stations-inc
scatterm(finallat, finallon,9, [147 112 219]/255,"filled",'DisplayName', 'Quality-controlled stations'); % stations-inc
load coastlines;
plotm(coastlat, coastlon, 'color',[.7 .7 .7]); % Plot the coastlines
hold on;
annotation('textbox',...
    [0.15 0.95 0.06 0.04],'String',{'a'},'LineStyle','none',...
    'FontName','Arial','FontSize',9,'FontWeight','bold');
% legend
pos=get(gca,'Position');
h_at=axes('Position',[0.04 0.7 0.06 0.03]);
scatter(1.5,1,50,'o','filled','MarkerFaceColor',[222 184 135]/255,'LineWidth',1); hold on;
scatter(1.5,2,100,'o','filled','MarkerFaceColor',[147 112 219]/255,'LineWidth',1); hold on;
text(2,1,'All GHCNd stations','FontName','Arial','fontsize',9');
text(2,2,'Included stations','FontName','Arial','fontsize',9');
axis off;
hold on;

%% plot the box plots
s=subplot(2,1,2); s.Position=poss(2,:);


% Combine only `inc` and `shi` data into a single vector
data = [inc_stations(:); inc_MMM(:); shi_stations(:); shi_MMM(:)];

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
% 84% size for the intervals
percentile8 = grpstats(data, {group1, group2}, @(x) prctile(x, 8));
percentile92 = grpstats(data, {group1, group2}, @(x) prctile(x, 92));
medianVals = grpstats(data, {group1, group2}, @median);

% 95% uncertainty range
percentile2_5 = grpstats(data, {group1, group2}, @(x) prctile(x, 2.5));
percentile97_5 = grpstats(data, {group1, group2}, @(x) prctile(x, 97.5));

% Sort order: inc_stations, inc_MMM, shi_stations, shi_MMM
perc8 = [percentile8(2,:); percentile8(1,:); percentile8(4,:); percentile8(3,:)];
perc92 = [percentile92(2,:); percentile92(1,:); percentile92(4,:); percentile92(3,:)];
mediv = [medianVals(2,:); medianVals(1,:); medianVals(4,:); medianVals(3,:)];
perc2_5 = [percentile2_5(2,:); percentile2_5(1,:); percentile2_5(4,:); percentile2_5(3,:)];
perc97_5 = [percentile97_5(2,:); percentile97_5(1,:); percentile97_5(4,:); percentile97_5(3,:)];

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
    color = MMMcolor;
    if mod(i,2) == 1
        color = stationcolor;
    end

    % Draw percentile box
    patch([x-0.15, x+0.15, x+0.15, x-0.15], ...
          [perc8(i), perc8(i), perc92(i), perc92(i)], ...
          color, 'FaceAlpha', 0.6, 'EdgeColor', 'none');
    hold on;

    % Draw median line
    plot([x-0.15, x+0.15], [mediv(i), mediv(i)], 'k-', 'LineWidth', 2);
    %% ==== ADD TEXT HERE ====
    y_text = perc92(i) + 0.5; % slightly above the box

    if i == 1
        txt = sprintf('%.2f%% K^{-1}', inc_w1);
    elseif i == 2
        txt = sprintf('%.2f%% K^{-1}', mmminc_w1);
    elseif i == 3
        txt = sprintf('%.2f%% K^{-1}', shift_w1);
    elseif i == 4
        txt = sprintf('%.2f%% K^{-1}', mmmshift_w1);
    end

    text(x, y_text, txt, ...
        'HorizontalAlignment','center', ...
        'FontSize',8, ...
        'FontName','Arial');
end

% Customize axes
clear xticks;
set(gca,'fontsize',9,'FontName','Arial');
set(gca,'xtick',[1.5 3.5],'xticklabel',{'Increase mode', 'Shift mode'},...
    'fontsize',9,'FontName','Arial','XTickLabelRotation',0);

xlim([0 5]);
ylim([-1.5 18]);
ylabel('Magnitude of modes (% K ^-^1)', 'fontsize',9,'FontName','Arial');
box on;
text(0.2,16,'b','FontWeight','bold','fontsize',9,'FontName','Arial');
legend('','Station observations','','Climate models','','','','','fontsize',9,'FontName','Arial'); legend('boxoff');

% export
savefig('\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\FigS2_xRU.fig');
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\FigS2_xRU.png",...
    'Resolution', 300);
% pdf version
addpath(genpath('C:\Program Files\MATLAB\altmany-export_fig-d5538e9'));
export_fig(gcf,'-eps', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\FigS2_xRU.eps');
export_fig(gcf,'-pdf', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\FigS2_xRU.pdf');
