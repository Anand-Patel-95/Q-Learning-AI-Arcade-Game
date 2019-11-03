function SameDirectionInputTable = CalcSameDirectionInput(previous_action, actionsTable)
% previous_action = explorer.last_action;

SameDirection_List = zeros(length(actionsTable.Actions),1);
for i=1:1:length(actionsTable.Actions)
   if(actionsTable.Actions(i) == previous_action)
       SameDirection_List(i,1) = 1;
   else
       SameDirection_List(i,1) = 0;
   end
   SameDirection_List(i,1) = SameDirection_List(i,1) +1; %+1 for indexing. [1,2] = [notsame,same]
end

SameDirectionInputTable = table(actionsTable.Actions, SameDirection_List, 'VariableNames',{'Actions' 'SameDirectionInput'});

end