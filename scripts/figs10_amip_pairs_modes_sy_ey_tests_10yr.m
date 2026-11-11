%% Supplementary Figure 7: Pairs of the global magnitude for Modes in AMIP6 and CMIP6. 
% 1 September 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
% Science Advances figure standards:
%   2-column width 18.4 cm; max depth 19.9 cm
%   all type 8 pt sans serif, 6 pt minimum
%   line weights >= 0.28 pt; SI units; variables in italics
fn  = 'Arial'; % sans serif equivalent of Myriad, accepted by the guidelines
fs  = 8;   % titles, row labels, legend, y labels
fsl = 7;   % tick labels in these small panels, still above the 6 pt minimum

% load data
missrate=19; % set acceptable miss rate (the filenames below hardcode 19%miss)
thelength=10;
folder='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';
count = 0;
results_med=[];
figure; clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'Color','white','Renderer','painters');
set(gcf,'position',[1 1 18.4 18.5]); % 2 columns wide, within the 19.9 cm depth
left=.095; down=.78; wid=.21; he=.17;
gapx=.008; gapy=.015;
poss=nan(16,4);
for ir=1:4
    for ic=1:4
        poss(4*(ir-1)+ic,:)=[left+(ic-1)*(wid+gapx) down-(ir-1)*(he+gapy) wid he];
    end
end

for startyear=1980:5:1995 % startyear: latest start year
    for endyear=1999:5:2014 % endyear: earliest end year
        if startyear+9 < endyear-9
            count=count+1;
        period1=startyear:(startyear+thelength-1);
        period2=(endyear-thelength+1):endyear;  
        
        % cmip6
        varname=sprintf('UR_inc_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        inc_stations=ncread([folder,'cmip6_uncertainty_range_20%miss_',num2str(thelength),'yrs.nc'],varname);

        varname=sprintf('UR_shift_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        shi_stations=ncread([folder,'cmip6_uncertainty_range_20%miss_',num2str(thelength),'yrs.nc'],varname);

        varname=sprintf('UR_a_o_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        ao_stations=ncread([folder,'cmip6_uncertainty_range_20%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_b_o_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        bo_stations=ncread([folder,'cmip6_uncertainty_range_20%miss_',num2str(thelength),'yrs.nc'],varname);
        
        % amip
        varname=sprintf('UR_inc_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        inc_MMM=ncread([folder,'amip_uncertainty_range_20%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_shift_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        shi_MMM=ncread([folder,'amip_uncertainty_range_20%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_a_o_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        ao_MMM=ncread([folder,'amip_uncertainty_range_20%miss_',num2str(thelength),'yrs.nc'],varname);
        
        varname=sprintf('UR_b_o_%d_%d_%d_%d',period1(1),period1(end),period2(1),period2(end));
        bo_MMM=ncread([folder,'amip_uncertainty_range_20%miss_',num2str(thelength),'yrs.nc'],varname);
                
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
   title([num2str(period2(1)),'-',num2str(period2(end))],'FontWeight','normal',...
       'FontName',fn,'FontSize',fs);
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
xlim([0.5 8.5]);
ylim([-5 30])
yticks('auto')
yticklabels({})
ax = gca; % Get current axes
ax.FontName = fn;
ax.YAxis.FontSize = fsl; % Set the font size for the y-axis tick labels
ax.XAxis.FontSize = fsl;
box on;

if count==1
   text(-0.22,0.5,[num2str(period1(1)),'-',num2str(period1(end))],'Units','normalized',...
       'Rotation',90,'HorizontalAlignment','center','FontName',fn,'FontSize',fs);
   xticklabels({'\itI', '\ita_o', '\itS', '\itb_o'});
   yticks('auto')
   yticklabels('auto')
   ylabel('% K^-^1','FontName',fn,'FontSize',fs);
   legend({'','AMIP','','CMIP6','','','','','','','','','','','','',''},'FontName',fn,'FontSize',fs);
   legend('boxoff')
elseif count==5
    text(-0.22,0.5,[num2str(period1(1)),'-',num2str(period1(end))],'Units','normalized',...
       'Rotation',90,'HorizontalAlignment','center','FontName',fn,'FontSize',fs);
   xticklabels({'\itI', '\ita_o', '\itS', '\itb_o'});
   yticks('auto')
   yticklabels('auto')
   ylabel('% K^-^1','FontName',fn,'FontSize',fs);
elseif count==8
    text(-0.22,0.5,[num2str(period1(1)),'-',num2str(period1(end))],'Units','normalized',...
       'Rotation',90,'HorizontalAlignment','center','FontName',fn,'FontSize',fs);
   xticklabels({'\itI', '\ita_o', '\itS', '\itb_o'});
   yticks('auto')
   yticklabels('auto')
   ylabel('% K^-^1','FontName',fn,'FontSize',fs);
elseif count==10
   text(-0.22,0.5,[num2str(period1(1)),'-',num2str(period1(end))],'Units','normalized',...
       'Rotation',90,'HorizontalAlignment','center','FontName',fn,'FontSize',fs);
   xticklabels({'\itI', '\ita_o', '\itS', '\itb_o'});
   yticks('auto')
   yticklabels('auto')
   ylabel('% K^-^1','FontName',fn,'FontSize',fs);
end

        end
    end
end


% median(results_med,2)   % median among pairs

savefig('\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\figS7.fig');
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\figS7.pdf",...
    'ContentType','vector','BackgroundColor','white'); % .pdf vector is the preferred format
exportgraphics(gcf,"\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\figS7.png",...
    'Resolution', 600); % png fallback; 600 dpi is the ceiling before downsampling

% % pdf version
% addpath(genpath('C:\Program Files\MATLAB\altmany-export_fig-d5538e9'));
% export_fig(gcf,'-eps', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Figs6.eps');
% export_fig(gcf,'-pdf', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Figs6.pdf');