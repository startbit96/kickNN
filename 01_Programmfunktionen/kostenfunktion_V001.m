function [J, gradient] = kostenfunktion_V001(   Theta_unroll, ...
                                                anzahl_features, ...
                                                anzahl_hiddenlayer, ...
                                                anzahl_knoten_hiddenlayer, ...
                                                anzahl_outputs, ...
                                                X, y, lambda, ...
                                                aktivierungsfunktion)
% COSTFUNCTION_V001
% Diese Funktion berechnet den aktuellen Fehler des Systems durch
% Feedforward (Vorwärtsrechnung) und berechnet mittels Rückwärtsrechnung
% (Backpropagation) die jeweiligen Gradienten der Knoten, welche wiederum
% für die Optimierungsfunktion fmincg genutzt werden können.

% Welche Aktivierungsfunktion und welche dazugehörige Ableitung soll
% verwendet werden (z.B. ReLU oder Leaky ReLU, ...).
% Im folgenden werden Funktionszeiger verwendet, um die
% Aktivierungsfunktion recht zügig austauschen zu können.
% 1. Sigmoid.
% 2. Tanh.
% 3. ReLU.
% 4. Leaky ReLU.
% 5. Swish.
% (6. SVM.)
% Quelle zu einer Übersicht: https://towardsdatascience.com/activation-functions-neural-networks-1cbd9f8d91d6
if (strcmpi(aktivierungsfunktion, 'Sigmoid') == true)
    aktivierungs_funktion = @(x) (1.0 ./ (1.0 + exp(-x)));
    aktivierungs_funktion_ableitung = @(x) (aktivierungs_funktion(x) .* (1-aktivierungs_funktion(x)));
elseif (strcmpi(aktivierungsfunktion, 'Tanh') == true)
    aktivierungs_funktion = @(x) tanh(x);
    aktivierungs_funktion_ableitung = @(x) (1 - tanh(x).^2);
elseif (strcmpi(aktivierungsfunktion, 'ReLU') == true)
    aktivierungs_funktion = @(x) max(0,x);
    aktivierungs_funktion_ableitung = @(x) aktivierung_funktion_ableitung_relu(x);
elseif (strcmpi(aktivierungsfunktion, 'Leaky ReLU') == true)
    aktivierungs_funktion = @(x) max(0.01*x,x);
    aktivierungs_funktion_ableitung = @(x) aktivierung_funktion_ableitung_leaky_relu(x);
elseif (strcmpi(aktivierungsfunktion, 'Swish') == true)
    aktivierungs_funktion = @(x) (x ./ (1.0 + exp(-x)));
    aktivierungs_funktion_ableitung = @(x) ((exp(-x) .* (x+1) + 1) ./ (1 + exp(-x)).^2);
else
    error('Unbekannt Aktivierungsfunktion!');
end

% Aktivierungsfunktion für das letzte Layer.
% Für Regressions-Aufgabe wird ein linearer Output empfohlen.
aktivierungs_funktion_L = @(x) (x);
aktivierungs_funktion_ableitung_L = @(x) (1);

% Die Parameter (Theta) liegen aktuell noch in einem langen Vektor vor, da
% die Optimierungsfunktion fmincg diese in diesem Format benötigt. Für die
% Matrizenmultiplikation werden die Daten jedoch auch in Matrizenform
% benötigt. Daher reshapen.

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

% Anzahl der Lernbeispiele.
m = size(X, 1);

% Berechnung des Fehlers des Netzes mittels Kostenfunktion.
% --> Vorwärtsrechnung (Feedforward).
% Die Kostenfunktion ist der quadratische Fehler aller Trainingsdaten
% geteilt durch die doppelte Anzahl der Trainingsdaten und ist somit ein Maß für die
% Genauigkeit des neuronalen Netzes.
y_nn = X;
for n_layer = 2:1:(length(Theta) + 1)
    if (n_layer < (length(Theta) + 1))
        y_nn = aktivierungs_funktion([ones(m,1), y_nn] * Theta{n_layer-1}.');
    else
        % Output als lineare Funktion.
        y_nn = aktivierungs_funktion_L([ones(m,1), y_nn] * Theta{n_layer-1}.');
    end
end
% Berechnung des Fehlers.
J = (1/(2*m)) * sum((y_nn - y).^2 ,'all');

% Regularisierung auf den Fehler.
for n_theta = 1:1:length(Theta)
    J = J + (lambda / (2*m)) * sum(Theta{n_theta}(:,2:end).^2, 'all');
end


% Rückrechnung des Fehlers auf die einzelnen Gewichte.
% --> Backpropagation.
% Deltas der Theta-Matrizen mit Null initialisieren.
Theta_delta = cell(1, length(Theta));
for i = 1:1:length(Theta)
    Theta_delta{i} = zeros(size(Theta{i}));
end

% z ist die Summe der Produkte der Signale und Gewichte.
% z ist der Input, welchen die Knoten des vorherigen Layers an den
% aktuellen Knoten weitergeben.
% z ist somit der Input für die Aktivierungsfunktion.
z = cell(1, length(Theta) + 1);
% a ist die Aktivierung von z durch die Aktivierungsfunktion.
% a wird an die Knoten des nächsten Layers weitergegeben.
a = cell(1, length(Theta) + 1);
% delta stellt die Fehler in den einzelnen Schichten dar.
delta = cell(1, length(Theta) + 1);
for trainings_beispiel = 1:1:m
    % Feedforward pass. --> Vorwärtsrechnung und aktuelle Prognose ermitteln.
    a{1} = X(trainings_beispiel, :);
    % Für Hiddenlayer.
    for n_layer = 2:1:length(Theta)
        % Berechnung von z.
        % Dabei wird die Bias-Unit hinzugefügt.
        z{n_layer} = [1, a{n_layer-1}] * Theta{n_layer-1}.';
        a{n_layer} = aktivierungs_funktion(z{n_layer});
    end
    
    % Vorwärtsrechnung für letztes Layer. (Output generieren).
    z{length(Theta) + 1} = [1, a{length(Theta)}] * Theta{length(Theta)}.';
    a{length(Theta) + 1} = aktivierungs_funktion_L(z{length(Theta) + 1});
   
    % Ermittlung des Fehlers im letzten Layer.
    % Dies entspricht der Abweichung zwischen vorhergesagtem Ergebnis zu
    % tatsächlichem Ergebnis des Trainingsbeispiels.
    delta{length(Theta) + 1} = (a{length(Theta) + 1} - y(trainings_beispiel,:)) .* aktivierungs_funktion_ableitung_L(z{length(Theta) + 1});

    % Ermittlung der Fehler in den Hidden Layers.
    for n_layer = length(Theta):-1:2
       delta{n_layer} = (delta{n_layer+1} * Theta{n_layer}(:,2:end)) .* aktivierungs_funktion_ableitung(z{n_layer});
    end

    % Fehler des gesamten Systems (wird über alle Trainingsbeispiele
    % aufaddiert und am Ende verrechnet).
    for i = 1:1:length(Theta_delta)
       Theta_delta{i} = Theta_delta{i} + delta{i+1}.' * [1 a{i}];
    end
end

% Theta_grad speichert für jedes Element der Matrizen die Gradienten.
Theta_grad = cell(1, length(Theta));

% Gradienten ermitteln.
for i = 1:1:length(Theta_grad)
    Theta_grad{i} = (1/m) * Theta_delta{i};
    % Anwendung von Regularisierung auf die Elemente der Gradientenmatrix,
    % welche sich nicht auf die Bias-Units beziehen.
    Theta_grad{i}(:,2:end) = Theta_grad{i}(:,2:end) + (lambda / m) * Theta{i}(:,2:end);
end

% Unrollen der Gradienten-Matrizen.
gradient = [];
for iterGrad = 1:1:length(Theta_grad)
    gradient = [gradient; Theta_grad{iterGrad}(:)];         %#ok<AGROW>
end

end


% Aktivierungsfunktionen, welche ausgelagert werden mussten.
% Ableitung für ReLU.
function ableitung = aktivierung_funktion_ableitung_relu(x)
    ableitung = zeros(1, length(x));
    for n = 1:1:length(x)
        if (x(n) > 0)
            ableitung(n) = 1;
        else
            ableitung(n) = 0;
        end
    end
end

% Ableitung für Leaky-ReLU.
function ableitung = aktivierung_funktion_ableitung_leaky_relu(x)
    ableitung = zeros(1, length(x));
    for n = 1:1:length(x)
        if (x(n) > 0)
            ableitung(n) = 1;
        else
            ableitung(n) = 0.01;
        end
    end
end

