function datos_circuito = caso10n11p5i()
% CASO10N11P - caso de prueba con 10 nodos, 11 puertas y 5 interruptores.
%
%    Por favor ingrese help formato_caso para comprender la sintaxis
%
%    Este es el circuito que aparece en la pagina 57 del capitulo 3 de las
%    notas del curso elaboradas por el Prof. Wilson Gonzalez Vanegas, 
%    disponibles en: https://drive.google.com/file/d/1mn4iMvGPnuir--qICwpV5h9zqc5dq5EC/view    

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

%% Definicion de indicadores

[R,L,C,LM,VI,II,VD,ID,CTE,SIN,COS,EXP,INTS,INTC] = id_col_caso;  % Definir indicadores para el ingreso de informacion

%% Definicion de nodos del circuito

%                        id_nodo    tipo_nodo
datos_circuito.nodos = [    1           0
                            2           0
                            3           0
                            4           0
                            5           0
                            6           0
                            7           0
                            8           0
                            9           0
                            10          0
                        ];


datos_circuito.nombre_nodos = {'N1'
                               'N2'
                               'N3'
                               'N4'
                               'N5'
                               'N6'
                               'N7'
                               'N8'
                               'N9'
                               'N10'
                              };

%% Definicion de puertas del circuito y conexiones de red

%                         id_puerta  nodo_envio  nodo_recibo  naturaleza   val_parametro   tipo_elemento   
datos_circuito.puertas = [     1           3          7            R             3000             1
                               2           3          7            L             1                2
                               3           10         7            C             0.5e-6           1
                               4           8          7            LM            2                2
                               5           5          6            II            SIN              2
                               6           5          8            R             2000             1
                               7           6          7            C             1e-6             2
                               8           1          4            LM            1                2
                               9           4          5            VI            CTE              1
                               10          1          9            R             1000             1
                               11          1          2            C             1e-6             2
                          ];

datos_circuito.nombre_puertas = {'R2'
                                 'L'
                                 'C3'
                                 '■  L2'
                                 'i(t)'
                                 'R3'
                                 'C2'
                                 '■  L1'
                                 'V'
                                 'R1'
                                 'C1' 
                                 };

%% Definicion de interruptores

%                               id_inter   tipo_inter     nodos      estado
datos_circuito.interruptores = {    1         INTS        [5 7]         1
                                    2         INTC        [6 2 3]       0
                                    3         INTS        [2 5]         0
                                    4         INTS        [5 9]         1
                                    5         INTS        [1 10]        0 
                               };

%% Definicion de fuentes independientes

%                               id_puerta   parametros_fuente                                       
datos_circuito.fuentes_ind = {      5      [4e-3 1000 53.13 0]     % 4 Sin(1000t + 53.13) mA
                                    9              12              % 12 V
                             };
                              
%% Definicion de fuentes dependientes

datos_circuito.fuentes_dep = [];     % No se tienen fuentes dependientes

%% Definicion de marcas de polaridad en inductores mutuamente acoplados

%                             id_marca  id_puerta_L1  nodo_marcado_L1  id_puerta_L2  nodo_marcado_L2  Acople
datos_circuito.marcas_pol = [     1          4              8               8             4             1    ];