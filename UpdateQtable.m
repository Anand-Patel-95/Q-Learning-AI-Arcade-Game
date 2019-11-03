function Q_table = UpdateQtable(Q_table, Q_new)


Q_table(StateAction_taken.Actions, StateAction_taken.DoorInput, StateAction_taken.LightningInput, StateAction_taken.CharmInput, StateAction_taken.RootInput, StateAction_taken.EnemyInput, StateAction_taken.LootProxInput, StateAction_taken.ItemProxInput, StateAction_taken.EntrapmentInput, StateAction_taken.SameDirectionInput) = Q_new;

end