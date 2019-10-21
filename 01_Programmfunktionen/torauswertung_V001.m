function torauswertung_V001()
% TORAUSWERTUNG_V001
% Wertet den Spielausgang statistisch aus.

close all;

rohdatentabelle = evalin('base', 'rohdatentabelle');

%% Auswärtung der geschossenen Tore.
saisons = 2019:2019;


for i = 0:1:length(saisons)
    if (i == 0)
        % Nimm alle Saisons.
        pos_daten = 1:1:length(rohdatentabelle.FTHG);
    else
        % Nimm die jeweilige Saison.
        pos_daten = find(rohdatentabelle.Saison == saisons(i));
    end
    tore_max = 7;
    anzahl_spiele = length(pos_daten);
    auswertung_tore = zeros(tore_max+1);
    for hg = 0:1:tore_max
        for ag = 0:1:tore_max
            
            % ####################### NUR FUER 2019 !!! ##################
            if (hg == 0 && ag == 0)
                continue;
            end
            % ############################################################
            
            auswertung_tore(hg+1, ag+1) = length(find(rohdatentabelle.FTHG(pos_daten) == hg & rohdatentabelle.FTAG(pos_daten) == ag));
        end
    end
    auswertung_tore = auswertung_tore ./ anzahl_spiele;
    figure_handle = figure();
    bar_handle = bar3(auswertung_tore);
    xlabel('Tore des Auswärtsteams')
    ylabel('Tore des Heimteams')
    zlabel('Wahrscheinlichkeit')
    if (i == 0)
        title(['Auswertung der Endstände der Spiele der Saisons von ' num2str(min(saisons)) ' bis ' num2str(max(saisons))])
    else
        title(['Auswertung der Endstände der Spiele der Saison ' num2str(saisons(i))])
    end
    set(gca, 'XTickLabel', num2str([0:1:tore_max].'))
    set(gca, 'YTickLabel', num2str([0:1:tore_max].'))
    axis([0, 9, 0, 9, 0, 0.2])
    
    % Farbskala.
    for k = 1:length(bar_handle)
        zdata = bar_handle(k).ZData;
        bar_handle(k).CData = zdata;
        bar_handle(k).FaceColor = 'interp';
    end
    colorbar;
    view(75, 40)

    % Bild abspeichern.
    set(figure_handle, 'Position', [0 0 2000 1000]);
    pause(0.5);
    if (i == 0)
        dateiname = 'Auswertung_Endstand_alle_Saisons.png';
    else
        dateiname = ['Auswertung_Endstand_Saison_' num2str(saisons(i)) '.png'];
    end
    saveas(figure_handle, dateiname);
    close(figure_handle);
end

end

