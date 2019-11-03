function plotEpisode(G, x, y, enemy1_path, enemy2_path, enemy3_path, explorer_path, enemy1, enemy2, enemy3, explorer)
figure(3)
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
end 