% mehrere Messreihen gleichzeitig öffnen und vergleichen
% Achtung: Sicherstellen, dass die gleichen Datensets verglichen werden!

singleFiles = false;
wholeDirectory = true;

% Verzeichnis für die TDMS-Dateien und .mat-Dateien
tdmsDirectory = 'C:\Users\navo36du\Downloads\Trainingsdaten_Voith\Prototypen\raanaasfoss';
matDirectory = 'C:\Users\navo36du\Downloads\matFiles';

% Liste der TDMS-Dateipfade
tdmsFilePaths = { ...
    'C:\Users\navo36du\Downloads\Trainingsdaten_Voith\Prototypen\raanaasfoss\raanaasfoss_9MW_a.tdms',
    'C:\Users\navo36du\Downloads\Trainingsdaten_Voith\Prototypen\raanaasfoss\raanaasfoss_11MW_a.tdms', 
    'C:\Users\navo36du\Downloads\Trainingsdaten_Voith\Prototypen\raanaasfoss\raanaasfoss_7MW_a.tdms', 
    'C:\Users\navo36du\Downloads\Trainingsdaten_Voith\Prototypen\raanaasfoss\raanaasfoss_13MW_a.tdms'
    };

if ~exist(matDirectory, 'dir')
    mkdir(matDirectory);
end

if wholeDirectory
    % Alle TDMS-Dateien im Verzeichnis auflisten
    tdmsFiles = dir(fullfile(tdmsDirectory, '*.tdms'));
    % Dateinamen extrahieren
    fileNames = {tdmsFiles.name};
    
    % Extrahiere numerische Teile der Dateinamen
    numParts = zeros(size(fileNames));
    for i = 1:length(fileNames)
        % Extrahiere den numerischen Teil aus dem Dateinamen
        tokens = regexp(fileNames{i}, '\d+', 'match');
        if ~isempty(tokens)
            numParts(i) = str2double(tokens{end}); % Letzte gefundene Zahl verwenden
        end
    end

    % Sortiere basierend auf den numerischen Teilen
    [~, sortOrder] = sort(numParts);
    tdmsFiles = tdmsFiles(sortOrder);
    numTDMSFiles = numel(tdmsFiles);
end

% Anzahl der gefundenen TDMS-Dateien
if wholeDirectory
    lastFile = numTDMSFiles;
end

if singleFiles
   lastFile = length(tdmsFilePaths);
end

% Schleife über alle TDMS-Dateien
for k = 1:lastFile
    % Einlesen der TDMS-Datei & Extraktion des Dateinamens
    if singleFiles
       tdmsFilePath = tdmsFilePaths{k};
    end
    if wholeDirectory
       tdmsFilePath = fullfile(tdmsDirectory, tdmsFiles(k).name);
    end
    [~, fileName, ~] = fileparts(tdmsFilePath);

    % Einlesen der TDMS-Daten
    my_data = TDMS_readTDMSFile(tdmsFilePath);
    
    % Finde die Indizes der nicht-leeren Arrays
    nonEmptyIndices = find(~cellfun(@isempty, my_data.data));
    
    % Bestimme die maximale Anzahl an Datenpunkten
    numberDataPoints = my_data.numberDataPointsRaw; % von allen Spalten
    maxDataPoints = max(numberDataPoints);

    % Initialisiere eine Cell-Array, um die Variablen zu speichern
    datasetsCellArray = cell(1, numel(nonEmptyIndices));
    datasetCount = 0;

    % Daten in Cell-Array speichern
    for i = 1:numel(nonEmptyIndices)
        index = nonEmptyIndices(i); % Holen Sie sich den tatsächlichen Index
        % Zugriff auf die Daten im aktuellen Cell
        dataset = my_data.data{index};

        % Umwandeln des Zeilenvektors in einen Spaltenvektor
        if isrow(dataset)
            dataset = dataset'; % Transponieren des Zeilenvektors
        end

        % Überprüfen, ob die Anzahl der Datenpunkte der maximalen Anzahl entspricht
        if numel(dataset) == maxDataPoints
            datasetCount = datasetCount + 1;
            % Speichern im Cell-Array
            datasetsCellArray{datasetCount} = dataset;
        end
    end

    % Entfernen der nicht verwendeten Zellen
    datasetsCellArray = datasetsCellArray(1:datasetCount);

    % Speichern in der Struktur
    allDatasetsStruct.(fileName) = datasetsCellArray;

    % Anzeige der Größe der jeweiligen Datensets
    for i = 1:datasetCount
        % Zugriff auf das Dataset aus dem Cell-Array
        dataset = datasetsCellArray{i};

        % Anzeige der Größe des Datensets
        sizeStr = [num2str(size(dataset, 1)) ' x ' num2str(size(dataset, 2))];
        disp([fileName ' - size: ' sizeStr]);

        % Speichern jedes Datensatzes einzeln
        datasetFileName = fullfile(matDirectory, sprintf('%s_dataset_%d.mat', fileName, i));
        save(datasetFileName, 'dataset', '-v7.3');
    end
end
disp(' ')

% Öffnen der Signal Analyzer App
signalAnalyzer