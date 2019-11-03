% function to find the closest intersection along some direction
function Intersection_ID = findIntersection(G, start_ID, direction)
current.id = start_ID;
Intersection_ID = 0;

while(Intersection_ID == 0)
    % get list of possible actions at current node
    actionsTable = possibleActions(G, current.id);
    % get the row that corresponds to the direction of movement
    moveTable = actionsTable(actionsTable.Actions == direction,:);
    % move and set current node to where this action leads from moveTable
    current.id = moveTable.Next_Position;
    
    % check if this current.id is an intersection point
    if(G.Nodes.Intersection(current.id)==1)
        Intersection_ID = current.id;
    end
end

end