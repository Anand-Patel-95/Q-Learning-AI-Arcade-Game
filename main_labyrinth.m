%% Build Graph (Do first)
nodeFile = 'nodes.csv';
edgeFile = 'edges.csv';

startNodeID = 1;
goalNodeID = 80;

nodes = csvread(nodeFile);
edges = csvread(edgeFile);


% make things easy for matlab to plot
numNodes = nodes(1,1);
numEdges = edges(1,1);

nodes = nodes(2:end,:);   % remove node count (first row)
edges = edges(2:end,:);   % remove edge count (first row)

j = 1;
for i = 1:1:length(edges)
    if(edges(i,2)>edges(i,1))
        edges2(j,1) = edges(i,1);
        edges2(j,2) = edges(i,2);
        j=j+1;
    end
end

EdgeTable = table([edges2(:,1) edges2(:,2)],'VariableNames',{'EndNodes'});
NodeTable = table(nodes(:,1),nodes(:,2),nodes(:,3),nodes(:,4),nodes(:,5),'VariableNames',{'ID' 'X' 'Y' 'Intersection' 'Door'});
G = graph(EdgeTable,NodeTable);

IntersectionTable = NodeTable(NodeTable.Intersection==1,:);

%% Visualization Set Up. For plotting graph to look like labyrinth
% For plotting graph to look like labyrinth
for i = 1:1:length(nodes)
    x(1,i) = nodes(i,2);
    y(1,i) = nodes(i,3);
end

figure
p = plot(G,'XData',x,'YData',y,'NodeLabel',G.Nodes.ID);

% shortest path between 2 nodes
[path1,d] = shortestpath(G,100,80)
highlight(p,path1,'EdgeColor','r')

%% Initialize the critic Q(S,A) with 0. For New Training ONLY
Q_table = zeros(4,25,2,10,6,25,25,25,11,2);
% actions (4), doorinput (25), lightninginput(2), charminput(11),
% rootinput(6), enemyinput(25), lootproxinput(25), itemproxinput(25),
% entrapmentinput(11), samedirectioninput(2)

%% Declare Training Settings. Always run before the training/testing
Training = 0;
Testing = 1;
% number of episodes for training on or testing on.
numEpisodes = 300;

if(Training == 1)
   % Learning Rate
%    alpha = 0.0003;
   alpha = 0.1;

   % Discount Factor
   gamma = 0.945;
   % Annealing Exploration
   epsilon = 0.9;   % starting epsilon value
%    epsilon_decay_rate = 0.0005;
%    epsilon_decay_rate = 6.28e-4;
   epsilon_min = 0.1;   % minimum epsilon value
  epsilon_decay_rate = 1 - (epsilon_min/epsilon)^(1/(4700-1));

elseif(Testing == 1)
    alpha = 0;
    gamma = 0;
    % No exploration during testing
    epsilon = 0;   % starting epsilon value
    epsilon_decay_rate = 0;
    epsilon_min = 0.1;   % minimum epsilon value
end

% PreAllocate sizes of metrics lists
List_Failure = zeros(numEpisodes,1);
List_LootCollected = zeros(numEpisodes,1);
List_LightningUsed = zeros(numEpisodes,1);
List_CharmUsed = zeros(numEpisodes,1);
List_RootUsed = zeros(numEpisodes,1);
List_numTurns = zeros(numEpisodes,1);

% indicate when to save data for visualization. Array indicates episode
% numbers for when to save data for visualization
Episode_Save = [numEpisodes];

%% TRAINING: Complete Episodes

% For each training episode
for currentEpisode = 1:1:numEpisodes
    % Initialize Enemies, Explorer, Loot, Items at the start of every
    % episode.
    [~, enemy_start] = max(G.Nodes.Door);   % start @ door
    explorer_start = 4;
    
    % Initialize the 3 enemies
    enemy1.id = enemy_start;
    enemy1.old_id = enemy_start;
    enemy1.killed = 0;              % status = 0 means unafflicted
    enemy1.charmed = 0;
    enemy1.rooted = 0;
    enemy1_path = [enemy1.id];
    enemy1_lightning_status = [enemy1.killed];
    enemy1_charmed_status = [enemy1.charmed];
    enemy1_rooted_status = [enemy1.rooted];

    enemy2.id = enemy_start;
    enemy2.old_id = enemy_start;
    enemy2.killed = 0;
    enemy2.charmed = 0;
    enemy2.rooted = 0;
    enemy2_path = [enemy2.id];
    enemy2_lightning_status = [enemy2.killed];
    enemy2_charmed_status = [enemy2.charmed];
    enemy2_rooted_status = [enemy2.rooted];

    enemy3.id = enemy_start;
    enemy3.old_id = enemy_start;
    enemy3.killed = 0;
    enemy3.charmed = 0;
    enemy3.rooted = 0;
    enemy3_path = [enemy3.id];
    enemy3_lightning_status = [enemy3.killed];
    enemy3_charmed_status = [enemy3.charmed];
    enemy3_rooted_status = [enemy3.rooted];

%     numTurns = 100;

    % place items & loot at designated nodes
    % random placement:
%     [lootTable, itemTable] = placeStuff(NodeTable, explorer_start, enemy_start);
    % fixed placement:
    [lootTable,itemTable] = FixedStuff;
    
    % initialize explorer at episode start
    explorer.id = explorer_start;       % current node id
    explorer.old_id = explorer_start;   % previous node id
    explorer.ValueCollected = 0;    % loot value collected
    explorer.charmsUsed = 0;         % number of charm items picked up
    explorer.rootsUsed = 0;          % number of root items picked up
    explorer.lightningsUsed = 0;     % number of lightning items picked up
    explorer.last_action = 0;       % last action taken by explorer
    explorer.last_action_prev = 0;   % previous last action taken by explorer

    explorer_path = [explorer.id];
    explorer_loot = [explorer.ValueCollected];


    % initialize charmDuration to 0
    charmDuration = 0;

    % initialize rootDuration to 0
    rootDuration = 0;
    
    % Initialize GameOver & Caught flags
    GameOver = 0;
    Caught = 0;
    
    % initialize # of turns
    numTurns = 1;
    
    while(GameOver == 0)
        % Move Enemies who are not rooted or killed------------------------
        if((enemy1.killed == 0) && (enemy1.rooted == 0))    
            [enemy1.id, enemy1.old_id] = enemyMove2(G, enemy1);
%             enemy1_path = [enemy1_path enemy1.id];
        end

        if((enemy2.killed == 0) && (enemy2.rooted == 0))    
            [enemy2.id, enemy2.old_id] = enemyMove2(G, enemy2);
%             enemy2_path = [enemy2_path enemy2.id];
        end    

        if((enemy3.killed == 0) && (enemy3.rooted == 0))    
            [enemy3.id, enemy3.old_id] = enemyMove2(G, enemy3);
%             enemy3_path = [enemy3_path enemy3.id];
        end  

        % check if any enemy has walked onto explorer. If so, update the
        % Q-value for the last StateAction_taken for the terminal case
        temp1 = ((enemy1.killed == 0) && (enemy1.charmed == 0) && (enemy1.id == explorer.id));
        temp2 = ((enemy2.killed == 0) && (enemy2.charmed == 0) && (enemy2.id == explorer.id));
        temp3 = ((enemy3.killed == 0) && (enemy3.charmed == 0) && (enemy3.id == explorer.id));
        if(temp1||temp2||temp3)
            GameOver = 1;
            Caught = 1;

            % recalculate Q-value for Q(S,A) with terminal state
            y_target = R - 1000; 
            del_Q = y_target - Q_now;
            Q_new = Q_now + alpha*del_Q;
            Q_table(StateAction_taken.Actions, StateAction_taken.DoorInput, StateAction_taken.LightningInput, StateAction_taken.CharmInput, StateAction_taken.RootInput, StateAction_taken.EnemyInput, StateAction_taken.LootProxInput, StateAction_taken.ItemProxInput, StateAction_taken.EntrapmentInput, StateAction_taken.SameDirectionInput) = Q_new;
            % break;
        end
        
        % End here if enemy has walked onto explorer
        if(Caught == 1)
            break;
        end
        
        % Explorer moves + Q-Learning--------------------------------------
        % Generate table of possible actions for current node/state S and next node
        actionsTable = possibleActions(G, explorer.id);

        % Generate Inputs/State-Action Pairs
        StateActionTable = calcStateActionTable(G, explorer.id, explorer.last_action, enemy1, enemy2, enemy3, enemy_start, actionsTable, itemTable, charmDuration, rootDuration, lootTable, IntersectionTable, NodeTable);

        % For the current observation S, select a random action A with probability
        % epsilon. Otherwise, select the action for which the critic value function is
        % greatest: A = max[Q(S,A)]
           if(rand > epsilon)
              [Q_now, StateAction_taken, new_id, action_taken] = CalcMaxQ(Q_table,actionsTable,StateActionTable);
           else
              [Q_now, StateAction_taken, new_id, action_taken] = ExplorerRandom(G, explorer, Q_table, actionsTable, StateActionTable);
           end

        % Execute action A. Observe the reward R and next observation S'
        % Take action A, and set the new explorer node to Next_Position (new_id)
        explorer.old_id = explorer.id;                      % store old
        explorer.last_action_prev = explorer.last_action;
        explorer.id = new_id;                               % update new
        explorer.last_action = action_taken;
        
        % save path if this is one of the recorded episodes
%         if(ismember(currentEpisode,Episode_Save))
%             explorer_path = [explorer_path explorer.id];
%         end
%         explorer_path = [explorer_path explorer.id];
        
        % Updating charm duration (decrement by 1 for one turn passing)
        if (charmDuration > 0) % if charm is active
            % decrease by 1 after explorer moves
            charmDuration = charmDuration - 1;
        end

        % Updating root duration  (decrement by 1 for one turn pass ing)
        if (rootDuration > 0) % if root is active
            % decrease by 1 after explorer moves
            rootDuration = rootDuration - 1;
        end

        % Calculate reward @ new node
        [R,GameOver, Caught] = CalcReward(explorer.id, enemy1, enemy2, enemy3, lootTable, itemTable, enemy_start, explorer.last_action, explorer.last_action_prev);

        % % Update Game after claiming stuff at the new node:
        % % Remove loot/item at new node from tables, reset durations, update explorer,
        % % update enemies' statuses
        [lootTable, itemTable, charmDuration, rootDuration, explorer, enemy1, enemy2, enemy3] = UpdateGame(G, lootTable, itemTable, charmDuration, rootDuration, explorer, enemy1, enemy2, enemy3);
        % update metrics for visualization if this is an episode set to
        % record/save (also save if WIN)
        if(ismember(currentEpisode,Episode_Save) || ((GameOver == 1)&&(Caught==0)))
            enemy1_path = [enemy1_path enemy1.id];
            enemy2_path = [enemy2_path enemy2.id];
            enemy3_path = [enemy3_path enemy3.id];
            explorer_path = [explorer_path explorer.id];
            
            explorer_loot = [explorer_loot   explorer.ValueCollected];
            enemy1_lightning_status = [enemy1_lightning_status enemy1.killed];
            enemy1_charmed_status = [enemy1_charmed_status enemy1.charmed];
            enemy1_rooted_status = [enemy1_rooted_status enemy1.rooted];
            enemy2_lightning_status = [enemy2_lightning_status enemy2.killed];
            enemy2_charmed_status = [enemy2_charmed_status enemy2.charmed];
            enemy2_rooted_status = [enemy2_rooted_status enemy2.rooted];
            enemy3_lightning_status = [enemy3_lightning_status enemy3.killed];
            enemy3_charmed_status = [enemy3_charmed_status enemy3.charmed];
            enemy3_rooted_status = [enemy3_rooted_status enemy3.rooted];
        end
        
        % Calculate value function target y
        if(GameOver == 1)
           % If S' is a terminal state, set the value function target y to R.
           y_target = R;  
        else
           % Otherwise set it to y = R + gamma*max[Q(S',A)]
           actionsTable_next = possibleActions(G, explorer.id);
           StateActionTable_next = calcStateActionTable(G, explorer.id, explorer.last_action, enemy1, enemy2, enemy3, enemy_start, actionsTable_next, itemTable, charmDuration, rootDuration, lootTable, IntersectionTable, NodeTable);
           [Q_next_max, ~, ~, ~] = CalcMaxQ(Q_table, actionsTable_next, StateActionTable_next);

           y_target = R +  gamma*Q_next_max;
        end

        % Compute the critic parameter update.
        del_Q = y_target - Q_now;
        Q_new = Q_now + alpha*del_Q;

        % Update the critic Q-table using the learning rate alpha.
        % Note: Using function to update is too slow
        % Q_table = UpdateQtable(Q_table, Q_now, StateAction_taken, alpha, del_Q);
        Q_table(StateAction_taken.Actions, StateAction_taken.DoorInput, StateAction_taken.LightningInput, StateAction_taken.CharmInput, StateAction_taken.RootInput, StateAction_taken.EnemyInput, StateAction_taken.LootProxInput, StateAction_taken.ItemProxInput, StateAction_taken.EntrapmentInput, StateAction_taken.SameDirectionInput) = Q_new;
        
        % add function to break out if too many turns (LOSS):
        if(((numTurns >= 800)&&(Testing == 1))||((numTurns >= 1000)&&(Training == 1)))
            GameOver = 1;
            Caught = 1;
            numTurns
            currentEpisode
        end
        numTurns = numTurns+1;
    end
    
    % update epsilon
    if(epsilon > epsilon_min)
        epsilon = epsilon*(1-epsilon_decay_rate);
    end
    
    % Save this episode for visualization?
    
    % Update metrics for analysis
    List_Failure(currentEpisode) = Caught;
    List_LootCollected(currentEpisode) = explorer.ValueCollected;
    List_LightningUsed(currentEpisode) = explorer.lightningsUsed;
    List_CharmUsed(currentEpisode) = explorer.charmsUsed;
    List_RootUsed(currentEpisode) = explorer.rootsUsed;
    List_numTurns(currentEpisode) = numTurns;
    
    % add print statement for current episode
    print_every = 10;
    if(mod(currentEpisode,print_every)==0)
        currentEpisode
    end
    
    % plot win
%     if((GameOver == 1)&&(Caught==0))
% %     if(currentEpisode == 5)
%         currentEpisode
%         explorer
%         enemy1
%         enemy2
%         enemy3
%         figure
%         p = plot(G,'XData',x,'YData',y,'NodeLabel',G.Nodes.ID);
%         hold on
% 
%         % draw enemy 1 path, and label last location
%         highlight(p,enemy1_path,'EdgeColor','[0.4660 0.6740 0.1880]', 'LineWidth', 2)
%         plot(G.Nodes.X([enemy1.id]), G.Nodes.Y([enemy1.id]), 'MarkerSize', 8, 'Marker', 'o', 'MarkerEdgeColor','[0.4660 0.6740 0.1880]','LineWidth',3)
%         % highlight(p,enemy1_path(length(enemy1_path)),'NodeColor','[0.4660 0.6740 0.1880]', 'MarkerSize', 10, 'Marker', 'x')
% 
%         % draw enemy 2 path, and label last location
%         highlight(p,enemy2_path,'EdgeColor','[0.9290 0.6940 0.1250]', 'LineWidth', 2)
%         plot(G.Nodes.X([enemy2.id]), G.Nodes.Y([enemy2.id]), 'MarkerSize', 8, 'Marker', 'o', 'MarkerEdgeColor','[0.9290 0.6940 0.1250]','LineWidth',3)
% 
%         % draw enemy 3 path, and label last location
%         highlight(p,enemy3_path,'EdgeColor','[0 0.4470 0.7410]', 'LineWidth', 2)
%         plot(G.Nodes.X([enemy3.id]), G.Nodes.Y([enemy3.id]), 'MarkerSize', 8, 'Marker', 'o', 'MarkerEdgeColor','[0 0.4470 0.7410]','LineWidth',3)
% 
%         % draw explorer path, and label last location
%         highlight(p,explorer_path,'EdgeColor','[0.6350, 0.0780, 0.1840]', 'LineWidth', 2)
%         plot(G.Nodes.X([explorer.id]), G.Nodes.Y([explorer.id]), 'MarkerSize', 8, 'Marker', '+', 'MarkerEdgeColor','[0.6350, 0.0780, 0.1840]','LineWidth',3)
% 
%         hold off
% 
% %         break;
%     end
    
end

% currentEpisode

%% Plot enemy paths for paper's implementation

figure(2)
p = plot(G,'XData',x,'YData',y,'NodeLabel',G.Nodes.ID);
hold on

% draw enemy 1 path, and label last location
highlight(p,enemy1_path,'EdgeColor','[0.4660 0.6740 0.1880]', 'LineWidth', 2)
plot(G.Nodes.X([enemy1.id]), G.Nodes.Y([enemy1.id]), 'MarkerSize', 8, 'Marker', 'o', 'MarkerEdgeColor','[0.4660 0.6740 0.1880]','LineWidth',3)
% highlight(p,enemy1_path(length(enemy1_path)),'NodeColor','[0.4660 0.6740 0.1880]', 'MarkerSize', 10, 'Marker', 'x')

% draw enemy 2 path, and label last location
highlight(p,enemy2_path,'EdgeColor','[0.9290 0.6940 0.1250]', 'LineWidth', 2)
plot(G.Nodes.X([enemy2.id]), G.Nodes.Y([enemy2.id]), 'MarkerSize', 8, 'Marker', 'o', 'MarkerEdgeColor','[0.9290 0.6940 0.1250]','LineWidth',3)

% draw enemy 3 path, and label last location
highlight(p,enemy3_path,'EdgeColor','[0 0.4470 0.7410]', 'LineWidth', 2)
plot(G.Nodes.X([enemy3.id]), G.Nodes.Y([enemy3.id]), 'MarkerSize', 8, 'Marker', 'o', 'MarkerEdgeColor','[0 0.4470 0.7410]','LineWidth',3)

% draw explorer path, and label last location
highlight(p,explorer_path,'EdgeColor','[0.6350, 0.0780, 0.1840]', 'LineWidth', 2)
plot(G.Nodes.X([explorer.id]), G.Nodes.Y([explorer.id]), 'MarkerSize', 8, 'Marker', '+', 'MarkerEdgeColor','[0.6350, 0.0780, 0.1840]','LineWidth',3)


hold off

%% Plot step by step playback
% c = @cmu.colors; % shortcut function handle
% figure(3)
% p = plot(G,'XData',x,'YData',y,'NodeLabel',G.Nodes.ID);
% hold on
% 
% [lootTable_temp,itemTable_temp] = FixedStuff;
% highlight(p,lootTable_temp.id,'NodeColor','[0.800000 0.630000 0.210000]', 'Marker', 'd', 'MarkerSize',5)
% highlight(p,itemTable_temp.id([1 2]),'NodeColor','[0.910000 0.330000 0.500000]', 'Marker', '*', 'MarkerSize',8)
% highlight(p,itemTable_temp.id([3 4]),'NodeColor','[0.310000 0.490000 0.160000]', 'Marker', 's', 'MarkerSize',7)
% highlight(p,itemTable_temp.id([5]),'NodeColor','[1.000000 0.800000 0.200000]', 'Marker', 'p', 'MarkerSize',7)
% highlight(p,80,'NodeColor','[0.000000 0.750000 1.000000]', 'Marker', 'o', 'MarkerSize',7)


plot_turns = length(explorer_path);

for turn=1:1:plot_turns
    figure(3)
    p = plot(G,'XData',x,'YData',y);
    hold on

    [lootTable_temp,itemTable_temp] = FixedStuff;
    highlight(p,lootTable_temp.id,'NodeColor','[0.800000 0.630000 0.210000]', 'Marker', 'd', 'MarkerSize',5)
    highlight(p,itemTable_temp.id([1 2]),'NodeColor','[0.910000 0.330000 0.500000]', 'Marker', '*', 'MarkerSize',8)
    highlight(p,itemTable_temp.id([3 4]),'NodeColor','[0.310000 0.490000 0.160000]', 'Marker', 's', 'MarkerSize',7)
    highlight(p,itemTable_temp.id([5]),'NodeColor','[1.000000 0.800000 0.200000]', 'Marker', 'p', 'MarkerSize',7)
    highlight(p,80,'NodeColor','[0.000000 0.750000 1.000000]', 'Marker', 'o', 'MarkerSize',7)
    
    plot(G.Nodes.X([enemy1_path(turn)]), G.Nodes.Y([enemy1_path(turn)]), 'MarkerSize', 10, 'Marker', 'd', 'MarkerEdgeColor','[0.880000 0.070000 0.370000]','LineWidth',2)
    plot(G.Nodes.X([enemy2_path(turn)]), G.Nodes.Y([enemy2_path(turn)]), 'MarkerSize', 10, 'Marker', 'd', 'MarkerEdgeColor','[0.880000 0.070000 0.370000]','LineWidth',2)
    plot(G.Nodes.X([enemy3_path(turn)]), G.Nodes.Y([enemy3_path(turn)]), 'MarkerSize', 10, 'Marker', 'd', 'MarkerEdgeColor','[0.880000 0.070000 0.370000]','LineWidth',2)
    plot(G.Nodes.X([explorer_path(turn)]), G.Nodes.Y([explorer_path(turn)]), 'MarkerSize', 10, 'Marker', 'o', 'MarkerEdgeColor','[0.630000 0.840000 0.710000]','LineWidth',2)

    hold off

    
end
% % draw enemy 1 path, and label last location
% highlight(p,enemy1_path,'EdgeColor','[0.4660 0.6740 0.1880]', 'LineWidth', 2)
% plot(G.Nodes.X([enemy1.id]), G.Nodes.Y([enemy1.id]), 'MarkerSize', 8, 'Marker', 'o', 'MarkerEdgeColor','[0.4660 0.6740 0.1880]','LineWidth',3)
% % highlight(p,enemy1_path(length(enemy1_path)),'NodeColor','[0.4660 0.6740 0.1880]', 'MarkerSize', 10, 'Marker', 'x')
% 
% % draw enemy 2 path, and label last location
% highlight(p,enemy2_path,'EdgeColor','[0.9290 0.6940 0.1250]', 'LineWidth', 2)
% plot(G.Nodes.X([enemy2.id]), G.Nodes.Y([enemy2.id]), 'MarkerSize', 8, 'Marker', 'o', 'MarkerEdgeColor','[0.9290 0.6940 0.1250]','LineWidth',3)
% 
% % draw enemy 3 path, and label last location
% highlight(p,enemy3_path,'EdgeColor','[0 0.4470 0.7410]', 'LineWidth', 2)
% plot(G.Nodes.X([enemy3.id]), G.Nodes.Y([enemy3.id]), 'MarkerSize', 8, 'Marker', 'o', 'MarkerEdgeColor','[0 0.4470 0.7410]','LineWidth',3)
% 
% % draw explorer path, and label last location
% highlight(p,explorer_path,'EdgeColor','[0.6350, 0.0780, 0.1840]', 'LineWidth', 2)
% plot(G.Nodes.X([explorer.id]), G.Nodes.Y([explorer.id]), 'MarkerSize', 8, 'Marker', '+', 'MarkerEdgeColor','[0.6350, 0.0780, 0.1840]','LineWidth',3)


% hold off



%% Plotting Metrics
x_step = linspace(1,numEpisodes,numEpisodes);

figure
scatter(x_step,List_Failure,'LineWidth',2)
title('Loss vs Episode during Training')
% title('Loss vs Episode during Testing')
xlabel('episode') 
ylabel('Loss') 
ylim([0 2])

figure
scatter(x_step,List_CharmUsed,'LineWidth',2)
title('Number of Charms Used vs Episode during Training')
% title('Number of Charms Used vs Episode during Testing')
xlabel('episode') 
ylabel('Charms Used') 
ylim([0 3])


figure
scatter(x_step,List_RootUsed,'LineWidth',2)
title('Number of Roots Used vs Episode during Training')
% title('Number of Roots Used vs Episode during Testing')
xlabel('episode') 
ylabel('Roots Used') 
ylim([0 3])

figure
scatter(x_step,List_LightningUsed,'LineWidth',2)
title('Lightning Usage vs Episode during Training')
% title('Lightning Usage vs Episode during Testing')
xlabel('episode') 
ylabel('Lightning Used')
ylim([0 2])

figure
plot(x_step,100*(List_LootCollected/103),'LineWidth',3)
title('Percent of Loot Value Collected vs Episode during Training')
% title('Percent of Loot Value Collected vs Episode during Testing')
xlabel('episode') 
ylabel('%') 
ylim([0 100])

figure
plot(x_step, List_numTurns,'LineWidth',3)
title('Game Duration vs Episode during Training')
% title('Game Duration vs Episode during Testing')
xlabel('episode') 
ylabel('Number of Turns') 


figure
hold on
scatter(x_step,List_CharmUsed,5,'LineWidth',1.5)
scatter(x_step,List_RootUsed,20,'LineWidth',1.5)
scatter(x_step,List_LightningUsed,45,'LineWidth',1.5)
title('Items Used vs Episode during Training')
% title('Items Used vs Episode during Testing')
xlabel('episode') 
ylabel('Number Used') 
ylim([0 2])
legend('Charm','Root', 'Lightning')
hold off

%% Metrics per win

% find the cases where win occured:

List_wins = (List_Failure == 0);


% find arrays containing info for wins:
List_CharmUsed_wins = List_CharmUsed(List_wins);
List_LightningUsed_wins = List_LightningUsed(List_wins);
List_LootCollected_wins = List_LootCollected(List_wins);
List_numTurns_wins = List_numTurns(List_wins);
List_RootUsed_wins = List_RootUsed(List_wins);

% plots of wins
numWins = length(List_numTurns_wins);
x_step = linspace(1,numWins,numWins);

figure
scatter(x_step,List_CharmUsed_wins,'LineWidth',2)
title('Per Win: Number of Charms Used')
% title('Number of Charms Used vs Episode during Testing')
% xlabel('episode') 
ylabel('Charms Used') 
ylim([0 3])


figure
scatter(x_step,List_RootUsed_wins,'LineWidth',2)
title('Per Win: Number of Roots Used')
% title('Number of Roots Used vs Episode during Testing')
% xlabel('episode') 
ylabel('Roots Used') 
ylim([0 3])

figure
scatter(x_step,List_LightningUsed_wins,'LineWidth',2)
title('Per Win: Lightning Usage')
% title('Lightning Usage vs Episode during Testing')
% xlabel('episode') 
ylabel('Lightning Used')
ylim([0 2])

figure
plot(x_step,100*(List_LootCollected_wins/103),'LineWidth',3)
title('Per Win: Percent of Loot Value Collected')
% title('Percent of Loot Value Collected vs Episode during Testing')
% xlabel('episode') 
ylabel('%') 
ylim([0 100])

figure
plot(x_step, List_numTurns_wins,'LineWidth',3)
title('Per Win: Game Duration')
% title('Game Duration vs Episode during Testing')
% xlabel('episode') 
ylabel('Number of Turns') 


figure
hold on
scatter(x_step,List_CharmUsed_wins,5,'LineWidth',1.5)
scatter(x_step,List_RootUsed_wins,20,'LineWidth',1.5)
scatter(x_step,List_LightningUsed_wins,45,'LineWidth',1.5)
title('Per Win: Items Used')
% title('Items Used vs Episode during Testing')
% xlabel('episode') 
ylabel('Number Used') 
ylim([0 2])
legend('Charm','Root', 'Lightning')
hold off

% win percentage
win_percentage = 100*(numWins/numEpisodes);

% percent loot value collected
avg_lootvalue = mean(List_LootCollected);
std_lootvalue = std(List_LootCollected);

% game duration
avg_numTurns = mean(List_numTurns_wins);
std_numTurns = std(List_numTurns_wins);

% items used
avg_lightning = mean(List_LightningUsed_wins);
std_lightning = std(List_LightningUsed_wins);

avg_charm = mean(List_CharmUsed_wins);
std_charm = std(List_CharmUsed_wins);

avg_root = mean(List_RootUsed_wins);
std_root = mean(List_RootUsed_wins);

List_totalitems_win = List_LightningUsed_wins + List_RootUsed_wins + List_CharmUsed_wins;
avg_items = mean(List_totalitems_win);
std_items = std(List_totalitems_win);

%% TESTING: Complete Episodes

% For each testing episode
for currentEpisode = 1:1:numEpisodes
    % Initialize Enemies, Explorer, Loot, Items at the start of every
    % episode.
    [~, enemy_start] = max(G.Nodes.Door);   % start @ door
    explorer_start = 4;
    
    % Initialize the 3 enemies
    enemy1.id = enemy_start;
    enemy1.old_id = enemy_start;
    enemy1.killed = 0;              % status = 0 means unafflicted
    enemy1.charmed = 0;
    enemy1.rooted = 0;
    enemy1_path = [enemy1.id];
    enemy1_lightning_status = [enemy1.killed];
    enemy1_charmed_status = [enemy1.charmed];
    enemy1_rooted_status = [enemy1.rooted];

    enemy2.id = enemy_start;
    enemy2.old_id = enemy_start;
    enemy2.killed = 0;
    enemy2.charmed = 0;
    enemy2.rooted = 0;
    enemy2_path = [enemy2.id];
    enemy2_lightning_status = [enemy2.killed];
    enemy2_charmed_status = [enemy2.charmed];
    enemy2_rooted_status = [enemy2.rooted];

    enemy3.id = enemy_start;
    enemy3.old_id = enemy_start;
    enemy3.killed = 0;
    enemy3.charmed = 0;
    enemy3.rooted = 0;
    enemy3_path = [enemy3.id];
    enemy3_lightning_status = [enemy3.killed];
    enemy3_charmed_status = [enemy3.charmed];
    enemy3_rooted_status = [enemy3.rooted];

%     numTurns = 100;

    % place items & loot at designated nodes
    % random placement:
    % [lootTable, itemTable] = placeStuff(NodeTable, explorer_start, enemy_start);
    % fixed placement:
    [lootTable,itemTable] = FixedStuff;
    
    % initialize explorer at episode start
    explorer.id = explorer_start;       % current node id
    explorer.old_id = explorer_start;   % previous node id
    explorer.ValueCollected = 0;    % loot value collected
    explorer.charmsUsed = 0;         % number of charm items picked up
    explorer.rootsUsed = 0;          % number of root items picked up
    explorer.lightningsUsed = 0;     % number of lightning items picked up
    explorer.last_action = 0;       % last action taken by explorer
    explorer.last_action_prev = 0;   % previous last action taken by explorer

    explorer_path = [explorer.id];
    explorer_loot = [explorer.ValueCollected];


    % initialize charmDuration to 0
    charmDuration = 0;

    % initialize rootDuration to 0
    rootDuration = 0;
    
    % Initialize GameOver & Caught flags
    GameOver = 0;
    Caught = 0;
    
    numTurns = 1;
    
%     for i = 1:1:numTurns
    while(GameOver == 0)
        % Move Enemies who are not rooted or killed------------------------
        if((enemy1.killed == 0) && (enemy1.rooted == 0))    
            [enemy1.id, enemy1.old_id] = enemyMove2(G, enemy1);
%             enemy1_path = [enemy1_path enemy1.id];
        end

        if((enemy2.killed == 0) && (enemy2.rooted == 0))    
            [enemy2.id, enemy2.old_id] = enemyMove2(G, enemy2);
%             enemy2_path = [enemy2_path enemy2.id];
        end    

        if((enemy3.killed == 0) && (enemy3.rooted == 0))    
            [enemy3.id, enemy3.old_id] = enemyMove2(G, enemy3);
%             enemy3_path = [enemy3_path enemy3.id];
        end  

        % check if any enemy has walked onto explorer. If so, update the
        % Q-value for the last StateAction_taken for the terminal case
        temp1 = ((enemy1.killed == 0) && (enemy1.charmed == 0) && (enemy1.id == explorer.id));
        temp2 = ((enemy2.killed == 0) && (enemy2.charmed == 0) && (enemy2.id == explorer.id));
        temp3 = ((enemy3.killed == 0) && (enemy3.charmed == 0) && (enemy3.id == explorer.id));
        if(temp1||temp2||temp3)
            GameOver = 1;
            Caught = 1;
        end
        
        % End here if enemy has walked onto explorer
        if(Caught == 1)
            break;
        end
        
        % Explorer moves + Q-Learning--------------------------------------
        % Generate table of possible actions for current node/state S and next node
        actionsTable = possibleActions(G, explorer.id);

        % Generate Inputs/State-Action Pairs
        StateActionTable = calcStateActionTable(G, explorer.id, explorer.last_action, enemy1, enemy2, enemy3, enemy_start, actionsTable, itemTable, charmDuration, rootDuration, lootTable, IntersectionTable, NodeTable);

        % For the current observation S, select a random action A with probability
        % epsilon. Otherwise, select the action for which the critic value function is
        % greatest: A = max[Q(S,A)]

        [Q_now, StateAction_taken, new_id, action_taken] = CalcMaxQ(Q_table,actionsTable,StateActionTable);


        % Execute action A. Observe the reward R and next observation S'
        % Take action A, and set the new explorer node to Next_Position (new_id)
        explorer.old_id = explorer.id;                      % store old
        explorer.last_action_prev = explorer.last_action;
        explorer.id = new_id;                               % update new
        explorer.last_action = action_taken;
        
%         % save path if this is one of the recorded episodes
%         if(ismember(currentEpisode,Episode_Save))
%             explorer_path = [explorer_path explorer.id];
%         end

        % Updating charm duration (decrement by 1 for one turn passing)
        if (charmDuration > 0) % if charm is active
            % decrease by 1 after explorer moves
            charmDuration = charmDuration - 1;
        end

        % Updating root duration  (decrement by 1 for one turn passing)
        if (rootDuration > 0) % if root is active
            % decrease by 1 after explorer moves
            rootDuration = rootDuration - 1;
        end

        % Calculate reward @ new node
        [~,GameOver, Caught] = CalcReward(explorer.id, enemy1, enemy2, enemy3, lootTable, itemTable, enemy_start, explorer.last_action, explorer.last_action_prev);

        % % Update Game after claiming stuff at the new node:
        % % Remove loot/item at new node from tables, reset durations, update explorer,
        % % update enemies' statuses
        [lootTable, itemTable, charmDuration, rootDuration, explorer, enemy1, enemy2, enemy3] = UpdateGame(G, lootTable, itemTable, charmDuration, rootDuration, explorer, enemy1, enemy2, enemy3);
        % update metrics for visualization if this is an episode set to
        % record/save
        if(ismember(currentEpisode,Episode_Save) || ((GameOver == 1)&&(Caught==0)))
            enemy1_path = [enemy1_path enemy1.id];
            enemy2_path = [enemy2_path enemy2.id];
            enemy3_path = [enemy3_path enemy3.id];
            explorer_path = [explorer_path explorer.id];
            
            explorer_loot = [explorer_loot   explorer.ValueCollected];
            enemy1_lightning_status = [enemy1_lightning_status enemy1.killed];
            enemy1_charmed_status = [enemy1_charmed_status enemy1.charmed];
            enemy1_rooted_status = [enemy1_rooted_status enemy1.rooted];
            enemy2_lightning_status = [enemy2_lightning_status enemy2.killed];
            enemy2_charmed_status = [enemy2_charmed_status enemy2.charmed];
            enemy2_rooted_status = [enemy2_rooted_status enemy2.rooted];
            enemy3_lightning_status = [enemy3_lightning_status enemy3.killed];
            enemy3_charmed_status = [enemy3_charmed_status enemy3.charmed];
            enemy3_rooted_status = [enemy3_rooted_status enemy3.rooted];
        end
        % add function to break out if too many turns (LOSS):
        if(((numTurns >= 800)&&(Testing == 1))||((numTurns >= 1000)&&(Training == 1)))
            GameOver = 1;
            Caught = 1;
            numTurns
            currentEpisode
        end
        numTurns = numTurns+1;
    end
    
    
    % Update metrics for analysis
    List_Failure(currentEpisode) = Caught;
    List_LootCollected(currentEpisode) = explorer.ValueCollected;
    List_LightningUsed(currentEpisode) = explorer.lightningsUsed;
    List_CharmUsed(currentEpisode) = explorer.charmsUsed;
    List_RootUsed(currentEpisode) = explorer.rootsUsed;
    List_numTurns(currentEpisode) = numTurns;
    
    % add print statement for current episode
    print_every = 2;
    if(mod(currentEpisode,print_every)==0)
        currentEpisode
    end
    
end

% currentEpisode
%% Permanent Loot & Item Tables testing
% temp1 = transpose([66 55 30 103 42 28  29  16  40  52   95 89  39  70  96   81  27  57  9  54  14]);
% temp2 = transpose([13 11 11 7 7 7 5 5 5 5 3 3 3 3 3 2 2 2 2 2 2]);
% 
% temp3 = transpose([43 72 48 76 38]);
% temp4 = transpose([1 1 2 2 3]);
% 
% lootTable2 = table(temp1,temp2,'VariableNames',{'id' 'value'});
% 
% itemTable2 = table(temp3,temp4,'VariableNames',{'id' 'type'});

[lootTable2,itemTable2] = FixedStuff;

%% Epsilon test
epsilon_list = zeros(numEpisodes, 1);
epsilon_list(1) = epsilon;
for i=2:1:numEpisodes
    if(epsilon > epsilon_min)
        epsilon = epsilon*(1-epsilon_decay_rate);
        epsilon_list(i) = epsilon;
    else
        epsilon_list(i) = epsilon;
    end
end

% temp = zeros(numEpisodes,1);
% for i=1:1:numEpisodes
%    if(rand > epsilon_list(i))
%        temp(i) = 1;
%    else
%        temp(i) = 0;
%    end
% end

figure(3)
plot(epsilon_list)

% temp2 =  linspace(0,numEpisodes,numEpisodes);
% figure(4)
% scatter(temp2,transpose(temp))