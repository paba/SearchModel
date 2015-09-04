%generate the distribution of title length
%generate the distribution of relevance
%generate the distribution of query words


function Generate_Training_Search_Result_Lists
    clear;clc;
    n_results_perpage=20; %number of results per page
    ntrials=10000; %1e4
    
    %length distribution data
    min_title_length = 5;%1;
    max_title_length = 15;%43; 
    median = 12; 
    
    %set these two parameters, when generating training sets: first_run,
    %order
    %first_run = 0;
    
    noise_level = 0.75;
    %relevance distribution data
    %order =    3; %order =1 -> descending order of relevance, 
               %order = 2 -> statistical noisy/fuzzy ranking functions
               %order = 3 -> totally random relevance distribution
               
      
    %if first_run
        [title_length_list] = Generate_Length_Distribution(n_results_perpage,...
            ntrials,min_title_length,max_title_length, median);
        save(strcat('Random_Title_Length.mat'),'title_length_list');
    
%     else
%         load(strcat('Random_Title_Length.mat'));
%         load(strcat('Relevance_Distribution_Descending.mat'));
%                
%     end
       [first_relevance_distribution] = Generate_first_Relevance_Distribution...
           (ntrials,n_results_perpage);
   
  for order=1:3
      
    
    if order==1
%         if first_run==1
            [relevance_distribution_descending] = ...
         Generate_Relevance_Distribution(order,ntrials,n_results_perpage,first_relevance_distribution);
%         else
%             [relevance_distribution_descending] = ...
%          Generate_Relevance_Distribution(order,ntrials,...
%          first_run,n_results_perpage,relevance_distribution_descending);
%         end
        save('Relevance_Distribution_Descending.mat','relevance_distribution_descending');

        correlation_coeficient = 0.9;
        keywords_in_query = 1;
        [query_word_distribution_read_descending_relevance] = Generate_Query_Word_Distribution...
            (order,ntrials,correlation_coeficient,relevance_distribution_descending,...
            title_length_list, keywords_in_query,n_results_perpage);
        save('Query_Word_Distribution_Read_Descending.mat',...
           'query_word_distribution_read_descending_relevance');

        %results ranked by descending order of relevance
        %skimming
        correlation_coeficient = 0.7;
        keywords_in_query = 1;
        [query_word_distribution_visit_descending_relevance] = ...
            Generate_Query_Word_Distribution...
            (order,ntrials,correlation_coeficient,first_relevance_distribution,...
           title_length_list, keywords_in_query,n_results_perpage);
        save('Query_Word_Distribution_Visit_Descending.mat',...
           'query_word_distribution_visit_descending_relevance');
        
       clear query_word_distribution_read_descending_relevance;
       clear query_word_distribution_visit_descending_relevance;
       clear relevance_distribution_descending;

    
    elseif order==2
%        if first_run ==1
%         [relevance_distribution_noisy] = ...
%             Generate_Relevance_Distribution(order,ntrials,first_run,n_results_perpage);
%        else

        [relevance_distribution_noisy] = ...
        Generate_Relevance_Distribution(order,ntrials,...
        n_results_perpage,first_relevance_distribution,noise_level);  
%        end
        save('Relevance_Distribution_Noisy.mat','relevance_distribution_noisy');
        
        %high correlation with relevance when you read the title completely
        correlation_coeficient = 0.9;
        keywords_in_query = 1;
        [query_word_distribution_read_noisy_relevance] = Generate_Query_Word_Distribution...
            (order,ntrials,correlation_coeficient, relevance_distribution_noisy,...
            title_length_list, keywords_in_query,n_results_perpage);
        save('Query_Word_Distribution_Read_Noisy.mat',...
            'query_word_distribution_read_noisy_relevance');

        %low correlation coefficent if you just skim or fixate on the item
        %just fixating with no reading is called visit. Then there is more
        %noise in the frequency of keyword distribution observed by the user by
        %just glancing. 
        correlation_coeficient = 0.7;
        keywords_in_query = 1;
        [query_word_distribution_visit_noisy_relevance] = ...
            Generate_Query_Word_Distribution...
            (order,ntrials,correlation_coeficient, relevance_distribution_noisy,...
            title_length_list, keywords_in_query,n_results_perpage);
        save('Query_Word_Distribution_Visit_Noisy.mat',...
            'query_word_distribution_visit_noisy_relevance');

        %generate query word distribution for results where the results are
        %perfectly ranked by the descending order of relevance
        %for reading
        
        clear relevance_distribution_noisy;
        clear query_word_distribution_read_noisy_relevance;
        clear query_word_distribution_visit_noisy_relevance;

        
    elseif order==3
%         if first_run==1
%             [relevance_distribution_random] = ...
%             Generate_Relevance_Distribution(order,ntrials,first_run,n_results_perpage);
%         else

        [relevance_distribution_random] = ...
        Generate_Relevance_Distribution(order,ntrials,...
        n_results_perpage,first_relevance_distribution);
%         end
        save('Relevance_Distribution_Random.mat','relevance_distribution_random');
        
        correlation_coeficient = 0.9;
        keywords_in_query = 1;
        [query_word_distribution_read_random_relevance] =... 
         Generate_Query_Word_Distribution...
         (order,ntrials,correlation_coeficient, relevance_distribution_random,...
            title_length_list, keywords_in_query,n_results_perpage);
        
        save('Query_Word_Distribution_Read_Random.mat',...
            'query_word_distribution_read_random_relevance');
        
        correlation_coeficient = 0.7;
        keywords_in_query = 1;
        [query_word_distribution_visit_random_relevance] = ...
            Generate_Query_Word_Distribution...
            (order,ntrials,correlation_coeficient, relevance_distribution_random,...
            title_length_list, keywords_in_query,n_results_perpage);
        save('Query_Word_Distribution_Visit_Random.mat',...
            'query_word_distribution_visit_random_relevance');
       
        clear relevance_distribution_random;
        clear query_word_distribution_read_random_relevance;
        clear query_word_distribution_visit_random_relevance;
        
    end
    
  end
    clear title_length_list;
    
end

function [title_length] = Generate_Length_Distribution(nitems, ntrials,...
    min,max, median)

    array = rand(ntrials,nitems);
    array = (max-min).*array + min; %fit the length the actual range
    
    %consider how to fix the median issue - next step
    array = round(array);
    
    title_length = array;
  

end

function [initial_relevance_distribution] = Generate_first_Relevance_Distribution...
    (ntrials,n_results_perpage)
    
    relevance_score_scale = [0.2 0.4 0.6 0.8 1]; 
    initial_relevance_distribution = [];%zeros(ntrials,n_results_perpage);
    
    for trial = 1 : ntrials
         relevance_score_row = [];   
         for item = length(relevance_score_scale):-1:1
                %count how many items per each relevance score value according
                %to power law distribution function y = 10 n^(-1.2) 

                %rel_score_items = 10*(item^(-1.2)); 

                items_per_score = round(10*(item^(-1.2)));

                score_start = 0;
                score_end = relevance_score_scale(item);
                if item > 1
                    score_start = relevance_score_scale(item-1);

                end


                relevance_score_row = [relevance_score_row ...
                    Random(score_start,score_end,items_per_score)];
         end
          initial_relevance_distribution(trial,:) = relevance_score_row;
    end
    
end

function [relevance_distribution] = Generate_Relevance_Distribution(order,...
    ntrials,n_results_perpage,relevance_distribution,noise)
    %relevance distribution function y = 10 n^(-1.2) 
    %this is one possible function 
    %relevance score is in the scale from 0.2, 0.4, 0.6, 0.8, 1
    %this function is best tunes for number of results per page = 20 
    %ToDo: write a seperate function to generate the power law distribution
    
    relevance_score_scale = [0.2 0.4 0.6 0.8 1]; 
    %relevance_distribution = zeros(ntrials,n_results_perpage);
    
    for trial = 1 : ntrials
            relevance_score_row = relevance_distribution(trial,:);
%         if first_run

%         else
%             relevance_score_row = relevance_distribution_descending(trial,:);
%             
%         end
           
            
        switch order
        case 1 %for now only case 1 and 2 are implemented
            
            relevance_score_row = sort(relevance_score_row,'descend');
            
        case 2
            %relevance_score_row = relevance_distribution_descending(trial,:);
%             levels = length(relevance_score_scale);
%             items_in_level_1and2 = round(10*(levels^(-1.2))) + ...
%                 round(10*((levels-1)^(-1.2)));
%             shuffled_items = Shuffle(relevance_score_row(1:items_in_level_1and2));
%             relevance_score_row(1:items_in_level_1and2) = shuffled_items;
            %ordered_relevance_score_row = sort(relevance_score_row,'descend');
            relevance_score_row = Add_Noise...
                (relevance_score_row,relevance_score_scale,noise);
            
        case 3
            %shuffle all the items in the list
            relevance_score_row = Shuffle(relevance_score_row);
        end
        
        relevance_distribution(trial,:) = relevance_score_row;
        
    end
    

  
end

function [shuffled_data] = Shuffle(data)
    rand_positions = randperm(length(data)); 
    shuffled_data = data(rand_positions);
    
end

function [random_number] = Random(range_start,range_end,count)
    random_number = range_start + (range_end-range_start).*rand(count,1);
    random_number =  random_number';

end

function [query_word_distribution] = Generate_Query_Word_Distribution...
    (order,ntrials,correlation_coeficient, relevance_distribution,...
    title_length_distribution, keywords_in_query,n_results_perpage)

    %as the first step let's assume that there is only one keyword 
    %in the query
    
    %iterate through each relevance distribution row and title length dist.
    %then using the title length as a max value and 0 as the min generate a
    %range of query frequency distributions. 
    %then use the correlaiton coefficent and relevance_distribution to
    %create a correlated query_word_distribution 
    
    query_word_distribution = [];
    
    for trial=1:ntrials
       relevance = relevance_distribution(trial,:);
       title_length = title_length_distribution(trial,:);
       
       half_length = 0.5.*title_length;
       keyword_frequency = rand(1,n_results_perpage);
       
       correlated_keyword_frequency =  correlation_coeficient.*relevance +...
           sqrt(1 - (correlation_coeficient^2)).*keyword_frequency;
       
       query_word_distribution = [query_word_distribution; ...
           round(5.*correlated_keyword_frequency)];
       
       
    end
   
  
end

function [noisy_relevance_score_row] = Add_Noise(data, relevance_score_scale, noise_level)
    nitems = length(data);
    nactions = 3; % 1= swap, 2= increase relevance, 3= decrease relevance 
    
    if noise_level == 0
    
            % just randomize within group this is the minimum
            %shuffle level 1 +2, 3, 4, 5
            levels = length(relevance_score_scale);
            nitems_level1and2 = round(10*(levels^(-1.2))) + ...
                round(10*((levels-1)^(-1.2)));
            shuffled_items = Shuffle(data(1:nitems_level1and2));
            data(1:nitems_level1and2) = shuffled_items;
            
%             next = nitems_level1and2;
%             
%             for position = (levels-2) :-1: 1
%                nitems = round(10*(position^(-1.2)));
%                shuffled_items = Shuffle(data(next:(nitems+next)));
%                data(next:(nitems+next)) = shuffled_items;
%                next = next + nitems;
%                
%             end
            noisy_relevance_score_row = data;
            
    else % reorder 25% , 50%, 75%, or 100% of the items
            nmodifications = round(nitems*noise_level);
            
            for modification = 1 : nmodifications
                %pick a random number and decide what action to perform
                
                action = randi(nactions);
                
                switch action
                    case 1 %swap
                        pos1 = randi(nitems);
                        pos2 = randi(nitems);
                        
                        item1 = data(pos1);
                        item2 = data(pos2);
                        data(pos1) = item2;
                        data(pos2) = item1;
                        
                    case 2 % increase relevance
                        position = randi(nitems);
                        current_val = data(position);
                        increase = rand(1)*(1-current_val);
                        new_val = current_val + increase;
                        data(position) = new_val;
                       
                    case 3 % decrease relevance
                        position = randi(nitems);
                        current_val = data(position);
                        decrease = rand(1)*(current_val);
                        new_val = current_val - decrease;
                        data(position) = new_val;
                end
                
                
            end
            
            noisy_relevance_score_row = data;
   
            
        
    end
end
