clear; close all; clc;

addpath(genpath(pwd));

% kickNN.
% Fussball-Bundesliga-Tipp-Software basierend auf einem Neuronalen Netz.
disp('+-----------------------------------------------------------------+');
disp('|                                                                 |');
disp('|                             kickNN                              |');
disp('|             Neural Network Bundesliga-Tippgenerator             |');
disp('|                       © Tim Schwarzbrunn                        |');
disp('|                                                                 |');
disp('+-----------------------------------------------------------------+');
disp(' ');

% Daten einladen.
dateien = dir('03_Daten/*.csv');
anzahl_dateien = length(dateien);
disp(['Es wurden ' num2str(anzahl_dateien) ' *.csv-Dateien im Ordner ''03_Daten'' gefunden.']);
disp('Datenquellen:');
disp('Liga 1 & 2 Saison 1993 - 2018: http://www.football-data.co.uk/germanym.php');
disp('Liga 1     Saison 1963 - 1992: https://github.com/footballcsv/deutschland');
disp(' ');
anzahl_spiele = zeros(1, anzahl_dateien);
liga = zeros(1, anzahl_dateien);
saison = zeros(1, anzahl_dateien);
for i = 1:1:anzahl_dateien
    disp(['--> Einlesen der Datei ''' dateien(i).name '''.']);
    daten{i} = readcell(['03_Daten/' dateien(i).name], 'DatetimeType', 'text', 'Delimiter',{';',',','\t'});         %#ok<SAGROW>
    % Ermittlung der Anzahl der Spiele des eingelesenen Datensatzes.
    % (Subtraktion - 1 aufgrund des Tabellenkopfes.)
    anzahl_spiele(i) = size(daten{i}, 1) - 1;
    if (anzahl_spiele(i) == 240)
        disp('   --> 240 Spiele = 16 Mannschaften.');
    elseif (anzahl_spiele(i) == 306)
        disp('   --> 306 Spiele = 18 Mannschaften.');
    elseif (anzahl_spiele(i) == 380)
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
% Div           = Liga
% HomeTeam      = Team1 (Heimteam)
% AwayTeam      = Team2 (Auswärtsteam)
% FTHG / HG     = Tore Team1 / Heimteam
% FTAG / AG     = Tore Team2 / Auswärtsteam
% HY            = Gelbe Karten Team1 / Heimteam
% AY            = Gelbe Karten Team2 / Auswärtsteam
% HR            = Rote Karten Team1 / Heimteam
% AR            = Rote Karten Team2 / Auswärtsteam
% HST           = Torschüsse Team1 / Heimteam
% AST           = Torschüsse Team2 / Auswärtsteam
gesuchte_daten = {  'HomeTeam', ...
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
    'VariableNames', gesuchte_daten, ...
    'RowNames', {dateien.name});
for i = 1:1:anzahl_dateien
    disp(['--> Bereinigen der Daten der Datei ''' dateien(i).name '''.']);
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
% Konvertierung der Liga von Chararray in eine Zahl.
pos_liga = find(contains(gesuchte_daten, 'Div'));
rohdatentabelle(:,pos_liga) = cellfun(@(x) {str2double(x)}, cellfun(@(x) {x(end)}, rohdatentabelle(:,pos_liga)));
% Konvertierung der Saison von einem Charray in eine Zahl (hierbei werden
% die letzten beiden Ziffern des ersten Spieldatums (Jahr des
% Saisonauftaktes genutzt).
pos_datum = find(contains(gesuchte_daten, 'Date')); 
for i = 1:1:anzahl_dateien
    datum = rohdatentabelle{1+((i-1)*306), pos_datum};
    jahr = 2000 + str2double(datum(end-1:end));
    rohdatentabelle(1+((i-1)*306):i*306, pos_datum) = {jahr};
end

% Umwandlung von Cell-Matrix in Tabelle.
rohdatentabelle = cell2table(rohdatentabelle, 'VariableNames', gesuchte_daten);
disp('Daten wurden von einer Cell-Matrix in eine Tabelle überführt.');
disp(' ');

% Umbennung von "St. Pauli" in "St Pauli", da dies in den Daten
% undurchgängig ist.
rohdatentabelle.HomeTeam(strcmp(rohdatentabelle.HomeTeam, 'St. Pauli')) = {'St Pauli'};
rohdatentabelle.AwayTeam(strcmp(rohdatentabelle.AwayTeam, 'St. Pauli')) = {'St Pauli'};

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

% Ermittlung der Spieltage.
for i = 1:1:anzahl_dateien
    rohdatentabelle.spieltag(1+((i-1)*306):i*306) = fix(((0:1:305)./9) + 1).';
end

% Ermittlung der Punkte.
% Sieg = 3 Punkte.
% Unentschieden = 1 Punkt.
% Niederlage = 0 Punkte.
punkte_sieg = 3;
punkte_unentschieden = 1;
punkte_niederlage = 0;

punktetabelle = [];
for i = 1:1:anzahl_dateien
    punktetabelle(i).liga = rohdatentabelle.Div(1+(i-1)*306);
    punktetabelle(i).saison = rohdatentabelle.Date(1+(i-1)*306);
    punktetabelle(i).teams = unique(rohdatentabelle.nHomeTeam(rohdatentabelle.Div == punktetabelle(i).liga & rohdatentabelle.Date == punktetabelle(i).saison));
    for j = 1:1:length(punktetabelle(i).teams)
        pos_heimspiele = find(rohdatentabelle.Div == punktetabelle(i).liga & ...
                                rohdatentabelle.Date == punktetabelle(i).saison & ...
                                rohdatentabelle.nHomeTeam == punktetabelle(i).teams(j));
        pos_auswaertsspiele = find(rohdatentabelle.Div == punktetabelle(i).liga & ...
                                rohdatentabelle.Date == punktetabelle(i).saison & ...
                                rohdatentabelle.nAwayTeam == punktetabelle(i).teams(j));
        
    end
end

% Aufräumen.
clearvars -except anzahl_dateien teamnamen rohdatentabelle punktetabelle anzahl_spiele
