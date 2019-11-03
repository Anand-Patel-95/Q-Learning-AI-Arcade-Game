function CharmInput = CalcCharmInput(charmDuration)

a = 9; % max duration for charm

% charm duration remaining/total duration
% CharmInput = charmDuration/a;
CharmInput = charmDuration + 1; % [1,10] where [0 turns left, 9 turns left]

end