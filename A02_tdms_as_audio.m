clear;
clc;

% Lade die verarbeiteten Zeitreihen-Daten
load('read_timeSeriesData.mat', 'timeSeriesDataArray');

outputDirectory = 'C:\Users\navo36du\LRZ Sync+Share\21_ReHydro (Axel Busboom)\07_Daten\Audio-Tests';

% Überprüfe, ob das Verzeichnis existiert, und erstelle es ggf.
if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);  % Erstelle das Verzeichnis, falls es nicht existiert
end

%% Zu definieren:
originalSpeed = false;
slowerSpeed = true;

originalSampleRate = 20000000;  % Ursprüngliche Abtastrate
slowDownFactor = 10;  % Faktor zur Verlangsamung (z.B. 10 Mal langsamer)
slowedSampleRate = originalSampleRate / slowDownFactor;  % Neue Abtastrate

%% Vertonung des tdms-files
for idx = 1:length(timeSeriesDataArray)
    timeSeriesData = timeSeriesDataArray(idx).Data;

    % Normalisierung der Daten für Audio
    normalizedData = timeSeriesData / max(abs(timeSeriesData)); 

    % Generiere den Dateinamen für die WAV-Datei
    if originalSpeed
        audioFileName = [timeSeriesDataArray(idx).FileName, '_', timeSeriesDataArray(idx).ChannelName, '.wav'];
        audioFilePath = fullfile(outputDirectory, audioFileName);
        audiowrite(audioFilePath, normalizedData, originalSampleRate);

    elseif slowerSpeed
        audioFileName = [timeSeriesDataArray(idx).FileName, '_', timeSeriesDataArray(idx).ChannelName, '_', num2str(slowDownFactor), 'x_slower.wav'];
        audioFilePath = fullfile(outputDirectory, audioFileName);
        audiowrite(audioFilePath, normalizedData, slowedSampleRate);
    end

    disp(['Audio gespeichert als: ', audioFileName]);
end