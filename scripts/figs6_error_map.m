%% Error of the shift-plus-increase fit at stations and in models
% Oct. 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
%   A: stations, shiftincerr_way1(:,3)
%   B: CMIP6 multi-model mean at the co-located grid points, 'griderr' in
%      cmip6_modes_spatial_dist_*.nc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
fn='Arial'; fs=8; fsl=7; fsp=9;   % Science Advances standards, as in Fig. 3
missrate=20;
emax=60;   % keep locations where both station and model fit errors are <= emax (%)
addpath('\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\');
path='\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\dataforplot\';
figdir='\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\';
esfx=[num2str(missrate),'%miss_19551984_19942023.nc'];

%% data
shiftincerr_way1=ncread([path,'stations_modes_spatial_dist_',esfx],'shiftincerr_way1');
errsta=shiftincerr_way1(:,3);   % col1 shift, col2 increase, col3 error
finallat=ncread([path,'stationslatlon.nc'],'finallat');
finallon=ncread([path,'stationslatlon.nc'],'finallon');
errmod=ncread([path,'cmip6_modes_spatial_dist_',esfx],'griderr');
errmod=errmod(:);               % one grid point per station, same order

% % keep locations where both errors are at most emax (NaN errors are dropped too)
% keep=errsta<=emax & errmod<=emax;
% fprintf('fit error <= %d%%: stations %d, model grid points %d, both %d (of %d)\n',...
%     emax,sum(errsta<=emax),sum(errmod<=emax),sum(keep),numel(keep));
% errsta=errsta(keep); errmod=errmod(keep);
% finallat=finallat(keep); finallon=finallon(keep);
% 
% % check the range before fixing the color limits
% fprintf('station error (%%): median %.0f, 95th %.0f, max %.0f\n',...
%     prctile(errsta,50),prctile(errsta,95),max(errsta));
% fprintf('model error (%%): median %.0f, 95th %.0f, max %.0f\n',...
%     prctile(errmod,50),prctile(errmod,95),max(errmod));

%% figure
% sequential yellow-to-red map, 3 classes of 20% over 0-60%
% (classes 2-4 of othercolor YlOrRd5; class 1 is too pale on a white background)
emap=othercolor('YlOrRd5',5); 
elim=[0 100];

f=figure; clf
set(f,'units','centimeters','paperpositionmode','auto','position',[1 1 18.4 5],...
    'Color','white','Renderer','painters');
poss=[0.04 0.05 0.40 0.74;
      0.47 0.05 0.40 0.74];
data={errsta, errmod}; nms={'Station','Model'};

load coastlines
for i=1:2
    s=subplot(1,2,i); s.Position=poss(i,:);
    axesm('MapProjection','robinson','MapLatLimit',[-60 85],'Frame','on','Grid','off',...
          'MeridianLabel','off','ParallelLabel','off');
    setm(gca,'FLineWidth',1);
    axis off;
    scatterm(finallat,finallon,9,data{i},'filled');
    colormap(gca,emap); caxis(elim);   % per-axes colormap, so it survives a merge into Fig. 3
    plotm(coastlat,coastlon,'color',[.7 .7 .7]);
    title(nms{i},'FontName',fn,'FontSize',fsp,'FontWeight','bold');
    if i==1; ax1=gca; end
    annotation('textbox',[poss(i,1)-0.035 poss(i,2)+poss(i,4)-0.06 0.04 0.1],...
        'String',char('A'+i-1),'LineStyle','none','FontName',fn,...
        'FontSize',fsp,'FontWeight','bold');
end

hc=colorbar(ax1,'Location','eastoutside','Position',[0.90 0.12 0.015 0.60]);
set(get(hc,'Title'),'string','Error (%)','FontName',fn,'FontSize',fs);
hc.Ticks=0:20:100;
hc.FontSize=fsl;

savefig(f,[figdir,'figS6.fig']);
exportgraphics(f,[figdir,'figS6.png'],'Resolution',600);
exportgraphics(f,[figdir,'figS6.pdf'],'ContentType','vector','BackgroundColor','white');