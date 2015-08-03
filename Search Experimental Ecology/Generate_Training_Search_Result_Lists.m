%generate the distribution of title length
%generate the distribution of relevance
%generate the distribution of query words


function Generate_Training_Search_Result_Lists

    n_results_perpage=20; %number of results per page
    ntrials=10000; %1e4

    %length distribution data
    min_title_length = 5;%1;
    max_title_length = 15;%43; 
    median = 12; 
    
    %relevance distribution data
    order = 1; %order =1 -> descending order of relevance, 
               %order = 2 -> statistical noisy/fuzzy ranking functions
               %order = 3 -> totally random relevance distribution
    
    [relevance_distribution_descending] = ...
        Generate_Relevance_Distribution(order,ntrials);
    save('Relevance_Distribution_Descending.mat','relevance_distribution_descending');
    
    order = 2;
    
    [relevance_distribution_noisy] = ...
        Generate_Relevance_Distribution(order,ntrials);
    save('Relevance_Distribution_Noisy.mat','relevance_distribution_noisy');
      

    [title_length_list] = Generate_Length_Distribution(n_results_perpage,...
        ntrials,min_title_length,max_title_length, median);
    save('Random_Title_Length.mat','title_length_list');
    
    
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
        (order,ntrials,correlation_coeficient,relevance_distribution_descending,...
        title_length_list, keywords_in_query,n_results_perpage);
    save('Query_Word_Distribution_Visit_Descending.mat',...
        'query_word_distribution_visit_descending_relevance');
    
    
    
    
    
    

end

function [title_length] = Generate_Length_Distribution(nitems, ntrials,...
    min,max, median)

    array = rand(ntrials,nitems);
    array = (max-min).*array + min; %fit the length the actual range
    
    %consider how to fix the median issue - next step
    array = round(array);
    
    title_length = array;
  

end


function [relevance_distribution] = Generate_Relevance_Distribution(order,ntrials,action)
    %relevance distribution function y = 10 n^(-1.2) 
    %this is one possible function 
    %relevance score is in the scale from 0.2, 0.4, 0.6, 0.8, 1
    %this function is best tunes for number of results per page = 20 
    %ToDo: write a seperate function to generate the power law distribution
    
    relevance_score_scale = [0.2 0.4 0.6 0.8 1]; 
    relevance_distribution = [];
    
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
        
        switch order
        case 1 %for now only case 1 and 2 are implemented
            relevance_score_row = sort(relevance_score_row,'descend');
        case 2
            relevance_score_row = relevance_score_row;
        case 3
            
        end
        
        relevance_distribution = [relevance_distribution; ... 
            relevance_score_row];
        
    end
    

  
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
