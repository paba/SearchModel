clear all
close all
clc

file1='Test_Data_1min_v4_Memory_Noisy_10000.mat';
file2='Test_Data_1min_v4_Memory_Descending_10000.mat';

bar_title1 = 'Mean visits';
bar_title2 = 'Mean reads';
bar_title3 = 'Mean clicks';

ntrials = 10000;

load(file1);

% total_clicks_noisy = sum(items_clicked_test);
mean_clicks_noisy = mean(items_clicked_test);
%percentage_clicks_noisy = total_clicks_noisy./sum(total_clicks_noisy);
% percentage_clicks_noisy = total_clicks_noisy./ntrials;

% total_reads_noisy = sum(items_read_test);
mean_reads_noisy = mean(items_read_test);
%percentage_reads_noisy = total_reads_noisy./sum(total_reads_noisy);
% percentage_reads_noisy = total_reads_noisy./ntrials;

% total_visits_noisy = sum(items_visited_test);
mean_visits_noisy = mean(items_visited_test);
%percentage_visits = total_visits_noisy./sum(total_visits_noisy);
% percentage_visits_noisy = total_visits_noisy./ntrials;

clear 'items_clicked_test';
clear 'items_read_test';
clear 'items_visited_test';
clear 'QT';
clear 'QTableEnterMap';

load(file2);

% total_clicks_descending = sum(items_clicked_test);
mean_clicks_descending = mean(items_clicked_test);
%percentage_clicks_noisy = total_clicks_noisy./sum(total_clicks_noisy);
% percentage_clicks_decending = total_clicks_descending./ntrials;

% total_reads_descending = sum(items_read_test);
mean_reads_descending = mean(items_read_test);
%percentage_reads_noisy = total_reads_noisy./sum(total_reads_noisy);
% percentage_reads_descending = total_reads_descending./ntrials;

% total_visits_descending = sum(items_visited_test);
% %percentage_visits = total_visits_noisy./sum(total_visits_noisy);
% percentage_visits_descending = total_visits_descending./ntrials;

mean_visits_descending = mean(items_visited_test);
% mean_reads = mean(items_read_test);
% mean_clicks = mean(items_clicked_test);

clear 'items_clicked_test';
clear 'items_read_test';
clear 'items_visited_test';
clear 'QT';
clear 'QTableEnterMap';

xdata = 1:20;
clicks = [mean_clicks_descending',mean_clicks_noisy'];
visits = [mean_visits_descending',mean_visits_noisy'];
reads = [mean_reads_descending',mean_reads_noisy'];


%createfigure([mean_visits',mean_reads',mean_clicks'], bar_title);
% ax1 = subplot(2,2,1);
% bar(ax1,[mean_visits_descending',mean_visits_noisy'] )
createfigure2([mean_visits_descending',mean_visits_noisy'], bar_title1,'descending','noisy')

hold on
% 
% ax2 = subplot(2,2,2);
% bar(ax2,[mean_reads_descending',mean_reads_noisy'])

hold on
createfigure2([mean_reads_descending',mean_reads_noisy'], bar_title2,'descending','noisy')
% 
% subplot(2,2,3)
hold on
createfigure2([mean_clicks_descending',mean_clicks_noisy'], bar_title3,'descending','noisy')

% x = 1:20;
% 
% % plot the results
% fig = figure('Color','w');
% 
% %h = bar(x,[percentage_clicks',percentage_visits',percentage_reads'],'grouped');
% h = bar(x,[mean_visits',mean_reads',mean_clicks'],'grouped');
% ax = get(gca);
% cat = ax.Children;
% 
% 
% l{1} = 'visits';
% l{2} = 'reads';
% l{3} = 'clicks';
% 
% legend(h,l);
% %title(bar_title);
% 
% 
% %set the first bar chart style
% set(cat(2),'FaceColor',[145 25 206]/255,'BarWidth',1);
% 
% %set the second bar chart style
% set(cat(1),'FaceColor',[45 125 206]/255,'BarWidth',1);
% 
% %set the second bar chart style
% set(cat(3),'FaceColor',[100 100 206]/255,'BarWidth',1);
% 
% %set the axes style
% set(gca,'box','off');
% 
% %set(gca, 'xlabel',title);