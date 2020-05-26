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
saisons_training = 1990:2014;
saisons_test = 2015:2018;

pos_training = [];
for saison = saisons_training
    pos_training = [pos_training; find(rohdatentabelle.Saison == saison)];  %#ok<AGROW>
end

% Theta abspeichern.
Theta_speicher_punkte = cell(10, 1);
n_theta = 1;

% Zeitmessung beginnen.
tStartzeit_Gesamt = tic;

% Verschiedene Features.
variation_features = 7;
for i_feature = variation_features
    if (i_feature == 1)
        X = feature_tabelle.feature1;
    elseif (i_feature == 2)
        X = feature_tabelle.feature2;
    elseif (i_feature == 3)
        X = feature_tabelle.feature3;
    elseif (i_feature == 4)
        X = feature_tabelle.feature4;
    elseif (i_feature == 5)
        X = feature_tabelle.feature5;
    elseif (i_feature == 6)
        X = feature_tabelle.feature6;
    elseif (i_feature == 7)
        X = feature_tabelle.feature7;
    else
        disp('Unbekanntes Feature.');
        return;
    end
    y = [rohdatentabelle.FTHG, rohdatentabelle.FTAG];
    % Trainingsdaten definieren.
    X_training = X(pos_training, :);
    y_training = y(pos_training, :);
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
    variation_aktivierungsfunktion = {  'Swish'};
    for aktivierungsfunktion = variation_aktivierungsfunktion
        % Verschiedene Anzahl an Hidden-Layers.
        variation_anzahl_hiddenlayer = 2;
        for anzahl_hiddenlayer = variation_anzahl_hiddenlayer
            % Verschiedene Anzahl an Knoten eines Hidden-Layers.
            variation_anzahl_knoten_hiddenlayer = 10;
            for anzahl_knoten_hiddenlayer = variation_anzahl_knoten_hiddenlayer
                % Variation des Regularization-Parameters Lambda.
                variation_lambda = 0.001;
                for i_lambda = 1:1:numel(variation_lambda)
                    lambda = variation_lambda(i_lambda);
                    % Verschiedene Anzahl an Lern-Iterationen.
                    variation_iterationen = 1000;
                    for iterationen = variation_iterationen
                        % Mehrere Anläufe (dadurch jedes Mal neu generierte,
                        % zufällige Initialisierungs-Matrizen, welche zu
                        % verschiedenen Optima führen können.
                        anzahl_wiederholungen = 10;
                        for wiederholungen = 1:1:anzahl_wiederholungen
                            % Ausgabe des aktuellen Fortschritts.
                            disp(['Untersuchungsumfang ' num2str(n_theta) ' / 10 ...']);
                            disp(' ');
                            % Initialisierungs-Parameter generieren.
                            % Die Matrizen haben die Größe (s_j+1 x (s_j + 1)) --> +1 aufgrund der Bias-Unit.
                            Theta = zufallsinitialisierung_gewichte_V001(anzahl_features, anzahl_hiddenlayer, anzahl_knoten_hiddenlayer, anzahl_outputs);
                            % Paramter-Unrolling. (Matrizen werden zu einem langen Vektor)
                            Theta_unroll = [];
                            for iterTheta = 1:1:length(Theta)
                                Theta_unroll = [Theta_unroll; Theta{iterTheta}(:)];
                            end

                            % Optionen für Anlernen definieren.
                            options = optimset('MaxIter', iterationen);

                            % Funktionszeiger auf die Costfunction erzeugen.
                            kostenfunktion = @(p) kostenfunktion_V002(  p, ...
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
                            
                            % Ergebnis prüfen.
                            figure_nn_check = figure;
                            hold on;
                            % Trainingsdaten prüfen.
                            for n_saison = saisons_training
                                pos_daten_check = find(rohdatentabelle.Saison == n_saison);
                                X_check = X(pos_daten_check,:);
                                y_check = y(pos_daten_check,:);
                                [tore_team1_tipp, tore_team2_tipp] = tippe_spiel_V001(X_check, Theta, aktivierungsfunktion);
                                tipppunkte = berechne_tipppunkte_V001(round(tore_team1_tipp), round(tore_team2_tipp), y_check(:,1), y_check(:,2));
                                punkte = zeros(1,length(tipppunkte));
                                for j = 1:1:length(tipppunkte)
                                    if (j == 1)
                                        punkte(j) = tipppunkte(j);
                                    else
                                        punkte(j) = punkte(j-1) + tipppunkte(j);
                                    end
                                end
                                plot(1:1:length(punkte), punkte, 'b-');
                            end
                            % Testdaten prüfen.
                            for n_saison = saisons_test
                                pos_daten_check = find(rohdatentabelle.Saison == n_saison);
                                X_check = X(pos_daten_check,:);
                                y_check = y(pos_daten_check,:);
                                [tore_team1_tipp, tore_team2_tipp] = tippe_spiel_V001(X_check, Theta, aktivierungsfunktion);
                                tipppunkte = berechne_tipppunkte_V001(round(tore_team1_tipp), round(tore_team2_tipp), y_check(:,1), y_check(:,2));
                                punkte = zeros(1,length(tipppunkte));
                                for j = 1:1:length(tipppunkte)
                                    if (j == 1)
                                        punkte(j) = tipppunkte(j);
                                    else
                                        punkte(j) = punkte(j-1) + tipppunkte(j);
                                    end
                                end
                                plot(1:1:length(punkte), punkte, 'r-', 'LineWidth', 2);
                            end
                            hold off
                            xlabel('Fortlaufende Nummer Tippabgabe')
                            ylabel('Tipppunkte aufsummiert')
                            title(['Feature: ' num2str(i_feature) ...
                                    ', AF: ' char(aktivierungsfunktion) ...
                                    ', n Hiddenlayer: ' num2str(anzahl_hiddenlayer) ...
                                    ', n Knoten: ' num2str(anzahl_knoten_hiddenlayer) ...
                                    ', Lambda: ' num2str(lambda) ...
                                    ', iter: ' num2str(iterationen) ...
                                    ', n: ' num2str(wiederholungen) ...
                                    ' (großes Trainingsset)'])
                            axis([0 400 0 700])
                            grid on
                            box on
                            set(figure_nn_check, 'Position', [0 0 1800 1200]);
                            saveas(figure_nn_check, [   '20190917_Untersuchung_FV' num2str(i_feature) ...
                                                        '_Af' char(aktivierungsfunktion) ...
                                                        '_' num2str(anzahl_hiddenlayer) 'x' num2str(anzahl_knoten_hiddenlayer) ...
                                                        '_lambda' num2str(lambda) ...
                                                        '_v' num2str(wiederholungen) ...
                                                        '_trainingsset_groß_iter_groß' ...
                                                        '.png']);
                            close(figure_nn_check);
                            
                            % Theta abspeichern.
%                             Theta_speicher_af5{n_theta} = Theta;
%                             n_theta = n_theta + 1;
                        end
                    end
                end
            end
        end
    end
end
    
% Zeitmessung beenden.
tEndzeit_Gesamt = toc(tStartzeit_Gesamt);

% Alles abspeichern.
% save untersuchung_af5.mat