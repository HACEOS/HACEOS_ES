function [ID_MARCA,ID_L1,N_MARCADO_L1,ID_L2,N_MARCADO_L2,VAL_ACOPLE] = id_col_marcas
%	id_col_puertas - Define constantes para acceder a las columnas de la matriz de 
%	informacion de las marcas de polaridad de un caso de HACEOS.
%
% 	El indice, nombre y significado de cada columna en la matriz de marcas es:
%	
%   1	ID_MARCA        identificador unico de la marca
%	2	ID_L1           identificador unico de la inductancia uno
%	3	N_MARCADO_L1    nodo marcado de la inductancia uno
%	4   ID_L2           identificador unico de la inductancia dos 
%	5   N_MARCADO_L2    nodo marcado de la inductancia dos
%	6   VAL_ACOPLE      valor de inductancia mutua

% See also: id_col_caso, id_col_interruptores, id_col_marcas, id_col_nodos,
% id_col_puertas

%   HACEOS - Herramienta para el Analisis de Circuitos Electricos de Orden Superior
%   Copyright (c) 2025, Grupo de Investigacion en Campos Electromagneticos y Fenomenos Energeticos - CAFE
%					    Universidad Tecnologica de Pereira (UTP)
%  	Por: Brandon Ospina y Brian Gordon, CAFE-UTP
%   y Wilson Gonzalez Vanegas, CAFE-UTP y Universidad Nacional de Colombia Sede Manizales
%
%   Este archivo es parte del proyecto HACEOS.
%   Cubierto por la licencia 3-clause BSD (mas detalles en el archivo LICENSE).
%   Vea https://github.com/HACEOS/ para mayor informacion.
% 	
%   Nota: este archivo es libre de tildes para evitar posibles conflictos en sistemas sin codificacion UTF-8

% Indicadores de columna de las marcas de polaridad
ID_MARCA     = 1;
ID_L1        = 2;
N_MARCADO_L1 = 3;
ID_L2        = 4;
N_MARCADO_L2 = 5;
VAL_ACOPLE   = 6;