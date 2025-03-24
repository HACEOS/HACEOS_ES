function [ID_INT,TIPO_INT,N_INT,ESTADO] = id_col_interruptores
%	id_col_puertas - Define constantes para acceder a las columnas de la matriz de 
%	informacion de los interruptores de un caso de HACEOS.
%
% 	El indice, nombre y significado de cada columna en la matriz de interruptores  es:
%	
%   1	ID_INT       numero identificador del interruptor
%	2	TIPO_INT     interruptor de tipo sencillo o compuesto
%	3	N_INT        nodos donde esta contenido el interruptor
%	4   ESTADO       > 1 = cerrado   > 2 = abierto

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

% Indicadores de columna de los interruptores

ID_INT   = 1;
TIPO_INT = 2;
N_INT    = 3;
ESTADO   = 4;
