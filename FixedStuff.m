function [lootTable,itemTable] = FixedStuff
temp1 = transpose([66 55 30 103 42 28  29  16  40  52   95 89  39  70  96   81  27  57  9  54  14]);
temp2 = transpose([13 11 11 7 7 7 5 5 5 5 3 3 3 3 3 2 2 2 2 2 2]);

temp3 = transpose([43 72 48 76 38]);
temp4 = transpose([1 1 2 2 3]);

SameNode = 0;

% check to make sure no doubling up on nodes
for i=1:1:length(temp1)
    for j=1:1:length(temp3)
        if(temp1(i)==temp3(j))
            SameNode = 1;
            break
        end
    end
end

if(SameNode == 0)
lootTable = table(temp1,temp2,'VariableNames',{'id' 'value'});

itemTable = table(temp3,temp4,'VariableNames',{'id' 'type'});
else
    lootTable = 0;
    itemTable = 0;
end

end