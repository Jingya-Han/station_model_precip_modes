%% Fig. 2: Changes in the precipitation amount distribution from 1955–1984 to 1994–2023.
% September 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
% Science Advances figure standards:
%   2-column width 18.4 cm; max depth 19.9 cm
%   panel letters 9 pt bold capitals; all other type 8 pt sans serif (6 pt min)
%   line weights >= 0.28 pt; SI units
fn  = 'Arial'; % sans serif equivalent of Myriad, accepted by the guidelines
fs  = 8;   % labels, ticks, legends
fsp = 9;   % panel letters, bold

period1 = 1955:1984;
period2 = 1994:2023;
missrate=20;
path='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';

% preliminary items
KDEMMMpamt1=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'KDEMMMpamt1');
mmm_dpamt1=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'mmm_dpamt1');
mmm_pamtshiftinc=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'mmm_pamtshiftinc');
mmmerr_w1=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'mmmerr_w1');
mmminc_w1=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'mmminc_w1');
mmmshift_w1=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'mmmshift_w1');

cmip_dpamt1=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)),...
    num2str(period1(end)),'_',num2str(period2(1)),num2str(period2(end)),'.nc'],'UR_dpamt1');
cmip_pamt1=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)),...
    num2str(period1(end)),'_',num2str(period2(1)),num2str(period2(end)),'.nc'],'UR_pamt1');
cmip_pamtshiftinc=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)),...
    num2str(period1(end)),'_',num2str(period2(1)),num2str(period2(end)),'.nc'],'UR_pamtshiftinc');

bincrates=ncread([path,'way1_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'bincrates');
dpamt1=ncread([path,'way1_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'dpamt1');
err_w1=ncread([path,'way1_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'err_w1');
inc_w1=ncread([path,'way1_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'inc_w1');
kdepamt1=ncread([path,'way1_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'kdepamt1');
pamtshiftinc=ncread([path,'way1_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'pamtshiftinc');
shift_w1=ncread([path,'way1_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'shift_w1');

UR_dpamt1=ncread([path,'stations_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'UR_dpamt1');
UR_pamtshiftinc=ncread([path,'stations_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'UR_pamtshiftinc');
UR_pamt1=ncread([path,'stations_uncertainty_range_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'UR_pamt1');
db=(bincrates(3)-bincrates(2))./bincrates(2);% bin width
% panels A and B start at 0.1 mm/day, the reporting resolution of GHCNd:
% below that the archive cannot resolve a non-zero value
x01=interp1(bincrates,1:length(bincrates),0.1);
xhi=130; % as before: drop the last few bins, where little should be happening

% colors 
stationobscolor=[0 0 0]/255;
stationspicolor=[138 43 226]/255;
MMMsimcolor=[255 140 0]/255;
MMMspicolor=[50 205 50]/255;
% x-axis label data
xtickrates=[0 0.1:.1:.9 1:1:9 10:10:90 100:100:1000]; % rain rates in mm/d for x axis 
xticks=interp1(bincrates,1:length(bincrates),xtickrates); % bin numbers associated with nice number rain rate 
xtickratesp={0 0.1 [] [] [] [] [] [] [] [] 1 [] [] [] [] [] [] [] [] 10 [] [] [] [] [] [] [] [] 100 [] [] [] [] [] [] [] [] 1000}; % rain rates with white space in between 
pbinm=(1-10.^(-.1:-.1:-4)); % percentile bins for calculations 
xtickpercent=[30:10:90 91:99 99.1:.1:99.9 99.91:.01:99.99]/100; % percentiles for x-axes of percentile plots 
xticks99=interp1(pbinm,1:length(pbinm),xtickpercent); % bin numbers of percentiles for plotting
xtickratesp(isnan(xticks))=[];
xticks(isnan(xticks))=[];

f=figure;clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 18.4 15]); 
set(f,'Color','white','Renderer','painters');
left=0.07; down= .55;width= .42;he= .4;
poss=[left down width he;
left+0.5 down width he;
left+0.2 down-he-0.08 width he];

% rain amount 
s=subplot(2,2,1); s.Position=poss(1,:);
% Compute 95% confidence intervals
dpamt1_Lower = prctile(UR_dpamt1, 2.5, 2); % 2.5th percentile
dpamt1_Upper = prctile(UR_dpamt1, 97.5, 2); % 97.5th percentile
x=1:length(UR_dpamt1(:,1)); x=x(:);
h1=fill([x; flipud(x)], [dpamt1_Lower; flipud(dpamt1_Upper)],...
    stationobscolor,'FaceAlpha', 0.2, 'EdgeColor', 'none');
hold on;
dpamtshiftinc_Lower = prctile((UR_pamtshiftinc-UR_pamt1)*1./db, 2.5, 2);
dpamtshiftinc_Upper = prctile((UR_pamtshiftinc-UR_pamt1)*1./db, 97.5, 2);
h2=fill([x; flipud(x)], [dpamtshiftinc_Lower; flipud(dpamtshiftinc_Upper)],...
    stationspicolor,'FaceAlpha', 0.2, 'EdgeColor', 'none');
hold on;
% plot the line
h3=dpamtplot(dpamt1(:),stationobscolor,(pamtshiftinc(:)-kdepamt1(:))*1./db,stationspicolor,xticks,xtickratesp,x01,xhi,fn,fs);
hold on;
l1 = legend([h3(1) h3(2) h1 h2], ['Station observations' newline], ...
    ['Increase = ', num2str(round(inc_w1,2)), '% K^{-1}', newline, ...
     'Shift = ', num2str(round(shift_w1,2)), '% K^{-1}'],...
     '95% CI (Station)','95% CI (Increase+Shift modes)','FontName',fn,'FontSize',fs);
set(l1,'box','off','Position',[0.14 0.75 0.19 0.2]); hold on;
text(0.52,0.44,['Error = ' num2str(err_w1,2),'%'],'Units','normalized', ...
    'FontName',fn,'FontSize',fs);
ylabel('\DeltaP (mm d ^-^1 K ^-^1)','FontName',fn,'FontSize',fs);% If you wanted to be precise, the y-axis label is in mm/d/K/\Delta bin
text(0.03,0.95,'A','Units','normalized','FontName',fn,'FontSize',fsp,'FontWeight','bold');

s=subplot(2,2,2); s.Position=poss(2,:);
% Compute 95% confidence intervals
dpamt1_Lower = prctile(cmip_dpamt1, 2.5, 2); % 2.5th percentile
dpamt1_Upper = prctile(cmip_dpamt1, 97.5, 2); % 97.5th percentile
x=1:length(cmip_dpamt1(:,1)); x=x(:);
h1=fill([x; flipud(x)], [dpamt1_Lower; flipud(dpamt1_Upper)],...
    MMMsimcolor,'FaceAlpha', 0.2, 'EdgeColor', 'none');
hold on;
dpamtshiftinc_Lower = prctile((cmip_pamtshiftinc-cmip_pamt1)*1./db, 2.5, 2);
dpamtshiftinc_Upper = prctile((cmip_pamtshiftinc-cmip_pamt1)*1./db, 97.5, 2);
h2=fill([x; flipud(x)], [dpamtshiftinc_Lower; flipud(dpamtshiftinc_Upper)],...
    MMMspicolor,'FaceAlpha', 0.2, 'EdgeColor', 'none');
hold on;
% plot the line
h3=dpamtplot(mmm_dpamt1(:),MMMsimcolor,(mmm_pamtshiftinc(:)-KDEMMMpamt1(:))*1./db,MMMspicolor,xticks,xtickratesp,x01,xhi,fn,fs); 
l1 = legend([h3(1) h3(2) h1 h2], ['Climate models' newline], ...
    ['Increase = ', num2str(round(mmminc_w1,2)), '% K^{-1}', newline, ...
     'Shift = ', num2str(round(mmmshift_w1,2)), '% K^{-1}'],...
     '95% CI (Model)','95% CI (Increase+Shift modes)','FontName',fn,'FontSize',fs);
set(l1,'box','off','Position',[0.2+width 0.75 0.19 0.2]);
text(0.52,0.44,['Error = ' num2str(mmmerr_w1,2),'%'],'Units','normalized', ...
    'FontName',fn,'FontSize',fs);
ylabel('\DeltaP (mm d ^-^1 K ^-^1)','FontName',fn,'FontSize',fs);% If you wanted to be precise, the y-axis label is in mm/d/K/\Delta bin
text(0.03,0.95,'B','Units','normalized','FontName',fn,'FontSize',fsp,'FontWeight','bold');

%% plot the box plots
s=subplot(2,2,3); s.Position=poss(3,:); 
% Load data
period1 = 1955:1984;
period2 = 1994:2023;

% Load station data
inc_stations=ncread([path,'stations_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_inc');
shi_stations=ncread([path,'stations_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_shift');

% Load CMIP6 model data
inc_MMM=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_inc');
shi_MMM=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_', num2str(period1(1)), num2str(period1(end)), '_', ...
      num2str(period2(1)), num2str(period2(end)), '.nc'],'UR_shift');

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
end

% Customize axes
clear xticks;
set(gca,'fontsize',fs,'FontName',fn);
set(gca,'xtick',[1.5 3.5],'xticklabel',{'Increase mode', 'Shift mode'},...
    'fontsize',fs,'FontName',fn,'XTickLabelRotation',0);

xlim([0 5]);
ylim([-1.5 18]);
ylabel('Magnitude of modes (% K ^-^1)', 'fontsize',fs,'FontName',fn);
box on;
text(0.03,0.95,'C','Units','normalized','FontWeight','bold','FontName',fn,'FontSize',fsp);
legend('','Station observations','','Climate models','','','','','fontsize',fs,'FontName',fn); legend('boxoff');

savefig('\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig2.fig');
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig2.pdf",...
    'ContentType','vector','BackgroundColor','white'); % .pdf vector is the preferred format
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig2.png",...
    'Resolution', 600); % png fallback; 600 dpi is the ceiling before downsampling


%% plotting functions 
    function [p]=dpamtplot(dpamt1,color1,dpamt2,color2,xticks,xtickratesp,x01,xhi,fn,fs)
        % plot the change in rain amount distribution.  two curves in two
        % different colors.  
        nb=length(dpamt1);
        p=plot(1:nb,dpamt1,'-k',1:nb,dpamt2,'-r');
        set(gca,'fontsize',fs,'FontName',fn);
        set(p(1),'color',color1)
        set(p(2),'color',color2)
        set(p,'linewidth',1.2)

        l=line([0 xhi],[0 0]);set(l,'color',[1 1 1]*.5) % add a zero line
        ylim([-.02 0.25]); % choose y-axes
        xlim([x01 xhi]) % start at 0.1 mm/day, drop the last few bins
        set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0) % make x-axes show rain rate in mm/d

        %  ylabel('\DeltaRain amount (mm/d/K)');% If you wanted to be precise, the y-axis label is in mm/d/K/\Delta bin
        xlabel('Precipitation rate (mm d ^-^1)','FontName',fn,'FontSize',fs);
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
        xlabel('Precipitation rate (mm ^d)','fontsize',fs,'FontName',fn);
                
    end

    function []=drpercentileplot(dfreq1,color1,dfreq2,color2,pbinm,xticks99)
        % plot the change in rain rate as a function of percentile.  two curves in two
        % different colors.  
        
        p=plot(1:length(pbinm),dfreq1,'-k',1:length(pbinm),dfreq2,'-m');
        set(gca,'fontsize',8,'FontName','Arial');
        set(p(1),'color',color1)
        set(p(2),'color',color2)
        set(p,'linewidth',1.2)
        
        ylim([-5 25]) % choose y-axes
        
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
        xlabel('Percentile')
    end