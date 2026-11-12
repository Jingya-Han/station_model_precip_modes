%% Diagnose why the fit error is large at some stations
% Oct. 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% Recomputes the shift-plus-increase fit for selected stations with the same
% inputs as run01_cal_modes_in_stations.m, and plots the change in the amount
% distribution with the fit, as in Fig. 2.
%   Fig. 1: change and fit at nhi high-error stations (spread through the top
%           10% of errors) and the nlo lowest-error stations, for reference
%   Fig. 2: error against mean precipitation and against the size of the
%           change, all stations
%   Table : where in rain rate the misfit sits, for the selected stations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
addpath('\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\');   % makeshiftinc_stations
path='\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\dataforplot\';
outpath='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\figs\';
missrate=20;
fsd=[path,'stations_modes_spatial_dist_',num2str(missrate),'%miss_19551984_19942023.nc'];
fn='Arial'; fs=8; fsp=9;   % fsp: panel letters, 9 pt bold (Science Advances)
nhi=3; nlo=3;   % number of high- and low-error stations to show

%% load the per-station smoothed distributions written by run01
ks_ppdf1s=double(ncread(fsd,'ks_ppdf1s'));   % station x bin
ks_ppdf2s=double(ncread(fsd,'ks_ppdf2s'));
ks_pamt1s=double(ncread(fsd,'ks_pamt1s'));
ks_pamt2s=double(ncread(fsd,'ks_pamt2s'));
bincrates=double(ncread(fsd,'bincrates')); bincrates=bincrates(:);
dt=double(ncread(fsd,'dt_noaa'));
sie=double(ncread(fsd,'shiftincerr_way1'));  % col1 shift, col2 increase, col3 error
err=sie(:,3);
lat=ncread([path,'stationslatlon.nc'],'finallat');
lon=ncread([path,'stationslatlon.nc'],'finallon');
nb=numel(bincrates);
db=(bincrates(3)-bincrates(2))/bincrates(2);  % bin width

P1=sum(ks_pamt1s,2);                          % mean precipitation, early epoch (mm/d)
dnorm=sqrt(sum((ks_pamt2s-ks_pamt1s).^2,2))/dt;   % size of the change in the amount distribution

%% select stations
ok=find(isfinite(err));
[~,o]=sort(err(ok),'descend'); o=ok(o);       % largest error first
ntop=ceil(0.1*numel(o));
ihi=o(round(linspace(1,ntop,nhi)));           % spread through the top 10%
ilo=o(end-nlo+1:end);                         % lowest errors, for reference
isel=[ihi(:); ilo(:)]; ns=numel(isel);

%% recompute the fit at the selected stations, same call as in run01
dp=nan(nb,ns); fit=nan(nb,ns); E=nan(ns,3);
for k=1:ns
    i=isel(k);
    [sh,in,er,dpamt1,~,~,pamtshiftinc]=makeshiftinc_stations(ks_ppdf1s(i,:)',ks_pamt1s(i,:)',...
        ks_ppdf2s(i,:)',ks_pamt2s(i,:)',dt,bincrates);
    close(gcf);                               % makeshiftinc_stations opens a figure
    L=numel(dpamt1);
    dp(1:L,k)=dpamt1(:);
    fit(1:L,k)=(pamtshiftinc(:)-ks_pamt1s(i,1:L)')/db;   % as in Fig. 2
    E(k,:)=[sh in er];
end
fprintf('largest difference from the stored error: %.2g%%\n',max(abs(E(:,3)-err(isel))));

%% table: where in rain rate the misfit sits
edges=[0 1 10 50 Inf];                        % mm/d
res2=(dp-fit).^2;
share=nan(ns,numel(edges)-1);
for b=1:numel(edges)-1
    m=bincrates>=edges(b) & bincrates<edges(b+1);
    share(:,b)=100*sum(res2(m,:),1,'omitnan')'./sum(res2,1,'omitnan')';
end
fprintf('\n  sta    lat     lon  err(%%)   inc  shift  P1(mm/d) | misfit share (%%):  <1  1-10  10-50   >50 mm/d\n');
for k=1:ns
    i=isel(k);
    fprintf('%5d %6.1f %7.1f %6.0f %6.1f %6.1f %8.2f | %21.0f %5.0f %6.0f %6.0f\n',...
        i,lat(i),lon(i),E(k,3),E(k,2),E(k,1),P1(i),share(k,:));
end

%% Fig. 1: change and fit at the selected stations
xtickrates=[0.1 1 10 100 1000];
xt=interp1(bincrates,1:nb,xtickrates); keep=~isnan(xt);
x01=interp1(bincrates,1:nb,0.1);
xend=find(any(ks_pamt1s(isel,:)+ks_pamt2s(isel,:)>0,1),1,'last');
fitcolor=[162 77 86]/255;                   

f=figure('Color','white','units','centimeters','position',[1 1 18 12]);
t=tiledlayout(ceil(ns/3),3,'TileSpacing','compact','Padding','compact');
for k=1:ns
    i=isel(k);
    nexttile
    plot(1:nb,dp(:,k),'k-','LineWidth',1); hold on
    plot(1:nb,fit(:,k),'-','Color',fitcolor,'LineWidth',1);
    yline(0,'Color',[.6 .6 .6]);
    xlim([x01 xend]);
    set(gca,'XTick',xt(keep),'XTickLabel',string(xtickrates(keep)),'FontName',fn,'FontSize',fs);
    title({sprintf('%.1f, %.1f',lat(i),lon(i)), ...
        sprintf('E = %.0f%%, inc = %.1f, shift = %.1f',E(k,3),E(k,2),E(k,1))},...
        'FontName',fn,'FontSize',fs,'FontWeight','normal');
    text(0.03,0.94,char('A'+k-1),'Units','normalized','FontName',fn,...
        'FontSize',fsp,'FontWeight','bold');   % panel letter: A-C top row, D-F bottom row
end
xlabel(t,'Precipitation rate (mm d^{-1})','FontName',fn,'FontSize',fs);
ylabel(t,'\DeltaP (mm d^{-1} K^{-1})','FontName',fn,'FontSize',fs);
% title(t,sprintf('First %d: high error (top 10%%). Last %d: lowest error',nhi,nlo),...
%     'FontName',fn,'FontSize',fs);

% %% Fig. 3: amount distributions in the two epochs at the selected stations
% ep1color=[0 0 0];             % 1955-1984
% ep2color=[30 144 255]/255;    % 1994-2023
% 
% figure('Color','white','units','centimeters','position',[1 1 18 15]);
% t3=tiledlayout(ceil(ns/3),3,'TileSpacing','compact','Padding','compact');
% for k=1:ns
%     i=isel(k);
%     nexttile
%     h1=plot(1:nb,ks_pamt1s(i,:),'-','Color',ep1color,'LineWidth',1); hold on
%     h2=plot(1:nb,ks_pamt2s(i,:),'--','Color',ep2color,'LineWidth',1);
%     xlim([x01 xend]);
%     set(gca,'XTick',xt(keep),'XTickLabel',string(xtickrates(keep)),'FontName',fn,'FontSize',fs);
%     title({sprintf('%.1f, %.1f',lat(i),lon(i)), ...
%         sprintf('E = %.0f%%, P: %.2f \\rightarrow %.2f mm d^{-1}',E(k,3),P1(i),sum(ks_pamt2s(i,:)))},...
%         'FontName',fn,'FontSize',fs,'FontWeight','normal');
%     if k==1
%         legend([h1 h2],{['1955',char(8211),'1984'],['1994',char(8211),'2023']},...
%             'Location','northwest','FontName',fn,'FontSize',fs-1,'Box','off');
%     end
% end
% xlabel(t3,'Precipitation rate (mm d^{-1})','FontName',fn,'FontSize',fs);
% ylabel(t3,'Precipitation amount (mm d^{-1})','FontName',fn,'FontSize',fs);
% title(t3,sprintf('First %d: high error (top 10%%). Last %d: lowest error',nhi,nlo),...
%     'FontName',fn,'FontSize',fs);

savefig(f,[outpath,'FigR3_dpamt_for_largeError.fig']);
exportgraphics(f,[outpath,'FigR3_dpamt_for_largeError.pdf'],...
    'ContentType','vector','BackgroundColor','white');
exportgraphics(f,[outpath,'FigR3_dpamt_for_largeError.png'],'Resolution',600);