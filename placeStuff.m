function [lootTable, itemTable] = placeStuff(NodeTable, explorer_start, enemy_start)
temp = NodeTable.ID;
temp([explorer_start,enemy_start],:) = [];
size_temp = numel(temp);
idx = randperm(size_temp);
location_list = temp(idx(1:26));

loot.id = location_list(1:21);
loot.value = transpose([13 11 11 7 7 7 5 5 5 5 3 3 3 3 3 2 2 2 2 2 2]);
lootTable = struct2table(loot);

item.id = location_list(22:end);
item.type = transpose([1 1 2 2 3]); % 1 = charm, 2 = root, 3 = kill
itemTable = struct2table(item);

end