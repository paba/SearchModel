%% for Q-learning
start_location=0;

% this value add additional cost for visiting the same item again and again
%visit_penalize = 100;
visit_penalize = 0;
%% directly copeied from menu model.
alpha = 1e-1; % <-learning rate, or the step size
gamma = 1;    % <- take this as an undiscounted task  <- for the epsilon greedy policy 
max_steps=20;
readingReward=10000; %reward for reading
openingReward = 20000; %reward for opening
Reward=[readingReward,openingReward];
average_reading_time = 300 ; %average reading speed = 200 wpm = 0.3 s/word
                              %0.3s = 300ms
                              %according to http://www.readingsoft.com/
average_opening_time = 7000;%300 ms/fixation * 2 fixations/row * 10 rows + 1000 ms
                            %    loading time
                            %300*150; %let's assume that the user reads the entire
                            %abstract which is 150 words after opening it
average_fixation_time =300; %TODO:find more realistic time

prob_opening = 0.8; %Following Blackmon et al. 2007, 
                    %all those search engine results that have a semantic 
                    %similarity of 0.8 times the maximum semantic similarity 
                    %are considered predicted clicks by the CoLiDeS model.
                    
prob_reading = 0.7; %taking insights from prob_opening
% for Q_table
qt_block_size =10000; 

%from each state there are n+2 actions (just like in menu model)
%including n actions for visiting an item from n result list items, 
%visitng is similar to fixating or glancing at that item
%an action for reading the visited item, and an action for
%selecting/clicking on the url of that item for reading the visited item.
%terminating condition is expiration of time

max_title_length = 15;
min_title_length = 5;
grid_levels_title = 4; % 1, 2, 3, 4

min_querywords = 0;
max_querywords = 6;
grid_levels_query = 3; % 0, 1, 2
max_action_record = 20;

n_actions=nitems+2;


if first_run==1
    Qtable_size=1e5; % initlal size of Q-table
    % if there is no enough space left in prelocated table, adding a new block.   
    listPtr = 1; 
    QT=zeros(Qtable_size,n_actions); 
    % hash table 
    QTableEnterMap = containers.Map;
    nEncountedStates=0;
else
    % for Q_table
    nEncountedStates=size(QTableEnterMap,1);
    listPtr=size(QTableEnterMap,1);
    Qtable_size=size(QT,1); % initlal size of Q-table
% if there is no enough space left in prelocated table, adding a new block.
    alpha = 0;
%this is to record the interaction path, only when testing
    action_path = zeros(ntrials,max_action_record);
end

%%initialize the items clicked,read, and visited
items_clicked_test = zeros(ntrials,nitems);
items_read_test = zeros(ntrials,nitems);
items_visited_test = zeros(ntrials,nitems);



%% for recording the data
% only record learning variable every 10000 trial
%Paba - Not sure exactly what is meant by recording data -> does it mean
%writing them to the q-table ?? or recording the time spent after every
%10000 trials??

% record_unit=10000;
% n_steps_unit=zeros(1,record_unit); %creates a column array of 10000...
% %columns and value 0. [00000 ....00(10000th item)]
% correct_unit=zeros(1,record_unit);
% TimeSpent_unit=zeros(1,record_unit);
count1=1;

% if first_run==1
%     all_steps=zeros(ntrials/record_unit,1);
%     all_timespent=zeros(ntrials/record_unit,1);
%     all_accuracy=zeros(ntrials/record_unit,1);
%     count2=1;
% else
%     all_steps_new=zeros(ntrials/record_unit,1);
%     all_timespent_new=zeros(ntrials/record_unit,1);
%     all_accuracy_new=zeros(ntrials/record_unit,1);
%     
%     n=size(find(all_steps>0),1);
%     all_steps=all_steps(1:n,1);
%     all_timespent=all_timespent(1:n,1);
%     all_accuracy=all_accuracy(1:n,1);
%     
%     all_steps=cat(1,all_steps,all_steps_new);
%     all_timespent=cat(1,all_timespent,all_timespent_new);
%     all_accuracy=cat(1,all_accuracy,all_accuracy_new);
%       
%     
%     count2=n+1;
% end

result_index=1;
ImmediateReward=0;

items_visited = zeros(1,nitems);
items_read = zeros(1,nitems);
items_clicked = zeros(1,nitems);
four_read_or_clicked = zeros(1,nitems);
four_focused = zeros(1,4);
relevance_read_or_clicked = zeros(1,nitems);
read_or_clicked = zeros(1,nitems);
    

%% grid all the 3 state vectors : 1. title_length_list, 2. QueryWordVisit, ...
%3. QueryWordRead
title_length_list = gridding...
    (min_title_length,max_title_length,grid_levels_title,title_length_list);
QueryWordVisit = ...
    gridding(min_querywords,max_querywords,grid_levels_query,QueryWordVisit);
QueryWordRead = ...
    gridding(min_querywords,max_querywords,grid_levels_query,QueryWordRead);

%% Begin the real training
for trial=1: ntrials
   

    %Relevance
    ResultListRelevance = ResultLibrary(result_index,:) ;
    
    %State features
    rank = [1:nitems]; %rank of items
    title_length = title_length_list(result_index,:); %title length
    query_words_visit = QueryWordVisit(result_index,:);% frequency of query words for visits
    query_words_read = QueryWordRead(result_index,:); %frequency of query words for reading
    
    result_index = result_index +1 ; 
    
    if result_index>size(ResultLibrary,1)
        result_index=1;
    end
    
%     current_list=[query_words_visit', title_length',...
%        items_visited_test(result_index,:)',...
%        items_read_test(result_index,:)', items_clicked_test(result_index,:)' ];
    
%     current_list=[items_visited_test(result_index,:)',...
%        items_read_test(result_index,:)', items_clicked_test(result_index,:)' ];

    %current_list=[items_read_test(result_index,:)', items_clicked_test(result_index,:)' ];
    current_list=[four_read_or_clicked'];
    
    %rank = NaN; 
    
    %calculate the reward for opening
    max_relevance = max(ResultListRelevance);
    %Reward(1,2) = round(average_opening_time/(prob_opening*max_relevance));
    
    
    
    % start a trial
    TimeSpent=100;
    responsed=0;
    correct=0;
    n_steps=0;
    focus=start_location;
    current_item_query_words = NaN;
    current_item_title_length = NaN;
    
    inital_state=NaN(size(current_list(:)));
    
    %state1=[inital_state;rank;]';
    state1=[inital_state;focus;current_item_query_words;current_item_title_length]';
    
    state_string=num2str(state1);
    
    if QTableEnterMap.isKey(state_string)
        state_row= QTableEnterMap(state_string);        
    else
        nEncountedStates=nEncountedStates+1;
        listPtr=listPtr+1;
        QTableEnterMap(state_string) = nEncountedStates;
        state_row=nEncountedStates;
    end
    
    items_visited(1,:) = 0;
    items_read(1,:) = 0;
    items_clicked(1,:) = 0;
    four_read_or_clicked(1,:) = 0;
    relevance_read_or_clicked(1,:) = 0;
    read_or_clicked(1,:) = 0 ; 
    four_focused(1,:) = 0;

    temp_memory = zeros(1,nitems);
    first_read_or_clicked = 0;
    last_read_or_clicked = 0;
    %% begin q-learning
    %while(n_steps<max_steps && TimeSpent<max_time)
    while(TimeSpent<max_time)

     temp_memory(1,:) = 0;
             
     %initializing state features, initially no information is available
     %therefore initialize to NaN
%      available_title_length = NaN(1,nitems);
%      available_query_words = NaN(1,nitems);
     available_title_length = current_item_title_length;
     available_query_words = current_item_query_words;
     
     if n_steps==0
         if order == 1
            action_chosen=1;%if this is the first step, select action 1, ...
            %action1 = visit/fixate on result item 1.
         elseif order == 2
             action_chosen = 1;%randi([1 3],1);
         elseif order == 3
             action_chosen = 1;%randi([1 nitems],1);
         end
     else
            [temp]=find(QT(state_row,:)==max(QT(state_row,:)));
            %logic: find all the actions that have the highest value. 
            %If there are several actions with the same highest value, 
            %then choose one of them randomly.
            action_chosen=temp(randi(size(temp,2)));
            if( rand<epsilon ) % explore with a random action
                %epsilon is defined in run_training.m, and the random complex
                %number generated by rand is defining the epsilon greedy policy. 
                %If the random value is less than the epsilon value then pick an action
                %randomly. This is where the exploration part comes from
                action_chosen=randi(n_actions);
            end
            
     end
     
     
      
       %STEP 2, take action chosen, observe rewards ,and s'.
       % check the item fixated,if the actions are to either read an item 
       %or open and item
       %reward function = 10000xrelevantxreading + 20000xrelevantxopening -
       %time spent
       %reading = 1 if action is reading the focused item
       %opening = 1 if action is opening the focused item
       %action_chosen
       if action_chosen>nitems 
         last_read_or_clicked = focus;
         if first_read_or_clicked == 0
            first_read_or_clicked = focus;
         end
        if action_chosen==nitems+1 %action = read the focused/visited item
%              Reward(1,1) = ...
%                  round(average_reading_time*title_length(focus)/(prob_reading*max_relevance));
%              ImmediateReward=Reward(1,1)*ResultListRelevance(focus);
             
             ImmediateReward = Reward(1,1)*ResultListRelevance(focus);
             Duration = average_reading_time*title_length(focus);
             
             %items_read(1,focus) = 1;
             items_read_test(trial,focus) = items_read_test(trial,focus)+ 1;
             items_read(1,focus) = 1;
             available_query_words = query_words_read(focus);

             
        elseif action_chosen==nitems+2 %action = open the focused/visited item
             ImmediateReward=Reward(1,2)*ResultListRelevance(focus);
             Duration = average_opening_time;
             
             %items_opened(1,focus) = 1;
             items_clicked_test(trial,focus) = items_clicked_test(trial,focus)+ 1;
             available_query_words = query_words_read(focus);
             items_clicked(1,focus) = 1;

        end
       else %i.e. the action is just to visit/fixate on an item
           ImmediateReward= 0; %just focus on the item = no reward
           Duration = average_fixation_time; %fixation time
           
           focus=action_chosen;
           %items_visited(1,focus) = 1;
                    
           available_query_words = query_words_visit(focus);
           items_visited_test(trial,focus) = items_visited_test(trial,focus)+1;
           items_visited(1,focus) = 1;
           
            
       end
       
       %pos = mod(n_steps,3);
       four_focused(1,1) = first_read_or_clicked;
       four_focused(1,2) = last_read_or_clicked;
       read_or_clicked = or(items_clicked,items_read);
       if first_read_or_clicked ~= 0 && (action_chosen > nitems)
           relevance_read_or_clicked = ...
           ResultListRelevance.*read_or_clicked;
           %make the first read or focused item and the last read or focused
           %item zero to consider only the inbetween ones
           relevance_read_or_clicked(1,four_focused(1,1)) = 0;
           relevance_read_or_clicked(1,four_focused(1,2)) = 0;
           %mean_rel_read_or_clicked = ...
            %   mean(relevance_read_or_clicked(relevance_read_or_clicked~=0));
           
           max_val = max(relevance_read_or_clicked);
           if max_val~=0
             four_focused(1,3) = find(relevance_read_or_clicked==max_val);
           end
           
           val = relevance_read_or_clicked(relevance_read_or_clicked~=0);
           if ~isnan(val) 
            four_focused(1,4) = find(relevance_read_or_clicked==min(val));
           end

           
%            if ~isnan(mean_rel_read_or_clicked)
%            
%                temp = relevance_read_or_clicked>=mean_rel_read_or_clicked;
%                max_ids = ...
%                    find(relevance_read_or_clicked == max(relevance_read_or_clicked(temp)));
%                four_focused(1,3) = max_ids(1);
% 
%                temp = ...
%                    find(relevance_read_or_clicked(relevance_read_or_clicked~=0)<mean_rel_read_or_clicked);
%                if ~isempty(temp)
%                    min_ids = find(...
%                        relevance_read_or_clicked == min(relevance_read_or_clicked(temp)));
%                    four_focused(1,4) = min_ids(1);
%                end 
%            
%            end
       end
       
       
     %mark the position of last three focused items 1
%      for x = 1: 3
%          has_visited = four_focused(1,x);
%          if has_visited
%             temp_focus(1,has_visited) = 1;
%          end
%      end

       for x = 1:4
           memory = four_focused(1,x); 
           if memory
                temp_memory(1,memory) = 1;
           end
       end
         
        
      n_steps=n_steps+1;
      
       
       
       available_title_length = title_length(focus);
       TimeSpent=TimeSpent+Duration;
       
       %make 3 items before the focus visible
       
       
      
       
        % STEP 2.2, take action chosen, observe s'.
        
%        if action_chosen<nitems+1 % is to fixate on next new location
%           focus=action_chosen;
%           items_visited(1,focus) = 1;
%           available_title_length(focus) = title_length(focus);           
%        elseif action_chosen == nitems+1
%            items_read(1,focus) = 1;
%            
%        elseif action_chosen == nitems+2
%            items_opened(1,focus) = 1;
%           
%        end
%         visited = find(items_visited==1);
%         read = find(items_read==1);
%         opened = find(items_opened==1);
%         
%         if opened
%             items_clicked_test(trial,opened) = items_clicked_test(trial,opened)+ 1;
%         end
%         if read
%             items_read_test(trial,read) = items_read_test(trial,read)+ 1;
%         end
%         if visited
%             items_visited_test(trial,visited) = items_visited_test(trial,visited)+1;
%         end
        
%         available_title_length(visited) = title_length(visited);
%         %available_query_words_visiting(visited) = query_words_visit(visited);
%         %available_query_words_reading(read) = query_words_read(read);
%         available_query_words(visited) = query_words_visit(visited);
%         available_query_words(read) = query_words_read(read);
%         % assume that even when you open you see the same query words
%         available_query_words(opened) = query_words_read(opened);
        
        
        
        %temp1= [available_query_words_visiting,available_query_words_reading,...
        %    available_title_length];
        %temp1= [available_query_words,available_title_length];
        %upudated the state vector to include the count of items visited,
        %items clicked, and items read
        %temp1= [items_visited_test(trial,:),items_read_test(trial,:),items_clicked_test(trial,:)];
        %temp1= [items_visited,items_read,items_clicked];
        %temp1= [and(items_read,temp_focus),and(items_clicked,temp_focus)];

        temp1= [and(read_or_clicked,temp_memory)];

        state1=[temp1,focus,available_query_words,available_title_length];
        
        state_string=num2str(state1);
        
        if QTableEnterMap.isKey(state_string)
            new_state_row= QTableEnterMap(state_string);        
        else
            nEncountedStates=nEncountedStates+1;
            listPtr=listPtr+1;
            QTableEnterMap(state_string) = nEncountedStates;
            new_state_row=nEncountedStates;
        end
        
        %% update the immediate reward considering the number of previous 
        %%visits, reads, and clicks
        if action_chosen>nitems 
            if action_chosen==nitems+1 %action = read the focused/visited item
               nreads = items_read_test(trial,focus);
               %ImmediateReward= ImmediateReward/(2^(nreads-1));
               if nreads > 1
                   ImmediateReward = 0;
               end
            elseif action_chosen==nitems+2 %action = open the focused/visited item
               nclicks = items_clicked_test(trial,focus);
               %ImmediateReward = ImmediateReward/(2^(nclicks-1));
               if nclicks > 1
                   ImmediateReward = 0;
               end
            end
        else %i.e. the action is just to visit/fixate on an item
            nvisits = items_visited_test(trial,focus);
            %add an additional cost to penalize immediate reward
            ImmediateReward = ImmediateReward - visit_penalize*(nvisits-1);
            
        end
                
       ImmediateReward= ImmediateReward - Duration;
        
        
        
        
        %% Q-table Update
        QT(state_row,action_chosen) = ...
        QT(state_row,action_chosen) + alpha*( ImmediateReward + gamma  *   max(QT(new_state_row,:)) - QT(state_row,action_chosen) ); 
        %equation 6.6 in the book
        % s=s'
        state_row = new_state_row;

        
        %% add new block of memory if needed
        if( listPtr+(qt_block_size/10) > Qtable_size)% less than 10%*qt_block_size free slots
            Qtable_size= Qtable_size+ qt_block_size; % add new qt_block_size slots
            QT(listPtr+1:Qtable_size,:) = 0;
        end
        
        if n_steps <= max_action_record && first_run == 0
            action_path(trial,n_steps) = action_chosen;
        end
        
        
    end
    %1e5
    
    if first_run == 1
        if mod(trial,2e5)==0
            filename = strcat('Data2_1min_v4_Memory_',...
                    ranking_type,'_',num2str(trial));
            save([filename '.mat'],'QT','QTableEnterMap');
        end
        if mod(trial,5000)==0
            trial
        end
    else
        trial
        
     
        
        if mod(trial,ntrials)==0
            filename = strcat('Test2_Data_1min_v4_Memory_',...
                                ranking_type,'_',num2str(trial));
            save([filename '.mat'],...
               'QT','QTableEnterMap','items_clicked_test',...
               'items_read_test','items_visited_test','action_path');
        end
    end
    
end


