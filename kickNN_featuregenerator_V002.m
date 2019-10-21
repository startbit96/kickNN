% Ermittlung der verschiedenen Features.
disp('Berechnung verschiedener Features für das neuronale Netz.');
disp(' ');

%% Allgemeine Feature-Erzeugung.
% In diesem Abschnitt werden folgende Features erzeugt, welche später den
% einzelnen Feature-Varianten zugewiesen werden können.

%% Initialisierung Allgemein.
feature_tabelle = table;
feature_tabelle.spieltag = zeros(size(rohdatentabelle, 1), 1);

% Minimalwert zur Generierung einer Statistik (sollte dieser Wert
% unterschritten werden, wird ein hinterlegter Wert genutzt, welcher der 
% manuellen Betrachtung einer größeren Statistik entspringt).
min_wert_statistik = 6;

% Wichtung von Globalem und lokalem Skillfaktor zueinander.
wichtung_global = 1;
wichtung_lokal = 2.2;
feature_tabelle.gesamt_skillwert_hometeam = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.gesamt_skillwert_awayteam = zeros(size(rohdatentabelle, 1), 1);

%% Initialisierung Global.
% Ergebnisse der letzten x Saisons in Punkten von 0 bis 1.
anzahl_rueckblick_saisons = 3;
feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_saisons);
feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_saisons);
% Globaler Skillwert = Wichtung der letzten drei Saisons nach Aktualität.
wichtung_saisons_globaler_skillwert = [0.6, 0.3, 0.1];
feature_tabelle.globaler_skillwert_hometeam = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.globaler_skillwert_awayteam = zeros(size(rohdatentabelle, 1), 1);


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

% Speichern der aktuellen Tabellenpunkte. Diese werden wieder entsprechend
% des Spieltags normalisiert.
feature_tabelle.tabellenpunkte_aktuell_hometeam = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.tabellenpunkte_aktuell_awayteam = zeros(size(rohdatentabelle, 1), 1);
% Heimsiegquote HomeTeam.
feature_tabelle.heimsiegquote_hometeam  = zeros(size(rohdatentabelle, 1), 1);
% Auswärtssiegquote AwayTeam.
feature_tabelle.auswaertssiegquote_awayteam  = zeros(size(rohdatentabelle, 1), 1);


% Ergebnisse der letzten fünf Spiele.
anzahl_rueckblick_spiele = 5;
%wichtung_rueckblick = [0.35 0.3 0.2 0.1 0.05];
wichtung_rueckblick = [0.3 0.25 0.2 0.15 0.1];
feature_scaling_tore = 5;
% Erreichte Punkte.
feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_gegnerwichtung = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_gegnerwichtung = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_gewichtet = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_gewichtet = zeros(size(rohdatentabelle, 1), 1);
% Tore.
feature_tabelle.rueckblick_spielergebnisse_tore_hometeam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_tore_awayteam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_tore_hometeam_gegnerwichtung = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_tore_awayteam_gegnerwichtung = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_tore_hometeam_gewichtet = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_spielergebnisse_tore_awayteam_gewichtet = zeros(size(rohdatentabelle, 1), 1);
% Gegentore.
feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam_gegnerwichtung = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam_gegnerwichtung = zeros(size(rohdatentabelle, 1), anzahl_rueckblick_spiele);
feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam_gewichtet = zeros(size(rohdatentabelle, 1), 1);
feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam_gewichtet = zeros(size(rohdatentabelle, 1), 1);


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
    % Punktzahl der letzten fünf Saisons. 
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
            feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam(i, i_saison) = 0.4118;
            feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam(i, i_saison) = 0.4118;
        elseif (length(pos_punktetabelle_rueck) > 1)
            % Sollte eigentlich nicht vorkommen ...
            disp('Mehrfacheintrag Puntketabelle!')
            return;
        else
            % Finde die Position der Mannschaft innerhalb der Datenstruktur.
            pos_hometeam_rueckblick = find(punktetabelle.teams{pos_punktetabelle_rueck} == rohdatentabelle.nHomeTeam(i));
            pos_awayteam_rueckblick = find(punktetabelle.teams{pos_punktetabelle_rueck} == rohdatentabelle.nAwayTeam(i));
            % HomeTeam.
            if (isempty(pos_hometeam_rueckblick) == true)
                % Dieses Team war in der vergangenen Saison nicht in dieser
                % Liga.
                % Weise diesem Team "schlechte" Werte zu.
                feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam(i, i_saison) = 0.3;
            else
                % Speicher die maximal erreichten Punkte ab und teile diese durch die maximal Erreichbaren.
                feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam(i, i_saison) = punktetabelle.tabelle{pos_punktetabelle_rueck}(pos_hometeam_rueckblick, end) / ...
                                                                                        (size(punktetabelle.tabelle{pos_punktetabelle_rueck}, 2) * 3);
            end
            % AwayTeam.
            if (isempty(pos_awayteam_rueckblick) == true)
                % Dieses Team war in der vergangenen Saison nicht in dieser
                % Liga.
                % Weise diesem Team "schlechte" Werte zu.
                feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam(i, i_saison) = 0.3;
            else
                % Speicher die maximal erreichten Punkte ab und teile diese durch die maximal Erreichbaren.
                feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam(i, i_saison) = punktetabelle.tabelle{pos_punktetabelle_rueck}(pos_awayteam_rueckblick, end) / ...
                                                                                        (size(punktetabelle.tabelle{pos_punktetabelle_rueck}, 2) * 3);
            end
        end
    end
    % Wichtung des globalen Skillwerts.
    feature_tabelle.globaler_skillwert_hometeam(i) = sum(feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam(i,:) .* wichtung_saisons_globaler_skillwert);
    feature_tabelle.globaler_skillwert_awayteam(i) = sum(feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam(i,:) .* wichtung_saisons_globaler_skillwert);

    
    %% Berechnung Lokal.
    
    % Speichern der aktuellen Tabellenpunkte. Diese werden wieder entsprechend des Spieltags normalisiert.
    % Dies stellt den lokalen Skillwert dar.
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
    
    % Berechnung des Gesamt-Skillwerts.
    % Wichte den lokalen Skillwert je nach zugrundeliegender Statistik.
    % HomeTeam.
    faktor_wichtung_lokal = min(min_wert_statistik, spieltag_hometeam) / min_wert_statistik;
    feature_tabelle.gesamt_skillwert_hometeam(i) =  (wichtung_global / (wichtung_global + faktor_wichtung_lokal*wichtung_lokal)) * feature_tabelle.globaler_skillwert_hometeam(i) + ...
                                                        ((faktor_wichtung_lokal*wichtung_lokal) / (wichtung_global + faktor_wichtung_lokal*wichtung_lokal)) * feature_tabelle.tabellenpunkte_aktuell_hometeam(i);
    % AwayTeam.
    faktor_wichtung_lokal = min(min_wert_statistik, spieltag_awayteam) / min_wert_statistik;
    feature_tabelle.gesamt_skillwert_awayteam(i) =  (wichtung_global / (wichtung_global + faktor_wichtung_lokal*wichtung_lokal)) * feature_tabelle.globaler_skillwert_awayteam(i) + ...
                                                        ((faktor_wichtung_lokal*wichtung_lokal) / (wichtung_global + faktor_wichtung_lokal*wichtung_lokal)) * feature_tabelle.tabellenpunkte_aktuell_awayteam(i);

    
    % Heimsiegquote HomeTeam.
    pos_heimspiele = find(punktetabelle.spieldaten{pos_punktetabelle}{pos_hometeam}(3,(1:spieltag_hometeam-1)) == 1);
    if (isempty(pos_heimspiele) == true)
        % Bislang gab es keine Heimspiele. Setze die Heimspielquote auf
        % einen moderaten Wert (siehe Statistiken).
        feature_tabelle.heimsiegquote_hometeam(i) = 0.44;
    elseif (length(pos_heimspiele) < min_wert_statistik)
        % Es existieren noch zu wenig Daten für eine Statistik.
        % Setze auch in diesem Fall die Heimspielquote auf einen moderaten
        % Wert.
        feature_tabelle.heimsiegquote_hometeam(i) = 0.44;
    else
        % Falls genügend Heimspiele in dieser Saison gespielt wurden, dann
        % berechne die Heimsieg-Quote.
        feature_tabelle.heimsiegquote_hometeam(i) = length(find(rohdatentabelle.pHT(punktetabelle.spieldaten{pos_punktetabelle}{pos_hometeam}(1,pos_heimspiele)) == 3)) / ...
                                                    length(pos_heimspiele);
    end
    
    % Auswärtssiegquote AwayTeam.
    pos_auswaertsspiele = find(punktetabelle.spieldaten{pos_punktetabelle}{pos_awayteam}(3,(1:spieltag_awayteam-1)) == 0);
    if (isempty(pos_auswaertsspiele) == true)
        % Bislang gab es keine Heimspiele. Setze die Heimspielquote auf
        % einen moderaten Wert (siehe Statistiken).
        feature_tabelle.auswaertssiegquote_awayteam(i) = 0.3;
    elseif (length(pos_auswaertsspiele) < min_wert_statistik)
        % Es existieren noch zu wenig Daten für eine Statistik.
        % Setze auch in diesem Fall die Heimspielquote auf einen moderaten
        % Wert.
        feature_tabelle.auswaertssiegquote_awayteam(i) = 0.3;
    else
        % Falls genügend Heimspiele in dieser Saison gespielt wurden, dann
        % berechne die Heimsieg-Quote.
        feature_tabelle.auswaertssiegquote_awayteam(i) = length(find(rohdatentabelle.pAT(punktetabelle.spieldaten{pos_punktetabelle}{pos_awayteam}(1,pos_auswaertsspiele)) == 3)) / ...
                                                         length(pos_auswaertsspiele);
    end
    
    
    % Spielrückblick.
    % HomeTeam.
    gegner_wichtung = zeros(1, anzahl_rueckblick_spiele);
    for i_spieltag = 1:1:anzahl_rueckblick_spiele
        % Sollte es nicht genügend Spiele zum Zurückblicken geben, wird der
        % letztmögliche mehrfach wiederholt.
        n_spieltag = spieltag_hometeam - i_spieltag;
        if (n_spieltag < 1)
            % Es ist noch am Anfang der Saison und es lässt sich nicht so
            % weit zurückblicken.
            feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam(i, i_spieltag) = 1/3;    % Unentschieden.
            feature_tabelle.rueckblick_spielergebnisse_tore_hometeam(i, i_spieltag) = 0;        % keine Tore.
            feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam(i, i_spieltag) = 0;   % keine Gegentore.
            gegner_wichtung(i_spieltag) = 1;                                                    % Nichts wichten.
        else
            % Punkte.
            % Differenz der Punktetabelle ergibt das Ergebnis für den
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
            % Feature-Scaling auf die Punkte.
            feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam(i, i_spieltag) = feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam(i, i_spieltag) / 3;
            % Position des Spiels in der Rohdatentabelle.
            pos_spiel = punktetabelle.spieldaten{pos_punktetabelle}{pos_hometeam}(1,n_spieltag);
            % Tore und Gegentore.
            if (punktetabelle.spieldaten{pos_punktetabelle}{pos_hometeam}(3,n_spieltag) == 1)
                % Heimspiel.
                feature_tabelle.rueckblick_spielergebnisse_tore_hometeam(i, i_spieltag) = rohdatentabelle.FTHG(pos_spiel) / feature_scaling_tore;
                feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam(i, i_spieltag) = rohdatentabelle.FTAG(pos_spiel) / feature_scaling_tore;
            else
                % Auswärtsspiel.
                feature_tabelle.rueckblick_spielergebnisse_tore_hometeam(i, i_spieltag) = rohdatentabelle.FTAG(pos_spiel) / feature_scaling_tore;
                feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam(i, i_spieltag) = rohdatentabelle.FTHG(pos_spiel) / feature_scaling_tore;
            end
            % Wichtung des Gegners.
            n_gegnerteam = punktetabelle.spieldaten{pos_punktetabelle}{pos_hometeam}(2, n_spieltag);
            pos_gegnerteam = find(punktetabelle.teams{pos_punktetabelle} == n_gegnerteam);
            % Werte die Wichtung des Gegners nur, wenn eine ausreichende
            % Grundlage für die Statistik vorhanden ist.
            if (n_spieltag < min_wert_statistik)
                % Wichte nicht. Statistik nicht aussagekräftig.
                gegner_wichtung(i_spieltag) = 1;
            else
                % Werte +1 addieren, um Nullteilen zu verhindern.
                % Die Wichtung ist für erzielte Punkte und Tore zu
                % multiplizieren und bei Gegentoren mit dem Reziproken zu
                % multiplizieren.
                gegner_wichtung(i_spieltag) =   (punktetabelle.tabelle{pos_punktetabelle}(pos_gegnerteam, n_spieltag) + 1) / ...
                                                (punktetabelle.tabelle{pos_punktetabelle}(pos_hometeam, n_spieltag) + 1);
            end
        end
    end
    % Nach Gegner wichten.
    feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_gegnerwichtung(i,:) = feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam(i,:) .* gegner_wichtung;
    feature_tabelle.rueckblick_spielergebnisse_tore_hometeam_gegnerwichtung(i,:) = feature_tabelle.rueckblick_spielergebnisse_tore_hometeam(i,:) .* gegner_wichtung;
    feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam_gegnerwichtung(i,:) = feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam(i,:) .* (1 ./ gegner_wichtung);
    % Manuell Wichten.
    feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_gewichtet(i) = sum(feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_gegnerwichtung(i,:) .* wichtung_rueckblick);
    feature_tabelle.rueckblick_spielergebnisse_tore_hometeam_gewichtet(i) = sum(feature_tabelle.rueckblick_spielergebnisse_tore_hometeam_gegnerwichtung(i,:) .* wichtung_rueckblick);
    feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam_gewichtet(i) = sum(feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam_gegnerwichtung(i,:) .* wichtung_rueckblick);
    
    
    % AwayTeam.
    gegner_wichtung = zeros(1, anzahl_rueckblick_spiele);
    for i_spieltag = 1:1:anzahl_rueckblick_spiele
        % Sollte es nicht genügend Spiele zum Zurückblicken geben, wird der
        % letztmögliche mehrfach wiederholt.
        n_spieltag = spieltag_awayteam - i_spieltag;
        if (n_spieltag < 1)
            % Es ist noch am Anfang der Saison und es lässt sich nicht so
            % weit zurückblicken.
            feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam(i, i_spieltag) = 1/3;    % Unentschieden.
            feature_tabelle.rueckblick_spielergebnisse_tore_awayteam(i, i_spieltag) = 0;        % keine Tore.
            feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam(i, i_spieltag) = 0;   % keine Gegentore.
            gegner_wichtung(i_spieltag) = 1;                                                    % Nichts wichten.
        else
            % Punkte.
            % Differenz der Punktetabelle ergibt das Ergebnis für den
            % jeweiligen Spieltag.
            if ((n_spieltag - 1) < 1)
                % Es handelt sich um den ersten Spieltag. Hier ist der
                % hinterlegte Wert zu nehmen.
                feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam(i, i_spieltag) = punktetabelle.tabelle{pos_punktetabelle}(pos_awayteam, n_spieltag);            
            else
                % Es handelt sich um einen höheren Spieltag. Hier ist die
                % Differenz mit dem vorhergehenden Spieltag zu berechnen.
                feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam(i, i_spieltag) = punktetabelle.tabelle{pos_punktetabelle}(pos_awayteam, n_spieltag) - ...
                                                                                            punktetabelle.tabelle{pos_punktetabelle}(pos_awayteam, n_spieltag-1);
            end
            % Feature-Scaling auf die Punkte.
            feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam(i, i_spieltag) = feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam(i, i_spieltag) / 3;
            % Position des Spiels in der Rohdatentabelle.
            pos_spiel = punktetabelle.spieldaten{pos_punktetabelle}{pos_awayteam}(1,n_spieltag);
            % Tore und Gegentore.
            if (punktetabelle.spieldaten{pos_punktetabelle}{pos_awayteam}(3,n_spieltag) == 1)
                % Heimspiel.
                feature_tabelle.rueckblick_spielergebnisse_tore_awayteam(i, i_spieltag) = rohdatentabelle.FTHG(pos_spiel) / feature_scaling_tore;
                feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam(i, i_spieltag) = rohdatentabelle.FTAG(pos_spiel) / feature_scaling_tore;
            else
                % Auswärtsspiel.
                feature_tabelle.rueckblick_spielergebnisse_tore_awayteam(i, i_spieltag) = rohdatentabelle.FTAG(pos_spiel) / feature_scaling_tore;
                feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam(i, i_spieltag) = rohdatentabelle.FTHG(pos_spiel) / feature_scaling_tore;
            end
            % Wichtung des Gegners.
            n_gegnerteam = punktetabelle.spieldaten{pos_punktetabelle}{pos_awayteam}(2, n_spieltag);
            pos_gegnerteam = find(punktetabelle.teams{pos_punktetabelle} == n_gegnerteam);
            % Werte die Wichtung des Gegners nur, wenn eine ausreichende
            % Grundlage für die Statistik vorhanden ist.
            if (n_spieltag < min_wert_statistik)
                % Wichte nicht. Statistik nicht aussagekräftig.
                gegner_wichtung(i_spieltag) = 1;
            else
                % Werte +1 addieren, um Nullteilen zu verhindern.
                % Die Wichtung ist für erzielte Punkte und Tore zu
                % multiplizieren und bei Gegentoren mit dem Reziproken zu
                % multiplizieren.
                gegner_wichtung(i_spieltag) =   (punktetabelle.tabelle{pos_punktetabelle}(pos_gegnerteam, n_spieltag) + 1) / ...
                                                (punktetabelle.tabelle{pos_punktetabelle}(pos_awayteam, n_spieltag) + 1);
            end
        end
    end
    % Nach Gegner wichten.
    feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_gegnerwichtung(i,:) = feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam(i,:) .* gegner_wichtung;
    feature_tabelle.rueckblick_spielergebnisse_tore_awayteam_gegnerwichtung(i,:) = feature_tabelle.rueckblick_spielergebnisse_tore_awayteam(i,:) .* gegner_wichtung;
    feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam_gegnerwichtung(i,:) = feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam(i,:) .* (1 ./ gegner_wichtung);
    % Wichten.
    feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_gewichtet(i) = sum(feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_gegnerwichtung(i,:) .* wichtung_rueckblick);
    feature_tabelle.rueckblick_spielergebnisse_tore_awayteam_gewichtet(i) = sum(feature_tabelle.rueckblick_spielergebnisse_tore_awayteam_gegnerwichtung(i,:) .* wichtung_rueckblick);
    feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam_gewichtet(i) = sum(feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam_gegnerwichtung(i,:) .* wichtung_rueckblick);
    
end
close(waitbar_handle)


%% Feature-Erstellung.
%% Feature-Variante 1:
feature_tabelle.feature1 = [feature_tabelle.gesamt_skillwert_hometeam, ...
                            feature_tabelle.gesamt_skillwert_awayteam, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_gewichtet, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_gewichtet, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_hometeam_gewichtet, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_awayteam_gewichtet, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam_gewichtet, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam_gewichtet, ...
                            feature_tabelle.heimsiegquote_hometeam, ...
                            feature_tabelle.auswaertssiegquote_awayteam];


%% Feature-Variante 2:
feature_tabelle.feature2 = [feature_tabelle.globaler_skillwert_hometeam, ...
                            feature_tabelle.globaler_skillwert_awayteam, ...
                            feature_tabelle.tabellenpunkte_aktuell_hometeam, ...
                            feature_tabelle.tabellenpunkte_aktuell_awayteam, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_hometeam, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_awayteam, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam, ...
                            feature_tabelle.heimsiegquote_hometeam, ...
                            feature_tabelle.auswaertssiegquote_awayteam];

%% Feature-Variante 3:
feature_tabelle.feature3 = [feature_tabelle.globaler_skillwert_hometeam, ...
                            feature_tabelle.globaler_skillwert_awayteam, ...
                            feature_tabelle.tabellenpunkte_aktuell_hometeam, ...
                            feature_tabelle.tabellenpunkte_aktuell_awayteam, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_awayteam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam_gegnerwichtung, ...
                            feature_tabelle.heimsiegquote_hometeam, ...
                            feature_tabelle.auswaertssiegquote_awayteam];
                        
%% Feature-Variante 4:
feature_tabelle.feature4 = [feature_tabelle.gesamt_skillwert_hometeam, ...
                            feature_tabelle.gesamt_skillwert_awayteam, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_awayteam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam_gegnerwichtung, ...
                            feature_tabelle.heimsiegquote_hometeam, ...
                            feature_tabelle.auswaertssiegquote_awayteam];

%% Feature-Variante 5:
feature_tabelle.feature5 = [feature_tabelle.spieltag, ...
                            feature_tabelle.rueckblick_saison_tabellenpunkte_hometeam, ...
                            feature_tabelle.rueckblick_saison_tabellenpunkte_awayteam, ...
                            feature_tabelle.tabellenpunkte_aktuell_hometeam, ...
                            feature_tabelle.tabellenpunkte_aktuell_awayteam, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_awayteam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam_gegnerwichtung, ...
                            feature_tabelle.heimsiegquote_hometeam, ...
                            feature_tabelle.auswaertssiegquote_awayteam];

%% Feature-Variante 6:
feature_tabelle.feature6 = [feature_tabelle.gesamt_skillwert_hometeam, ...
                            feature_tabelle.gesamt_skillwert_awayteam, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_gewichtet, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_gewichtet, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_hometeam_gewichtet, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_awayteam_gewichtet, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam_gewichtet, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam_gewichtet];
                        
%% Feature-Variante 7:
feature_tabelle.feature7 = [feature_tabelle.spieltag, ...
                            feature_tabelle.gesamt_skillwert_hometeam, ...
                            feature_tabelle.gesamt_skillwert_awayteam, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_punkte_awayteam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_tore_awayteam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_hometeam_gegnerwichtung, ...
                            feature_tabelle.rueckblick_spielergebnisse_gegentore_awayteam_gegnerwichtung, ...
                            feature_tabelle.heimsiegquote_hometeam, ...
                            feature_tabelle.auswaertssiegquote_awayteam];
                        
%% Aufräumen.
clearvars -except anzahl_dateien teamnamen rohdatentabelle punktetabelle anzahl_spiele feature_tabelle


% Neuronales Netz starten.
% kickNN_neural_network_V002;