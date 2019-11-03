function RootInput = CalcRootInput(rootDuration)

a = 5; % max duration for root

% root duration remaining/total duration
% RootInput = rootDuration/a;
RootInput = rootDuration+1; % [1,6] where [0 turns left, 5 turns left]

end