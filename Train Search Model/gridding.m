%gridding available_query_words
function [gridded_values]=gridding(min, max, nlevels,input)
[r,c]=size(input);

gap = round((max-min)/nlevels);

level = 0: nlevels;

gridded_values = zeros(r,c);
for row = 1 : r
    for col=1 : c
        val = (input(row,col)-min)/gap;%
        n = 1;
        l = -1;
        while n < nlevels+2
            if  n == (nlevels +1) && val >= level(n)
              l = level(n);                  
            elseif level(n) <= val &&  val < level(n+1)
              l = level(n)+1;
              break
            end
            n = n+ 1;  
             
        end
        gridded_values(row,col) = l;

    end

end
gridded_values;
    
