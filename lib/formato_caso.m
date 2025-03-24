% formato_caso  - Define el formato de datos para un caso de HACEOS
% ::
%   ----------------------------------------------------------------
%   Nota: esta documentacion no contiene tildes para evitar posibles 
%         conflictos en sistemas sin codificacion UTF-8
%   ----------------------------------------------------------------
%
%   Un caso de HACEOS es un script de MATLAB con extension .m o un archivo
%   de datos de MATLAB con extension .mat que define una variable de tipo
%   estructura (struct) con los siguientes campos obligatorios: nodos, 
%   puertas, interruptores, fuentes_ind, fuentes_dep, marcas_pol; y 
%   los siguientes campos opcionales: nombre_nodos, nombre_puertas. 
%   Algunos de estos campos son matrices y otros son celdas como se indica
%   a continuacion:
%
%               Campo                Tipo de dato
%               -----               ---------------
%               nodos               matriz (double)
%           nombre_nodos*            celda (cell)
%              puertas              matriz (double)
%          nombre_puertas*           celda (cell)       
%           interruptores            celda (cell)
%            fuentes_ind             celda (cell)
%            fuentes_dep            matriz (double)
%            marcal_pol             matriz (double)
%           ----------------------------------------
%           * campo opcional en forma de celda de cadenas de caracteres
%
%   El formato para cada uno de estos campos se describe a continuacion:
%
%   Formato de datos para el campo 'nodos':
%      1	ID_NODO      identificador unico del nodo (entero positivo)	
%	   2	TIPO_NODO    tipo de nodo. 0: nodo simple, 1: nodo de referencia
%
%   Formato de datos para el campo 'puertas' (ver notas 1 a 4):
%      1	ID_P         idenfificador unico de la puerta (entero positivo)	
%	   2	N_ENV        nodo de envio de la puerta
%	   3    N_REC        nodo de recibo de la puerta
%	   4    NAT_P        naturaleza de la puerta
%	   5    VAL_P        valor asociado a la puerta
%	   6    TIPO_P       tipo de puerta. 1: rama, 2: enlace
%
%   Formato de datos para el campo 'interruptores' (ver notas 7 a 9):
%      1	ID_INT       identificador unico del interruptor (entero positivo)
%	   2	TIPO_INT     tipo de interruptor segun sea sencillo o compuesto
%	   3	N_INT        nodos donde esta contenido el interruptor
%	   4    ESTADO       estado del interruptor segun sea abierto o cerrado
%
%   Formato de datos para el campo 'fuentes_ind' (ver nota 3):
%	   1    ID_FTE_IND      identificador de la puerta
%	   2    PAR_FTE_IND     parametros de la fuente
%
%   Formato de datos para el campo 'fuentes_dep' (ver notas 5, 6 y 9):
%      1    ID_FTE_DEP      identificador de la puerta
%      2    TIPO_FTE_DEP    tipo de fuente segun sea de voltage o corriente
%      3    ID_DEPEN        identificador de la puerta de dependencia
%      4    TIPO_DEPEN      tipo de dependencia
%      5    PARAMETRO       constante de dependencia lineal
%
%   Formato de datos para el campo 'marcas_pol' (ver notas 2, 4 y 9):
%      1	ID_MARCA        identificador unico de la marca
%	   2	ID_L1           identficador de la puerta de la primera inductancia
%	   3	N_MARCADO_L1    nodo marcado de la primera inductancia
%	   4    ID_L2           identificador de la puerta de la segunda inductancia 
%	   5    N_MARCADO_L2    nodo marcado de la segunda inductancia
%	   6    VAL_ACOPLE      valor de inductancia mutua
%       
%   Para facilitar el ingreso y la manipulacion de datos, HACEOS emplea
%   algunas constantes disponibles en la funcion id_col_caso, asi:
%   
%       Para definir la columna naturaleza (NAT_P) en el campo puerta 
%       se usan letras en mayuscula con los siguientes significados:
% 
%                    R: resistencia                          
%                    C: capacitancia                        
%                    L: inductancia
%                    LM: inductancia mutuamente acoplada
%                    VI: fuente independiente de voltaje
%                    II: fuente independiente de corriente
%                    VD: fuente dependiente de voltaje
%                    ID: fuente dependiente de corriente
%       
%       Para definir la columna de valor del parametro (VAL_P) en el campo 
%       'puerta', para el caso de fuentes independientes, se usan letras en 
%       mayuscula con los siguientes significados:      
%                   
%                   CTE: fuente de valor constante
%                   SIN: fuente de tipo seno
%                   COS: fuente de tipo coseno
%                   EXP: fuente de tipo exponencial
%       
%       Para definir la columna de tipo de interruptor (TIPO_INT) en el campo 
%       'interruptores' se usan letras en mayuscula con los siguientes significados:   
%
%                   INTS: interruptor sencillo
%                   INTC: interruptor compuesto
%
%   Algunas notas adicionales a tener en cuenta:
%
%   1) Los valores de resistencia, capacitancia e inductancia en la columna 
%      VAL_P del campo 'puertas' se deben ingresar en Ohmios, Faradios y
%      Henrios, respectivamente.
%   2) Los valores de inductancia mutua en la columna VAL_ACOPLE del campo 
%      'marcas_pol' se deben ingresar en Henrios.
%   3) Los valores para los parametros de las fuentes independientes en la
%      columna PAR_FTE_IND del campo 'fuentes_ind' dependen del valor
%      ingresado en la columna VAL_P del campo 'puertas', asi:
%
%           SIN/COS:    A*Sin/Cos(W*t+DEG) + OFFSET
%            EXP:            A*e^(C*t) + K
%            CTE:                   X                   
%
%           VAL_P             PAR_FTE_INDP [tipo]            Unidades
%           -----         ----------------------         --------------
%          SIN/COS        [A,W,DEG,OFFSET] [vector]
%                         Amplitud (A)                  Amperios o Voltios
%                         Frecuencia angular (W)         radianes/segundo
%                         Desfase (DEG)                      grados
%                         Nivel DC (OFFSET)             Amperios o Voltios
%
%            EXP          [B,C,K] [vector]               
%                         Amplitud (B)                  Amperios o Voltios
%                         Exponente (C)                    segundos^(-1)   
%                         Nivel DC (K)                  Amperios o Voltios
%
%            CTE          X [escalar]                   Amperios o Voltios
%           
%   4) Los valores de inductancia mutua en la columna TIPO_P del campo 
%      'puertas' pueden ser: 1 para rama o 2 para enlace.
%   5) Los valores para el tipo de fuente en la columna TIPO_FTE_DEP del
%      campo 'fuentes_dep' pueden ser: 1 para fuente de voltaje y 2 para 
%      fuente de corriente.
%   6) Los valores para el tipo de dependencia en la columna TIPO_DEPEN del
%      campo 'fuentes_dep' pueden ser: 1 para fuente que depende de un voltaje 
%      y 2 para fuente que depende de una corriente.
%   7) Para definir los nodos de un interruptor en la columna N_INT del campo
%      'interruptores' se debe tener en cuenta el tipo de interruptor. Si
%      el interruptor es sencillo (se uso INTS en la columna TIPO_INT), se
%      debe ingresar en N_INT un vector de dos elementos indicando los
%      identificadres de los nodos donde va conectado el interuptor sencillo.
%      Si el interruptor es compuesto (se uso INTC en la columna TIPO_INT),
%      se debe ingresar en N_INT un vector de tres elementos de la forma
%      [PIV, A, B] donde PIV, A y B son identificadores de nodos que se 
%      eligen siguiendo el siguiente esquema:
%
%                                A         B
%                                 ^
%                                  \     
%                       ----->>     \   
%               giro:  '             \         (interruptor cerrado)
%                      '              o    
%                       \ __ /        |    
%                                     |
%                                     |
%                                    PIV
%       
%        Regla: Estando en el puerto pivote (PIV), es decir, aquel 
%               respecto al cual el interruptor compuesto conmuta, 
%               se barren los demas puertos en el sentido de las 
%               manecillas del reloj; el primer puerto encontrado
%               sera el nodo A y el segundo puerto hallado sera el B.
%   
%   8) Para definir el estado de un interruptor en la columna ESTADO del campo
%      'interruptores' se debe tener en cuenta el tipo de interrupor. Se usa
%      1 para indicar interruptor cerrado y 0 para interruptor abierto. Si
%      el interruptor es compuesto (se uso INTC en la columna TIPO_INT), se
%      toma la conexion entre el nodo pivote (PIV) y el nodo A como refencia
%      para interpretar cerrado o abierto.
%   9) Si un circuito no posee elementos asociados a algunos de lo campos del 
%      formato de entrada, entonces dicho campo se deja vacío teniendo en
%      cuenta el tipo de dato del campo respectivo. Por ejemplo, si un circuito 
%      no posee fuentes dependientes ni interruptores, entonces se ingresan
%      estos campos en el caso así:
%               
%                   datos_circuito.fuentes_dep = [];
%                   datos_circuito.interruptores = {};
%
% See also: id_col_caso, id_col_nodos, id_col_puertas,id_col_interruptores, id_col_marcas

 
%   HACEOS - Herramienta para el Analisis de Circuitos Electricos de Orden Superior
%   Copyright (c) 2025, Grupo de Investigacion en Campos Electromagneticos y Fenomenos Energeticos - CAFE
%						Universidad Tecnologica de Pereira (UTP)
%  	Por: Wilson Gonzalez Vanegas, CAFE-UTP y Universidad Nacional de Colombia Sede Manizales
%   y Brandon Ospina y Brian Gordon, CAFE-UTP
%
%   Este archivo es parte del proyecto HACEOS.
%   Cubierto por la licencia 3-clause BSD (mas detalles en el archivo LICENSE).
%   Vea https://github.com/HACEOS/ para mayor informacion.