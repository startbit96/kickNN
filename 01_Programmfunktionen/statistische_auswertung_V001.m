function statistische_auswertung_V001()
% STATISTISCHE_AUSWERTUNG_V001 Erstellt eine statistische Auswertung über
% die eingeladenen Spiele. Dies ermöglicht es, das Problemfeld besser zu
% erkunden und eventuelle Einflüsse manuell zu erkennen.

close all;

%% Datenimport.
% Import der Rohdaten.
rohdatentabelle = evalin('base', 'rohdatentabelle');

% Import der Teamnamen.
teamnamen = evalin('base', 'teamnamen');

% Import der Punktetabelle.
punktetabelle = evalin('base', 'punktetabelle');

%% Anzahl Heimsiege, Unentschieden und Auswärtssiege.
% 1. Gesamtheitlich. --> Könnte durch Reihenfolge im Neuronalen Netz
% abgefangen werden.
% 2. Von Verein zu Verein unterschiedlich --> Muss durch die Features
% abgefangen werden.

% Gesamtheitlich (Absolutwerte).
anzahl_heimsieg = length(find(rohdatentabelle.pHT == 3));
anzahl_unentschieden = length(find(rohdatentabelle.pHT == 1));
anzahl_auswaertssieg = length(find(rohdatentabelle.pHT == 0));

figure_bar_gesamt = figure;
bar([anzahl_heimsieg, anzahl_unentschieden, anzahl_auswaertssieg]);
set(gca, 'XTickLabel', {'Heimsieg', 'Unentschieden', 'Auswärtssieg'});
title(['Statistische Auswertung des Heimvorteils von ' num2str(length(rohdatentabelle.pHT)) ' Spielen des der 1. und 2. Bundesliga.']);
ylabel('Anzahl Ereignisse (absolut)');
set(figure_bar_gesamt, 'Position', [0 0 1000 800]);
grid on
assignin('base', 'figure_bar_gesamt', figure_bar_gesamt);

% Für jede Saison separate (Prozentual).
saisons = unique(rohdatentabelle.Saison);
anzahl_heimsieg = zeros(1, length(saisons));
anzahl_unentschieden = zeros(1, length(saisons));
anzahl_auswaertssieg = zeros(1, length(saisons));
for i = 1:1:length(saisons)
    pos_daten = find(rohdatentabelle.Saison == saisons(i));
    anzahl_spiele = length(pos_daten);
    anzahl_heimsieg(i) = length(find(rohdatentabelle.pHT(pos_daten) == 3)) / anzahl_spiele;
    anzahl_unentschieden(i) = length(find(rohdatentabelle.pHT(pos_daten) == 1)) / anzahl_spiele;
    anzahl_auswaertssieg(i) = length(find(rohdatentabelle.pHT(pos_daten) == 0)) / anzahl_spiele;
end
figure_heimvorteil_saisons = figure;
hold on
plot(saisons, anzahl_heimsieg, 'g-', 'LineWidth', 2);
plot(saisons, anzahl_unentschieden, 'b-', 'LineWidth', 2);
plot(saisons, anzahl_auswaertssieg, 'r-', 'LineWidth', 2);
hold off
title(['Statistische Auswertung des Heimvorteils von ' num2str(length(saisons)) ' Saisons der 1. und 2. Bundesliga.'])
xlabel('Saison')
ylabel('Anzahl Ergebnisse (prozentual)')
legend({'Heimsieg', 'Unentschieden', 'Auswärtssieg'});
axis([min(saisons)-1, max(saisons)+1, 0, 1]);
grid on
box on
set(figure_heimvorteil_saisons, 'Position', [0 0 2000 1500]);
assignin('base', 'figure_heimvorteil_saisons', figure_heimvorteil_saisons);

% Für jedes Team separat (Prozentual).
anzahl_ereignisse = zeros(length(teamnamen), 6);
for i = 1:1:length(teamnamen)
    pos_heimspiel = find(rohdatentabelle.nHomeTeam == i);
    pos_auswaertsspiel = find(rohdatentabelle.nAwayTeam == i);
    anzahl_heimspiele = length(pos_heimspiel);
    anzahl_auswaertsspiele = length(pos_auswaertsspiel);
    anzahl_heimspiel_sieg = length(find(rohdatentabelle.pHT(pos_heimspiel) == 3));
    anzahl_heimspiel_unentschieden = length(find(rohdatentabelle.pHT(pos_heimspiel) == 1));
    anzahl_heimspiel_niederlage = length(find(rohdatentabelle.pHT(pos_heimspiel) == 0));
    anzahl_auswaertsspiel_sieg = length(find(rohdatentabelle.pAT(pos_auswaertsspiel) == 3));
    anzahl_auswaertsspiel_unentschieden = length(find(rohdatentabelle.pAT(pos_auswaertsspiel) == 1));
    anzahl_auswaertsspiel_niederlage = length(find(rohdatentabelle.pAT(pos_auswaertsspiel) == 0));
    anzahl_ereignisse(i,:) = [   anzahl_heimspiel_sieg / anzahl_heimspiele, ...
                            anzahl_heimspiel_unentschieden / anzahl_heimspiele, ...
                            anzahl_heimspiel_niederlage / anzahl_heimspiele, ...
                            anzahl_auswaertsspiel_sieg / anzahl_auswaertsspiele, ...
                            anzahl_auswaertsspiel_unentschieden / anzahl_auswaertsspiele, ...
                            anzahl_auswaertsspiel_niederlage / anzahl_auswaertsspiele];
end
figure_bar_individuell = figure;
bar(anzahl_ereignisse, 'stacked');
set(gca,'XTick',1:1:length(teamnamen))
set(gca,'XTickLabel', teamnamen);
set(gca,'XTickLabelRotation',45)
set(gca,'YTick',0:0.1:2)
set(gca,'YTickLabel',num2str([0:0.1:1, 0.1:0.1:1].'))
ylabel('Anzahl Ereignisse (prozentual)');
title(['Statistische Auswertung des Heimvorteils von ' num2str(length(teamnamen)) ' Mannschaften der 1. und 2. Bundesliga.']);
legend({'Heimspiel gewonnen', 'Heimspiel unentschieden', 'Heimspiel verloren', 'Auswärtsspiel gewonnen', 'Auswärtsspiel unentschieden', 'Auswärtsspiel verloren'});
set(figure_bar_individuell, 'Position', [0 0 3000 1500]);
assignin('base', 'figure_bar_individuell', figure_bar_individuell);


%% Punkteverlauf und Platzierungsverlauf von Mannschaften der 1. Bundesliga.
saison = 1963:1970;

% Finde Mannschaften, welche in der ersten Liga spielten.
pos_saison = false(length(rohdatentabelle.Saison), 1);
for i = 1:1:length(saison)
    pos_saison = (rohdatentabelle.Saison == saison(i)) | pos_saison;
end
mannschaften_bundesliga = unique(rohdatentabelle.nHomeTeam((rohdatentabelle.Liga == 1) & (pos_saison)));

figure_punkteverlauf = figure;
hold on
for i = 1:1:length(mannschaften_bundesliga)
    punkteverlauf = zeros(1, length(saison));
    platzierungsverlauf = zeros(1, length(saison));
    for j = 1:1:length(saison)
        pos_daten = find((punktetabelle.liga == 1) & (punktetabelle.saison == saison(j)));
        pos_mannschaft = find(punktetabelle.teams{pos_daten} == mannschaften_bundesliga(i));
        if (isempty(pos_mannschaft) == true)
            % Mannschaft hat in dieser Saison nicht in der 1. Bundesliga
            % gespielt.
            punkteverlauf(j) = -1;
            platzierungsverlauf(j) = 21;
        else
            punkteverlauf(j) = punktetabelle.tabelle{pos_daten}(pos_mannschaft, end);
            platzierungsverlauf(j) = find(punktetabelle.platzierung{pos_daten} == pos_mannschaft);
        end
    end
    [linie, farbe] = erstelle_linieneigenschaften_V001(mannschaften_bundesliga(i));
    plot(saison, platzierungsverlauf, ...
        linie, ...
        'Color', farbe, ...
        'LineWidth', 4);
end
hold off
% title('Verlauf der Tabellenpunkte der Mannschaften der 1. Bundesliga.');
title('Verlauf der Tabellenplatzierung der Mannschaften der 1. Bundesliga.');
xlabel('Saison');
% ylabel('Tabellenpunkte zu Saisonende');
ylabel('Tabellenplatzierung zu Saisonende');
legend(teamnamen(mannschaften_bundesliga), 'Location', 'eastoutside');
% axis([min(saison), max(saison), 0, 100]);
axis([min(saison), max(saison), 0, 20]);
set(gca, 'YTick', 0:1:20);
grid on
box on
set(figure_punkteverlauf, 'Position', [0 0 3000 1500]);
assignin('base', 'figure_punkteverlauf', figure_punkteverlauf);


end
