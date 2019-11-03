function StateActionTable = calcStateActionTable(G, explorer_id, last_action,enemy1,enemy2,enemy3,enemy_start,actionsTable,itemTable,charmDuration,rootDuration,lootTable,IntersectionTable,NodeTable)
len_table = length(actionsTable.Actions);
% 1st Input: Game Progress: DoorInput(c)
DoorInputTable = calcDoorInput(G, enemy_start, actionsTable);

% 2nd Input: Lightning use
LightningInput = calcLightningInput(itemTable);

% 3rd Input: Charm use: percentage of charm duration left 
CharmInput = CalcCharmInput(charmDuration);

% 4th Input: Root use: percentage of root duration left 
RootInput = CalcRootInput(rootDuration);

% 5th Input: Enemy threat: EnemyInput(c)
EnemyInputTable = CalcEnemyInput(G, enemy1, enemy2, enemy3, explorer_id, actionsTable);

% 6th Input: Loot proximity: LootProxInput(c)
% 7th Input: Loot Value Closest: LootValueInput
% [LootProxInputTable,LootValueInput] = CalcLootProxInput(G, lootTable, actionsTable);
[LootProxInputTable,~] = CalcLootProxInput(G, lootTable, actionsTable);


% 8th Input: Item proximity: ItemProxInput(c)
% 9th Input: Item type Closest: ItemTypeInput
% [ItemProxInputTable,ItemTypeInput] = CalcItemProxInput(G, itemTable, actionsTable);
[ItemProxInputTable,~] = CalcItemProxInput(G, itemTable, actionsTable);

% 10th Input: EntrapmentInput(c)
EntrapmentInputTable = CalcEntrapmentInput(G, explorer_id, enemy1, enemy2, enemy3, IntersectionTable, NodeTable, actionsTable);

% 11th Input: SameDirectionInput(c)
SameDirectionInputTable = CalcSameDirectionInput(last_action, actionsTable);

% temp = [actionsTable.Actions,DoorInputTable.DoorInput,LightningInput*ones(len_table,1),CharmInput*ones(len_table,1),RootInput*ones(len_table,1),EnemyInputTable.EnemyInput,LootProxInputTable.LootProxInput,ItemProxInputTable.ItemProxInput, EntrapmentInputTable.EntrapmentInput,SameDirectionInputTable.SameDirectionInput]
StateActionTable = table(actionsTable.Actions,DoorInputTable.DoorInput,LightningInput*ones(len_table,1),CharmInput*ones(len_table,1),RootInput*ones(len_table,1),EnemyInputTable.EnemyInput,LootProxInputTable.LootProxInput,ItemProxInputTable.ItemProxInput, EntrapmentInputTable.EntrapmentInput,SameDirectionInputTable.SameDirectionInput, 'VariableNames',{'Actions' 'DoorInput' 'LightningInput' 'CharmInput' 'RootInput' 'EnemyInput' 'LootProxInput' 'ItemProxInput' 'EntrapmentInput' 'SameDirectionInput'});




end