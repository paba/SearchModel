%% for Q-learning
start_location=0;

%% directly copeied from menu model.
alpha = 1e-1; % <-learning rate, or the step size
gamma = 1;    % <- take this as an undiscounted task  <- for the epsilon greedy policy 
max_steps=200;
readingReward=10000; %reward for reading
openingReward = 20000; %reward for opening
Reward=[readingReward,openingReward];
average_reading_time = 300 ; %average reading speed = 200 wpm = 0.3 s/word
                              %0.3s = 300ms
                              %according to http://www.readingsoft.com/
average_opening_time = 300*150; %let's assume that the user reads the entire
                                %abstract which is 150 words after opening it
average_fixation_time =300; %TODO:find more realistic time
% for Q_table
qt_block_size =10000; 

%from each state there are n+2 actions (just like in menu model)
%including n actions for visiting an item from n result list items, 
%visitng is similar to fixating or glancing at that item
%an action for reading the visited item, and an action for
%selecting/clicking on the url of that item for reading the visited item.
%terminating condition is expiration of time

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
end

%% for recording the data
% only record learning variable every 10000 trial
%Paba - Not sure exactly what is meant by recording data -> does it mean
%writing them to the q-table ?? or recording the time spent after every
%10000 trials??

record_unit=10000;
n_steps_unit=zeros(1,record_unit); %creates a column array of 10000...
%columns and value 0. [00000 ....00(10000th item)]
correct_unit=zeros(1,record_unit);
TimeSpent_unit=zeros(1,record_unit);
count1=1;

if first_run==1
    all_steps=zeros(ntrials/record_unit,1);
    all_timespent=zeros(ntrials/record_unit,1);
    all_accuracy=zeros(ntrials/record_unit,1);
    count2=1;
else
    all_steps_new=zeros(ntrials/record_unit,1);
    all_timespent_new=zeros(ntrials/record_unit,1);
    all_accuracy_new=zeros(ntrials/record_unit,1);
    
    n=size(find(all_steps>0),1);
    all_steps=all_steps(1:n,1);
    all_timespent=all_timespent(1:n,1);
    all_accuracy=all_accuracy(1:n,1);
    
    all_steps=cat(1,all_steps,all_steps_new);
    all_timespent=cat(1,all_timespent,all_timespent_new);
    all_accuracy=cat(1,all_accuracy,all_accuracy_new);
    
    count2=n+1;
end

result_index=1;
%% Begin the real training
for trial=1: ntrials
    trial
    
    %Relevance
    ResultListRelevance = ResultLibrary(result_index,:); 
    
    %State features
    rank = [1:nitems]; %rank of items
    title_length = title_length_list(result_index,:); %title length
    query_words_visit = QueryWordVisit(result_index,:);% frequency of query words for visits
    query_words_read = QueryWordRead(result_index,:); %frequency of query words for reading
    
    result_index = result_index +1 ; 
    
    if result_index>size(ResultLibrary,1)
        result_index=1;
    end
    
    current_list=[query_words_visit', query_words_read',title_length'];
    
    %rank = NaN; 
    
    % start a trial
    TimeSpent=100;
    responsed=0;
    correct=0;
    n_steps=0;
    focus=start_location;
    
    inital_state=NaN(size(current_list(:)));
    
    %state1=[inital_state;rank;]';
    state1=[inital_state;focus;]';
    
    state_string=num2str(state1);
    
    if QTableEnterMap.isKey(state_string)
        state_row= QTableEnterMap(state_string);        
    else
        nEncountedStates=nEncountedStates+1;
        listPtr=listPtr+1;
        QTableEnterMap(state_string) = nEncountedStates;
        state_row=nEncountedStates;
    end
    
    items_visited = zeros(1,nitems);
    items_read = zeros(1,nitems);
    items_opened = zeros(1,nitems);
    
    
    %% begin q-learning
    while(n_steps<max_steps && TimeSpent<max_time)
     
     %initializing state features, initially no information is available
     %therefore initialize to zero
     available_title_length = zeros(1,nitems);
     available_query_words_visiting = zeros(1,nitems);
     available_query_words_reading = zeros(1,nitems);
     
     if n_steps==0
            action_chosen=1;%if this is the first step, select action 1, ...
            %action1 = visit/fixate on result item 1. 
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
     
      n_steps=n_steps+1;
      
       %STEP 2, take action chosen, observe rewards ,and s'.
       % check the item fixated,if the actions are to either read an item 
       %or open and item
       %reward function = 10000xrelevantxreading + 20000xrelevantxopening -
       %time spent
       %reading = 1 if action is reading the focused item
       %opening = 1 if action is opening the focused item
       if action_chosen>nitems 
        if action_chosen==nitems+1 %action = read the focused/visited item
             ImmediateReward=Reward(1,1)*ResultListRelevance(focus);
             Duration = average_reading_time*title_length(focus);
        elseif action_chosen==nitems+2 %action = open the focused/visited item
             ImmediateReward=Reward(1,2)*ResultListRelevance(focus);
             Duration = average_opening_time;
        end
       else %i.e. the action is just to visit/fixate on an item
           ImmediateReward= 0; %just focus on the item = no reward
           Duration = average_fixation_time; %fixation time
        
       end
       
       TimeSpent=TimeSpent+Duration;
       ImmediateReward=-Duration;
       
        % STEP 2.2, take action chosen, observe s'.
        
       if action_chosen<nitems+1 % is to fixate on next new location
          focus=action_chosen;
          items_visited(1,focus) = 1;
          
       elseif action_chosen == nitems+1
           items_read(1,focus) = 1;
           
       elseif action_chosen == nitems+2
           items_opened(1,focus) = 1;
          
       end
        visited = find(items_visited==1);
        read = find(items_read==1);
        opened = find(items_opened==1);
        
        available_title_length(visited) = title_length(visited);
        available_query_words_visiting(visited) = query_words_visit(visited);
        available_query_words_reading(read) = query_words_read(read);
        
        temp1= [available_query_words_visiting,available_query_words_reading,...
            available_title_length];
        
        state1=[temp1,focus];
        
        state_string=num2str(state1);
        
        if QTableEnterMap.isKey(state_string)
            new_state_row= QTableEnterMap(state_string);        
        else
            nEncountedStates=nEncountedStates+1;
            listPtr=listPtr+1;
            QTableEnterMap(state_string) = nEncountedStates;
            new_state_row=nEncountedStates;
        end
        
            
      %% Q-table Update
        QT(state_row,action_chosen) = ...
        QT(state_row,action_chosen) + alpha*( ImmediateReward + gamma  *   max(QT(new_state_row,:)) - QT(state_row,action_chosen) ); 
        %equation 6.6 in the book
        % s=s'
        state_row = new_state_row;

        
        %% add new block of memory if needed
        if( listPtr+(qt_block_size/10) > Qtable_size)  % less than 10%*qt_block_size free slots
            Qtable_size= Qtable_size+ qt_block_size;       % add new qt_block_size slots
            QT(listPtr+1:Qtable_size,:) = 0;
        end
        
        
    end
    
    if mod(trial,1e6)==0
        filename = 'All_Data';
        save([filename '.mat'],...
            'QT','QTableEnterMap')
    end
    
end

