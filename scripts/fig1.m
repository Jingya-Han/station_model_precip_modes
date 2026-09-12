%% Fig. 1: Global precipitation amount distributions for stations and models
% 1 September 2026, Jingya Han, Cornell University, Ithaca, NY.
% jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
fn='Arial'; fs=8; fsp=9; ms=36; xlab=0.03;
path='\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\dataforplot\';

%% Load full-period climatology, 1955-2023
f_sta_full=[path,'Fig1_stations_climatology_1955_2023.nc'];
bincrates=ncread(f_sta_full,'bincrates_full');
kdepamt_full=ncread(f_sta_full,'kdepamt_full');
oldbincrates=ncread(f_sta_full,'oldbincrates_full');
oldpamt_full=ncread(f_sta_full,'oldpamt_full');

f_mmm_full=[path,'Fig1_MMM_climatology_1955_2023.nc'];
BINCRATES=ncread(f_mmm_full,'BINCRATES_full');
KDEMMMpamt_full=ncread(f_mmm_full,'KDEMMMpamt_full');
oldBINCRATES=ncread(f_mmm_full,'oldBINCRATES_full');
oldMMMpamt_full=ncread(f_mmm_full,'oldMMMpamt_full');

%% Station locations
finallat=ncread([path,'stationslatlon.nc'],'finallat');
finallon=ncread([path,'stationslatlon.nc'],'finallon');
ghcnlats=ncread([path,'stationslatlon.nc'],'ghcnlats');
ghcnlons=ncread([path,'stationslatlon.nc'],'ghcnlons');

%% Figure
f=figure; clf
set(gcf,'units','centimeters','paperpositionmode','auto','position',[1 1 18.4 15]);
set(f,'Color','white');
poss=[0.090 0.57 0.80 0.40;
      0.180 0.15 0.64 0.34];

%% A: station map
s=subplot(2,1,1); s.Position=poss(1,:);
axesm('MapProjection','robinson','MapLatLimit',[-60 85],'Frame','on','Grid','off','MeridianLabel','off','ParallelLabel','off');
setm(gca,'FLineWidth',1); axis off
scatterm(ghcnlats,ghcnlons,4,[222 184 135]/255,"filled",'DisplayName','Original stations'); hold on
scatterm(finallat,finallon,9,[147 112 219]/255,"filled",'DisplayName','Quality-controlled stations');
load coastlines
plotm(coastlat,coastlon,'color',[.7 .7 .7]);
annotation('textbox',[0.17 0.90 0.06 0.04],'String',{'A'},'LineStyle','none','FontName',fn,'FontSize',fsp,'FontWeight','bold');

% Custom legend
h_at=axes('Position',[0.15 0.67 0.06 0.03]);
scatter(1.5,1,50,'o','filled','MarkerFaceColor',[222 184 135]/255,'LineWidth',1); hold on
scatter(1.5,2,100,'o','filled','MarkerFaceColor',[147 112 219]/255,'LineWidth',1);
text(2,1,'All GHCNd stations','FontName',fn,'fontsize',fs);
text(2,2,'Included stations','FontName',fn,'fontsize',fs);
axis off

%% X-axis setup for panel B
xtickrates=[0 0.1:.1:.9 1:1:9 10:10:90 100:100:1000];
xticks=interp1(bincrates,1:length(bincrates),xtickrates);
xtickratesp={0 0.1 [] [] [] [] [] [] [] [] 1 [] [] [] [] [] [] [] [] 10 [] [] [] [] [] [] [] [] 100 [] [] [] [] [] [] [] [] 1000};
xtickratesp(isnan(xticks))=[]; xticks(isnan(xticks))=[];
x01=interp1(bincrates,1:length(bincrates),0.1);
xmax=max([length(bincrates) length(oldbincrates) length(BINCRATES) length(oldBINCRATES)]);

stacolor=[30 144 255]/255;
modcolor=[255 144 30]/255;
staraw=[.5 .5 .5];
modraw=[50 205 50]/255;

%% B: Full-period climatology, 1955-2023
s=subplot(2,1,2); s.Position=poss(2,:);
h1=scatter(1:length(oldbincrates),oldpamt_full,ms,'MarkerEdgeColor',staraw); hold on; box on
h2=plot(1:length(bincrates),kdepamt_full,'-','Color',stacolor,'LineWidth',1.5);
h3=plot(1:length(oldBINCRATES),oldMMMpamt_full,'-','Color',modraw,'LineWidth',1.5);
h4=plot(1:length(BINCRATES),KDEMMMpamt_full,'-','Color',modcolor,'LineWidth',1.5);

legend([h1 h2 h3 h4],{'Station-raw','Station-smoothed','Model-raw','Model-smoothed'}, ...
    'Location','northeast','FontName',fn,'fontsize',fs);
legend('boxoff')
x1000=interp1(BINCRATES,1:length(BINCRATES),1000);
set(gca,'xtick',xticks,'xticklabel',xtickratesp,'fontsize',fs,'XTickLabelRotation',0,'FontName',fn);
xlim([x01 x1000]); ylim([0 0.065]);
text(xlab,0.94,'B','Units','normalized','FontName',fn,'fontsize',fsp,'FontWeight','bold');
title(['1955',char(8211),'2023'],'FontName',fn,'fontsize',fs,'FontWeight','normal');
xlabel('Precipitation rate (mm d^-^1)','FontName',fn,'fontsize',fs);
ylabel('Precipitation amount (mm d^-^1)','FontName',fn,'fontsize',fs);

savefig('\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.fig');
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.png",'Resolution',600);
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.pdf",'ContentType','vector','BackgroundColor','white');
% addpath(genpath('C:\Program Files\MATLAB\altmany-export_fig-d5538e9'));
% export_fig(gcf,'-eps','-r300','-painters','\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.eps');