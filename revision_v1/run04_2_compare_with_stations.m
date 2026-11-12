%% Fig. RX: stations, REGEN-Long and REGEN-All, 1955-1984 vs 1987-2016
% Sept. 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% Columns: stations | REGEN-Long | REGEN-All, the two gridded products taken
% at the cells co-located with the stations.
%   A,B,C  precipitation amount distribution in each epoch
%   D,E,F  change in the amount distribution, with 95% CI
%   G,H,I  map of the increase mode
%   J,K,L  map of the shift mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
period1 = 1955:1984;
period2 = 1987:2016;
missrate=20;
addpath('\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\scripts\')
path_sta='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';
path_reg='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\REGEN\REGEN_outputs\';
outpath=path_reg;

% Science Advances figure standards, as in Fig. 3
fn  = 'Arial';
fs  = 8;   % labels, ticks, legends
fsl = 7;   % colorbar ticks
fsp = 9;   % panel letters, bold

esfx=[num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end))];

%% load the three datasets ----------------------------------------------
S = loadset(path_sta,'stations',   esfx);
L = loadset(path_reg,'regen_long', esfx);
A = loadset(path_reg,'regen_all',  esfx);

% Station coordinates are not stored in stations_modes_spatial_dist_*.nc;
% they come from the file written for this pair of epochs.
flatlon=[path_sta,'stationslatlon',num2str(period1(1)),num2str(period2(end)),'.nc'];
S.lat=double(ncread(flatlon,'finallat')); S.lat=S.lat(:);
S.lon=double(ncread(flatlon,'finallon')); S.lon=S.lon(:);
assert(numel(S.lat)==S.n, ...
    ['%s holds %d stations but the modes file holds %d; the two come from ' ...
     'different networks and the modes would be plotted at the wrong places.'], ...
    flatlon, numel(S.lat), S.n);

% REGEN cell coordinates are stored alongside the modes
for D={'L','A'}
    ev=eval(D{1});
    ev.lat=double(ncread(ev.fspat,'gridlat')); ev.lat=ev.lat(:);
    ev.lon=double(ncread(ev.fspat,'gridlon')); ev.lon=ev.lon(:);
    eval([D{1},'=ev;']);
end

fprintf('stations %d points; REGEN-Long %d cells; REGEN-All %d cells\n', S.n, L.n, A.n);

sets={S,L,A};
nms={'Stations','REGEN-Long','REGEN-All'};

% colors
obscolor=[0 0 0]/255;              % data itself
spicolor=[138 43 226]/255;         % shift + increase fit
ep1color=[0 0 0];                  % early epoch
ep2color=[30 144 255]/255;         % late epoch

f=figure;clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 18.4 19.5]); % 2 columns wide, within the 19.9 cm depth
set(f,'Color','white','Renderer','painters');

% rows 1 and 2 hold line plots, rows 3 and 4 the maps. Maps are wider than
% the line plots because the robinson projection needs the room; the shared
% colorbar sits to the right of the third map column.
lw=0.245; lx=[0.075 0.395 0.715];   % line plots
mw=0.28;  mx=[0.035 0.325 0.615];   % maps; left margin leaves room for the
                                    % panel letters, which sit outside the axes
ly=[0.79 0.55];  lh=0.17;
my=[0.30 0.06];  mh=0.17;

poss=nan(12,4);
for ic=1:3
    poss(ic  ,:)=[lx(ic) ly(1) lw lh];   % row 1  A B C
    poss(ic+3,:)=[lx(ic) ly(2) lw lh];   % row 2  D E F
    poss(ic+6,:)=[mx(ic) my(1) mw mh];   % row 3  G H I
    poss(ic+9,:)=[mx(ic) my(2) mw mh];   % row 4  J K L
end

%% A,B,C -- amount distribution in each epoch ----------------------------
for ic=1:3
    D=sets{ic};
    s=subplot(4,3,ic); s.Position=poss(ic,:);
    p=pamtplot(D.kdepamt1(:),ep1color,D.kdepamt2(:),ep2color,D.xticks,D.xtickratesp);
    hold on;
    if ic==1
        l0=legend(p,[num2str(period1(1)),'-',num2str(period1(end))], ...
                    [num2str(period2(1)),'-',num2str(period2(end))], ...
                    'FontName',fn,'FontSize',fs-1,'Location','northwest');
        set(l0,'box','off');
    end
    if ic==1
        ylabel('P (mm d ^-^1)','FontName',fn,'FontSize',fs);
    end
end

%% D,E,F -- change in the amount distribution ----------------------------
for ic=1:3
    D=sets{ic};
    s=subplot(4,3,ic+3); s.Position=poss(ic+3,:);

    hci=[];
    if D.hasUR
        x=(1:size(D.UR_dpamt1,1)).';
        lo=prctile(D.UR_dpamt1,2.5,2);  hi=prctile(D.UR_dpamt1,97.5,2);
        h1=fill([x; flipud(x)],[lo; flipud(hi)], ...
            obscolor,'FaceAlpha',0.2,'EdgeColor','none'); hold on;
        lo=prctile((D.UR_pamtshiftinc-D.UR_pamt1)*1./D.db,2.5,2);
        hi=prctile((D.UR_pamtshiftinc-D.UR_pamt1)*1./D.db,97.5,2);
        h2=fill([x; flipud(x)],[lo; flipud(hi)], ...
            spicolor,'FaceAlpha',0.2,'EdgeColor','none'); hold on;
        hci=[h1 h2];
    end

    h3=dpamtplot(D.dpamt1(:),obscolor, ...
        (D.pamtshiftinc(:)-D.kdepamt1(:))*1./D.db,spicolor, ...
        D.xticks,D.xtickratesp);
    hold on;

    % Mode values as text rather than in the legend: at this panel width a
    % four-entry legend would run over the curves.
    if ic==1
        if D.hasUR
            l1=legend([h3(1) h3(2) hci(1) hci(2)],'Data','Increase + Shift', ...
                '95% CI','95% CI (fit)','FontName',fn,'FontSize',fs-1, ...
                'Location','northwest');
        else
            l1=legend([h3(1) h3(2)],'Data','Increase + Shift', ...
                'FontName',fn,'FontSize',fs-1,'Location','northwest');
        end
        set(l1,'box','off');
        ylabel('\DeltaP (mm d ^-^1 K ^-^1)','FontName',fn,'FontSize',fs);
    end
    a=axis;
    text(0.42*a(2),0.90*a(4), ...
        {['Increase = ',num2str(round(D.inc_w1,2)),'% K^{-1}'], ...
         ['Shift = ',   num2str(round(D.shift_w1,2)),'% K^{-1}'], ...
         ['Error = ',   num2str(D.err_w1,2),'%']}, ...
        'FontName',fn,'FontSize',fs-1,'VerticalAlignment','top');
end

%% G..L -- increase and shift modes at each point ------------------------
cdata=othercolor('RdBu10',8);
load coastlines;
ax_maps=[];
for irow=1:2                 % 1 increase, 2 shift
    for ic=1:3
        D=sets{ic};
        ip=3*(irow+1)+ic;    % panels 7..9 then 10..12
        s=subplot(4,3,ip); s.Position=poss(ip,:);
        axesm('MapProjection','robinson','MapLatLimit',[-60 85],'Frame','on','Grid','off', ...
              'MeridianLabel','off','ParallelLabel','off');
        setm(gca,'FLineWidth',1);
        axis off;
        col = D.shiftincerr(:, 3-irow);   % irow 1 -> col 2 (increase); irow 2 -> col 1 (shift)
        scatterm(D.lat, D.lon, 7, col, 'filled');
        colormap(cdata); caxis([-40 40]);
        plotm(coastlat, coastlon, 'color',[.7 .7 .7]);
        hold on;
        if isempty(ax_maps); ax_maps=gca; end
    end
end

%% panel letters, row and column labels ----------------------------------
lbl={'A','B','C','D','E','F','G','H','I','J','K','L'};
for i=1:12
    % annotation rejects positions outside [0 1], so the letter is clamped to
    % the figure edge for the left-hand column rather than pushed off it
    xl=max(poss(i,1)-0.025, 0);
    yl=min(max(poss(i,2)+poss(i,4)-0.02, 0), 0.97);
    annotation('textbox',[xl yl 0.04 0.03],...
        'String',lbl{i},'LineStyle','none','FontName',fn,'FontSize',fsp,'FontWeight','bold');
end

% column headers above row 1
for ic=1:3
    annotation('textbox',[lx(ic) ly(1)+lh+0.005 lw 0.025],'String',nms{ic}, ...
        'LineStyle','none','HorizontalAlignment','center', ...
        'FontName',fn,'FontSize',fs,'FontWeight','bold');
end
% row labels for the two map rows
annotation('textbox',[mx(1) my(1)+mh-0.005 mw 0.025],'String','Increase', ...
    'LineStyle','none','HorizontalAlignment','center', ...
    'FontName',fn,'FontSize',fsp,'FontWeight','bold');
annotation('textbox',[mx(1) my(2)+mh-0.005 mw 0.025],'String','Shift', ...
    'LineStyle','none','HorizontalAlignment','center', ...
    'FontName',fn,'FontSize',fsp,'FontWeight','bold');

hc=colorbar(ax_maps,'Location','eastoutside', ...
    'Position',[0.915 my(2) 0.015 (my(1)+mh)-my(2)]);
set(get(hc,'Title'),'string','% K^-^1','FontName',fn,'FontSize',fsp);
hc.Ticks = [-40 -30 -20 -10 0 10 20 30 40];
hc.FontSize = fsl;
cbarrow;

% savefig([outpath,'FigR_stations_vs_REGEN.fig']);
% exportgraphics(gcf,[outpath,'FigR_stations_vs_REGEN.png'],'Resolution',300);
% exportgraphics(gcf,[outpath,'FigR_stations_vs_REGEN.pdf'], ...
%     'ContentType','auto','Resolution',300,'BackgroundColor','white');

%% ------------------------------------------------------------- helpers
    function D=loadset(p,tag,esfx)
    % Everything one column of the figure needs. The uncertainty file is
    % optional: the REGEN bootstrap is commented out in run05_REGEN_cal.m,
    % so the shading is drawn only when the file is there.
        if strcmp(tag,'stations')
            fway1=[p,'way1_stations_',esfx,'.nc'];
            fspat=[p,'stations_modes_spatial_dist_',esfx,'.nc'];
            fur  =[p,'stations_uncertainty_range_',esfx,'.nc'];
        else
            fway1=[p,'way1_',tag,'_',esfx,'.nc'];
            fspat=[p,tag,'_modes_spatial_dist_',esfx,'.nc'];
            fur  =[p,tag,'_uncertainty_range_',esfx,'.nc'];
        end
        for fk={fway1,fspat}
            assert(isfile(fk{1}), ...
                ['missing %s\nFor REGEN-All, run05_REGEN_cal.m has to loop over ' ...
                 'ip = 1:2 rather than ip = 2.'], fk{1});
        end

        D.fspat=fspat;
        D.bincrates   =ncread(fway1,'bincrates');
        D.dpamt1      =ncread(fway1,'dpamt1');
        D.kdepamt1    =ncread(fway1,'kdepamt1');
        D.kdepamt2    =ncread(fway1,'kdepamt2');
        D.pamtshiftinc=ncread(fway1,'pamtshiftinc');
        D.inc_w1      =ncread(fway1,'inc_w1');
        D.shift_w1    =ncread(fway1,'shift_w1');
        D.err_w1      =ncread(fway1,'err_w1');
        D.db=(D.bincrates(3)-D.bincrates(2))./D.bincrates(2);

        D.shiftincerr=ncread(fspat,'shiftincerr_way1');
        D.n=size(D.shiftincerr,1);

        D.hasUR=isfile(fur);
        if D.hasUR
            D.UR_dpamt1      =double(ncread(fur,'UR_dpamt1'));
            D.UR_pamtshiftinc=double(ncread(fur,'UR_pamtshiftinc'));
            D.UR_pamt1       =double(ncread(fur,'UR_pamt1'));
        else
            fprintf('  no uncertainty file for %s, shading omitted:\n    %s\n', tag, fur);
        end

        % x-axis label data, built on this dataset's own bin axis
        xtickrates=[0 0.1:.1:.9 1:1:9 10:10:90 100:100:1000];
        xt=interp1(D.bincrates,1:length(D.bincrates),xtickrates);
        xtp={0 0.1 [] [] [] [] [] [] [] [] 1 [] [] [] [] [] [] [] [] 10 [] [] [] [] [] [] [] [] 100 [] [] [] [] [] [] [] [] 1000};
        xtp(isnan(xt))=[];  xt(isnan(xt))=[];
        D.xticks=xt;  D.xtickratesp=xtp;
    end

    function [p]=pamtplot(pamt1,color1,pamt2,color2,xticks,xtickratesp)
        % the precipitation amount distribution in the two epochs. They are
        % nearly indistinguishable at this scale, which is why the change is
        % quantified through the difference in the row below.
        nb=length(pamt1);
        p=plot(1:nb,pamt1,'-',1:nb,pamt2,'--');
        set(gca,'fontsize',8,'FontName','Arial');
        set(p(1),'color',color1); set(p(2),'color',color2);
        set(p,'linewidth',1.2)

        ylim([0 0.075]);
        xlim([4 130])
        set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0)
        xlabel('Precipitation rate (mm d ^-^1)','fontsize',9,'FontName','Arial');
    end

    function [p]=dpamtplot(dpamt1,color1,dpamt2,color2,xticks,xtickratesp)
        % plot the change in rain amount distribution.  two curves in two
        % different colors.
        nb=length(dpamt1);
        p=plot(1:nb,dpamt1,'-k',1:nb,dpamt2,'-r');
        set(gca,'fontsize',8,'FontName','Arial');
        set(p(1),'color',color1)
        set(p(2),'color',color2)
        set(p,'linewidth',1.2)

        l=line([0 130],[0 0]);set(l,'color',[1 1 1]*.5) % add a zero line
        ylim([-.02 0.25]); % choose y-axes
        xlim([4 130]) % exclude the zero bin and also the last few, where little should be happening.
        set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0) % make x-axes show rain rate in mm/d

        xlabel('Precipitation rate (mm d ^-^1)','fontsize',9,'FontName','Arial');
    end