function speicher_punktetabellen_V001()
% SPEICHER_PUNKTETABELLEN_V001 Erstellt die Punktetabellen aller Ligen und
% Saisons, welche eingeladen wurden und speichert diese ab.

% Punktetabelle einladen.
punktetabelle = evalin('base', 'punktetabelle');

% Plotte für jede Saison das Diagramm und speicher es ab.
for i = 1:1:length(punktetabelle.liga)
    figure_handle = plot_punktetabelle_V001(punktetabelle.liga(i), punktetabelle.saison(i));
    dateiname = ['04_Medien/Punktetabelle_Liga' num2str(punktetabelle.liga(i)) '_Saison' num2str(punktetabelle.saison(i)) '.png'];
    % Kurz pausieren. Ansonsten kommt es manchmal zu unerklärlichen
    % Größenunterschieden der Bilder. Vermutlich ist die Position noch
    % nicht 100%ig gefunden / eingestellt.
    pause(0.5);
    saveas(figure_handle, dateiname);
    close(figure_handle);
end

end

