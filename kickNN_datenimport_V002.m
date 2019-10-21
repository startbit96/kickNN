clear; close all; clc;

addpath(genpath(pwd));

% kickNN.
% Fussball-Bundesliga-Tipp-Software basierend auf einem Neuronalen Netz.
disp('+-----------------------------------------------------------------+');
disp('|                                                                 |');
disp('|                             kickNN                              |');
disp('|              Neural Network Bundesliga-Tippgenerator            |');
disp('|                       © Tim Schwarzbrunn                        |');
disp('|                                                                 |');
disp('+-----------------------------------------------------------------+');
disp(' ');

% Daten einladen.
dateien = dir('03_Daten/*.csv');
anzahl_dateien = length(dateien);
disp(['Es wurden ' num2str(anzahl_dateien) ' *.csv-Dateien im Ordner ''03_Daten'' gefunden.']);
disp('Datenquellen:');
disp('Liga 1     Saison 1963 - 1992: https://github.com/footballcsv/deutschland');
disp('Liga 1 & 2 Saison 1993 - 2018: https://github.com/footballcsv/deutschland');
disp('                               (http://www.football-data.co.uk/germanym.php)');
disp(' ');
anzahl_spiele = zeros(1, anzahl_dateien);
anzahl_spieltage = zeros(1, anzahl_dateien);
liga = zeros(1, anzahl_dateien);
saison = zeros(1, anzahl_dateien);
for i = 1:1:anzahl_dateien
    disp(['--> Einlesen der Datei ''' dateien(i).name '''.']);
    daten{i} = readcell(['03_Daten/' dateien(i).name], 'DatetimeType', 'text', 'Delimiter',{';',',','\t'});         %#ok<SAGROW>
    % Ermittlung der Anzahl der Spiele des eingelesenen Datensatzes.
    % (Subtraktion - 1 aufgrund des Tabellenkopfes.)
    anzahl_spiele(i) = size(daten{i}, 1) - 1;
    if (anzahl_spiele(i) == 240)
        anzahl_spieltage(i) = 30;
        disp('   --> 240 Spiele = 16 Mannschaften.');
    elseif (anzahl_spiele(i) == 306)
        anzahl_spieltage(i) = 34;
        disp('   --> 306 Spiele = 18 Mannschaften.');
    elseif (anzahl_spiele(i) == 380)
        anzahl_spieltage(i) = 38;
        disp('   --> 380 Spiele = 20 Mannschaften.');
    else
        % Anzahl Spiele entspricht nicht der Erwartung? (Kann auch an
        % leerer Zeile am Dateiende liegen!)
        disp(['   --> Anzahl der Spiele beträgt nicht wie erwartet 306 Spiele sondern ' num2str(anzahl_spiele(i)) '!']);
        return;
    end
    % Ermittlung der Liga und der Saison anhand des Dateinamens.
    liga(i) = str2double(dateien(i).name(2));
    saison(i) = str2double(dateien(i).name(4:7));
end
disp(' ');
disp(['Es wurden ' num2str(sum(anzahl_spiele)) ' Spiele eingelesen.']);
disp(' ');

% Welche Daten sind von Bedeutung? Den Rest löschen ...
% Folgender Abschnitt ist aufgrund der vorher verwendeten Daten historisch
% so gewachsen und könnte sicherlich noch optimiert werden ...
% Funktioniert aber auch so .. ;-)
gesuchte_daten = {  'Liga', ...
                    'Saison', ...
                    'HomeTeam', ...
                    'AwayTeam', ...
                    'FTHG', ...
                    'FTAG'};
disp('Löschen der nicht benötigten Daten. Behalten werden folgende Daten:');
disp(gesuchte_daten);

% Bereinigung der Daten und Beibehaltung der gesuchten Daten.
tabelle_datentyp = cell(1, length(gesuchte_daten));
tabelle_datentyp(:) = {'int8'};
tabellen_handle = table('Size', [anzahl_dateien, length(gesuchte_daten)], ...
    'VariableTypes', tabelle_datentyp, ...
    'VariableNames', cellfun(@(x) strrep(x, ' ', ''), gesuchte_daten, 'UniformOutput', false), ...
    'RowNames', {dateien.name});
for i = 1:1:anzahl_dateien
    disp(['--> Bereinigen der Daten der Datei ''' dateien(i).name '''.']);
    % Umbennen von 'Team 1' in 'HomeTeam' und 'Team 2' in 'AwayTeam'.
    % Falls dem so ist, dann entferne die letzten vier bis fünf Ziffern. Dort steht
    % in diesem Fall der Spieltag.
    pos_team1 = find(contains(string(daten{i}(1,:)), 'Team 1'));
    pos_team2 = find(contains(string(daten{i}(1,:)), 'Team 2'));
    if ((isempty(pos_team1) == false) && ...
        (isempty(pos_team2) == false))
        disp('   --> Umwandlung ''Team 1'', ''Team 2'', ''FT''.');
        % HomeTeam & AwayTeam.
        daten{i}(1, pos_team1) = {'HomeTeam'};
        daten{i}(1, pos_team2) = {'AwayTeam'};
        daten{i}(2:end, pos_team1) = cellfun(@(x) x(1:find(x == '(', 1)-2), daten{i}(2:end, pos_team1), 'UniformOutput', false);
        daten{i}(2:end, pos_team2) = cellfun(@(x) x(1:find(x == '(', 1)-2), daten{i}(2:end, pos_team2), 'UniformOutput', false);
        % FT in FTHG und FTAG umwandeln.
        pos_FT = find(contains(string(daten{i}(1,:)), 'FT'));
        cell_FTHG = cellfun(@(x) str2double(x(1:strfind(x,'-')-1)), daten{i}(2:end, pos_FT), 'UniformOutput', false);
        cell_FTAG = cellfun(@(x) str2double(x(strfind(x,'-')+1:end)), daten{i}(2:end, pos_FT), 'UniformOutput', false);
        daten{i} = [daten{i}, [{'FTHG'}; cell_FTHG], [{'FTAG'}; cell_FTAG]];
        % Liga und Saison hinzufügen.
        daten{i} =  [[{'Liga'}; num2cell(zeros(anzahl_spiele(i), 1) + liga(i))], ...
                    [{'Saison'}; num2cell(zeros(anzahl_spiele(i), 1) + saison(i))], ...
                    daten{i}];
    end
    % Welche Daten können gelöscht werden?
    pos_behalten = contains(string(daten{i}(1,:)), gesuchte_daten);
    pos_loeschen = pos_behalten == 0;
    daten{i}(:, pos_loeschen) = [];
    % Welche Daten von den gesuchten Daten sind auch vorhanden?
    daten_vorhanden = contains(gesuchte_daten, string(daten{i}(1,:)));
    tabellen_handle{i,:} = daten_vorhanden;
end

disp(' ');
disp('Folgende Daten wurden in den eingeladenen Dateien gefunden:');
disp(' ');
disp(tabellen_handle);
disp(' ');


% Zusammenführung der Daten in eine große Zellen-Matrix.
% Speicher reservieren.
rohdatentabelle = cell(sum(anzahl_spiele), length(gesuchte_daten));
for i = 1:1:anzahl_dateien
    for j = 1:1:size(daten{i},2)
        pos_spalte = find(contains(string(gesuchte_daten(:)), daten{i}(1,j)));
        if (isempty(pos_spalte) == true)
            continue;
        end
        rohdatentabelle(1+sum(anzahl_spiele(1:(i-1))):sum(anzahl_spiele(1:i)), pos_spalte) = daten{i}(2:end, j);
    end
end

disp('Daten wurden in eine gemeinsame Cell-Matrix überführt.');
disp(' ');

% Datenaufbereitung.
disp('Daten werden aufbereitet.');
disp(' ');

% Umwandlung von Cell-Matrix in Tabelle.
rohdatentabelle = cell2table(rohdatentabelle, 'VariableNames', gesuchte_daten);
disp('Daten wurden von einer Cell-Matrix in eine Tabelle überführt.');
disp(' ');

% Ermittlung der Teams und Zuweisung von Nummern anstelle von Zeichenketten.
teamnamen_hometeam = unique(rohdatentabelle.HomeTeam);
teamnamen_awayteam = unique(rohdatentabelle.AwayTeam);
if (isequal(teamnamen_hometeam, teamnamen_awayteam) == true)
    disp(['Folgende ' num2str(length(teamnamen_hometeam)) ' Teams sind in diesen Datensätzen vorhanden:']);
    disp(' ')
    disp(teamnamen_hometeam);
    disp(' ');
    teamnamen = teamnamen_hometeam;
    clear teamnamen_hometeam teamnamen_awayteam
else
    disp('In den Daten liegt ein Fehler vor. Es sind unterschiedliche Teams in den Datenreihen HomeTeam und AwayTeam erkannt wurden:');
    disp('HomeTeam:')
    disp(teamnamen_hometeam);
    disp('AwayTeam:')
    disp(teamnamen_awayteam);
    return;
end

% Umwandlung in Nummern.
rohdatentabelle.nHomeTeam = cellfun(@(x) find(contains(teamnamen, x)), rohdatentabelle.HomeTeam);
rohdatentabelle.nAwayTeam = cellfun(@(x) find(contains(teamnamen, x)), rohdatentabelle.AwayTeam);
rohdatentabelle.HomeTeam = [];
rohdatentabelle.AwayTeam = [];

% Ermittlung der Punkte.
disp('Ermittlung der Spielpunkte.');
disp(' ');
% Sieg = 3 Punkte.
% Unentschieden = 1 Punkt.
% Niederlage = 0 Punkte.
punkte_sieg = 3;
punkte_unentschieden = 1;
punkte_niederlage = 0;

rohdatentabelle.pHT = zeros(size(rohdatentabelle, 1), 1);
rohdatentabelle.pAT = zeros(size(rohdatentabelle, 1), 1);

for i = 1:1:size(rohdatentabelle, 1)
    if (rohdatentabelle.FTHG(i) > rohdatentabelle.FTAG(i))
        % Heimsieg.
        rohdatentabelle.pHT(i) = punkte_sieg;
        rohdatentabelle.pAT(i) = punkte_niederlage;
    elseif (rohdatentabelle.FTHG(i) < rohdatentabelle.FTAG(i))
        % Auswärtssieg.
        rohdatentabelle.pHT(i) = punkte_niederlage;
        rohdatentabelle.pAT(i) = punkte_sieg;
    else
        % Unentschieden.
        rohdatentabelle.pHT(i) = punkte_unentschieden;
        rohdatentabelle.pAT(i) = punkte_unentschieden;
    end
end


% Aufstellen der Punktetabellen.
% Hinweis: Phantomtor Bayern - Nürnberg 1993 32. Spieltag führt zu
% Unordnung in den Daten. Muss manuell in der csv-Datei angepasst werden.
% Hinweis: Spielverlegungen 16. und 17. Spieltag und 21. und 22. Spieltag 1994 der 1. Liga. (...)
% --> richtige Reihenfolge analog https://www.kicker.de/1-bundesliga/spieltag/1994-95/-1
% ==> Aufgrund vieler Inkonsistenzen wird nicht mehr anhand des automatisch
% generierten Spieltags die Tabelle aufgestellt, sondern anhand der
% Reihenfolge der Spiele eines jeden Teams.
disp('Berechnung der Punktetabellen ...');
disp('(Torverhältnis wird bei Punktegleichstand nicht berücksichtigt.)');
punktetabelle = [];
punktetabelle.liga = liga;
punktetabelle.saison = saison;
punktetabelle.teams = [];
punktetabelle.spieldaten = [];
for i = 1:1:anzahl_dateien
    disp(['--> Liga: ' num2str(punktetabelle.liga(i)) ' | Saison: ' num2str(punktetabelle.saison(i))]);
    % Wo befinden sich die gesuchten Daten?
    pos_rohdaten = find((((rohdatentabelle.Liga == punktetabelle.liga(i)) == 1) & ...
                        ((rohdatentabelle.Saison == punktetabelle.saison(i)) == 1)) == 1);
    % Ermittlung der in dieser Liga und der Saison angetretenen Teams.
    punktetabelle.teams{i} = unique(rohdatentabelle.nHomeTeam(pos_rohdaten));
    punktetabelle.tabelle{i} = zeros(length(punktetabelle.teams{i}), anzahl_spieltage(i));
    % Ermittle für jedes Team die erreichte Punktzahl.
    for j = 1:1:length(punktetabelle.teams{i})
        % Heimspiele.
        pos_heimspiele = find(rohdatentabelle.nHomeTeam(pos_rohdaten) == punktetabelle.teams{i}(j));
        punkte_heimspiele = rohdatentabelle.pHT(pos_rohdaten(pos_heimspiele));
        gegner_heimspiele = rohdatentabelle.nAwayTeam(pos_rohdaten(pos_heimspiele));
        % Auswärtsspiele.
        pos_auswaertsspiele = find(rohdatentabelle.nAwayTeam(pos_rohdaten) == punktetabelle.teams{i}(j));
        punkte_auswaertsspiele = rohdatentabelle.pAT(pos_rohdaten(pos_auswaertsspiele));
        gegner_auswartsspiele = rohdatentabelle.nHomeTeam(pos_rohdaten(pos_auswaertsspiele));
        % Punktetabelle befüllen.
        ergebnis_tabelle = [pos_heimspiele.',               pos_auswaertsspiele.'; ...
                            punkte_heimspiele.',            punkte_auswaertsspiele.'; ...
                            gegner_heimspiele.',            gegner_auswartsspiele.'; ...
                            ones(1, length(pos_heimspiele)),zeros(1, length(pos_auswaertsspiele))];
        if(size(ergebnis_tabelle, 2) ~= anzahl_spieltage(i))
            disp('Inkonsistente Anzahl der Spieltage!');
            return;
        end
        % Sortieren, um Spieltage herauszufinden.
        [~, spieltage] = sort(ergebnis_tabelle(1,:));
        for k = 1:1:anzahl_spieltage(i)
            if (k == 1)
                punktetabelle.tabelle{i}(j,k) = ergebnis_tabelle(2, spieltage(k));
            else
                punktetabelle.tabelle{i}(j,k) = punktetabelle.tabelle{i}(j,k-1) + ergebnis_tabelle(2, spieltage(k));
            end
        end
        % Punktetabelle Spieldaten befüllen.
        % Aufbau:
        % Anzahl Spalten = Spieltage.
        % 1. Zeile = Position der Spiele in der Rohdatentabelle.
        % 2. Zeile = Gegner.
        % 3. Zeile = 1 für Heimspiel; 0 für Auswärtsspiel.
        punktetabelle.spieldaten{i}{j} = [  ergebnis_tabelle(1, spieltage) + min(pos_rohdaten) - 1; ...
                                            ergebnis_tabelle(3, spieltage); ...
                                            ergebnis_tabelle(4, spieltage)];
                                            
    end
    % Platzierung anhand der Ergebnisse des letzten Spieltages
    % herausfinden. Hier wird keine Doppelbelegung einer Punktzahl
    % beachtet, bei welcher normalerweise das Torverhältnis mit
    % betrachtet wird.
    [~, punktetabelle.platzierung{i}] = sort(punktetabelle.tabelle{i}(:,end), 'descend');
    % Ausgabe der ersten drei Platzierungen.
    disp(['    Platz 1: ' teamnamen{punktetabelle.teams{i}(punktetabelle.platzierung{i}(1))} ' (' num2str(punktetabelle.tabelle{i}(punktetabelle.platzierung{i}(1), end)) ' Punkte)']);
    disp(['    Platz 2: ' teamnamen{punktetabelle.teams{i}(punktetabelle.platzierung{i}(2))} ' (' num2str(punktetabelle.tabelle{i}(punktetabelle.platzierung{i}(2), end)) ' Punkte)']);
    disp(['    Platz 3: ' teamnamen{punktetabelle.teams{i}(punktetabelle.platzierung{i}(3))} ' (' num2str(punktetabelle.tabelle{i}(punktetabelle.platzierung{i}(3), end)) ' Punkte)']);
end
disp(' ');


% Aufräumen.
clearvars -except anzahl_dateien teamnamen rohdatentabelle punktetabelle anzahl_spiele

% Berechnung der Features.
kickNN_featuregenerator_V002;