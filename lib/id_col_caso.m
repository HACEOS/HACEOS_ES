function [R,L,C,LM,VI,II,VD,ID,CTE,SIN,COS,EXP,INTS,INTC] = id_col_caso
%	id_col_puertas - Define constantes para acceder a las columnas de la matriz de 
%	informacion de las puertas de un caso de HACEOS.
%
% 	El indice, nombre y significado de cada columna en la matriz de puertas es:
%	
%   1	R       % objeto de tipo resistencia       
%	2	L       % objeto de tipo inductancia
%	3	C       % objeto de tipo capacitancia
%	4   LM      % objeto de tipo inductancia mutuamente acoplada
%	5   VI      % objeto de tipo fuente independiente de voltaje
%	6   II      % objeto de tipo fuente independiente de corriente
%	7   VD      % objeto de tipo fuente dependiente de voltaje
%	8   ID      % objeto de tipo fuente dependiente de corriente
%  -1   CTE     % fuente de tipo constante
%  -2   SIN     % fuente de tipo alterna
%  -3   COS     % fuente de tipo alterna
%  -4   EXP     % fuente de tipo exponencial
%   1   INTS    % interruptor sencillo
%   2   INTC    % interruptor compuesto
%
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

% Indicadores para la naturaleza de la puerta
R = 1; 
L = 2;
C = 3;
LM = 4;
VI = 5;
II = 6;
VD = 7;
ID = 8;

% Indicadores para el tipo de señal de las fuentes independientes
CTE = -1;
SIN = -2;
COS = -3;
EXP = -4;    

% Indicadores para el tipo de interruptor
INTS = 1;
INTC = 2;
end