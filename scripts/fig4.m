%% Fig. 4: Change in extreme precipitation.
% September 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
% Science Advances figure standards:
%   2-column width 18.4 cm; max depth 19.9 cm
%   panel letters 9 pt bold capitals; all other type 8 pt sans serif (6 pt min)
%   line weights >= 0.28 pt
fn  = 'Arial'; % sans serif equivalent of Myriad, accepted by the guidelines
fs  = 8;   % labels, ticks, legends
fsp = 9;   % panel letters, bold

% preliminary items
missrate=20;
path='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';

mmm_dfreq=ncread([path,'way1_MMM_',num2str(missrate),'%miss_19551984_19942023.nc'],'mmm_dfreq');
mmm_dfreqshiftinc=ncread([path,'way1_MMM_',num2str(missrate),'%miss_19551984_19942023.nc'],'mmm_dfreqshiftinc');
cmip_dfreq=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_19551984_19942023.nc'],'UR_dfreq');
cmip_dfreqshiftinc=ncread([path,'cmip6_uncertainty_range_',num2str(missrate),'%miss_19551984_19942023.nc'],'UR_dfreqshiftinc');

bincrates=ncread([path,'way1_stations_',num2str(missrate),'%miss_19551984_19942023.nc'],'bincrates');
db=(bincrates(3)-bincrates(2))./bincrates(2);% bin width
dfreq=ncread([path,'way1_stations_',num2str(missrate),'%miss_19551984_19942023.nc'],'dfreq');
dfreqshiftinc=ncread([path,'way1_stations_',num2str(missrate),'%miss_19551984_19942023.nc'],'dfreqshiftinc');

UR_dfreq=ncread([path,'stations_uncertainty_range_',num2str(missrate),'%miss_19551984_19942023.nc'],'UR_dfreq');
UR_dfreqshiftinc=ncread([path,'stations_uncertainty_range_',num2str(missrate),'%miss_19551984_19942023.nc'],'UR_dfreqshiftinc');

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
set(gcf,'position',[1 1 18.4 7]);
set(f,'Color','white','Renderer','painters');
left=0.085; down=.20; width=.40; he=.70;
poss=[left       down width he;
      left+0.475 down width he];

% percentile
s=subplot(2,2,1); s.Position=poss(1,:);
% Compute 95% confidence intervals
x=1:length(pbinm); x=x(:);
dfreq_Lower = prctile(cmip_dfreq(1:length(pbinm),:), 2.5, 2); % 2.5th percentile
dfreq_Upper = prctile(cmip_dfreq(1:length(pbinm),:), 97.5, 2); % 97.5th percentile
jud=~isnan(dfreq_Lower);
fill([x(jud); flipud(x(jud))], [dfreq_Lower(jud); flipud(dfreq_Upper(jud))],...
    MMMsimcolor,'FaceAlpha', 0.2, 'EdgeColor', 'none');
hold on;
dfreqshiftinc_Lower = prctile(cmip_dfreqshiftinc(1:length(pbinm),:), 2.5, 2);
dfreqshiftinc_Upper = prctile(cmip_dfreqshiftinc(1:length(pbinm),:), 97.5, 2);
jud2=~isnan(dfreqshiftinc_Lower);
fill([x(jud2); flipud(x(jud2))], [dfreqshiftinc_Lower(jud2); flipud(dfreqshiftinc_Upper(jud2))],...
    MMMspicolor,'FaceAlpha', 0.2, 'EdgeColor', 'none');
hold on;
%plot the line
drpercentileplot(mmm_dfreq,MMMsimcolor,mmm_dfreqshiftinc,MMMspicolor,pbinm,xticks99,fn,fs);
xlim([2 length(pbinm)])
ylabel('\DeltaPrecipitation rate (% K^-^1)','FontName',fn,'FontSize',fs);
text(0.03,0.95,'A','Units','normalized','FontWeight','bold','FontName',fn,'FontSize',fsp);
legend('','','Climate models','Increase + shift modes','FontName',fn,'FontSize',fs); legend('boxoff');

s=subplot(2,2,2); s.Position=poss(2,:);
% Compute 95% confidence intervals
x=1:length(pbinm); x=x(:);
dfreq_Lower = prctile(UR_dfreq(1:length(pbinm),:), 2.5, 2); % 2.5th percentile
dfreq_Upper = prctile(UR_dfreq(1:length(pbinm),:), 97.5, 2); % 97.5th percentile
jud=~isnan(dfreq_Lower);
fill([x(jud); flipud(x(jud))], [dfreq_Lower(jud); flipud(dfreq_Upper(jud))],...
    stationobscolor,'FaceAlpha', 0.2, 'EdgeColor', 'none');
hold on;
dfreqshiftinc_Lower = prctile(UR_dfreqshiftinc(1:length(pbinm),:), 2.5, 2);
dfreqshiftinc_Upper = prctile(UR_dfreqshiftinc(1:length(pbinm),:), 97.5, 2);
jud2=~isnan(dfreqshiftinc_Lower);
fill([x(jud2); flipud(x(jud2))], [dfreqshiftinc_Lower(jud2); flipud(dfreqshiftinc_Upper(jud2))],...
    stationspicolor,'FaceAlpha', 0.2, 'EdgeColor', 'none');
hold on;
%plot the line
drpercentileplot(dfreq,stationobscolor,dfreqshiftinc,stationspicolor,pbinm,xticks99,fn,fs);
% start where the station data actually begin: the lowest percentile bins are
% empty because a station's dry days leave no rain rate to report there
xb=find(~isnan(dfreq(1:length(pbinm))) & dfreq(1:length(pbinm))~=0, 1, 'first');
xlim([xb length(pbinm)])
ylabel('\DeltaPrecipitation rate (% K^-^1)','FontName',fn,'FontSize',fs);
text(0.03,0.95,'B','Units','normalized','FontWeight','bold','FontName',fn,'FontSize',fsp);
legend('','','Station observations','Increase + shift modes','FontName',fn,'FontSize',fs); legend('boxoff');

savefig('\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\figures\Fig4.fig');
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig4.pdf",...
    'ContentType','vector','BackgroundColor','white'); % .pdf vector is the preferred format
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig4.png",...
    'Resolution', 600); % png fallback; 600 dpi is the ceiling before downsampling

% % pdf version
% addpath(genpath('C:\Program Files\MATLAB\altmany-export_fig-d5538e9'));
% export_fig(gcf,'-eps', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig4.eps');
% export_fig(gcf,'-pdf', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig4.pdf');


%% plotting functions 
    

    function []=drpercentileplot(dfreq1,color1,dfreq2,color2,pbinm,xticks99,fn,fs)
        % plot the change in rain rate as a function of percentile.  two curves in two
        % different colors.  
        
        p=plot(1:length(pbinm),dfreq1,'-k',1:length(pbinm),dfreq2,'-m');
        set(gca,'fontsize',fs,'FontName',fn);
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
        xlabel('Percentile','FontName',fn,'FontSize',fs)
    end