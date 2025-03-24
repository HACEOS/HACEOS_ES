function resultados = haceos(caso, opciones)
% HACEOS - Funcion principal para analizar un circuito electrico de orden 
% superior empleando variables simbolicas en el dominio del tiempo.
% ::
%   ----------------------------------------------------------------
%   Nota: esta documentacion no contiene tildes para evitar posibles 
%         conflictos en sistemas sin codificacion UTF-8
%   ----------------------------------------------------------------
%
%               resultados = HACEOS(caso) 
%               resultados = HACEOS(caso, opciones) 
% 
% ejecuta un analisis de un CASO para determinar voltajes y/o corrientes en 
% elementos de circuito y retorna una estructura de RESULTADOS. La entrada
% CASO corresponde a una estructura que refleja un CASO de HACEOS, mientras 
% la entrada (opcional) OPCIONES es una estructura con todas las
% configuraciones disponibles en la herramienta.
%
% See also formato_caso, hcs_opciones

%   HACEOS - Herramienta para el Analisis de Circuitos Electricos de Orden Superior
%   Copyright (c) 2025, Grupo de Investigacion en Campos Electromagneticos y Fenomenos Energeticos - CAFE
%						Universidad Tecnologica de Pereira (UTP)
%  	Por: Wilson Gonzalez Vanegas, CAFE-UTP y Universidad Nacional de Colombia Sede Manizales
%   y Brandon Ospina y Brian Gordon, CAFE-UTP
%
%   Este archivo es parte del proyecto HACEOS.
%   Cubierto por la licencia 3-clause BSD (mas detalles en el archivo LICENSE).
%   Vea https://github.com/HACEOS/ para mayor informacion.
% 	
%   Nota: este archivo es libre de tildes para evitar posibles conflictos en sistemas sin codificacion UTF-8

    %% Revisar datos de entrada
    hcs_caso = caso;
    if ~isstruct(hcs_caso)
        error('haceos: la entrada ''caso'' debe ser una estructura')
    end

    if nargin < 2
        opciones = hcs_opciones;
    end
    
    %% Construir modelo de red
    mr = hcs.modelo_red();
    
    %% Construir modelo de datos de acuerdo con los estados a analizar
    estados = opciones.estado_de_analisis; 
    switch estados
        case {'estacionario'}
            md = md_estacionario();
            metodos_extraccion_md = {@md.extraer_info_estacionario};
            metodos_inicializacion_md = {@md.inicializar_estacionario};
        case {'conmutacion'}
            md = md_conmutacion();
            metodos_extraccion_md = {@md.extraer_info_conmutacion};
            metodos_inicializacion_md = {@md.inicializar_conmutacion};
        case {'transitorio'}
            md = md_trasitorio();
            metodos_extraccion_md = {@md.extraer_info_transitorio};
            metodos_inicializacion_md = {@md.inicializar_transitorio};
        case {'estionario_conmutacion', 'conmutacion_estacionario'}
            md = md_estacionario_conmutacion();
            metodos_extraccion_md = {@md.extraer_estacionario
                                     @md.extraer_conmutacion};
            metodos_inicializacion_md = {@md.inicializar_estacionario
                                         @md.inicializar_conmutacion};
        case {'conmutacion_transitorio', 'transitorio_conmutacion'}
            md = md_conmutacion_transitorio();
            metodos_extraccion_md = {@md.extraer_conmutacion
                                     @md.extraer_transitorio};
            metodos_inicializacion_md = {@md.inicializar_conmutacion
                                         @md.inicializar_transitorio};
        otherwise
            md = md_completo();
            metodos_extraccion_md = {@md.extraer_estacionario
                                     @md.extraer_conmutacion
                                     @md.extraer_transitorio};
            metodos_inicializacion_md = {@md.inicializar_estacionario
                                         @md.inicializar_conmutacion
                                         @md.inicializar_transitorio};
    end
    
    cellfun(@(x) x(hcs_caso, mr), metodos_extraccion_md,'UniformOutput',false);  % ejecutar cada metodo de extraccion
    cellfun(@(x) x(),metodos_inicializacion_md,'UniformOutput',false);           % ejecutar cada metodo de inicializacion
    md.construir();                                                              % crear objetos para cada puerta del circuito
    md.importar(md.circuito_cero_menos);                                         % importar información a cada puerta del circuito de cero menos
    
    md.crear_estadisticas_caso(hcs_caso);
    
    %% Construir gráficas según requerimientos
    if opciones.dibujar_graficos
        mr.dibujar_graficos(md, estados, opciones);
    end
    
    %% Crear estructura de resultados
    resultados = struct('md', md, ...
                        'mr', mr);
end