% Ermittlung der verschiedenen Features.
disp('Berechnung verschiedener Features für das neuronale Netz.');
disp(' ');

%% Allgemeine Feature-Erzeugung.
% In diesem Abschnitt werden folgende Features erzeugt, welche später den
% einzelnen Feature-Varianten zugewiesen werden können.

%% Initialisierung Allgemein.
feature_tabelle = table;


%% Initialisierung Global.
% Globaler Skillwert.
anzahl_rueckblick_saisons = 3;
feature_tabelle.rueckblick_saison_platzierung_hometeam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_saisons);
feature_tabelle.rueckblick_saison_platzierung_awayteam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_saisons);
feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_saisons);
feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_saisons);
% Gewichtet (manuell).
wichtung_rueckblick_saisons_v1 = [0.5, 0.25, 0.15, 0.08, 0.02];
wichtung_rueckblick_saisons_v2 = [0.7, 0.2, 0.1, 0, 0];
feature_tabelle.rueckblick_saison_platzierung_hometeam_wichtung1 = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_saison_platzierung_hometeam_wichtung2 = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_saison_platzierung_awayteam_wichtung1 = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_saison_platzierung_awayteam_wichtung2 = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam_wichtung1 = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam_wichtung2 = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam_wichtung1 = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam_wichtung2 = zeros(size(rohdatentabelle, 1), 1);


%% Initialisierung Lokal.
% Lokaler Skillwert.
% Ergebnisse können verschieden im Voraus verrechnet / gewichtet werden:
% 1. Ungewichtet:
%   - Alle Ergebnisse werden 1:1 genutzt.
% 2. Gewichtet nach lokalem Skill:
%   - Alle Ergebnisse werden mit dem Verhältnis Punkte Gegner /
%   Punkte eigen multipliziert. (Gegner ist jeweils jener, welcher zu dem
%   jeweiligen Ergebnis gehört)
%   - Somit werden z.B. Tore gegen eine stärkere Mannschaft mehr gewichtet
%   als Tore gegen eine schwächere Mannschaft.
% 3. Gewichtet nach globalem Skill:
%   - Analog zu 2. nur mit den Ergebnissen der letzten Saisons.
% 4. Gewichtet nach lokalem und globalem Skill:
%   - Zusammenführung von 2. und 3. und Wichtung zwischen lokalem und
%   globalem Skill mittels der Faktoren beta_lokal und beta_global.
feature_tabelle.spieltag = zeros(size(rohdatentabelle, 1), 1);
% Speichern der aktuellen Tabellenpunkte. Diese werden wieder entsprechend
% des Spieltags normalisiert.
feature_tabelle.tabellenpunkte_aktuell_hometeam = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.tabellenpunkte_aktuell_awayteam = zeros(size(rohdatentabelle, 1), 1);
% Ergebnisse der letzten fünf Spiele.
anzahl_rueckblick_spiele = 5;
feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
% Gewichtet (manuell).
wichtung_rueckblick_spiele_v1 = [0.4, 0.25, 0.25, 0.08, 0.02];
wichtung_rueckblick_spiele_v2 = [0.6, 0.2, 0.15, 0.05, 0];
feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_wichtung1 = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_wichtung1 = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_wichtung2 = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_wichtung2 = zeros(size(rohdatentabelle, 1), 1);
% Gewichtet (nach dem Verhältnis Tabellenpunkte Gegner / Tabellenpunkte eigen).
% Somit werden Spiele, bei welchem die Gegner-Mannschaft stärker war als die eigene Mannschaft, mehr gewichtet.
% --> Lokale Wichtung.
feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_wichtung_l = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_wichtung_l = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
% Gewichtet (nach dem Verhältnis Globaler Skill Gegner / Globaler Skill eigen).
% Somit werden Spiele, bei welchem die Gegner-Mannschaft stärker war als die eigene Mannschaft, mehr gewichtet.
% --> Globale Wichtung.
feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_wichtung_g = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_wichtung_g = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
% Gewichtet (nach globalem und lokalen Skillwert).
% Somit werden Spiele, bei welchem die Gegner-Mannschaft stärker war als die eigene Mannschaft, mehr gewichtet.
% --> Globale und lokale Wichtung.
feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_wichtung_g_l = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_wichtung_g_l = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
% Heimsieg-Quote Heimteam. (gemittelt über bisherige Spiele der Saison)
feature_tabelle.heimsiegquote_hometeam = zeros(size(rohdatentabelle, 1), 1);
% Auswärtssieg-Quote Auswärtsteam. (gemittelt über bisherige Spiele der Saison)
feature_tabelle.auswaertssiegquote_awayteam = zeros(size(rohdatentabelle, 1), 1);
% Quoten-Division (Heimsiegquote / Auswärtssiegquote).
feature_tabelle.quotendivision_heim_auswaertssiege = zeros(size(rohdatentabelle, 1), 1);


%% Berechnung.
waitbar_handle = waitbar(0, 'Berechnen der Features ...');
for i = 1:1:size(rohdatentabelle, 1)
    waitbar(i/size(rohdatentabelle, 1), waitbar_handle);
    
    %% Berechnung Allgemein.
    % Finde als erstes die dazugehörige Punktetabelle.
    pos_punktetabelle = find(   (punktetabelle.liga == rohdatentabelle.Liga(i)) & ...
                                (punktetabelle.saison == rohdatentabelle.Saison(i)));
    if (isempty(pos_punktetabelle) == true)
        disp('Keine zugehörige Punktetabelle gefunden!')
        return;
    elseif (length(pos_punktetabelle) > 1)
        disp('Mehrfacheintrag Puntketabelle!')
        return;
    end
    
    % Finde die Position der Mannschaft innerhalb der Datenstruktur.
    pos_hometeam = find(punktetabelle.teams{pos_punktetabelle} == rohdatentabelle.nHomeTeam(i));
    pos_awayteam = find(punktetabelle.teams{pos_punktetabelle} == rohdatentabelle.nAwayTeam(i));
    
    % Spieltag.
    % Der Spieltag ist in den Daten aufgrund verschiedener Spielverschiebungen
    % nicht zu 100% konsistent. Daher ist es nicht möglich, einfach die
    % Spieltage aller 9 Spiele um eins zu erhöhen. 
    % Der Algorithmus geht jedes Spiel durch, sucht in den Tabellen für die
    % jeweilige Mannschaft nach dem Spiel und nimmt dessen Index.
    % Die beiden ermittelten Spieltage der beiden Mannschaften werden dannsum(
    % gemittelt. Es kann somit sein, dass Spieltage auf halbe Tage genau
    % angegeben werden. Aufgrund des Features-Scalings im folgenden erkennt man
    % dies jedoch eh nicht. Das Feature-Scaling ist in diesem Fall ebenso eine
    % Ausnahme. Ziel soll es sein, dass "1" dem letzten Spieltag entspricht. Da
    % es Saisons mit verschiedenen Anzahl an Spieltagen gab, müssen diese auch
    % individuell skaliert werden.
    spieltag_hometeam = find(   (punktetabelle.spieldaten{pos_punktetabelle}{pos_hometeam}(3,:) == 1) & ...                         % Heimspiele finden
                                (punktetabelle.spieldaten{pos_punktetabelle}{pos_hometeam}(2,:) == rohdatentabelle.nAwayTeam(i)));  % Gegner finden
    spieltag_awayteam = find(   (punktetabelle.spieldaten{pos_punktetabelle}{pos_awayteam}(3,:) == 0) & ...                         % Auswärtsspiele finden
                                (punktetabelle.spieldaten{pos_punktetabelle}{pos_awayteam}(2,:) == rohdatentabelle.nHomeTeam(i)));  % Gegner finden
    feature_tabelle.spieltag(i) = ((spieltag_hometeam + spieltag_awayteam) / 2) / length(punktetabelle.spieldaten{pos_punktetabelle}{pos_hometeam}(3,:));
    
    
    %% Berechnung Global.
    % Platzierung der letzten fünf Saisons in der gleichen Liga. Durch die spätere Zuweisung zu den
    % Feature-Varianten können auch nur die der letzten drei Saison o.ä.
    % übertragen werden. Aber somit bestehen zumindest die Ergebnisse.
    % Hier muss ebenfalls beim Feature-Scaling die verschiedenen Anzahl an
    % Mannschaften pro Saison berücksichtigt werden.
    % Punktzahl der letzten fünf Saisons. Analog zur Platzierung (siehe oben).
    for i_saison = 1:1:anzahl_rueckblick_saisons
        n_saison = rohdatentabelle.Saison(i) - i_saison;
        % Finde die Position der Daten der vergangenen Saison.
        % Sollten keine Daten zu dieser Position vorliegen, dann nimm für
        % diesen Eintrag für die Platzierung 9 an und für die Punkte 42.
        % (Mittleres Ergebnis)
        pos_punktetabelle_rueck = find( (punktetabelle.liga == rohdatentabelle.Liga(i)) & ...
                                (punktetabelle.saison == n_saison));
        if(isempty(pos_punktetabelle_rueck) == true)
            % Es gibt zu der ermittelten Saison keine Werte mehr.
            % Nimm daher Alternativwerte.
            feature_tabelle.rueckblick_saison_platzierung_hometeam(i, i_saison) = 0.5;
            feature_tabelle.rueckblick_saison_platzierung_awayteam(i, i_saison) = 0.5;
            feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam(i, i_saison) = 0.42;
            feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam(i, i_saison) = 0.42;
        elseif (length(pos_punktetabelle_rueck) > 1)
            % Sollte eigentlich nicht vorkommen ...
            disp('Mehrfacheintrag Puntketabelle!')
            return;
        else
            % Finde die Platzierung des Teams sowie die Punkte der Tabelle in der vergangenen Saison.
            % Finde die Position der Mannschaft innerhalb der Datenstruktur.
            pos_hometeam_rueckblick = find(punktetabelle.teams{pos_punktetabelle_rueck} == rohdatentabelle.nHomeTeam(i));
            pos_awayteam_rueckblick = find(punktetabelle.teams{pos_punktetabelle_rueck} == rohdatentabelle.nAwayTeam(i));
            % HomeTeam.
            if (isempty(pos_hometeam_rueckblick) == true)
                % Dieses Team war in der vergangenen Saison nicht in dieser
                % Liga.
                % Weise diesem Team "schlechte" Werte zu.
                feature_tabelle.rueckblick_saison_platzierung_hometeam(i, i_saison) = 0.15;
                feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam(i, i_saison) = 0.3;
            else
                % Speicher die Platzierung ab und teile diese durch die Anzahl der Teams.
                feature_tabelle.rueckblick_saison_platzierung_hometeam(i, i_saison) = 1 - ...
                                                                                        find(punktetabelle.platzierung{pos_punktetabelle_rueck} == pos_hometeam_rueckblick) / ...
                                                                                        length(punktetabelle.platzierung{pos_punktetabelle_rueck});
                % Speicher die maximal erreichten Punkte ab und teile diese durch die maximal Erreichbaren.
                feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam(i, i_saison) = punktetabelle.tabelle{pos_punktetabelle_rueck}(pos_hometeam_rueckblick, end) / ...
                                                                                        (size(punktetabelle.tabelle{pos_punktetabelle_rueck}, 2) * 3);
            end
            % AwayTeams.
            if (isempty(pos_awayteam_rueckblick) == true)
                % Dieses Team war in der vergangenen Saison nicht in dieser
                % Liga.
                % Weise diesem Team "schlechte" Werte zu.
                feature_tabelle.rueckblick_saison_platzierung_awayteam(i, i_saison) = 0.15;
                feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam(i, i_saison) = 0.3;
            else
                % Speicher die Platzierung ab und teile diese durch die Anzahl der Teams.
                feature_tabelle.rueckblick_saison_platzierung_awayteam(i, i_saison) = 1- ....
                                                                                        find(punktetabelle.platzierung{pos_punktetabelle_rueck} == pos_awayteam_rueckblick) / ...
                                                                                        length(punktetabelle.platzierung{pos_punktetabelle_rueck});
                % Speicher die maximal erreichten Punkte ab und teile diese durch die maximal Erreichbaren.
                feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam(i, i_saison) = punktetabelle.tabelle{pos_punktetabelle_rueck}(pos_awayteam_rueckblick, end) / ...
                                                                                        (size(punktetabelle.tabelle{pos_punktetabelle_rueck}, 2) * 3);
            end
        end
    end
    % Wichtung des globalen Skillwerts anhand zweier verschiedener
    % Wichtungen.
    feature_tabelle.rueckblick_saison_platzierung_hometeam_wichtung1(i) = sum(feature_tabelle.rueckblick_saison_platzierung_hometeam(i,:) .* wichtung_rueckblick_saisons_v1);
    feature_tabelle.rueckblick_saison_platzierung_hometeam_wichtung2(i) = sum(feature_tabelle.rueckblick_saison_platzierung_hometeam(i,:) .* wichtung_rueckblick_saisons_v2);
    feature_tabelle.rueckblick_saison_platzierung_awayteam_wichtung1(i) = sum(feature_tabelle.rueckblick_saison_platzierung_awayteam(i,:) .* wichtung_rueckblick_saisons_v1);
    feature_tabelle.rueckblick_saison_platzierung_awayteam_wichtung2(i) = sum(feature_tabelle.rueckblick_saison_platzierung_awayteam(i,:) .* wichtung_rueckblick_saisons_v2);
    feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam_wichtung1(i) = sum(feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam(i,:) .* wichtung_rueckblick_saisons_v1);
    feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam_wichtung2(i) = sum(feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam(i,:) .* wichtung_rueckblick_saisons_v2);
    feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam_wichtung1(i) = sum(feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam(i,:) .* wichtung_rueckblick_saisons_v1);
    feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam_wichtung2(i) = sum(feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam(i,:) .* wichtung_rueckblick_saisons_v2);
    
    
    
    %% Berechnung Lokal.
    
    % Speichern der aktuellen Tabellenpunkte. Diese werden wieder entsprechend des Spieltags normalisiert.
    % HomeTeam.
    if (spieltag_hometeam > 1)
        feature_tabelle.tabellenpunkte_aktuell_hometeam(i) = punktetabelle.tabelle{pos_punktetabelle}(pos_hometeam, spieltag_hometeam - 1) / ...
                                                                ((spieltag_hometeam - 1) * 3);
    else
        feature_tabelle.tabellenpunkte_aktuell_hometeam(i) = 0;
    end
    % AwayTeam.
    if (spieltag_awayteam > 1)
        feature_tabelle.tabellenpunkte_aktuell_awayteam(i) = punktetabelle.tabelle{pos_punktetabelle}(pos_awayteam, spieltag_awayteam - 1) / ...
                                                                ((spieltag_awayteam - 1) * 3);
    else
        feature_tabelle.tabellenpunkte_aktuell_awayteam(i) = 0;
    end
    
    % Spielrückblick.
    % HomeTeam.
    gegner_wichtung = zeros(1, anzahl_rueckblick_spiele);
    if (spieltag_hometeam > 1)
        for i_spieltag = 1:1:anzahl_rueckblick_spiele
            % Sollte es nicht genügend Spiele zum Zurückblicken geben, wird der
            % letztmögliche mehrfach wiederholt.
            n_spieltag = max(spieltag_hometeam - i_spieltag, 1);

            % Punkte.
            % Differenz der Punktetabelle ergibt das Ergebnis fdür den
            % jeweiligen Spieltag.
            if ((n_spieltag - 1) < 1)
                % Es handelt sich um den ersten Spieltag. Hier ist der
                % hinterlegte Wert zu nehmen.
                feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam(i, i_spieltag) = punktetabelle.tabelle{pos_punktetabelle}(pos_hometeam, n_spieltag);            
            else
                % Es handelt sich um einen höheren Spieltag. Hier ist die
                % Differenz mit dem vorhergehenden Spieltag zu berechnen.
                feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam(i, i_spieltag) = punktetabelle.tabelle{pos_punktetabelle}(pos_hometeam, n_spieltag) - ...
                                                                                            punktetabelle.tabelle{pos_punktetabelle}(pos_hometeam, n_spieltag-1);
            end

            % Wichtung des Gegners.
            n_gegnerteam = punktetabelle.spieldaten{pos_punktetabelle}{pos_hometeam}(2, n_spieltag);
            pos_gegnerteam = find(punktetabelle.teams{pos_punktetabelle} == n_gegnerteam);
            % +1, um Nullteilen zu verhindern.
            gegner_wichtung(i_spieltag) =   (punktetabelle.tabelle{pos_punktetabelle}(pos_gegnerteam, n_spieltag) + 1) / ...
                                            (punktetabelle.tabelle{pos_punktetabelle}(pos_hometeam, n_spieltag) + 1);
        end
    else
        feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam(i,:) = zeros(1,anzahl_rueckblick_spiele);
    end
    
    % Punkte der letzten Spiele gewichtet nach Gegnerstärke.
    feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_punktewichtung(i,:) = feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam(i,:) .* gegner_wichtung;
    
    % Heimspielquote.
    pos_heimspiele = find(punktetabelle.spieldaten{pos_punktetabelle}{pos_hometeam}(3,(1:spieltag_hometeam-1)) == 1);
    if (isempty(pos_heimspiele) == true)
        % Bislang gab es keine Heimspiele. Setze die Heimspielquote auf
        % einen moderaten Wert (siehe Statistiken).
        feature_tabelle.heimsiegquote_hometeam(i) = 0.4;
    else
        feature_tabelle.heimsiegquote_hometeam(i) = length(find(rohdatentabelle.pHT(punktetabelle.spieldaten{pos_punktetabelle}{pos_hometeam}(1,pos_heimspiele)) == 3)) / ...
                                                    length(pos_heimspiele);
    end
    
    % Offensive.
    
    % Defensive.
    
    

end
close(waitbar_handle)


%% Feature-Erstellung.
%% Feature-Variante 1:
disp('Feature-Variante 1:');
disp('- Spieltag');
disp('- Aktuelle Tabellenpunktzahl Team 1 und x vorherige Spiele.');
disp('- Aktuelle Tabellenpunktzahl Team 2 und x vorherige Spiele.');
disp(' ');


%% Feature-Variante 2:

%% Feature-Variante 3:


%% Aufräumen.
clearvars -except anzahl_dateien teamnamen rohdatentabelle punktetabelle anzahl_spiele feature_tabelle