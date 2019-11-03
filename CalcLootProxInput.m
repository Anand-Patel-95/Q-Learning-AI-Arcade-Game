function [LootProxInputTable,LootValueInput] = CalcLootProxInput(G, lootTable, actionsTable)
% for each direction of movement, calculate the distance to the closest
% loot
a = max(max(distances(G))); % max distance between 2 nodes in graph this

% min_d = zeros(1,length(actionsTable.Actions));
% min_loot_id = zeros(1,length(actionsTable.Actions));
% LootProxInput = zeros(1,length(actionsTable.Actions));
% LootValueInput = zeros(1,length(actionsTable.Actions));

min_d = zeros(length(actionsTable.Actions),1);
min_loot_id = zeros(length(actionsTable.Actions),1);
LootProxInput = zeros(length(actionsTable.Actions),1);
LootValueInput = zeros(length(actionsTable.Actions),1);

% for every possible action
for i = 1:1:length(actionsTable.Actions)
    % check number of items remaining
    numLootRemain = length(lootTable.id);
    
    % if no loot remain, set min d = a, min_loot_id = 0
    if(numLootRemain == 0)
        min_d(i) = a;
        min_loot_id(i) = 0;
    else
        dist2loot = zeros(1,numLootRemain);
        % for every loot remaining, calculate distance2loot
        if(numLootRemain > 1)
            for j = 1:1:numLootRemain
                [~,dist2loot(j)] = shortestpath(G,lootTable.id(j), actionsTable.Next_Position(i));

            end
            % find the minimum distance and the corresponding loot for given action
            [min_d(i), min_loot_id(i)] = min(dist2loot);
        else
            % if there is only 1 loot remaining, use the following 
            [~,dist2loot] = shortestpath(G,lootTable.id(numLootRemain), actionsTable.Next_Position(i));
            min_d(i) = dist2loot;
            min_loot_id(i) = 1;
        end
    end
    
%     % calculate LootProxInput(c)
%     LootProxInput(i) = (a - min_d(i))/a;        
%     % round to 3 decimal places
%     LootProxInput(i) = round(LootProxInput(i),3);

    % calculate LootProxInput(c)
    LootProxInput(i) = min_d(i) + 1;        % +1 for indexing. [1,25] ==> [right on top of loot, furthest away/no loot left]   
    % round to 3 decimal places
%     LootProxInput(i) = round(LootProxInput(i),3);
    
    % calculate LootValueInput(c)
    b_val = 13;
    if(numLootRemain == 0)
        LootValueInput(i) = 0;
    else
        LootValueInput(i) = lootTable.value(min_loot_id(i))/b_val;  
        % round to 3 decimal places
        LootValueInput(i) = round(LootValueInput(i),3);
    end

end

% store to tables
% LootProxInputTable = table(actionsTable.Actions, lootTable.id([min_loot_id]), transpose(min_d), transpose(LootProxInput), 'VariableNames',{'Actions' 'Closest_loot_id' 'Loot_distance' 'LootProxInput'});
% 
% LootValueInput = table(actionsTable.Actions, lootTable.id([min_loot_id]), transpose(min_d), transpose(LootValueInput), 'VariableNames',{'Actions' 'Closest_loot_id' 'Loot_distance' 'LootValueInput'});

if(numLootRemain ~= 0)
    LootProxInputTable = table(actionsTable.Actions, lootTable.id(min_loot_id), min_d, LootProxInput, 'VariableNames',{'Actions' 'Closest_loot_id' 'Loot_distance' 'LootProxInput'});
    LootValueInput = table(actionsTable.Actions, lootTable.id(min_loot_id), min_d, LootValueInput, 'VariableNames',{'Actions' 'Closest_loot_id' 'Loot_distance' 'LootValueInput'});

else
    LootProxInputTable = table(actionsTable.Actions, min_loot_id, min_d, LootProxInput, 'VariableNames',{'Actions' 'Closest_loot_id' 'Loot_distance' 'LootProxInput'});
    LootValueInput = table(actionsTable.Actions, min_loot_id, min_d, LootValueInput, 'VariableNames',{'Actions' 'Closest_loot_id' 'Loot_distance' 'LootValueInput'});
end

end