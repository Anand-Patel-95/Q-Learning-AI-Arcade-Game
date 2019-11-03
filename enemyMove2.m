function [enemy_id, enemy_old_id] = enemyMove2(G, enemy)

        neighbor_list = neighbors(G,enemy.id);
        numNeighbors = degree(G,enemy.id);
        
        if(G.Nodes.Intersection([enemy.id]) == 1)  % if @ an intersection
            % pick random neighbor to travel to
            j = randi([1 numNeighbors]);
            enemy_old_id = enemy.id;       % save current node as prev position
            enemy_id = neighbor_list(j);   % move to new node
        else % if in a hallway, dont move back to old node
            if(neighbor_list(1) == enemy.old_id) % if checked node is old node
                enemy_old_id = enemy.id;       % save current node as prev position
                enemy_id = neighbor_list(2);   % move to other node
            else
                enemy_old_id = enemy.id;       % save current node as prev position
                enemy_id = neighbor_list(1);   % move to checked node  
            end
        end
%         % make list of enemy path
%         enemy_path = [path enemy_id];


end