function Theta_init = zufallsinitialisierung_gewichte_V001(anzahl_features, anzahl_hiddenlayer, anzahl_knoten_hiddenlayer, anzahl_outputs)
% ZUFALLSINITIALISIERUNG_GEWICHTE_V001
% Die Funktion erstellt Initialisierungs-Matrizen Theta_init, welche für das neuronale Netz als
% Startwert genutzt werden können.
% Die Matrizen beinhalten zufällige Werte, damit die Symmetrie des Systems
% gebrochen wird (kann ansonsten nicht lernen).

% Die Matrizen haben die Größe (s_j+1 x (s_j + 1)) --> +1 aufgrund der Bias-Unit.

knoten_anzahl = [anzahl_features, ones(1,anzahl_hiddenlayer) * anzahl_knoten_hiddenlayer, anzahl_outputs];

Theta_init = cell(1, length(knoten_anzahl) - 1);
for i = 1:1:(length(knoten_anzahl)-1)
    anzahl_knoten_1 = knoten_anzahl(i);
    anzahl_knoten_2 = knoten_anzahl(i+1);
    
    % Die Werte liegen zwischen -epsilon und epsilon.
    % Empfehlung für Epsilon: Wurzel(6) / Wurzel(Anzahl Knoten Eingang + Anzahl
    % Knoten Ausgang) --> Wobei die Daten für Bias-Unit ausgenommen werden.
    epsilon_init = sqrt(6) / sqrt(anzahl_knoten_1 + anzahl_knoten_2);
    % anzahl_knoten_1 + 1 für die Bias-Unit.
    Theta_init{i} = rand(anzahl_knoten_2, anzahl_knoten_1 + 1) * 2 * epsilon_init - epsilon_init;
end
    
end

