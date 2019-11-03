function actionsTable = possibleActions(G, explorer_id)
neighbor_list = neighbors(G,explorer_id);
actions = zeros(length(neighbor_list),1);

% determine actions to get to each neighbor
for i = 1:1:length(neighbor_list)
    diff = neighbor_list(i) - explorer_id;
    
    if(diff>0)
        if(diff>1)
            actions(i) = 4; % up
%             actions(i) = "up"; % up
        else
            actions(i) = 3; % right
        end
    else
        if(diff < -1)
            actions(i) = 1; % down
        else
            actions(i) = 2; % left
        end
    end    
end

% can put item/loot checker here to generate expected rewards for actions

% put this info into an actionsTable
actionsTable = table(actions,neighbor_list,'VariableNames',{'Actions' 'Next_Position'});

end


