function [Q_now_max, StateAction_taken, new_id, action_taken] = CalcMaxQ(Q_table,actionsTable,StateActionTable)
Qval_list = zeros(height(StateActionTable),1);

% for every State/Action possible, record the Q-value
for i=1:1:height(StateActionTable)
   Qval_list(i,1) = Q_table(StateActionTable.Actions(i), StateActionTable.DoorInput(i), StateActionTable.LightningInput(i), StateActionTable.CharmInput(i), StateActionTable.RootInput(i), StateActionTable.EnemyInput(i), StateActionTable.LootProxInput(i), StateActionTable.ItemProxInput(i), StateActionTable.EntrapmentInput(i), StateActionTable.SameDirectionInput(i));
end

[Q_now_max, Q_id] = max(Qval_list);
StateAction_taken = StateActionTable(Q_id,:);
action_taken = StateActionTable.Actions(Q_id);
new_id = actionsTable.Next_Position(Q_id);
end