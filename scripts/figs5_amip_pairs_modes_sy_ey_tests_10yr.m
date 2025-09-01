%% Supplementary Figure 5: Pairs of the global magnitude for Modes in AMIP6 and CMIP6. 
% 1 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
% load data
missrate=19; % set acceptable miss rate 
thelength=10;
% folder='/share/cliprelabs/jh2423/modesofchange_system/results_24-Oct-2024 12:06:31/';
count = 0;
results_med=[];
figure; clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'Color','white'); 
set(gcf,'position',[1 1 18 20]);
left=.1; down=.8; wid=.16; he=.15;
poss=[left down wid he;
    left+wid+.01 down wid he;
    left+2*(wid+.01) down wid he;
    left+3*(wid+.01) down wid he;
    left down-(he+0.01) wid he;
    left+wid+.01 down-(he+0.01) wid he;
    left+2*(wid+.01) down-(he+0.01) wid he;
    left+3*(wid+.01) down-(he+0.01) wid he;
    left down-2*(he+0.01) wid he;
    left+wid+.01 down-2*(he+0.01) wid he;
    left+2*(wid+.01) down-2*(he+0.01) wid he;
    left+3*(wid+.01) down-2*(he+0.01) wid he;
    left down-3*(he+0.01) wid he;
    left+wid+.01 down-3*(he+0.01) wid he;
    left+2*(wid+.01) down-3*(he+0.01) wid he;
    left+3*(wid+.01) down-3*(he+0.01) wid he;]

for startyear=1980:5:1995 % startyear: latest start year
    for endyear=1999:5:2014 % endyear: earliest end year
        if startyear+9 < endyear-9
            count=count+1;
        period1=startyear:(startyear+thelength-1);
        period2=(endyear-thelength+1):endyear;  
        
        % cmip6
        varname=sprintf('UR_inc_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        inc_stations=ncread(['dataforplot/cmip6_uncertainty_range_19%miss_',num2str(thelength),'yrs.nc'],varname);

        varname=sprintf('UR_shift_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        shi_stations=ncread(['dataforplot/cmip6_uncertainty_range_19%miss_',num2str(thelength),'yrs.nc'],varname);

        varname=sprintf('UR_a_o_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        ao_stations=ncread(['dataforplot/cmip6_uncertainty_range_19%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_b_o_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        bo_stations=ncread(['dataforplot/cmip6_uncertainty_range_19%miss_',num2str(thelength),'yrs.nc'],varname);
        
        % amip
        varname=sprintf('UR_inc_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        inc_MMM=ncread(['dataforplot/amip_uncertainty_range_19%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_shift_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        shi_MMM=ncread(['dataforplot/amip_uncertainty_range_19%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_a_o_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        ao_MMM=ncread(['dataforplot/amip_uncertainty_range_19%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_b_o_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        bo_MMM=ncread(['dataforplot/amip_uncertainty_range_19%miss_',num2str(thelength),'yrs.nc'],varname);
                
        % Combine data into a single vector
        data = [ao_stations(:); ao_MMM(:); inc_stations(:); inc_MMM(:); ...
        bo_stations(:); bo_MMM(:);shi_stations(:); shi_MMM(:)];

        % Create grouping variables
        grouping1 = [repmat({'a_o'}, length(ao_stations), 1); ...
             repmat({'a_o'}, length(ao_MMM), 1);...
             repmat({'Increase'}, length(inc_stations), 1); ...
             repmat({'Increase'}, length(inc_MMM), 1); ...
             repmat({'b_o'}, length(bo_stations), 1); ...
             repmat({'b_o'}, length(bo_MMM), 1); ...
             repmat({'Shift'}, length(shi_stations), 1); ...
             repmat({'Shift'}, length(shi_MMM), 1);
             ];

grouping2 = [repmat({'Stations'}, length(ao_stations), 1); ...
             repmat({'Models'}, length(ao_MMM), 1);...
             repmat({'Stations'}, length(inc_stations), 1); ...
             repmat({'Models'}, length(inc_MMM), 1); ...
             repmat({'Stations'}, length(bo_stations), 1); ...
             repmat({'Models'}, length(bo_MMM), 1); ...
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
perc8=[percentile8(1:2,:); percentile8(5:6,:); percentile8(3:4,:); percentile8(7:8,:)];
perc92=[percentile92(1:2,:); percentile92(5:6,:); percentile92(3:4,:); percentile92(7:8,:)];
mediv=[medianVals(1:2,:); medianVals(5:6,:); medianVals(3:4,:); medianVals(7:8,:)];

%median values for each pair
results_med(:,count)=mediv;

if count<=4
   s=subplot(4,4,count); s.Position=poss(count,:);
   title([num2str(period2(1)),' - ',num2str(period2(end))],'FontWeight','normal',...
       'FontName','Arial','FontSize',9);
elseif count>4 && count<=7
       s=subplot(4,4,count+1); s.Position=poss(count+1,:);
elseif count>7 && count<=9
       s=subplot(4,4,count+3); s.Position=poss(count+3,:);
elseif count>9 && count<=10
       s=subplot(4,4,16); s.Position=poss(16,:);
end
% Customize colors for stations and models
stationcolor=[50 205 50]/255;
MMMcolor=[255 140 0]/255;
yline(0, '-', 'Color',[0.6 0.6 0.6],'LineWidth', 0.5); % '--' for dashed line, adjust LineWidth as needed

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
    patch([x-0.15, x+0.15, x+0.15, x-0.15], ... % x-coordinates for box
          [perc8(i), perc8(i), perc92(i), perc92(i)], ... % y-coordinates
          color, 'FaceAlpha', 0.8, 'EdgeColor', 'none'); % Box color and outline
hold on;
    % Plot median line
    plot([x-0.15, x+0.15], [mediv(i), mediv(i)], 'k-', 'LineWidth', 0.7);
end

% Customize axes
xticks([1.5 3.5 5.5 7.5]);
xticklabels([]);
xlim([0 10]);
ylim([-5 30])
yticks('auto')
yticklabels({})
ax = gca; % Get current axes
ax.YAxis.FontSize = 7; % Set the font size for the y-axis tick labels
box on;

if count==1
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90);
   xticklabels({'I', '\ita_o',  'S',  '\itb_o' });
   yticks('auto')
   yticklabels('auto')
   ylabel('%/K','FontName','Arial','FontSize',9);
   legend({'','AMIP','','CMIP6','','','','','','','','','','','','',''},'FontName','Arial','FontSize',9);
   legend('boxoff')
elseif count==5
    text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90);
   xticklabels({'I', '\ita_o',  'S',  '\itb_o' });
   yticks('auto')
   yticklabels('auto')
   ylabel('%/K','FontName','Arial','FontSize',9);
elseif count==8
    text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90);
   xticklabels({'I', '\ita_o',  'S',  '\itb_o' });
   yticks('auto')
   yticklabels('auto')
   ylabel('%/K','FontName','Arial','FontSize',9);
elseif count==10
   text(s.Position(1)-0.4,s.Position(2),[num2str(period1(1)),' - ',num2str(period1(end))],'Rotation',90);
   xticklabels({'I', '\ita_o',  'S',  '\itb_o' });
   yticks('auto')
   yticklabels('auto')
   ylabel('%/K','FontName','Arial','FontSize',9);
end

        end
    end
end


median(results_med,2)   % median among pairs

% savefig('/share/cliprelabs/jh2423/modesofchange_system/results_01-Feb-2025 15:39:58/figs_19%miss_19551984_19942023/v2/Figs5.fig');
% exportgraphics(gcf,"/share/cliprelabs/jh2423/modesofchange_system/results_01-Feb-2025 15:39:58/figs_19%miss_19551984_19942023/v2/Figs5.png",...
%     'Resolution', 300);



