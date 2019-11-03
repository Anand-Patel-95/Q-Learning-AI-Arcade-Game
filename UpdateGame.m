function [lootTable, itemTable, charmDuration, rootDuration, explorer, enemy1, enemy2, enemy3] = UpdateGame(G, lootTable, itemTable, charmDuration, rootDuration, explorer, enemy1, enemy2, enemy3)

% will check for items as default
check4items = 1;

% check if explorer is on loot
for i=1:1:length(lootTable.id)
    if(explorer.id == lootTable.id(i))
       % add value of this loot to explorer's loot value collected
       explorer.ValueCollected = explorer.ValueCollected + lootTable.value(i);
       
       % flag not to check for landing on item since already on loot
       check4items = 0;
        
       % delete claimed loot row from lootTable!!!
       lootTable(i,:) = [];
       break;
    end    
end

% find the closest living enemy for the item related stuff
[~,closest_enemy] = calcNearestEnemy(G, enemy1, enemy2, enemy3, explorer.id);
% figure out which enemy this is
if(closest_enemy.id == enemy1.id)
    close_id = 1;
elseif(closest_enemy.id == enemy2.id)
    close_id = 2;
else
    close_id = 3;
end

% check if explorer is on item, if not already on loot
if(check4items == 1)
    % check for every item in the loot table
    for i=1:1:length(itemTable.id)
        if(explorer.id == itemTable.id(i))
           % identify the type of item
           item_claimed = itemTable.type(i);
           
           % if charm (1)
           if(item_claimed == 1)
               % update the explorer's charm usage
               explorer.charmsUsed = explorer.charmsUsed + 1;
               
               % reset the charm duration
               charmDuration = 9;
               
               % Reset the currently charmed enemy's charm duration,
               % otherwise reset closest enemy's charmed status
               if( (enemy1.charmed ~= 0)||(enemy2.charmed ~= 0)||(enemy3.charmed ~= 0) )
                   if(enemy1.charmed ~= 0)
                       enemy1.charmed = charmDuration;
                   elseif(enemy2.charmed ~= 0)
                       enemy2.charmed = charmDuration;
                   elseif(enemy3.charmed ~= 0)
                       enemy3.charmed = charmDuration;
                   end
               else
                   if(close_id == 1)
                       enemy1.charmed = charmDuration;
                   elseif(close_id == 2)
                       enemy2.charmed = charmDuration;
                   else
                       enemy3.charmed = charmDuration;
                   end
               end
               
           % if root (2)
           elseif(item_claimed == 2)
               % update the explorer's root usage
               explorer.rootsUsed = explorer.rootsUsed + 1;
               
               % reset the root duration
               rootDuration = 5;
               
               % Reset all enemy's rooted statuses
               enemy1.rooted = rootDuration;
               enemy2.rooted = rootDuration;
               enemy3.rooted = rootDuration;
               
           % if lightning (3)
           elseif(item_claimed == 3)
               % update the explorer's lightning usage
               explorer.lightningsUsed = 1;
               
               % Set closest enemy status to killed
               if(close_id == 1)
                   enemy1.killed = 1;
               elseif(close_id == 2)
                   enemy2.killed = 1;
               else
                   enemy3.killed = 1;
               end
           end
           
           % delete claimed item row from itemTable!!!
           itemTable(i,:) = [];
           break;
        
       % if not on loot, just decremet existing statuses   
        else
            % update the currently charmed enemy's status 
            if( (enemy1.charmed ~= 0)||(enemy2.charmed ~= 0)||(enemy3.charmed ~= 0) )
                if(enemy1.charmed ~= 0)
                    enemy1.charmed = charmDuration;
                elseif(enemy2.charmed ~= 0)
                    enemy2.charmed = charmDuration;
                elseif(enemy3.charmed ~= 0)
                    enemy3.charmed = charmDuration;
                end
            end
            

            % update all enemy root status
            enemy1.rooted = rootDuration;
            enemy2.rooted = rootDuration;
            enemy3.rooted = rootDuration;
       end
    end    
% if loot claimed, just decrement enemy statuses.   
else
    
    % update the enemy's statuses with decremented charm duration and root duration
    % that were inputed
    
    % update the currently charmed enemy's status 
    if( (enemy1.charmed ~= 0)||(enemy2.charmed ~= 0)||(enemy3.charmed ~= 0) )
       if(enemy1.charmed ~= 0)
           enemy1.charmed = charmDuration;
       elseif(enemy2.charmed ~= 0)
           enemy2.charmed = charmDuration;
       elseif(enemy3.charmed ~= 0)
           enemy3.charmed = charmDuration;
       end
    end
    
    % update all enemy root status
    enemy1.rooted = rootDuration;
    enemy2.rooted = rootDuration;
    enemy3.rooted = rootDuration;
end

end