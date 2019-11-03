function safe_routes = CalcSafeRoutes(G, explorer_id, enemy1, enemy2, enemy3, checkIntersections, IntersectionTable, NodeTable)
% make sure explorer location is not counted as intersection
IntersectionTable = IntersectionTable(IntersectionTable.ID ~= explorer_id,:);
% ID, distance2explorer, 2nd node on path to ID, # intersections away from
% explorer
Intersection_List = zeros(height(IntersectionTable),4);
Intersection_List(:,1) = IntersectionTable.ID;

for i=1:1:length(Intersection_List)
    [temp_path, Intersection_List(i,2)] = shortestpath(G,explorer_id, Intersection_List(i,1));
    Intersection_List(i,3) = temp_path(2);
    % count # of intersections along the shortest path
    numIntersections = 0;
    for j=2:1:length(temp_path)
        if(NodeTable.Intersection(temp_path(j)) == 1)
            numIntersections = numIntersections + 1;
        end
    end
    Intersection_List(i,4) = numIntersections;
end

checking_routes = [];
for i=1:1:length(Intersection_List)
   if(Intersection_List(i,4)==checkIntersections)
       checking_routes = [checking_routes;Intersection_List(i,:)];
   end
end
% checking_routes
safe_routes = [];
max_i = length(checking_routes(:,1));
for index=1:1:max_i
   d1 = 24;
   d2 = 24;
   d3 = 24;
   
   if(enemy1.killed == 0)
       [~,d1] = shortestpath(G,enemy1.id, checking_routes(index,1));
   end
   if(enemy2.killed == 0)
       [~,d2] = shortestpath(G,enemy2.id, checking_routes(index,1));
   end
   if(enemy3.killed == 0)
       [~,d3] = shortestpath(G,enemy3.id, checking_routes(index,1));
   end
   
   if((checking_routes(index,2)<d1) && (checking_routes(index,2)<d2) && (checking_routes(index,2)<d3))
      safe_routes = [safe_routes;checking_routes(index,:)];
   end
%    index

   if(index == max_i)
       break;
   end
end

end