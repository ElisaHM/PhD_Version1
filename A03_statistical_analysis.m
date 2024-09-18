clear;
clc;

loadedData = load('read_timeSeriesData.mat', 'timeSeriesDataArray');
timeSeriesDataArray = loadedData.timeSeriesDataArray;

%%Statistische Berechnungen
for idx = 1:length(timeSeriesDataArray)
    timeSeriesData = timeSeriesDataArray(idx).Data;
    disp(['Statistical analysis of: ', timeSeriesDataArray(idx).FileName]);

    % Berechnungen
    meanValue = mean(timeSeriesData);
    rmsValue = rms(timeSeriesData);
    stdDev = std(timeSeriesData);
    variance = var(timeSeriesData);
    peakToPeakValue = peak2peak(timeSeriesData);
    kurtosisValue = kurtosis(timeSeriesData);
    skewnessValue = skewness(timeSeriesData);
    shapeFactor = mean(abs(timeSeriesData)) / rmsValue;
    clearanceFactor = max(abs(timeSeriesData)) / rmsValue;
    crestFactor = max(abs(timeSeriesData)) / rmsValue;
    
    % Ausgabe der Ergebnisse
    fprintf('  Mean: %.4f\n', meanValue);
    fprintf('  RMS: %.4f\n', rmsValue);
    fprintf('  Standard Deviation: %.4f\n', stdDev);
    fprintf('  Variance: %.4f\n', variance);
    fprintf('  Peak to Peak Value: %.4f\n', peakToPeakValue);
    fprintf('  Kurtosis: %.4f\n', kurtosisValue);
    fprintf('  Skewness: %.4f\n', skewnessValue);
    fprintf('  Shape Factor: %.4f\n', shapeFactor);
    fprintf('  Clearance Factor: %.4f\n', clearanceFactor);
    fprintf('  Crest Factor: %.4f\n\n', crestFactor);
end

