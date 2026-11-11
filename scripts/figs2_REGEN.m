%% Fig. S2: stations, REGEN-Long and REGEN-All, 1955-1984 vs 1987-2016
% Sept. 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% Figure 1: A,B,C change in the precipitation amount distribution with 95% CI,
%           each with the increase + shift mode fit overlaid.
%           A the 295 stations whose REGEN cells pass QC in both products,
%           B REGEN-Long and C REGEN-All at the cells containing them
% Figure 2: spatial patterns of the increase and shift modes (commented out)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
period1=1955:1984; period2=1987:2016; missrate=20;
addpath('\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\scripts\')
path_sta='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';
path_reg='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\REGEN\REGEN_outputs\';
outpath='\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\';
fn='Arial'; fs=8; fsl=7; fsp=9;
ylm=[-0.02 0.18];   % shared y range for the three panels
esfx=[num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end))];

%% Load datasets
% way1_295stations_*.nc is written by section 6 of run06_REGEN_cal.m into
% REGEN_outputs, next to the REGEN files
S=loadset(path_reg,'295stations',esfx);
L=loadset(path_reg,'regen_long',esfx);
A=loadset(path_reg,'regen_all',esfx);
for D={'L','A'}
    ev=eval(D{1});
    ev.lat=double(ncread(ev.fspat,'gridlat')); ev.lat=ev.lat(:);
    ev.lon=double(ncread(ev.fspat,'gridlon')); ev.lon=ev.lon(:);
    eval([D{1},'=ev;']);
end
fprintf('stations %d; REGEN-Long %d cells; REGEN-All %d cells\n',S.n,L.n,A.n);

sets={S,L,A}; nms={'Stations','REGEN-Long','REGEN-All'};
obscolor=[0 0 0];
spicolor=[162 77 86]/255;   % increase + shift fit

%% ========================================================================
%% FIGURE 1: A,B,C -- change in precipitation amount distribution
f1=figure; clf
set(f1,'units','centimeters','paperpositionmode','auto','position',[1 1 18.4 7],...
    'Color','white','Renderer','painters');

lx=[0.065 0.385 0.705]; ly=0.18; lw=0.265; lh=0.68;
poss1=[lx(1) ly lw lh; lx(2) ly lw lh; lx(3) ly lw lh];

for ic=1:3
    D=sets{ic};
    s=subplot(1,3,ic); s.Position=poss1(ic,:);

    if D.hasUR
        x=(1:size(D.UR_dpamt1,1)).';
        lo=prctile(D.UR_dpamt1,2.5,2);
        hi=prctile(D.UR_dpamt1,97.5,2);
        fill([x;flipud(x)],[lo;flipud(hi)],obscolor,...
            'FaceAlpha',0.2,'EdgeColor','none'); hold on
        lo=prctile((D.UR_pamtshiftinc-D.UR_pamt1)*1./D.db,2.5,2);
        hi=prctile((D.UR_pamtshiftinc-D.UR_pamt1)*1./D.db,97.5,2);
        fill([x;flipud(x)],[lo;flipud(hi)],spicolor,...
            'FaceAlpha',0.2,'EdgeColor','none'); hold on
    end

    hdata=dpamtplot(D.dpamt1(:),obscolor,...
        (D.pamtshiftinc(:)-D.kdepamt1(:))*1./D.db,spicolor,...
        D.xticks,D.xtickratesp,fn,fs,ylm);

    if ic==1
        % empty patches carry the two shading entries, so the legend is
        % complete even if panel A has no uncertainty file
        h1=fill(NaN,NaN,obscolor,'FaceAlpha',0.2,'EdgeColor','none');
        h2=fill(NaN,NaN,spicolor,'FaceAlpha',0.2,'EdgeColor','none');
        lg=legend([hdata(1) hdata(2) h1 h2],...
            {'Data','Increase + Shift','95% CI','95% CI (fit)'},...
            'FontName',fn,'FontSize',fsl,'Location','northwest');
        set(lg,'box','off');
        ylabel('\DeltaP (mm d ^-^1 K ^-^1)','FontName',fn,'FontSize',fs);
    end

    % mode magnitudes as in-panel text, placed below the panel A legend
    a=axis;
    text(0.10*a(2),0.62*a(4),...
        {['Increase = ',num2str(round(D.inc_w1,2)),'% K^{-1}'],...
         ['Shift = ',   num2str(round(D.shift_w1,2)),'% K^{-1}'],...
         ['Error = ',   num2str(D.err_w1,2),'%']},...
        'FontName',fn,'FontSize',fsl,'VerticalAlignment','top');

    title(nms{ic},'FontName',fn,'FontSize',fs,'FontWeight','bold');

    annotation('textbox',[max(poss1(ic,1)-0.030,0) poss1(ic,2)+poss1(ic,4)-0.015 0.04 0.03],...
        'String',char('A'+ic-1),'LineStyle','none','FontName',fn,...
        'FontSize',fsp,'FontWeight','bold');
end

savefig(f1,[outpath,'figS2_REGEN_distribution.fig']);
exportgraphics(f1,[outpath,'figS2_REGEN_distribution.pdf'],...
    'ContentType','vector','BackgroundColor','white');
exportgraphics(f1,[outpath,'figS2_REGEN_distribution.png'],'Resolution',600);

% %% FIGURE 2: spatial patterns of increase and shift
% f2=figure; clf
% set(f2,'units','centimeters','paperpositionmode','auto','position',[1 1 18.4 10],...
%     'Color','white','Renderer','painters');
%
% mw=0.40; mx=[0.045 0.465];
% my=[0.53 0.08]; mh=0.38;
% poss2=[mx(1) my(1) mw mh; mx(2) my(1) mw mh;...
%        mx(1) my(2) mw mh; mx(2) my(2) mw mh];
%
% cdata=othercolor('RdBu10',8);
% load coastlines
% ax_maps=[];
%
% for irow=1:2
%     for ic=1:2
%         D=sets{ic+1};   % skip sets{1}, the stations
%         ip=2*(irow-1)+ic;
%         s=subplot(2,2,ip); s.Position=poss2(ip,:);
%
%         axesm('MapProjection','robinson','MapLatLimit',[-60 85],...
%             'Frame','on','Grid','off','MeridianLabel','off','ParallelLabel','off');
%         setm(gca,'FLineWidth',1); axis off
%
%         col=D.shiftincerr(:,3-irow); % irow 1 = increase; irow 2 = shift
%         scatterm(D.lat,D.lon,5,col,'filled');
%         colormap(cdata); caxis([-40 40]);
%         plotm(coastlat,coastlon,'color',[.7 .7 .7]); hold on
%
%         if isempty(ax_maps); ax_maps=gca; end
%
%         annotation('textbox',[poss2(ip,1)+0.008 poss2(ip,2)+poss2(ip,4)-0.045 0.04 0.03],...
%             'String',char('C'+ip-1),'LineStyle','none','FontName',fn,...
%             'FontSize',fsp,'FontWeight','bold');
%     end
% end
%
% % Column headers
% for ic=1:2
%     annotation('textbox',[mx(ic) my(1)+mh+0.01 mw 0.03],...
%         'String',nms{ic+1},'LineStyle','none','HorizontalAlignment','center',...
%         'FontName',fn,'FontSize',fs,'FontWeight','bold');
% end
%
% % Row labels
% mfull=[mx(1) mx(2)+mw-mx(1)];
% annotation('textbox',[mfull(1) my(1)+mh-0.005 mfull(2) 0.025],...
%     'String','Increase','LineStyle','none','HorizontalAlignment','center',...
%     'FontName',fn,'FontSize',fs,'FontWeight','bold');
% annotation('textbox',[mfull(1) my(2)+mh-0.005 mfull(2) 0.025],...
%     'String','Shift','LineStyle','none','HorizontalAlignment','center',...
%     'FontName',fn,'FontSize',fs,'FontWeight','bold');
%
% hc=colorbar(ax_maps,'Location','eastoutside',...
%     'Position',[0.900 my(2)+0.05 0.014 (my(1)+mh)-my(2)-0.10]);
% set(get(hc,'Title'),'string','% K^-^1','FontName',fn,'FontSize',fs);
% hc.Ticks=[-40 -30 -20 -10 0 10 20 30 40];
% hc.FontSize=fsl;
% cbarrow;
%
% % savefig(f2,[outpath,'FigR2_REGEN_spatial_modes.fig']);
% % exportgraphics(f2,[outpath,'FigR2_REGEN_spatial_modes.pdf'],...
% %     'ContentType','vector','BackgroundColor','white');
% % exportgraphics(f2,[outpath,'FigR2_REGEN_spatial_modes.png'],'Resolution',600);

%% Helpers
function D=loadset(p,tag,esfx)
    if strcmp(tag,'stations')
        fway1=[p,'way1_stations_',esfx,'.nc'];
        fspat=[p,'stations_modes_spatial_dist_',esfx,'.nc'];
        fur  =[p,'stations_uncertainty_range_',esfx,'.nc'];
        msg=['missing %s\nThe station analysis has to be run for this pair '...
            'of epochs (1955-1984 vs 1987-2016), not only for the main-text pair.'];
    else
        fway1=[p,'way1_',tag,'_',esfx,'.nc'];
        fspat=[p,tag,'_modes_spatial_dist_',esfx,'.nc'];
        fur  =[p,tag,'_uncertainty_range_',esfx,'.nc'];
        msg=['missing %s\nIt is written by run06_REGEN_cal.m on unicorn; '...
            'copy it from REGEN_outputs.'];
    end
    assert(isfile(fway1),msg,fway1);

    D.fspat=fspat;
    D.bincrates   =ncread(fway1,'bincrates');
    D.dpamt1      =ncread(fway1,'dpamt1');
    D.kdepamt1    =ncread(fway1,'kdepamt1');
    D.pamtshiftinc=ncread(fway1,'pamtshiftinc');
    D.inc_w1      =ncread(fway1,'inc_w1');
    D.shift_w1    =ncread(fway1,'shift_w1');
    D.err_w1      =ncread(fway1,'err_w1');
    D.db=(D.bincrates(3)-D.bincrates(2))./D.bincrates(2);   % bin width

    if isfile(fspat)
        D.shiftincerr=ncread(fspat,'shiftincerr_way1');
        D.n=size(D.shiftincerr,1);
    else
        D.n=sscanf(tag,'%d');   % '295stations' -> 295; no spatial file for this set
    end

    D.hasUR=isfile(fur);
    if D.hasUR
        D.UR_dpamt1      =double(ncread(fur,'UR_dpamt1'));
        D.UR_pamtshiftinc=double(ncread(fur,'UR_pamtshiftinc'));
        D.UR_pamt1       =double(ncread(fur,'UR_pamt1'));
    else
        fprintf('no uncertainty file for %s, shading omitted:\n%s\n',tag,fur);
    end

    xtickrates=[0 0.1:.1:.9 1:1:9 10:10:90 100:100:1000];
    xt=interp1(D.bincrates,1:length(D.bincrates),xtickrates);
    xtp={0 0.1 [] [] [] [] [] [] [] [] 1 [] [] [] [] [] [] [] [] 10 ...
        [] [] [] [] [] [] [] [] 100 [] [] [] [] [] [] [] [] 1000};
    xtp(isnan(xt))=[]; xt(isnan(xt))=[];
    D.xticks=xt; D.xtickratesp=xtp;
end

function p=dpamtplot(dpamt1,color1,dpamt2,color2,xticks,xtickratesp,fn,fs,ylm)
    % dpamt1: the change itself; dpamt2: the increase + shift mode fit
    nb=length(dpamt1);
    p=plot(1:nb,dpamt1,'-',1:nb,dpamt2,'-'); hold on
    set(p(1),'Color',color1); set(p(2),'Color',color2);
    set(p,'LineWidth',1.2);
    line([0 130],[0 0],'Color',[.5 .5 .5]);
    set(gca,'fontsize',fs,'FontName',fn);
    ylim(ylm); xlim([4 130]);
    set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0);
    xlabel('Precipitation rate (mm d ^-^1)','FontName',fn,'FontSize',fs);
end