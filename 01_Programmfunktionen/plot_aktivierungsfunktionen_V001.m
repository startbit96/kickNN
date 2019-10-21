function plot_aktivierungsfunktionen_V001()
% PLOT_AKTIVIERUNGSFUNKTIONEN_V001
% Plottet alle betrachteten Aktivierungsfunktionen und deren Ableitungen.

% Definitionen.
x_min = -3;
x_max = 3;
y_min = -2;
y_max = 2;
aufloesung = 0.05;

variation_aktivierungsfunktion = {  'Sigmoid', ... 
                                    'Tanh', ...
                                    'ReLU', ...
                                    'Leaky ReLU', ...
                                    'Swish'};

figure_handle = figure;
                                
% Durchlaufe alle Aktivierungsfunktionen.
for i = 1:1:length(variation_aktivierungsfunktion)
    aktivierungsfunktion = variation_aktivierungsfunktion{i};
    % Aktivierungsfunktion wählen und in Funktionszeiger hinterlegen.
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

    % Plotten.
    pos_funktion = i;
    pos_funktion_ableitung = length(variation_aktivierungsfunktion) + i;
    % Funktion.
    subplot(2, length(variation_aktivierungsfunktion), pos_funktion);
    plot(x_min:aufloesung:x_max, aktivierungs_funktion(x_min:aufloesung:x_max), 'b-');
    title(['Aktivierungsfunktion ''' aktivierungsfunktion '''']);
    axis([x_min, x_max, y_min, y_max]);
    grid on
    box on
    % Ableitung.
    subplot(2, length(variation_aktivierungsfunktion), pos_funktion_ableitung);
    plot(x_min:aufloesung:x_max, aktivierungs_funktion_ableitung(x_min:aufloesung:x_max), 'b-');
    title(['Ableitung der Aktivierungsfunktion ''' aktivierungsfunktion '''']);
    axis([x_min, x_max, y_min, y_max]);
    grid on
    box on
    
end

% Bild abspeichern.
set(figure_handle, 'Position', [0 0 3500 1500]);
saveas(figure_handle, 'Variation_Aktivierungsfunktionen.png');

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