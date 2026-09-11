%% Supplementary Figure 2: Pairs of the global magnitude of increase mode and shift mode over stations (purple) and co-located grids in models (green) with different start and end years.
% 1 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
% load data
missrate=19; % set acceptable miss rate 
thelength=30;
folder='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';
all_endyears=2014:2023; % endyear: earliest end year
startycount = 0; % count of start year, different start year corresponds to different number of end years
count = 0;
results_med=[];
f=figure; clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(f,'Color','white'); 
set(gcf,'position',[1 1 27 16]); 
left=.08; down=.85; wid=.065; he=.075;
poss=nan(100,4); % 3rd: left down wid he for each subplot

for isub=1:100
    if isub<=10
        poss(isub,1)=left+(isub-1)*(wid+0.01); poss(isub,2)=down; poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=11 && isub<=20  
        poss(isub,1)=left+(isub-10-1)*(wid+0.01); poss(isub,2)=down-1*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=21 && isub<=30  
        poss(isub,1)=left+(isub-20-1)*(wid+0.01); poss(isub,2)=down-2*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=31 && isub<=40  
        poss(isub,1)=left+(isub-30-1)*(wid+0.01); poss(isub,2)=down-3*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=41 && isub<=50  
        poss(isub,1)=left+(isub-40-1)*(wid+0.01); poss(isub,2)=down-4*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=51 && isub<=60  
        poss(isub,1)=left+(isub-50-1)*(wid+0.01); poss(isub,2)=down-5*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=61 && isub<=70  
        poss(isub,1)=left+(isub-60-1)*(wid+0.01); poss(isub,2)=down-6*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=71 && isub<=80  
        poss(isub,1)=left+(isub-70-1)*(wid+0.01); poss(isub,2)=down-7*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=81 && isub<=90  
        poss(isub,1)=left+(isub-80-1)*(wid+0.01); poss(isub,2)=down-8*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=91 && isub<=100  
        poss(isub,1)=left+(isub-90-1)*(wid+0.01); poss(isub,2)=down-9*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;

    end
end


for startyear=1955:1964 % startyear: latest start year
    startycount=startycount+1;
    for endyear=all_endyears(startycount):all_endyears(end)
        count=count+1;
        period1=startyear:(startyear+thelength-1);
        period2=(endyear-thelength+1):endyear; 
        
        varname=sprintf('UR_inc_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        inc_stations=ncread([folder,'stations_uncertainty_ranges_20%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_shift_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        shi_stations=ncread([folder,'stations_uncertainty_ranges_20%miss_',num2str(thelength),'yrs.nc'],varname);

        
        varname=sprintf('UR_inc_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        inc_MMM=ncread([folder,'cmip6_uncertainty_range_20%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_shift_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        shi_MMM=ncread([folder,'cmip6_uncertainty_range_20%miss_',num2str(thelength),'yrs.nc'],varname);
    
        % Combine data into a single vector
        data = [inc_stations(:); inc_MMM(:); ...
        shi_stations(:); shi_MMM(:)];

        % Create grouping variables
        grouping1 = [repmat({'Increase'}, length(inc_stations), 1); ...
             repmat({'Increase'}, length(inc_MMM), 1); ...
             repmat({'Shift'}, length(shi_stations), 1); ...
             repmat({'Shift'}, length(shi_MMM), 1);
             ];

        grouping2 = [repmat({'Stations'}, length(inc_stations), 1); ...
             repmat({'Models'}, length(inc_MMM), 1); ...
             repmat({'Stations'}, length(shi_stations), 1); ...
             repmat({'Models'}, length(shi_MMM), 1)
             ];

% Convert grouping variables to categorical
group1 = categorical(grouping1);
group2 = categorical(grouping2);

% Calculate the 8th and 92nd percentiles
percentile8 = grpstats(data, {group1, group2}, @(x) prctile(x, 8));
percentile92 = grpstats(data, {group1, group2}, @(x) prctile(x, 92));
medianVals = grpstats(data, {group1, group2}, @median);

% sort by inc_MMM; inc_stations; ao_MMM; ao_sations; shi_MMM; shi_stations;
% bo_MMM; bo_stations
perc8=[percentile8(1:2,:); percentile8(3:4,:)];
perc92=[percentile92(1:2,:); percentile92(3:4,:)];
mediv=[medianVals(1:2,:); medianVals(3:4,:)];

%median values for each pair
results_med(:,count)=mediv;

if count<=10
   s=subplot(10,10,count); s.Position=poss(count,:);
   title([num2str(period2(1)),' - ',num2str(period2(end))],'FontWeight','normal',...
       'FontName','Arial','FontSize',9);
elseif count>10 && count<=19
    s=subplot(10,10,count+1); s.Position=poss(count+1,:);
elseif count>19 && count<=27
    s=subplot(10,10,count+3); s.Position=poss(count+3,:);
elseif count>27 && count<=34
    s=subplot(10,10,count+6); s.Position=poss(count+6,:);
elseif count>34 && count<=40
    s=subplot(10,10,count+10); s.Position=poss(count+10,:);
elseif count>40 && count<=45
    s=subplot(10,10,count+15); s.Position=poss(count+15,:);
elseif count>45 && count<=49
    s=subplot(10,10,count+21); s.Position=poss(count+21,:);
elseif count>49 && count<=52
    s=subplot(10,10,count+28); s.Position=poss(count+28,:);
elseif count>52 && count<=54
    s=subplot(10,10,count+36); s.Position=poss(count+36,:);
else
    s=subplot(10,10,100); s.Position=poss(100,:);
end
% Customize colors for stations and models
stationcolor=[138 43 226]/255;
MMMcolor=[50 205 50]/255;
yline(0, '-', 'Color',[0.6 0.6 0.6],'LineWidth', 0.5); % '--' for dashed line, adjust LineWidth as needed
hold on;
% Loop over each category and plot custom boxes
for i = 1:numel(perc8)
    % X position (for each category)
    x = i;

    % Select color based on group (station or model)
    color = stationcolor;
    if mod(i,2) == 1 
        color = MMMcolor;
    end

    % Plot box using patch from 8th to 92nd percentile
    patch([x-0.25, x+0.25, x+0.25, x-0.25], ... % x-coordinates for box
          [perc8(i), perc8(i), perc92(i), perc92(i)], ... % y-coordinates
          color, 'FaceAlpha', 0.8, 'EdgeColor', 'none'); % Box color and outline
    hold on;
    % Plot median line
    plot([x-0.25, x+0.25], [mediv(i), mediv(i)], 'k-', 'LineWidth', 0.7);
    hold on;
end

% Customize axes
xticks([1.5 3.5]);
xticklabels([]);
xlim([0.5 4.5])
ylim([-2 17]);
yticks('auto')
yticklabels({})

ax = gca; % Get current axes
ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
box on;


if count==1
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90,'FontSize',10);
   xticklabels({'I', 'S' });
   ylabel('%/K','FontName','Arial','fontsize',9);
   yticks([0 4 8 12 16]);
   yticklabels({'0','','8','','16'});
   legend({'','Model','','Station','','','','','',''},'FontName','Arial','fontsize',9);
   legend('boxoff');

elseif count==11
    text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90,'FontSize',9);
   xticklabels({'I', 'S' });
elseif count==20
    text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90,'FontSize',9);
    xticklabels({'I', 'S' });
elseif count==28
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90,'FontSize',9);
    xticklabels({'I', 'S' });
elseif count==35
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90,'FontSize',9);
    xticklabels({'I', 'S' });
elseif count==41
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90,'FontSize',9);
    xticklabels({'I', 'S' });
elseif count==46
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90,'FontSize',9);
    xticklabels({'I', 'S' });
elseif count==50
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90,'FontSize',9);
    xticklabels({'I', 'S' });
elseif count==53
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90,'FontSize',9);
    xticklabels({'I', 'S' });
elseif count==55
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90,'FontSize',9);
    xticklabels({'I', 'S' });
end
disp([num2str(period2(1)),' - ',num2str(period2(end))])
medianpairs=median(results_med,2)   % median among pairs
% incrate(count)=inc_w1./nanmedian(inc_MMM(:));
% shirate(count)=shift_w1./nanmedian(shi_MMM(:));
% obsincrease(count)=inc_w1;
% obsshift(count)=shift_w1;

    end
end

savefig('\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\figS4.fig');
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\figS4.png",...
    'Resolution', 600); % png fallback; 600 dpi is the ceiling before downsampling
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\figS4.pdf",...
    'ContentType','vector','BackgroundColor','white'); % .pdf vector is the preferred format

% % pdf version
% addpath(genpath('C:\Program Files\MATLAB\altmany-export_fig-d5538e9'));
% export_fig(gcf,'-eps', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Figs3.eps');
% export_fig(gcf,'-pdf', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Figs3.pdf');





% incrate_range(1,1)=prctile(incrate,2.5);
% incrate_range(1,2)=prctile(incrate,97.5);
% shirate_range(1,1)=prctile(shirate,2.5);
% shirate_range(1,2)=prctile(shirate,97.5);
% incrate_range
% shirate_range
% % observed increase mode value
% obsinc_range(1,1)=prctile(obsincrease,2.5);
% obsinc_range(1,2)=prctile(obsincrease,97.5)
% obsshi_range(1,1)=prctile(obsshift,2.5);
% obsshi_range(1,2)=prctile(obsshift,97.5)
