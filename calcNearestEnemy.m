% Find nearest enemy to a node
function [min_dist,closest_enemy] = calcNearestEnemy(G, enemy1, enemy2, enemy3, node)
if(enemy1.killed == 1)
    d_1 = 100;
else
    [~, d_1] = shortestpath(G, enemy1.id, node);
end

if(enemy2.killed == 1)
    d_2 = 100;
else
    [~, d_2] = shortestpath(G, enemy2.id, node);
end

if(enemy3.killed == 1)
    d_3 = 100;
else
    [~, d_3] = shortestpath(G, enemy3.id, node);
end

distances2enemies = [d_1; d_2; d_3];
min_dist = min(distances2enemies);

if (min_dist == d_1)
    closest_enemy = enemy1;
elseif (min_dist == d_2)
    closest_enemy = enemy2;
else
    closest_enemy = enemy3;


end