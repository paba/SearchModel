%Test distributions 

clear;clc;

load('Random/Relevance_Distribution_Random_Test.mat');

nitems = length(relevance_distribution_random);

max_positions = zeros(1,20);

for i = 1 : nitems 
  position = find(relevance_distribution_random(i,:) == max(relevance_distribution_random(i,:)));
  
  max_positions(1,position) = max_positions(1,position) +1;
  

end
bar(max_positions)