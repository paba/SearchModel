clear;clc;
file1 = 'Test_Data_1min_v4_Memory_Noisy_10000.mat';
file2 = 'Test_Data_1min_v4_Memory_Descending_10000.mat';
load(file1);

noisy_action_path = action_path;
clear action_path;

load(file2);
descending_action_path = action_path;
clear action_path;

[ntrials nactions] = size(noisy_action_path)
noisy_visits_before_first_click = zeros(ntrials,1);
noisy_reads_before_first_click = zeros(ntrials,1);
descending_visits_before_first_click = zeros(ntrials,1);
descending_reads_before_first_click = zeros(ntrials,1);
noisy_visits_before_first_read = zeros(ntrials,1);
descending_visits_before_first_read = zeros(ntrials,1);

for trial = 1 : ntrials
        trial
        for action = 1 : nactions
           if noisy_action_path(trial,action) == 21
               break
           else
               noisy_visits_before_first_read(trial,1) = ...
                   noisy_visits_before_first_read(trial,1) +1 ;
           end
        
        end
        
        for action = 1 : nactions
           if descending_action_path(trial,action) == 21
               break
           else
               descending_visits_before_first_read(trial,1) = ...
                   descending_visits_before_first_read(trial,1) +1 ;
           end
        
        end
end

for trial = 1 : ntrials
        trial
        for action = 1 : nactions
           if noisy_action_path(trial,action) == 22 
               break
           else
               if noisy_action_path(trial,action) ~= 21
                   noisy_visits_before_first_click(trial,1) = ...
                       noisy_visits_before_first_click(trial,1) +1 ;
               elseif noisy_action_path(trial,action) == 21
                       noisy_reads_before_first_click(trial,1) = ...
                           noisy_reads_before_first_click(trial,1) + 1;
               end
           end
        
        end
        for action = 1 : nactions
           if descending_action_path(trial,action) == 22
               break
           else
               if descending_action_path(trial,action) ~= 21
                   descending_visits_before_first_click(trial,1) = ...
                   descending_visits_before_first_click(trial,1) +1 ;
               elseif descending_action_path(trial,action) == 21
                    descending_reads_before_first_click(trial,1) = ...
                        descending_reads_before_first_click(trial,1)+1;
               end
           end
        
        end
end
