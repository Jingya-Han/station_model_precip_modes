%% Fig. RX: REGEN-Long and REGEN-All, 1955-1984 vs 1987-2016
% Sept. 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% Figure 1: A,B change in precipitation amount distribution with 95% CI
% Figure 2: C,D increase mode; E,F shift mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
period1=1955:1984; period2=1987:2016; missrate=20;
addpath('\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\scripts\')
path_reg='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\REGEN\REGEN_outputs\';
outpath='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\figs\';
fn='Arial'; fs=8; fsl=7; fsp=9;
esfx=[num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end))];

%% Load datasets
L=loadset(path_reg,'regen_long',esfx);
A=loadset(path_reg,'regen_all',esfx);
for D={'L','A'}
    ev=eval(D{1});
    ev.lat=double(ncread(ev.fspat,'gridlat')); ev.lat=ev.lat(:);
    ev.lon=double(ncread(ev.fspat,'gridlon')); ev.lon=ev.lon(:);
    eval([D{1},'=ev;']);
end
fprintf('REGEN-Long %d cells; REGEN-All %d cells\n',L.n,A.n);
sets={L,A}; nms={'REGEN-Long','REGEN-All'};
obscolor=[0 0 0];

%% ========================================================================
%% FIGURE 1: A,B -- change in precipitation amount distribution
f1=figure; clf
set(f1,'units','centimeters','paperpositionmode','auto','position',[1 1 18.4 7],...
    'Color','white','Renderer','painters');

lx=[0.090 0.555]; ly=0.18; lw=0.39; lh=0.70;
poss1=[lx(1) ly lw lh; lx(2) ly lw lh];

for ic=1:2
    D=sets{ic};
    s=subplot(1,2,ic); s.Position=poss1(ic,:);

    if D.hasUR
        x=(1:size(D.UR_dpamt1,1)).';
        lo=prctile(D.UR_dpamt1,2.5,2);
        hi=prctile(D.UR_dpamt1,97.5,2);
        hci=fill([x;flipud(x)],[lo;flipud(hi)],obscolor,...
            'FaceAlpha',0.2,'EdgeColor','none'); hold on
    end

    hdata=dpamtplot(D.dpamt1(:),obscolor,D.xticks,D.xtickratesp,fn,fs);

    if ic==1
        if D.hasUR
            lg=legend([hdata hci],{'Data','95% CI'},'FontName',fn,...
                'FontSize',fsl,'Location','northwest');
        else
            lg=legend(hdata,{'Data'},'FontName',fn,'FontSize',fsl,...
                'Location','northwest');
        end
        set(lg,'box','off');
    end

    ylabel('\DeltaP (mm d ^-^1 K ^-^1)','FontName',fn,'FontSize',fs);
    title(nms{ic},'FontName',fn,'FontSize',fs,'FontWeight','bold');

    annotation('textbox',[poss1(ic,1)-0.030 poss1(ic,2)+poss1(ic,4)-0.015 0.04 0.03],...
        'String',char('A'+ic-1),'LineStyle','none','FontName',fn,...
        'FontSize',fsp,'FontWeight','bold');
end

savefig(f1,[outpath,'FigR1_REGEN_distribution.fig']);
exportgraphics(f1,[outpath,'FigR1_REGEN_distribution.pdf'],...
    'ContentType','vector','BackgroundColor','white');
exportgraphics(f1,[outpath,'FigR1_REGEN_distribution.png'],'Resolution',600);

% %% FIGURE 2: C-F -- spatial patterns of increase and shift
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
%         D=sets{ic};
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
%         'String',nms{ic},'LineStyle','none','HorizontalAlignment','center',...
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
    fway1=[p,'way1_',tag,'_',esfx,'.nc'];
    fspat=[p,tag,'_modes_spatial_dist_',esfx,'.nc'];
    fur=[p,tag,'_uncertainty_range_',esfx,'.nc'];

    for fk={fway1,fspat}
        assert(isfile(fk{1}),['missing %s\nFor REGEN-All, run05_REGEN_cal.m has to loop over '...
            'ip = 1:2 rather than ip = 2.'],fk{1});
    end

    D.fspat=fspat;
    D.bincrates=ncread(fway1,'bincrates');
    D.dpamt1=ncread(fway1,'dpamt1');
    D.shiftincerr=ncread(fspat,'shiftincerr_way1');
    D.n=size(D.shiftincerr,1);

    D.hasUR=isfile(fur);
    if D.hasUR
        D.UR_dpamt1=double(ncread(fur,'UR_dpamt1'));
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

function p=dpamtplot(dpamt1,color1,xticks,xtickratesp,fn,fs)
    nb=length(dpamt1);
    p=plot(1:nb,dpamt1,'-','Color',color1,'LineWidth',1.2); hold on
    line([0 130],[0 0],'Color',[.5 .5 .5]);
    set(gca,'fontsize',fs,'FontName',fn);
    ylim([-.02 0.12]); xlim([4 130]);
    set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0);
    xlabel('Precipitation rate (mm d ^-^1)','FontName',fn,'FontSize',fs);
end