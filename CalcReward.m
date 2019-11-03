function [R,GameOver, Caught] = CalcReward(node_id, enemy1, enemy2, enemy3, lootTable, itemTable, enemy_start, current_action, previous_action)

GameOver = 0;
Caught = 0;

% Reward for taking step is -1
R = -1;

% Check if this node is the door
if(node_id == enemy_start)
    % Reward for reaching door is +400
    R = R + 400;
    % flag that game is over
    GameOver = 1;
end

% Check if this node is (not killed or not charmed) enemy's location 
if((enemy1.killed == 0) && (enemy1.charmed == 0) && (node_id == enemy1.id))    

   % Reward for getting caught by enemy is -1000
   R = R - 1000;
   % flag that game is over
   GameOver = 1;
   % flag that you have been caught
   Caught = 1;

elseif((enemy2.killed == 0) && (enemy2.charmed == 0) && (node_id == enemy2.id))    

   % Reward for getting caught by enemy is -1000
   R = R - 1000;
   % flag that game is over
   GameOver = 1;
   % flag that you have been caught
   Caught = 1;

elseif((enemy3.killed == 0) && (enemy3.charmed == 0) && (node_id == enemy3.id))    

   % Reward for getting caught by enemy is -1000
   R = R - 1000;
   % flag that game is over
   GameOver = 1;
   % flag that you have been caught
   Caught = 1;
    
end

% Check if this node is on some loot
for i=1:1:length(lootTable.id)
    if(node_id == lootTable.id(i))
       % Reward for loot is +[3x(value)]
       R = R + 3*lootTable.value(i);
       break;
    end    
end
    
% Check if this node is on some item
for i=1:1:length(itemTable.id)
    if(node_id == itemTable.id(i))
       % Reward for item is +6
       R = R + 6;
       break;
    end    
end

% Check if explorer has reversed directions 
% determine opposite directions
if(previous_action == 1)
    reverse_action = 4;
elseif(previous_action == 2)
    reverse_action = 3;
elseif(previous_action == 3)
    reverse_action = 2;
elseif(previous_action == 4)
    reverse_action = 1;
else
    reverse_action = 0;
end
% if new action reverses directions
if(current_action == reverse_action)
    R = R - 1.2;
end

end