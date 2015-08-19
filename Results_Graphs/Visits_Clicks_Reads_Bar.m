clear all
close all
clc

file='Test_Data_Random10000.mat'
bar_title = 'Descending relevance ranking'


load(file);

total_clicks = sum(items_clicked_test);

percentage_clicks = total_clicks./sum(total_clicks);

total_reads = sum(items_read_test);

percentage_reads = total_reads./sum(total_reads);

mean_visits = mean(items_visited_test);
mean_reads = mean(items_read_test);
mean_clicks = mean(items_clicked_test);


total_visits = sum(items_visited_test);
percentage_visits = total_visits./sum(total_visits);

createfigure([mean_visits',mean_reads',mean_clicks'], bar_title);

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