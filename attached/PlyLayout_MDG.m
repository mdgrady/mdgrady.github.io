%Michael Grady, 33733494, Homework #6, 4/20/23 , 

%This code takes the dimensions of parts for a box and a given width and
%length of a sheet of wood. Using the dimensions of both aspects(the box
%has 5 parts, so there are 5 different aspects for the 1), the code
%calculates the maximum number of boxes that can be created using the given
%amount of wood available on the sheet. The first function selects one of
%the 5 parts needed to make a box at random, and continually does so until
%there is no wood left to create a box. The second function finds the
%maximum number of boxes created as well as the area that is wasted(not
%used for parts). The script runs the functions a specified number of
%times(1000) and returns the maximum number of boxes overall(the highest #
%of boxes from any iteration) and the associated area that was wasted for
%that specific iteration. So, if the 512th iteration gave the most amount
%of completed boxes, we also get the area that was wasted on the 512th
%iteration. The two are not directly related, as there could be no area
%wasted, but all the parts that are made could be bottom pieces, resulting
%in no complete boxes.
clc
clear
%% Script
sheet_dim = [96,48];
width = 8;
height = 4;
temp = zeros(1,17);
maxBoxes = zeros(1,17);
area_wasted = zeros(1,17);
forgraph = [8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24];
%initilizations for the script
for i = 8:24
    
    new_Dimensions = [i,width,height];
    N_complete = zeros(1000,1);
    A_wasted = zeros(1000,1);
  %new part lengths
  for j = 1:1000
   
        [W,H] = rand_Layout(new_Dimensions, sheet_dim);
        [A_wasted(j), N_complete(j)] = check_Ratio(new_Dimensions, sheet_dim, H,W);
  end
    
    maxBoxes(i-7) = max(N_complete);
    index = find(N_complete == maxBoxes(i-7),1);%had to research thru matlab documentation to find out how to use "find" and index
    area_wasted(i-7) = A_wasted(index);
%calculation of best iteration for total boxes, then find the matching area
%wasted for that iteration
end

figure(1)
plot(forgraph,maxBoxes)
xlabel('Part Lengths')
ylabel('Max Number of Boxes')
title('Max # of Boxes Vs. Part Lengths')
figure(2)
plot(forgraph,area_wasted)
xlabel('Part Lengths')
ylabel('Area Wasted')
title('Area Wasted Vs. Part Lengths')
%plotting!!!
%figure 1 makes sense, because as the part lengths increase, the maximum
%number of boxes is going to decrease, as there is going to be less parts
%that can be made from the sheet of wood.
%figure 2 also makes sense, and also corresponds to the part length. you
%would expected 16 to have the lowest area wasted, as three pieces would be
%able to perfectly fit into the according sheet, but when you remember that
%the saw blade is included, the lowest is actually 15, as it's still three
%parts but with the saw blade taken into account.
%% Function 1
function [width_array, height_array] = rand_Layout(part_dim, sheet_dim)

saw_blade = .125;
part_dim = part_dim + saw_blade;
%part_dim(3) is height, part_dim(2) is width, part_dim(1) is length
%sheet_dim(2) is width, sheet_dim(1) is length
PL = part_dim(1);
PW = part_dim(2);
PH = part_dim(3);
SL = sheet_dim(1);
SW = sheet_dim(2);
parts = [PH,PW; PH,PW;%vertical short
         PH,PL; PH,PL;%vertical long
         PW,PL];%bottom

rows = floor(SL / PH);
columns = floor(SW / PW);
height_array = zeros(rows, columns);
width_array = zeros(rows, columns);
%prof's code to initialize
running_height = SL;

i = 1;
  
    while running_height >= PH
       
        j = 1;
        running_width = SW;
        numpart = randi(5);
        randompart = parts(numpart,:);
        RPH = randompart(1);
        RPW = randompart(2);
%select a random part
        if running_height > RPH
          
            height_array(i,j) = RPH;
            width_array(i,j) = RPW;
            
            running_width = running_width - RPW;
        
            while running_width >= PW
         
                newnumber = randi(5);
                newpart = parts(newnumber,:);
                NPH = newpart(1);
                NPW = newpart(2);

                if newnumber == 5
                    part5 = true;
                else
                    part5 = false;
                end
            
              
                if (NPH == RPH && NPW <= running_width) %newnumber == numpart || 
               %dinor nallbani assisted with the idea of creating an additional part 
               %to compare to the already created part.
                    j = j + 1;
                    height_array(i,j) = NPH;
                    width_array(i,j) = NPW;
                    running_width = running_width - NPW;
                elseif part5
                    running_width = 0;
               
                else
                   continue;
                    %assign output and add an iteration
                end
            end
        end

        running_height = running_height - RPH;
        i = i + 1;
        %reassign iterations
    end
end

%% Function 2
function [A_wasted, N_complete] = check_Ratio(part_dim,sheet_dim,height_array,width_array)

saw_blade = .125;
part_dim = part_dim + saw_blade;

PL = part_dim(1);
PW = part_dim(2);
PH = part_dim(3);
SL = sheet_dim(1);
SW = sheet_dim(2);

total_Area = SL * SW;
totalParts_Area = sum(sum(height_array .* width_array));
%initially a single sum would output an array, so had to double to sum that
%output
A_wasted = (total_Area - totalParts_Area) / total_Area;
%calculation of the total area wasted, follow prof's steps

[height,width] = size(height_array);
horiz = 0;
bottom = 0;
vert = 0;
%initialize
    for i = 1:height
        for j = 1:width
          temp_Area = width_array(i,j) * height_array(i,j);
            if temp_Area == (PL * PH)
            horiz = horiz + 1;
            end

            if temp_Area == (PL * PW)
            bottom = bottom + 1;
            end

            if temp_Area == (PH * PW)
            vert = vert + 1;
            end
        %initially had [if --> elseif --> elseif]for the same setup,
        %but I later realized that the script breaks it since for the first
        %iteration, length would be 8 as well as width, resulting in zeros
        %for N_complete since all the math got screwed up.
        end
    end

horiz = floor(horiz/2);%floor because half a box rounds down to make full
vert = floor(vert/2);  %and divide by 2 because each box needs two sides
N_complete = min([horiz,vert,bottom]);

end