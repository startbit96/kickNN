function tipppunkte = berechne_tipppunkte_V001(tore_team1_tipp, tore_team2_tipp, tore_team1_ist, tore_team2_ist)
% BERECHNE_TIPPPUNKTE_V001 Berechnet die Punktzahl, welche im Tippspiel
% erhalten worden wäre.

anzahl_spiele = length(tore_team1_tipp);

% Initialisierung des Rückgabevektors mit Nullen.
tipppunkte = zeros(anzahl_spiele, 1);

for i = 1:1:anzahl_spiele
    if ((tore_team1_tipp(i) == tore_team1_ist(i)) && ...
        (tore_team2_tipp(i) == tore_team2_ist(i)))
        % Ergebnis richtig getippt.
        tipppunkte(i) = 4;
    elseif ((tore_team1_tipp(i) - tore_team2_tipp(i)) == ...
            (tore_team1_ist(i) - tore_team2_ist(i)))
        % Tordifferenz richtig getippt.
        tipppunkte(i) = 3;
    elseif (sign(tore_team1_tipp(i) - tore_team2_tipp(i)) == ...
            sign(tore_team1_ist(i) - tore_team2_ist(i)))
        % Tendenz richtig getippt.
        tipppunkte(i) = 2;
    end
end

end

