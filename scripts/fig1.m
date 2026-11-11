%% Fig. 1: Global precipitation amount distributions for stations and models
% 1 September 2026, Jingya Han, Cornell University, Ithaca, NY.
% jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%   A: station map
%   B: early epoch (1955-1984), raw and smoothed
%   C: late epoch (1994-2023), smoothed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
fn='Arial'; fs=8; fsl=7; fsp=9; ms=36; xlab=0.03;
period1=1955:1984; period2=1994:2023; missrate=20;
path='\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\dataforplot\';

%% Load distributions for the two epochs
ep=[num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'];
f_sta0=[path,'way0_stations_',ep];   % raw
f_sta1=[path,'way1_stations_',ep];   % smoothed
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
kdepamt2=ncread(f_sta1,'kdepamt2');
BINCRATES=ncread(f_mmm1,'BINCRATES');
KDEMMMpamt1=ncread(f_mmm1,'KDEMMMpamt1');
KDEMMMpamt2=ncread(f_mmm1,'KDEMMMpamt2');

%% Station locations
finallat=ncread([path,'stationslatlon.nc'],'finallat');
finallon=ncread([path,'stationslatlon.nc'],'finallon');
ghcnlats=ncread([path,'stationslatlon.nc'],'ghcnlats');
ghcnlons=ncread([path,'stationslatlon.nc'],'ghcnlons');

%% Figure
f=figure; clf
set(gcf,'units','centimeters','paperpositionmode','auto','position',[1 1 18.4 15]);
set(f,'Color','white');
poss=[0.090 0.57 0.80 0.40;    % A: station map
      0.085 0.15 0.39 0.34;    % B: early epoch
      0.545 0.15 0.39 0.34];   % C: late epoch

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

%% X-axis setup, shared by B and C
xtickrates=[0 0.1:.1:.9 1:1:9 10:10:90 100:100:1000];
xticks=interp1(bincrates,1:length(bincrates),xtickrates);
xtickratesp={0 0.1 [] [] [] [] [] [] [] [] 1 [] [] [] [] [] [] [] [] 10 [] [] [] [] [] [] [] [] 100 [] [] [] [] [] [] [] [] 1000};
xtickratesp(isnan(xticks))=[]; xticks(isnan(xticks))=[];
x01=interp1(bincrates,1:length(bincrates),0.1);
x1000=interp1(BINCRATES,1:length(BINCRATES),1000);

stacolor=[30 144 255]/255;
modcolor=[255 144 30]/255;
staraw=[.5 .5 .5];
modraw=[50 205 50]/255;

%% B: early epoch, raw and smoothed
s=subplot(2,2,3); s.Position=poss(2,:);
h1=scatter(1:length(oldbincrates),oldpamt1,ms,'MarkerEdgeColor',staraw); hold on; box on
h2=plot(1:length(bincrates),kdepamt1,'-','Color',stacolor,'LineWidth',1.5);
h3=plot(1:length(oldBINCRATES),oldMMMpamt1,'-','Color',modraw,'LineWidth',1.5);
h4=plot(1:length(BINCRATES),KDEMMMpamt1,'-','Color',modcolor,'LineWidth',1.5);

% legend in the upper left, where the curves are low (light rain rates)
lg=legend([h1 h2 h3 h4],{'Station-raw','Station-smoothed','Model-raw','Model-smoothed'}, ...
    'Location','northwest','FontName',fn,'FontSize',fsl,'Box','off');
lg.ItemTokenSize=[15 18];            % shorter line samples, so the legend ends before the peak
lg.Position(2)=lg.Position(2)-0.025; % move it below the panel letter

set(gca,'xtick',xticks,'xticklabel',xtickratesp,'fontsize',fs,'XTickLabelRotation',0,'FontName',fn);
xlim([x01 x1000]); ylim([0 0.065]);
text(xlab,0.94,'B','Units','normalized','FontName',fn,'fontsize',fsp,'FontWeight','bold');
title([num2str(period1(1)),char(8211),num2str(period1(end))],'FontName',fn,'fontsize',fs,'FontWeight','normal');
xlabel('Precipitation rate (mm d^-^1)','FontName',fn,'fontsize',fs);
ylabel('Precipitation amount (mm d^-^1)','FontName',fn,'fontsize',fs);

%% C: late epoch, smoothed only
s=subplot(2,2,4); s.Position=poss(3,:);
c1=plot(1:length(bincrates),kdepamt2,'--','Color',stacolor,'LineWidth',1.5); hold on; box on
c2=plot(1:length(BINCRATES),KDEMMMpamt2,'--','Color',modcolor,'LineWidth',1.5);

lg=legend([c1 c2],{'Station-smoothed','Model-smoothed'}, ...
    'Location','northwest','FontName',fn,'FontSize',fsl,'Box','off');
lg.ItemTokenSize=[15 18];
lg.Position(2)=lg.Position(2)-0.025;

set(gca,'xtick',xticks,'xticklabel',xtickratesp,'fontsize',fs,'XTickLabelRotation',0,'FontName',fn);
xlim([x01 x1000]); ylim([0 0.065]);   % same scale as B
text(xlab,0.94,'C','Units','normalized','FontName',fn,'fontsize',fsp,'FontWeight','bold');
title([num2str(period2(1)),char(8211),num2str(period2(end))],'FontName',fn,'fontsize',fs,'FontWeight','normal');
xlabel('Precipitation rate (mm d^-^1)','FontName',fn,'fontsize',fs);
% no y label: C shares the y axis of B

savefig('\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.fig');
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.png",'Resolution',600);
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.pdf",'ContentType','vector','BackgroundColor','white');