function EnemyInputTable = CalcEnemyInput(G, enemy1, enemy2, enemy3, explorer_id, actionsTable)
Intersection_ID = zeros(length(actionsTable.Actions),1);
EnemyInput = zeros(length(actionsTable.Actions),1);
a = max(max(distances(G))); % max distance between 2 nodes in graph this
v = 1;

% For each action/direction of movement possible 
for i = 1:1:length(actionsTable.Actions)
    % Find the nearest intersection point along direction
    Intersection_ID(i,1) = findIntersection(G, explorer_id, actionsTable.Actions(i));

    % Finding the closest LIVING enemy to intersection point
    [min_dist,~] = calcNearestEnemy(G, enemy1, enemy2, enemy3, Intersection_ID(i,1));
    
    % Calculate the input
    % b = Distance between the nearest enemy and the nearest intersection 
    b = min_dist;
    % d = Distance between explorer and nearest intersection
    [~,d] = shortestpath(G,explorer_id, Intersection_ID(i,1));
    
%     EnemyInput(i,1) = (a + d*v - b)/a;
%     if(EnemyInput(i,1) > 1)
%        EnemyInput(i,1) = 1; % Makes sure input doesnt exceed 1
%     end
    
    EnemyInput(i,1) = (a + d*v - b) + 1;    % +1 for Q-table indexing. Will always be below 25 (high value is bad)
    if(EnemyInput(i,1) > (a+1))
       EnemyInput(i,1) = (a+1); % Makes sure input doesnt exceed 1
    end
end

EnemyInputTable = table(actionsTable.Actions, EnemyInput(:,1), Intersection_ID(:,1), 'VariableNames',{'Actions' 'EnemyInput' 'Nearest_Intersection'});

end