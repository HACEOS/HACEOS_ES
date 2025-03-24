function [ID_P,N_ENV,N_REC,NAT_P,VAL_P,TIPO_P,ID_FTE_IND,PAR_FTE_IND,ID_FTE_DEP,TIPO_FTE_DEP,ID_DEPEN,TIPO_DEPEN,PARAMETRO] = id_col_puertas
%	id_col_puertas - Define constantes para acceder a las columnas de la matriz de 
%	informacion de las puertas de un caso de HACEOS.
%
% 	El indice, nombre y significado de cada columna en la matriz de puertas es:
%	
%   1	ID_P            numero de la puerta (un entero positivo)	
%	2	N_ENV           nodo de envio de la puerta (numero positivo)
%	3	N_REC           nodo de recibo de la puerta (numero positivo)
%	4   NAT_P           naturaleza de la puerta (RLC,LM,VI,II,VD,ID)
%	5   VAL_P           valor de la puerta (10 A, 1 H, 10 Ohm)
%	6   TIPO_P          tipo de puerta (rama, enlace)
%	1   ID_FTE_IND      numero asociado a la puerta
%	2   PAR_FTE_IND     Parametros de la fuente
%   1   ID_FTE_DEP      identificador unico de la fuente dependiente
%   2   TIPO_FTE_DEP    tipo de fuente (Fuente de coriente/tension)
%   3   ID_DEPEN        identificador unico de la puerta de dependencia
%   4   TIPO_DEPEN      tipo de dependencia (dependiente de corriente/tension)
%   5   PARAMETRO       parametro de la dependencia (mhos, alfa, mu, g)

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

% Indicadores para las columnas del campo 'puertas' de un caso de HACEOS
ID_P   = 1;                 
N_ENV  = 2;                
N_REC  = 3;                
NAT_P  = 4;                
VAL_P  = 5;                 
TIPO_P = 6;                

% Indicadores para las fuentes independientes

ID_FTE_IND =  1;            
PAR_FTE_IND = 2;           

% Indicadores para las fuentes dependientes

ID_FTE_DEP   = 1;        
TIPO_FTE_DEP = 2;            
ID_DEPEN     = 3;           
TIPO_DEPEN   = 4;           
PARAMETRO    = 5;           


