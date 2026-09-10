%%  Fig. 1: Global precipitation amount distributions for stations and models
% 1 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
% Science Advances figure standards:
%   2-column width 18.4 cm; max depth 19.9 cm (leaves room for the legend)
%   panel letters 9 pt bold capitals; all other type 8 pt sans serif (6 pt min)
%   symbols 5-8 pt; line weights >= 0.28 pt; no minor ticks or grid lines
fn  = 'Arial'; % falls back to the default sans serif if not installed
fs  = 8;    % all labels, ticks and legends
fsp = 9;    % panel letters, bold
ms  = 36;   % scatter area in pt^2 -> 6 pt diameter, as in the manuscript
xlab = 0.03; % panel letter, normalized x

period1=1955:1984;
period2=1994:2023; %1995:2024;
missrate=20;
path='\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\dataforplot\';

ep=[num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'];
f_sta0=[path,'way0_stations_',ep];
f_sta1=[path,'way1_stations_',ep];
f_mmm0=[path,'way0_MMM_',ep];
f_mmm1=[path,'way1_MMM_',ep];

% raw distributions, early epoch only
oldbincrates=ncread(f_sta0,'oldbincrates');
oldpamt1=ncread(f_sta0,'oldpamt1');
oldBINCRATES=ncread(f_mmm0,'oldBINCRATES');
oldMMMpamt1=ncread(f_mmm0,'oldMMMpamt1');

% smoothed distributions, both epochs
bincrates=ncread(f_sta1,'bincrates');
kdepamt1=ncread(f_sta1,'kdepamt1');
kdepamt2=ncread(f_sta1,'kdepamt2');     % NEW: must be added to the save in run01
BINCRATES=ncread(f_mmm1,'BINCRATES');
KDEMMMpamt1=ncread(f_mmm1,'KDEMMMpamt1');
KDEMMMpamt2=ncread(f_mmm1,'KDEMMMpamt2'); % NEW: must be added to the save in run01_3

finallat=ncread([path,'stationslatlon.nc'],'finallat');
finallon=ncread([path,'stationslatlon.nc'],'finallon');
ghcnlats=ncread([path,'stationslatlon.nc'],'ghcnlats');
ghcnlons=ncread([path,'stationslatlon.nc'],'ghcnlons');

f=figure; clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 18.4 16]); 
set(f,'Color','white');
poss=[0.090 0.60 0.80 0.40;   % A: station map
      0.085 0.20 0.39 0.34;   % B: early epoch
      0.545 0.20 0.39 0.34];  % C: late epoch
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
    [0.17 0.93 0.06 0.04],'String',{'A'},'LineStyle','none',...
    'FontName',fn,'FontSize',fsp,'FontWeight','bold');
% legend
pos=get(gca,'Position');
h_at=axes('Position',[0.15 0.7 0.06 0.03]);
scatter(1.5,1,50,'o','filled','MarkerFaceColor',[222 184 135]/255,'LineWidth',1); hold on;
scatter(1.5,2,100,'o','filled','MarkerFaceColor',[147 112 219]/255,'LineWidth',1); hold on;
text(2,1,'All GHCNd stations','FontName',fn,'fontsize',fs);
text(2,2,'Included stations','FontName',fn,'fontsize',fs);
axis off;
hold on;

% x-axis setup, shared by B and C
xtickrates=[0 0.1:.1:.9 1:1:9 10:10:90 100:100:1000]; % rain rates in mm/d for x axis
xticks=interp1(bincrates,1:length(bincrates),xtickrates); % bin numbers associated with nice number rain rate
xtickratesp={0 0.1 [] [] [] [] [] [] [] [] 1 [] [] [] [] [] [] [] [] 10 [] [] [] [] [] [] [] [] 100 [] [] [] [] [] [] [] [] 1000}; % rain rates with white space in between
xtickratesp(isnan(xticks))=[];
xticks(isnan(xticks))=[];
db=(bincrates(3)-bincrates(2))./bincrates(2); % bin width
% start at the GHCNd reporting resolution of 0.1 mm/day, and do not run the
% axis past the last bin that carries data
x01=interp1(bincrates,1:length(bincrates),0.1);
xmax=max([length(bincrates) length(oldbincrates) length(BINCRATES) length(oldBINCRATES)]);

stacolor=[30 144 255]/255;  % stations, smoothed: blue
modcolor=[255 144 30]/255;  % CMIP6 MMM, smoothed: orange
staraw =[.5 .5 .5];         % stations, raw: gray
modraw =[50 205 50]/255;    % CMIP6 MMM, raw: green

%% B: early epoch (1955-1984), raw and smoothed
s=subplot(2,2,3); s.Position=poss(2,:);
h1=scatter(1:length(oldbincrates),oldpamt1,ms,'MarkerEdgeColor',staraw); hold on; box on;
h2=plot(1:length(bincrates),kdepamt1,'-','Color',stacolor,'lineWidth',1.5); hold on;
h3=plot(1:length(oldBINCRATES),oldMMMpamt1,'-','Color',modraw,'lineWidth',1.5); hold on;
h4=plot(1:length(BINCRATES),KDEMMMpamt1,'-','Color',modcolor,'lineWidth',1.5); hold on;
legend([h1 h2 h3 h4],{'Station-raw','Station-smoothed','Model-raw','Model-smoothed'},...
    'Location','northeast','FontName',fn,'fontsize',fs);
legend('boxoff')

set(gca,'xtick',xticks,'xticklabel',xtickratesp,'fontsize',fs,'XTickLabelRotation',0,'FontName',fn);
xlim([x01 xmax]);
ylim([0 0.065]);
text(xlab,0.94,'B','Units','normalized','FontName',fn,'fontsize',fsp,'FontWeight','bold');
% char(8211) is an en dash, inserted this way so the file encoding cannot break it
title(['1955',char(8211),'1984'],'FontName',fn,'fontsize',fs,'FontWeight','normal');
xlabel('Precipitation rate (mm d^-^1)','FontName',fn,'fontsize',fs);
ylabel('Precipitation amount (mm d^-^1)','FontName',fn,'fontsize',fs);

%% C: late epoch (1994-2023), smoothed only
s=subplot(2,2,4); s.Position=poss(3,:);
p1=plot(1:length(bincrates),kdepamt2,'--','Color',stacolor,'lineWidth',1.5); hold on; box on;
p2=plot(1:length(BINCRATES),KDEMMMpamt2,'--','Color',modcolor,'lineWidth',1.5); hold on;
legend([p1 p2],{'Station-smoothed','Model-smoothed'},...
    'Location','northeast','FontName',fn,'fontsize',fs);
legend('boxoff')

set(gca,'xtick',xticks,'xticklabel',xtickratesp,'fontsize',fs,'XTickLabelRotation',0,'FontName',fn);
xlim([x01 xmax]);
ylim([0 0.065]); % same scale as B, so the two epochs can be read against each other
text(xlab,0.94,'C','Units','normalized','FontName',fn,'fontsize',fsp,'FontWeight','bold');
title(['1994',char(8211),'2023'],'FontName',fn,'fontsize',fs,'FontWeight','normal');
xlabel('Precipitation rate (mm d^-^1)','FontName',fn,'fontsize',fs);
% y label not repeated: C shares the axis of B

savefig('\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.fig');
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.png",...
    'Resolution', 600); % png fallback; 600 dpi is the ceiling before downsampling
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.pdf",...
    'ContentType','vector','BackgroundColor','white'); % .pdf vector is the preferred format
% % eps version
% addpath(genpath('C:\Program Files\MATLAB\altmany-export_fig-d5538e9'));
% export_fig(gcf,'-eps', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.eps');
% export_fig(gcf,'-pdf', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.pdf');