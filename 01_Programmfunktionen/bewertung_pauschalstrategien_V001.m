function bewertung_pauschalstrategien_V001()
% BEWERTUNG_PAUSCHALSTRATEGIEN
% Bewertet pauschale Tipp-Strategien.

% Rohdaten importieren.
rohdatentabelle = evalin('base', 'rohdatentabelle');

% Zu analysierende Saisons.
saisons = 2009:2018;

% Definition Tippstrategien.
% Dauerhaftes Tippen von 1 - 1.
strategien = [  1,  0; ...
                1,  1; ...
                2,  1; ...
                1,  2];
anzahl_strategien = size(strategien, 1);
            
% Tippstrategien durchlaufen.
for i = 1:1:anzahl_strategien
    figure_handle = figure;
    hold on
    for saison = saisons
        pos_daten = find((rohdatentabelle.Liga == 1) & (rohdatentabelle.Saison == saison));
        tipppunkte = berechne_tipppunkte_V001(  zeros(length(pos_daten),1) + strategien(i,1), ...
                                                zeros(length(pos_daten),1) + strategien(i,2), ...
                                                rohdatentabelle.FTHG(pos_daten), ...
                                                rohdatentabelle.FTAG(pos_daten));
        punkte = zeros(1,length(tipppunkte));
        for j = 1:1:length(tipppunkte)
            if (j == 1)
                punkte(j) = tipppunkte(j);
            else
                punkte(j) = punkte(j-1) + tipppunkte(j);
            end
        end
        [linie, farbe] = erstelle_linieneigenschaften_V001(min(saisons) - saison + 1);
        plot(1:1:length(pos_daten), punkte, 'Color', farbe, 'LineWidth', 2);
    end
    hold off
    title(['Bewertung der Pauschal-Strategie ''' num2str(strategien(i,1)) ' - ' num2str(strategien(i,2)) ''' anhand der Saisons ' num2str(min(saisons)) ' bis ' num2str(max(saisons))])
    xlabel('Fortlaufende Nummer Tippabgabe')
    ylabel('Tipppunkte')
    legend(num2str(saisons(:)), 'Location', 'NorthEast');
    axis([0 400 0 700])
    grid on
    box on
    set(figure_handle, 'Position', [0 0 1800 1200]);
    saveas(figure_handle, ['Pauschalstrategie' num2str(i) '.png']);
end

end

