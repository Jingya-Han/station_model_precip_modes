%% Supplementary Figure 4: The same as Fig. S2 but for a one-decade length for each epoch.
% 1 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
% load data
missrate=19; % set acceptable miss rate 
thelength=10;
%folder='/share/cliprelabs/jh2423/modesofchange_system/results_24-Oct-2024 12:06:31/';
startycount = 0; % count of start year, different start year corresponds to different number of end years
count = 0;
results_med=[];
figure;clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'Color','white'); 
set(gcf,'position',[1 1 18 16]); 
left=.17; down=.85; wid=.09; he=.07;
poss=nan(60,4); % 3rd: left down wid he for each subplot
for isub=1:60
    if isub<=6
       poss(isub,1)=left+(isub-1)*(wid+0.01); poss(isub,2)=down; poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=7 && isub<=12
       poss(isub,1)=left+(isub-6-1)*(wid+0.01); poss(isub,2)=down-1*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=13 && isub<=18
       poss(isub,1)=left+(isub-12-1)*(wid+0.01); poss(isub,2)=down-2*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=19 && isub<=24
       poss(isub,1)=left+(isub-18-1)*(wid+0.01); poss(isub,2)=down-3*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=25 && isub<=30
       poss(isub,1)=left+(isub-24-1)*(wid+0.01); poss(isub,2)=down-4*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=31 && isub<=36
       poss(isub,1)=left+(isub-30-1)*(wid+0.01); poss(isub,2)=down-5*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=37 && isub<=42
       poss(isub,1)=left+(isub-36-1)*(wid+0.01); poss(isub,2)=down-6*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=43 && isub<=48
       poss(isub,1)=left+(isub-42-1)*(wid+0.01); poss(isub,2)=down-7*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=49 && isub<=54
       poss(isub,1)=left+(isub-48-1)*(wid+0.01); poss(isub,2)=down-8*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;
    elseif isub>=55 && isub<=60
       poss(isub,1)=left+(isub-54-1)*(wid+0.01); poss(isub,2)=down-9*(he+0.01); poss(isub,3)=wid; poss(isub,4)=he;

    end

end

for startyear=1955:5:2000 % startyear: latest start year
    for endyear=1999:5:2024 % endyear: earliest end year
        if startyear+9 < endyear-9
            count=count+1;
        period1=startyear:(startyear+thelength-1);
        period2=(endyear-thelength+1):endyear;   
        
        varname=sprintf('UR_inc_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        inc_stations=ncread(['dataforplot/stations_uncertainty_ranges_19%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_shift_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        shi_stations=ncread(['dataforplot/stations_uncertainty_ranges_19%miss_',num2str(thelength),'yrs.nc'],varname);

        
        varname=sprintf('UR_inc_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        inc_MMM=ncread(['dataforplot/cmip6_uncertainty_range_19%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_shift_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        shi_MMM=ncread(['dataforplot/cmip6_uncertainty_range_19%miss_',num2str(thelength),'yrs.nc'],varname);

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

if count<=36
   s=subplot(10,6,count); s.Position=poss(count,:);
   if count<6
   title([num2str(period2(1)),' - ',num2str(period2(end))],'FontWeight','normal',...
       'FontName','Arial','FontSize',9);
   elseif count==6
   title([num2str(period2(1)),' - ',num2str(period2(end)-1)],'FontWeight','normal',...
       'FontName','Arial','FontSize',9);
   end
elseif count>36 && count<=41
       s=subplot(10,6,count+1); s.Position=poss(count+1,:);
elseif count>41 && count<=45
       s=subplot(10,6,count+3); s.Position=poss(count+3,:);
elseif count>45 && count<=48
       s=subplot(10,6,count+6); s.Position=poss(count+6,:);
elseif count>48 && count<=50
       s=subplot(10,6,count+10); s.Position=poss(count+10,:);

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
    patch([x-0.2, x+0.2, x+0.2, x-0.2], ... % x-coordinates for box
          [perc8(i), perc8(i), perc92(i), perc92(i)], ... % y-coordinates
          color, 'FaceAlpha', 0.8, 'EdgeColor', 'none'); % Box color and outline
    hold on;
    % Plot median line
    plot([x-0.2, x+0.2], [mediv(i), mediv(i)], 'k-', 'LineWidth', 0.7);
    hold on;
end

% Customize axes
xticks([1.5 3.5 5.5 7.5]);
xticklabels([]);
xlim([0.5 4.5])
% xticklabels({'I', 'a_o',  'S',  'b_o' });
ylim([-2 17]);
yticks('auto')
yticklabels({})
ax = gca; % Get current axes
ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
box on;


if count==1
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))]);
   yticks([0 4 8 12 16]);
   yticklabels({'0','','8','','16'});
   ax = gca; % Get current axes
   ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
   ylabel('%/K','FontName','Arial','FontSize',9);
elseif count==7
    text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))]);
   yticks([0 4 8 12 16]);
   yticklabels({'0','','8','','16'});
   ax = gca; % Get current axes
   ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
   ylabel('%/K','FontName','Arial','FontSize',9);
elseif count==13
    text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))]);
   yticks([0 4 8 12 16]);
   yticklabels({'0','','8','','16'});
   ax = gca; % Get current axes
   ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
   ylabel('%/K','FontName','Arial','FontSize',9);
elseif count==19
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))]);
   yticks([0 4 8 12 16]);
   yticklabels({'0','','8','','16'});
   ax = gca; % Get current axes
   ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
   ylabel('%/K','FontName','Arial','FontSize',9);
elseif count==25
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))]);
   yticks([0 4 8 12 16]);
   yticklabels({'0','','8','','16'});
   ax = gca; % Get current axes
   ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
   ylabel('%/K','FontName','Arial','FontSize',9);
elseif count==31
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))]);
   xticklabels({'I', 'S' });
   yticks([0 4 8 12 16]);
   yticklabels({'0','','8','','16'});
   ax = gca; % Get current axes
   ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
   ylabel('%/K','FontName','Arial','FontSize',9);
   legend({'','Model','','Station','','','','','',''},'FontName','Arial','FontSize',9);
   legend('boxoff');
elseif count==37
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))]);
   xticklabels({'I', 'S' });
   yticks([0 4 8 12 16]);
   yticklabels({'0','','8','','16'});
   ax = gca; % Get current axes
   ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
   ylabel('%/K','FontName','Arial','FontSize',9);

elseif count==42
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))]);
   xticklabels({'I', 'S' });
   yticks([0 4 8 12 16]);
   yticklabels({'0','','8','','16'});
   ax = gca; % Get current axes
   ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
   ylabel('%/K','FontName','Arial','FontSize',9);

elseif count==46
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))]);
   xticklabels({'I', 'S' });
   yticks([0 4 8 12 16]);
   yticklabels({'0','','8','','16'});
   ax = gca; % Get current axes
   ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
   ylabel('%/K','FontName','Arial','FontSize',9);

elseif count==49
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))]);
   xticklabels({'I', 'S' });
   yticks([0 4 8 12 16]);
   yticklabels({'0','','8','','16'});
   ax = gca; % Get current axes
   ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
   ylabel('%/K','FontName','Arial','FontSize',9);

end
disp([num2str(period2(1)),' - ',num2str(period2(end))])
medianpairs=median(results_med,2);   % median among pairs
i_incrate=medianpairs(2)./medianpairs(1) % rate of increase mode
i_shirate=medianpairs(4)./medianpairs(3) % rate of shift mode
% incrate(count)=inc_w1./nanmedian(inc_MMM(:));
% shirate(count)=shift_w1./nanmedian(shi_MMM(:));
        end
    end
end
% incrate_range(1,1)=prctile(incrate,2.5);
% incrate_range(1,2)=prctile(incrate,97.5);
% shirate_range(1,1)=prctile(shirate,2.5);
% shirate_range(1,2)=prctile(shirate,97.5);
% incrate_range
% shirate_range

savefig('/share/cliprelabs/jh2423/P1/figures/Figs5.fig');
exportgraphics(gcf,"/share/cliprelabs/jh2423/P1/figures/Figs5.png",...
    'Resolution', 300);
% % pdf version
% addpath(genpath('C:\Program Files\MATLAB\altmany-export_fig-d5538e9'));
% export_fig(gcf,'-eps', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Figs5.eps');
% export_fig(gcf,'-pdf', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Figs5.pdf');


