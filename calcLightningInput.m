function LightningInput = calcLightningInput(itemTable)
temp_table = itemTable(itemTable.type==3,:);

if(height(temp_table) == 1) % if lightning item still in table (still unclaimed)
    a = 0;
else
    a = 1;
end

% LightningInput = a;
LightningInput = a+1;   % +1 for matlab indexing for Q-table


end