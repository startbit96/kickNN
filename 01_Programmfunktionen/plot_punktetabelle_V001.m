function figure_handle = plot_punktetabelle_V001(liga, saison)
% PLOT_PUNKTETABELLE_V001 Plottet den Verlauf der Punktetabelle über die
% Spieltage.

% Einlesen der Punktetabelle.
punktetabelle = evalin('base', 'punktetabelle');

% Einlesen der Teamnamen (für die Legende).
teamnamen = evalin('base', 'teamnamen');

% Finden der Position im Struct.
pos_daten = find((punktetabelle.liga == liga) & (punktetabelle.saison == saison));

if (isempty(pos_daten) == true)
    disp(['Punktetabelle für Liga ' num2str(liga) ' | Saison ' num2str(saison) ' existiert nicht!']);
    return;
end

% Tabellenreihenfolge anhand der Punktzahl ermitteln.
[~, platzierung] = sort(punktetabelle.tabelle{pos_daten}(:,size(punktetabelle.tabelle{pos_daten}, 2)), 'descend');

% Plotten.
figure_handle = figure;
hold on
for i = 1:1:length(platzierung)
    [linie, farbe] = erstelle_linieneigenschaften_V001(punktetabelle.teams{pos_daten}(platzierung(i)));
    plot(0:1:size(punktetabelle.tabelle{pos_daten},2), [0 punktetabelle.tabelle{pos_daten}(platzierung(i),:)], ...
        linie, ...
        'Color', farbe, ...
        'LineWidth', 2);
end
hold off
title(['Punktetabelle Liga ' num2str(liga) ' | Saison ' num2str(saison)])
xlabel('Spieltag')
ylabel('Tabellenpunkte')
legend(teamnamen(punktetabelle.teams{pos_daten}(platzierung)), 'Location', 'NorthWest')
axis([0, 40, 0 100]);
set(figure_handle, 'Position', [0 0 2000 1000]);
grid on
box on

end