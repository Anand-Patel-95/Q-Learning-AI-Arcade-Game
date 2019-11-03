function [ItemProxInputTable,ItemTypeInput] = CalcItemProxInput(G, itemTable, actionsTable)
% for each direction of movement, calculate the distance to the closest
% item
a = max(max(distances(G))); % max distance between 2 nodes in graph this

% min_d = zeros(1,length(actionsTable.Actions));
% min_item_id = zeros(1,length(actionsTable.Actions));
% ItemProxInput = zeros(1,length(actionsTable.Actions));
% ItemTypeInput = zeros(1,length(actionsTable.Actions));

min_d = zeros(length(actionsTable.Actions),1);
min_item_id = zeros(length(actionsTable.Actions),1);
ItemProxInput = zeros(length(actionsTable.Actions),1);
ItemTypeInput = zeros(length(actionsTable.Actions),1);

% for every possible action
for i = 1:1:length(actionsTable.Actions)
    % check number of items remaining
    numItemsRemain = length(itemTable.id);
    
    % if no items remain, set min d = a, min_item_id = 0
    if(numItemsRemain == 0)
        min_d(i) = a;
        min_item_id(i) = 0;
    else
        dist2item = zeros(1,numItemsRemain);
        % for every item remaining, calculate distance2item
        if(numItemsRemain > 1)
            for j = 1:1:numItemsRemain
                [~,dist2item(j)] = shortestpath(G,itemTable.id(j), actionsTable.Next_Position(i));

            end
            % find the minimum distance and the corresponding item for given action
            [min_d(i), min_item_id(i)] = min(dist2item);
        else
            % if there is only 1 item remaining, use the following 
            [~,dist2item] = shortestpath(G,itemTable.id(numItemsRemain), actionsTable.Next_Position(i));
            min_d(i) = dist2item;
            min_item_id(i) = 1;
        end
    end
    
%     % calculate ItemProxInput(c)
%     ItemProxInput(i) = (a - min_d(i))/a;        
%     % round to 3 decimal places
%     ItemProxInput(i) = round(ItemProxInput(i),3);

    % calculate ItemProxInput(c)
    ItemProxInput(i) = min_d(i)+1;        % +1 for indexing. [1,25] ==> [right on top of item, furthest away/no item left]
    % round to 3 decimal places
%     ItemProxInput(i) = round(ItemProxInput(i),3);
    
    % calculate ItemValueInput(c)
    b_types = 3;
    % if no items remain, set ItemTypeInput = 0;
    if(numItemsRemain == 0)
        ItemTypeInput(i) = 0;
    else
        ItemTypeInput(i) = itemTable.type(min_item_id(i))/b_types;  
        % round to 3 decimal places
        ItemTypeInput(i) = round(ItemTypeInput(i),3);
    end

end

% % debugging
% actionsTable.Actions
% itemTable.id(min_item_id)
% min_d
% ItemProxInput

% store to tables
% ItemProxInputTable = table(actionsTable.Actions, itemTable.id([min_item_id]), transpose(min_d), transpose(ItemProxInput), 'VariableNames',{'Actions' 'Closest_item_id' 'Item_distance' 'ItemProxInput'});
if(numItemsRemain ~= 0)
ItemProxInputTable = table(actionsTable.Actions, itemTable.id(min_item_id), min_d, ItemProxInput, 'VariableNames',{'Actions' 'Closest_item_id' 'Item_distance' 'ItemProxInput'});

% ItemTypeInput = table(actionsTable.Actions, itemTable.id([min_item_id]), transpose(min_d), transpose(ItemTypeInput), 'VariableNames',{'Actions' 'Closest_item_id' 'Item_distance' 'ItemTypeInput'});
ItemTypeInput = table(actionsTable.Actions, itemTable.id(min_item_id), min_d, ItemTypeInput, 'VariableNames',{'Actions' 'Closest_item_id' 'Item_distance' 'ItemTypeInput'});

else
    ItemProxInputTable = table(actionsTable.Actions, min_item_id, min_d, ItemProxInput, 'VariableNames',{'Actions' 'Closest_item_id' 'Item_distance' 'ItemProxInput'});
    ItemTypeInput = table(actionsTable.Actions, min_item_id, min_d, ItemTypeInput, 'VariableNames',{'Actions' 'Closest_item_id' 'Item_distance' 'ItemTypeInput'});
end

end