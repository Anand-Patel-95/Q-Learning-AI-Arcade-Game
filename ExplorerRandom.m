function [Q_now, StateAction_taken, new_id, action_taken] = ExplorerRandom(G, explorer, Q_table, actionsTable, StateActionTable)
        
if(G.Nodes.Intersection([explorer.id]) == 1)  % if @ an intersection
    % pick random Action and neighbor to travel to
    j = randi([1 height(actionsTable)]);
    action_taken = actionsTable.Actions(j);
    new_id = actionsTable.Next_Position(j);
    StateAction_taken = StateActionTable(j,:);

else % if in a hallway, repeat the last action
    j = 1;
    for i=1:1:height(actionsTable)
        % find the same action as last time
        if(actionsTable.Actions(i) == explorer.last_action)
            j = i;
        end
    end
    % move in same direction as before
    action_taken = actionsTable.Actions(j);
    new_id = actionsTable.Next_Position(j);
    StateAction_taken = StateActionTable(j,:);
end

% Look up what the Q-value is for the action taken
Q_now = Q_table(StateAction_taken.Actions, StateAction_taken.DoorInput, StateAction_taken.LightningInput, StateAction_taken.CharmInput, StateAction_taken.RootInput, StateAction_taken.EnemyInput, StateAction_taken.LootProxInput, StateAction_taken.ItemProxInput, StateAction_taken.EntrapmentInput, StateAction_taken.SameDirectionInput);


end