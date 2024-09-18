% einfach mal verschiedene Dinge an Raanaasfoss ausprobiert:
% jeweils für gesamtes Signal so wie eine Umdrehung (5 Peaks)
% - Downsampling (Hälte aller Daten)
% - Statistische Analysen (RMS, ...)

% Achtung: - A02 needs to be run first
%          - Der Dateiname der loadedData muss angepasst werden

%--------------------------------------------------------------------------

% Ausprobierte Dinge auswählen
% Bedingung für das kleinere Fenster und Downsampling
minMaxNorm = false;
zScoreNorm = true; 
certainWindow = true;  % Setze auf true, um das Fenster anzuzeigen
downsamplingRegular = false;  % Setze auf true, um das Downsampling durchzuführen
downsamplingOnWindow = false;  % Setze auf true, um das Downsampling auf den gewählten Bereich anzuwenden


% 1. Daten laden
inputFileName = 'raanaasfoss_9MW_a.mat';
loadedData = load(inputFileName);
variableNames = fieldnames(loadedData);
data = loadedData.(variableNames{1});  % Angenommen, das Datenfeld heißt 'data'

%NORMALISIERUNGEN__________________________________________________________

% MIN-MAX NORMALISIERUNG FÜR ALLE DATEN_____________________________________
if minMaxNorm
    minData = min(data);
    maxData = max(data);
    normalizedDataAll = (data - minData) / (maxData - minData);
end
    
% Z-SCORE NORMALISIERUNG FÜR ALLE DATEN_____________________________________
if zScoreNorm
    meanData = mean(data);
    stdData = std(data);
    zScoreDataAll = (data - meanData) / stdData;
end

%KLEINERES FENSTER_________________________________________________________
if certainWindow

    if minMaxNorm
        data = normalizedDataAll;
    end

    if zScoreNorm
        data = zScoreDataAll;
    end

    % 2. Datenbereich definieren
    startIndex = 1;  % Startindex des Bereichs
    endPoint = 2000000;  % Definiere den Endpunkt des Datenbereichs
    endIndex = min(length(data), endPoint);  % Endindex des Bereichs, maximal 'end_point' Datenpunkte
    
    % Sicherstellen, dass wir nicht außerhalb der Datenreichweite zugreifen
    if endIndex > length(data)
        endIndex = length(data);
    end
    
    % Wählen des Datenbereichs aus
    windowData = data(startIndex:endIndex);
    windowX = startIndex:endIndex;
    
    if ~downsamplingOnWindow
        % 3. Plotten des Datenbereichs
        figure;
        plot(windowX, windowData);
        xlabel('Index');
        ylabel('Wert');
        title('Ausschnitt von ' + string(startIndex) + ' bis ' + string(endPoint) + ' DP');
    end
end

% DOWNNAMPLING_____________________________________________________________
if downsamplingRegular
    % 2. Downsampling
    downsampleFactor1 = 1000;
    downsampleFactor2 = 10000;
    
    % Downsampling auf die gesamten Daten anwenden
    dataToDownsample = data;
    xToDownsample = 1:length(data);
    
    % Downsampling durchführen
    dataDown1 = dataToDownsample(1:downsampleFactor1:end);
    dataDown2 = dataToDownsample(1:downsampleFactor2:end);
    
    % 3. Diagramme erstellen
    figure;
    
    % Originaldaten (gesamtes Signal oder Fenster, je nach Bedingung)
    subplot(3, 1, 1);
    plot(xToDownsample, dataToDownsample);
    title('Daten');
    xlabel('Index');
    ylabel('Wert');
    
    % Um Faktor 1000 gedownsamplte Daten
    subplot(3, 1, 2);
    plot(1:downsampleFactor1:length(dataToDownsample), dataDown1);
    title(['Downsampling um Faktor ', num2str(downsampleFactor1)]);
    xlabel('Index');
    ylabel('Wert');
    
    % Um Faktor 10000 gedownsamplte Daten
    subplot(3, 1, 3);
    plot(1:downsampleFactor2:length(dataToDownsample), dataDown2);
    title(['Downsampling um Faktor ', num2str(downsampleFactor2)]);
    xlabel('Index');
    ylabel('Wert');
end

% DOWNNAMPLING_____________________________________________________________
if downsamplingOnWindow
    % 2. Downsampling
    downsampleFactor1 = 1000;
    downsampleFactor2 = 10000;
   
    % Downsampling auf den gewählten Bereich anwenden
    dataToDownsample = windowData;
    xToDownsample = windowX;
    
    % Downsampling durchführen
    dataDown1 = dataToDownsample(startIndex:downsampleFactor1:endIndex);
    dataDown2 = dataToDownsample(startIndex:downsampleFactor2:endIndex);
    
    % 3. Diagramme erstellen
    figure;
    
    % Originaldaten (gesamtes Signal oder Fenster, je nach Bedingung)
    subplot(3, 1, 1);
    plot(xToDownsample, dataToDownsample);
    title('Daten');
    xlabel('Index');
    ylabel('Wert');
    
    % Um Faktor 1000 gedownsamplte Daten
    subplot(3, 1, 2);
    plot(1:downsampleFactor1:length(dataToDownsample), dataDown1);
    title(['Downsampling um Faktor ', num2str(downsampleFactor1)]);
    xlabel('Index');
    ylabel('Wert');
    
    % Um Faktor 10000 gedownsamplte Daten
    subplot(3, 1, 3);
    plot(1:downsampleFactor2:length(dataToDownsample), dataDown2);
    title(['Downsampling um Faktor ', num2str(downsampleFactor2)]);
    xlabel('Index');
    ylabel('Wert');
end

% Speichern der Daten
save('processedData.mat', 'data', 'normalizedDataAll', 'zScoreDataAll', 'dataDown1', 'dataDown2');

signalAnalyzer