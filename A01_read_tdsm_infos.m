clear;
clc;

%% EINSTELLUNGEN / MODE-AUSWAHL
singleFile = false;
multipleFiles = true;
wholeDirectory = false;

% Single Files
tdmsSingleFilePath = 'D:/Daten/Prototypen/raanaasfoss/raanaasfoss_9MW_a.tdms';
%tdmsFilePath = 'D:\Daten\Prototypen\sarelli_prot/31-03-2015-15-08-20.tdms';

% Multiple Files
tdmsMultipleFilePaths = { ...
    'D:/Daten/Prototypen/raanaasfoss/raanaasfoss_12MW_b.tdms',
    'D:/Daten/Prototypen/raanaasfoss/raanaasfoss_14MW_a.tdms'
};

% Directory
directoryPath = 'D:/Daten/Prototypen/raanaasfoss';  % Setze den Pfad des Verzeichnisses
if wholeDirectory
    % Hole alle TDMS-Dateien im angegebenen Verzeichnis
    tdmsDirectoryFileStructs = dir(fullfile(directoryPath, '*.tdms'));
    
    % Erstelle einen Zell-Array von Dateipfaden
    tdmsDirectoryFilePaths = fullfile({tdmsDirectoryFileStructs.folder}, {tdmsDirectoryFileStructs.name});
end

% Wähle die Dateipfade basierend auf den Einstellungen
if singleFile
    disp("Single File chosen")
    tdmsFilePaths = {tdmsSingleFilePath}; % Um sicherzustellen, dass es sich um eine Zell-Array handelt
elseif multipleFiles
    disp("Multiple Files chosen")
    tdmsFilePaths = tdmsMultipleFilePaths;
elseif wholeDirectory
    disp("Directory chosen")
    tdmsFilePaths = tdmsDirectoryFilePaths;
else
    error('Keine gültige Mode-Auswahl getroffen.');
end
disp(' ')

% Initialisiere eine leere Struktur für die Zeitreihen-Daten
timeSeriesDataArray = struct('FileName', {}, 'GroupName', {}, 'ChannelName', {}, 'Data', {});

%% Schleife über alle TDMS-Dateipfade
for fileIdx = 1:length(tdmsFilePaths)
    tdmsFilePath = tdmsFilePaths{fileIdx};
    
    % Lese die TDMS-Datei
    [data, info] = TDMS_readTDMSFile(tdmsFilePath);
    
    % Extrahiere den Basisdateinamen
    [~, baseFileName, ~] = fileparts(tdmsFilePath);    
    validBaseFileName = strrep(baseFileName, '-', '_'); % Ersetze Bindestriche durch Unterstriche
    validBaseFileName = matlab.lang.makeValidName(validBaseFileName); % Sicherstellen, dass der Name gültig ist
    
    % Initialisiere einen Index für die Zeitreihendaten dieser Datei
    i = 1;

    % Finde alle Spalten, die Datenpunkte enthalten
    numDataPoints = info.numberDataPoints;

    disp(['Verarbeite Datei: ', tdmsFilePath]);

    for idx = 1:numel(numDataPoints)
        if numDataPoints(idx) > 0
            disp(['  Spalte ', num2str(idx), ': Anzahl der Datenpunkte = ', num2str(numDataPoints(idx))]);

            % Gruppennamen und Kanalnamen für die aktuelle Spalte
            if idx <= numel(info.groupNames)
                groupName = info.groupNames{idx};
            else
                groupName = 'Unbekannt';
            end

            if idx <= numel(info.chanNames)
                channelName = info.chanNames{idx};
            else
                channelName = 'Unbekannt';
            end

            disp(['    Gruppenname: ', groupName]);
            disp(['    Kanalname: ', channelName]);

            if isfield(data, 'data') && numDataPoints(idx) > 0
                timeSeriesData = data.data{idx};  % Beispiel für einen möglichen Zugriff

                % Speichern der Zeitreihe in der Struktur
                timeSeriesDataArray(end+1).FileName = validBaseFileName;
                timeSeriesDataArray(end).GroupName = groupName;
                timeSeriesDataArray(end).ChannelName = channelName;
                timeSeriesDataArray(end).Data = timeSeriesData;

                disp('    Erste 10 Werte der Zeitreihe:');
                disp(timeSeriesData(1:min(10, end)));  % Zeige die ersten 10 Werte oder weniger, falls weniger vorhanden
                
                i = i + 1;
            end
        end
    end
    disp(' ');
end

%% Speichern der gefilterten Zeitreihen in die MATLAB-Arbeitsumgebung
for idx = 1:length(timeSeriesDataArray)
    % Erstelle einen gültigen Variablennamen basierend auf Dateiname und Index
    varName = [timeSeriesDataArray(idx).FileName, '_', num2str(idx)];
    % Speichere die Zeitreihe in der MATLAB-Arbeitsumgebung
    assignin('base', varName, timeSeriesDataArray(idx).Data);
end

% Speichere alle Zeitreihen-Daten in einer .mat-Datei
save('read_timeSeriesData.mat', 'timeSeriesDataArray');

disp('Zeitreihen-Daten wurden in read_timeSeriesData.mat gespeichert.');

%signalAnalyzer