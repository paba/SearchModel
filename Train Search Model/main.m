clear;clc;

nitems=20; % the number of results displayed in a search page
%relevance distribution data
order = 3; %order =1 -> descending order of relevance, 
               %order = 2 -> statistical noisy/fuzzy ranking functions
               %order = 3 -> totally random relevance distribution

first_run=1; % 1 first run; 0 not firstrun
max_time = 60000; 
%set it to 60 seconds - as prposed by Antti
% max_time is the maximum amount of time allocated per 
                  %search task in milliseconds. For now we set it to 5
                  %minute which is = 300,000 ms

run_training(nitems,order,first_run,max_time)