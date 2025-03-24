function instalar_haceos
% INSTALAR_HACEOS es una rutina sencilla para adicionar todo los archivos
% de HACEOS al path de MATLAB.

%   HACEOS - Herramienta para el Analisis de Circuitos Electricos de Orden Superior
%   Copyright (c) 2025, Grupo de Investigacion en Campos Electromagneticos y Fenomenos Energeticos - CAFE
%				        Universidad Tecnologica de Pereira (UTP)
%  	Por: Brandon Ospina y Brian Gordon, CAFE-UTP
%   y Wilson Gonzalez Vanegas, Universidad Nacional de Colombia Sede Manizales y CAFE-UTP
%
%   Este archivo es parte del proyecto HACEOS.
%   Cubierto por la licencia 3-clause BSD (mas detalles en el archivo LICENSE).
%   Vea https://github.com/HACEOS/ para mayor informacion.
% 	
%   Nota: este archivo es libre de tildes para evitar posibles conflictos en sistemas sin codificacion UTF-8

%% Add current MPNG directory the the MATLAB path

fprintf('\n ----------- Rutina de instalacion de HACEOS ----------- \n\n')

base_dir = pwd(); 
file_sep = filesep();
addpath(pwd);

%% Adicionar carpetas internas y scripts de HACEOS

folders = {'lib',...
           'casos'           
            };
for i = 1:length(folders)
    folder = folders{i};
    directory = [base_dir , file_sep, folder];
    fprintf('Adicionando directorio al path: %s\n', directory);
    addpath(genpath(directory));
end

fprintf('\n ¡HACEOS se ha instalado correctamente! \n')

clear base_dir file_sep folder folders i directory 