function DoorInputTable = calcDoorInput(G, enemy_start, actionsTable)
door = enemy_start;

% 1st Input: DoorInput(c)
a = max(max(distances(G))); % max distance between 2 nodes in graph this
DoorInput = zeros(height(actionsTable),2);

% for every possible action, calculate DoorInput
for i = 1:1:height(actionsTable)
   DoorInput(i,1) = actionsTable.Actions(i);
   [~,b_c] = shortestpath(G,actionsTable.Next_Position(i),door);
%    DoorInput(i,2) = (a - b_c)/a;
    DoorInput(i,2) = b_c + 1;   % distance to door + 1 (for matlab indexing starting @ 1)
end
DoorInputTable = table(DoorInput(:,1),DoorInput(:,2),'VariableNames',{'Actions' 'DoorInput'});



end