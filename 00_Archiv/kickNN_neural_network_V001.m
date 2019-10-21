% Dieses Skript variiert verschiedenste Parameter und durchläuft
% verschiedenste Konzepte des neuronalen Netzes.
% Diese werden anhand der Kriterien verglichen und abgespeichert, sodass am
% Ende ein neuronales Netz ausgewählt werden kann.
% Hintergrund ist das Generieren eines Verständnisses darüber, was welcher
% Parameter am neuronalen Netz im konkreten Fall bewirkt.

% Gradienten checken, um zu überprüfen, ob die Algorithmen des neuronalen
% Netzes korrekt implementiert wurden.
% gradienten_check();

clc;

% Definition der Trainings- und Testdaten.
saisons_training = 2000:2017;
saisons_test = 2018;

pos_training = [];
for saison = saisons_training
    pos_training = [pos_training; find(rohdatentabelle.Saison == saison)];  %#ok<AGROW>
end

pos_test = [];
for saison = saisons_test
    pos_test = [pos_test; find(rohdatentabelle.Saison == saison)];  %#ok<AGROW>
end

tipppunkte = [];

% Zeitmessung beginnen.
tStartzeit_Gesamt = tic;

% Verschiedene Features.
variation_features = [1, 4];
for i_feature = variation_features
    if (i_feature == 1)
        X = feature_tabelle.feature1;
    elseif (i_feature == 2)
        X = feature_tabelle.feature2;
    elseif (i_feature == 3)
        X = feature_tabelle.feature3;
    elseif (i_feature == 4)
        X = feature_tabelle.feature4;
    else
        disp('Unbekanntes Feature.');
        return;
    end
    y = [rohdatentabelle.FTHG, rohdatentabelle.FTAG];
    % Trainingsdaten definieren.
    X_training = X(pos_training, :);
    y_training = y(pos_training, :);
    % Testdaten definieren.
    X_test = X(pos_test, :);
    y_test = y(pos_test, :);
    % Informationen ermitteln.
    anzahl_features = size(X_training, 2);
    anzahl_outputs = size(y_training, 2);
    
    % Verschiedene Aktivierungsfunktionen.
    % 1. Sigmoid.
    % 2. Tanh.
    % 3. ReLU.
    % 4. Leaky ReLU.
    % 5. Swish.
    % 6. SVM.
    variation_aktivierungsfunktion = {'Swish'};
    for aktivierungsfunktion = variation_aktivierungsfunktion
        % Verschiedene Anzahl an Hidden-Layers.
        variation_anzahl_hiddenlayer = 3;
        for anzahl_hiddenlayer = variation_anzahl_hiddenlayer
            % Verschiedene Anzahl an Knoten eines Hidden-Layers.
            variation_anzahl_knoten_hiddenlayer = [10 25 100];
            for anzahl_knoten_hiddenlayer = variation_anzahl_knoten_hiddenlayer
                % Variation des Regularization-Parameters Lambda.
                % variation_lambda = [0, 0.001, 0.003, 0.01, 0.03, 0.1, 0.3, 1, 3, 10];
                variation_lambda = 1;
                for lambda = variation_lambda
                    % Verschiedene Anzahl an Lern-Iterationen.
                    variation_iterationen = 100;
                    for iterationen = variation_iterationen
                        % Mehrere Anläufe (dadurch jedes Mal neu generierte,
                        % zufällige Initialisierungs-Matrizen, welche zu
                        % verschiedenen Optima führen können.
                        anzahl_wiederholungen = 3;
                        for wiederholungen = 1:1:anzahl_wiederholungen
                            % Initialisierungs-Parameter generieren.
                            % Die Matrizen haben die Größe (s_j+1 x (s_j + 1)) --> +1 aufgrund der Bias-Unit.
                            Theta = zufallsinitialisierung_gewichte_V001(anzahl_features, anzahl_hiddenlayer, anzahl_knoten_hiddenlayer, anzahl_outputs);
                            % Paramter-Unrolling. (Matrizen werden zu einem langen Vektor)
                            Theta_unroll = [];
                            for iterTheta = 1:1:length(Theta)
                                Theta_unroll = [Theta_unroll; Theta{iterTheta}(:)];         %#ok<AGROW>
                            end

                            % Optionen für Anlernen definieren.
                            options = optimset('MaxIter', iterationen);

                            % Funktionszeiger auf die Costfunction erzeugen.
                            kostenfunktion = @(p) kostenfunktion_V001(  p, ...
                                                                        anzahl_features, ...
                                                                        anzahl_hiddenlayer, ...
                                                                        anzahl_knoten_hiddenlayer, ...
                                                                        anzahl_outputs, ...
                                                                        X_training, y_training, ...
                                                                        lambda, ...
                                                                        aktivierungsfunktion);

                            % Neuronales Netz anlernen.
                            [Theta_unroll, Cost] = fmincg(kostenfunktion, Theta_unroll, options);

                            % Reshapen der Theta-Matrizen. (Langer Vektor wird zu Matrizen)
                            % Die Matrizen haben die Größe (s_j+1 x (s_j + 1)) --> +1 aufgrund der Bias-Unit.
                            knoten_anzahl = [anzahl_features, ones(1,anzahl_hiddenlayer) * anzahl_knoten_hiddenlayer, anzahl_outputs];
                            Theta = cell(1, length(knoten_anzahl) - 1);
                            pos_start = 1;
                            for i = 1:1:(length(knoten_anzahl) - 1)
                                pos_end = (pos_start-1) + knoten_anzahl(i+1) * (knoten_anzahl(i) + 1);
                                Theta{i} = reshape(Theta_unroll(pos_start:pos_end), ...
                                                    knoten_anzahl(i+1), ...
                                                    knoten_anzahl(i) + 1);
                                pos_start = pos_end + 1;
                            end

                            % Feedforward auf das Testset.
                            % Berechnung der pro Saison theoretisch erhaltenen
                            % Tipppunktzahl.
                            [tore_team1_tipp, tore_team2_tipp] = tippe_spiel_V001(X_test, Theta, aktivierungsfunktion);
                            % Zeige Punktzahl auf.
                            tipppunkte = [tipppunkte, sum(berechne_tipppunkte_V001(round(tore_team1_tipp), round(tore_team2_tipp), y_test(:,1), y_test(:,2)))]; %#ok<AGROW>
                            disp(['Aktivierungsfunktion: ' char(aktivierungsfunktion) ', Lambda: ' num2str(lambda), ', Anzahl Knoten/Layer: ' num2str(anzahl_knoten_hiddenlayer) ', Anzahl Hiddenlayer: ' num2str(anzahl_hiddenlayer)]);
                            disp(['Erreichte Punktzahl Saison 2018: ' num2str(tipppunkte(end))]);
                            disp(' ');

                        end
                    end
                end
            end
        end
    end
end
    
% Zeitmessung beenden.
tEndzeit_Gesamt = toc(tStartzeit_Gesamt);