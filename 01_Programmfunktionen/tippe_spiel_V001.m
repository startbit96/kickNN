function [tore_team1_tipp, tore_team2_tipp] = tippe_spiel_V001(X, Theta, aktivierungsfunktion)
% TIPPE_SPIEL_V001 
% Tippt ein Spiel auf Grundlage des neuronalen Netzes.

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

% Größe der Eingabe.
m = size(X, 1);

% Feedforward. Berechne das Tippergebnis.
y_nn = X;
for n_layer = 2:1:(length(Theta) + 1)
    if (n_layer < (length(Theta) + 1))
        y_nn = aktivierungs_funktion([ones(m,1), y_nn] * Theta{n_layer-1}.');
    else
        % Output als lineare Funktion.
        y_nn = aktivierungs_funktion_L([ones(m,1), y_nn] * Theta{n_layer-1}.');
    end
end

tore_team1_tipp = y_nn(:,1);
tore_team2_tipp = y_nn(:,2);

end

