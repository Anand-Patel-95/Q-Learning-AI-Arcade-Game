function EntrapmentInputTable = CalcEntrapmentInput(G, explorer_id, enemy1, enemy2, enemy3, IntersectionTable, NodeTable, actionsTable)

safe_routes_3 = CalcSafeRoutes(G, explorer_id, enemy1, enemy2, enemy3, 3, IntersectionTable, NodeTable);
safe_routes_2 = CalcSafeRoutes(G, explorer_id, enemy1, enemy2, enemy3, 2, IntersectionTable, NodeTable);
safe_routes_1 = CalcSafeRoutes(G, explorer_id, enemy1, enemy2, enemy3, 1, IntersectionTable, NodeTable);

if(isempty(safe_routes_3))
    if(isempty(safe_routes_2))
        safe_routes = safe_routes_1;    % if safe_routes_3 & safe_routes_2 are both empty, use safe_route_1
    else
        safe_routes = safe_routes_2;    % if safe_routes_3 is empty, use safe_routes_2
    end
else
    safe_routes = safe_routes_3;        % default: if safe_route_3 is NOT EMPTY, use it
end

% Entrapment_List = [];
% debugging
% safe_routes

Entrapment_List = zeros(length(actionsTable.Actions),1);

% if the safe_routes list is empty, consider this the worst case for
% EntrapmentInput ==> 10+1
if(isempty(safe_routes))
    Entrapment_List = Entrapment_List + 11;
else
    for i=1:length(actionsTable.Actions)
        numPaths = 0;
       % count the number of safe paths that begin with this action
       for j=1:1:length(safe_routes(:,1))
          if(actionsTable.Next_Position(i) == safe_routes(j,3))
             numPaths = numPaths + 1; 
          end 
       end
       % calculate entrapment input for this action (# of safe paths NOT on route/total safe_routes) 
        EntrapmentInput = (length(safe_routes(:,1)) - numPaths)/length(safe_routes(:,1));
        EntrapmentInput = round(EntrapmentInput*10)+1;  %+1 for indexing
        Entrapment_List(i) = EntrapmentInput;
    end
end
EntrapmentInputTable = table(actionsTable.Actions, Entrapment_List, 'VariableNames',{'Actions' 'EntrapmentInput'});

end