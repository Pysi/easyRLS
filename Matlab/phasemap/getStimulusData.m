function [time, motor] = getStimulusData(filename)

delimiter = '\t';
formatSpec = '%*q%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec,...
    'Delimiter', delimiter,...
    'TextType', 'string',...
    'EmptyValue', NaN,...
    'ReturnOnError', false);
fclose(fileID);
time = dataArray{:, 1};
motor = dataArray{:, 2};

end