% 	Find four weather stations outside Des Moines and generate a
% 	statistical model that estimates the weather in Des Moines given the
% 	forecast at the other four weather stations. There are several APIs that
% 	provide current weather conditions like
% 	http://www.wunderground.com/weather/api/d/docs?d=data/conditions (the
% 	output is estimated weather for Des Moines as a txt or html file). You may
% 	have to look in a wide radius outside of the area to find four stations.

%% Section 1
% To close all the open figures and to clean the workspace and cmd line

clear; clc; close all;

%% Section 2
% This section deals with getting the data from the API where the data from
% 4 cities near Des Moines were collected and stored as a data structure

api = 'http://api.wunderground.com/api/85c1ffa457698e4d/forecast10day/q/IA/Iowa_City.json';
iowa_city = webread(api);

api = 'http://api.wunderground.com/api/85c1ffa457698e4d/forecast10day/q/IA/Fort_Dodge.json';
fort_dodge = webread(api);

api = 'http://api.wunderground.com/api/85c1ffa457698e4d/forecast10day/q/MO/Kansas_City.json';
kansas_city = webread(api);

api = 'http://api.wunderground.com/api/85c1ffa457698e4d/forecast10day/q/NE/Omaha.json';
omaha = webread(api);

api = 'http://api.wunderground.com/api/85c1ffa457698e4d/forecast10day/q/IA/Des_Moines.json';
des_moines = webread(api);

%% Section 3
% Initialization of the variables used further in the program

ic_weather_high = zeros(1,10);
fd_weather_high = zeros(1,10);
kc_weather_high = zeros(1,10);
om_weather_high = zeros(1,10);
dm_weather_high = zeros(1,10);

ic_weather_low = zeros(1,10);
fd_weather_low = zeros(1,10);
kc_weather_low = zeros(1,10);
om_weather_low = zeros(1,10);
dm_weather_low = zeros(1,10);

%% Section 4
% Average weather of the 4 cities were calculated using the data collected
% from the API to predict the weather in Des Moines. 
% The average weatger for Des Moines is also calculated to compare the
% predicted data with the actual data.

for i = 1:10
    ic_weather_high(i) = str2num(iowa_city.forecast.simpleforecast.forecastday(i).high.celsius);
    fd_weather_high(i) = str2num(fort_dodge.forecast.simpleforecast.forecastday(i).high.celsius);
    kc_weather_high(i) = str2num(kansas_city.forecast.simpleforecast.forecastday(i).high.celsius);
    om_weather_high(i) = str2num(omaha.forecast.simpleforecast.forecastday(i).high.celsius);
    dm_weather_high(i) = str2num(des_moines.forecast.simpleforecast.forecastday(i).high.celsius);


    ic_weather_low(i) = str2num(iowa_city.forecast.simpleforecast.forecastday(i).low.celsius);
    fd_weather_low(i) = str2num(fort_dodge.forecast.simpleforecast.forecastday(i).low.celsius);
    kc_weather_low(i) = str2num(kansas_city.forecast.simpleforecast.forecastday(i).low.celsius);
    om_weather_low(i) = str2num(omaha.forecast.simpleforecast.forecastday(i).low.celsius);
    dm_weather_low(i) = str2num(des_moines.forecast.simpleforecast.forecastday(i).low.celsius);
end

ic_avg_weather = (ic_weather_high + ic_weather_low)./2;
fd_avg_weather = (fd_weather_high + fd_weather_low)./2;
kc_avg_weather = (kc_weather_high + kc_weather_low)./2;
om_avg_weather = (om_weather_high + om_weather_low)./2;
dm_avg_weather = (dm_weather_high + dm_weather_low)./2;

%% Section 5
% Weighted Average approach to predict the weather in Des Moines. It was
% based on a relationship that the farthest city would have less
% accountability in predicting the weather as compared to the closest city.

dm_to_om = 139.3;
dm_to_fd = 95;
dm_to_kc = 193.8;
dm_to_ic = 113.7;

kc_to_fd_ratio = dm_to_kc/dm_to_fd;
om_to_fd_ratio = dm_to_om/dm_to_fd;
ic_to_fd_ratio = dm_to_ic/dm_to_fd;

w_fd = kc_to_fd_ratio*om_to_fd_ratio*ic_to_fd_ratio / ...
    (kc_to_fd_ratio*om_to_fd_ratio*ic_to_fd_ratio + ...
    kc_to_fd_ratio*om_to_fd_ratio + kc_to_fd_ratio*ic_to_fd_ratio + ...
    ic_to_fd_ratio*om_to_fd_ratio);

w_kc = w_fd / kc_to_fd_ratio;
w_ic = w_fd / ic_to_fd_ratio;
w_om = w_fd / om_to_fd_ratio;

dm_weighted_prediction = w_fd*fd_avg_weather + w_ic*ic_avg_weather+...
w_kc*kc_avg_weather + w_om*om_avg_weather;

%% Section 6
% A more simple approach to forecast the weather in Des Moines using the 
% averaging approach. Assisgning same weight to each city automatically 
% calculates the average weather in Des Moines for a particular day.

dm_predicted = 0.25*fd_avg_weather + 0.25*ic_avg_weather+...
0.25*kc_avg_weather + 0.25*om_avg_weather;

%% Section 7
% Plotting the weather data from the 4 cities along with the comparison of 
% 2 models developed for predicting the weather in Des Moines with the
% actual average weather in Des Moines.

figure(1); 
plot(ic_avg_weather,'r--'); hold on; axis([1 10 min([ic_avg_weather,...
fd_avg_weather,kc_avg_weather, om_avg_weather])-1 max([ic_avg_weather,...
fd_avg_weather,kc_avg_weather, om_avg_weather])+1]);plot(fd_avg_weather,'b-');...
plot(kc_avg_weather,'g--');plot(om_avg_weather,'m-');
legend('Iowa City','Fort Dodge','Kansas City','Omaha');
xlabel('Days --->'); ylabel('Average Temperature in degree C');
title('10 Day Forecast of cities nearby Des Moines');

figure(2);plot(dm_avg_weather,'c-');hold on; axis([1 10 min([dm_avg_weather,...
    dm_predicted])-1 max([dm_avg_weather,dm_predicted])+1]);...
    plot(dm_predicted,'p-');
legend('Des Moines Actual Weather Forecast','Des Moines Predicted Weather forecast');
xlabel('Days --->'); ylabel('Average Temperature in degree C'); 
title('Actual vs Predicted Weather Forecast');

figure(3);plot(dm_avg_weather,'c-');hold on; axis([1 10 min([dm_avg_weather,...
    dm_weighted_prediction])-1 max([dm_avg_weather,dm_weighted_prediction])+1]);...
    plot(dm_weighted_prediction,'p-');
legend('Des Moines Actual Weather Forecast', 'Des Moines Weighted Predicted Weather forecast');
xlabel('Days --->'); ylabel('Average Temperature in degree C'); 
title('Actual vs Weighted Predicted Weather Forecast');


%% Section 8
% Writing the data to the text file. The file contains the actual average
% data collected from the API along with the predicted data calculated
% using the averaging appraoch. The text file 'weather_dm.txt' is created
% in the same folder as this file.

i = 1:10;
temp = [i ; dm_predicted; dm_avg_weather];
fileID = fopen('weather_dm.txt','w');
fprintf(fileID, 'Weather Prediction for Des Moines:\r\n\r\n');
formatSpec = '\r\nThe predicted average temperature on day%3d is %3.3f degree Celsius and the average weather is %3.3f degree Celsius. \r\n\r\n';
fprintf(fileID,formatSpec,temp);
fclose(fileID);

