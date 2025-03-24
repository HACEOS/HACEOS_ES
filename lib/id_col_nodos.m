function [ID_NODO, TIPO_NODO] = id_col_nodos
%	id_col_puertas - Define constantes para acceder a las columnas del vector 
%	informacion de los nodos de un caso de HACEOS.
%
% 	El indice, nombre y significado de cada columna en el vector de nodos es:
%	
%   1	ID_NODO            identificador unico de ese nodo	
%	2	TIPO_NODO          > 1 = nodo de referencia > 0 = no referencia

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

ID_NODO = 1;
TIPO_NODO = 2;
end