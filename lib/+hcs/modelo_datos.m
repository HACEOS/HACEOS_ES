classdef modelo_datos < handle
% hcs.modelo_datos - Superclase para administrar el modelo de datos.
%
% Esta superclase se encarga de crear objetos de clase <interruptor> para 
% modelar interruptores sencillos y compuestos de un circuito dado.
% Asimismo, implementa las etapas principales de importacion y construccion
% de elementos de circuitos de diversas clases empleando los resultados de
% la etapa de inicializacion que se realiza en las subclases que heredan
% de hcs.modelo_datos.
%
% Propiedades de hcs.modelo_datos:
%	* clases - estructura con handles a puertas y marcas de polaridad
%   * elementos - estructura con objetos de cada puerta y marcas de polaridad
%   * id_elementos - vector de identificadores de elementos energizados
%   * interruptores - estructura con objetos de cada interruptor
%   * islas - estructura con subcasos clasificados por tipo de excitacion
%   * stats_caso - estructura con estadisticas generales de un caso    
%
% Metodos de hcs.modelo_datos:
%	* construir - construye el modelo de datos para el estado de analisis entregado
%   * importar - importa informacion del caso a los objetos de cada puerta y marca de polaridad
%   * crear_interruptores - crea los objetos de tipo interruptor
%   * crear_estadisticas_caso - calcula informacion general del caso

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

    properties
        clases
        elementos
        id_elementos
        interruptores
        islas
        stats_caso
    end

    methods
        function obj = modelo_datos()    % Constructor
            es1 = struct('puertas', [], ...
                         'marcas_pol', []);
            est_clases = struct('DC', es1, ...
                                  'SIN', es1, ...
                                  'EXP', es1, ...
                                  'NoFuente', es1, ...
                                  'Combinada', es1);
            %est_clases.SIN = struct('igual_W', es1, ...
            %                          'dif_W', es1);            
            es2 = struct('nodos', [], ...
                         'nombre_nodos', [], ...
                         'puertas', [], ...
                         'nombre_puertas', [], ...
                         'fuentes_ind', [], ...
                         'fuentes_dep', [], ...
                         'marcas_pol', []);
            est_islas = struct('DC', es2, ...
                               'SIN', es2, ...
                               'EXP', es2, ...
                               'NoFuente', es2, ...
                               'Combinada',es2);
            %est_islas.SIN = struct('igual_W', es1, ...
            %                       'dif_W', es1);
            obj.clases = struct('estacionario', est_clases, ...
                                'conmutacion', [], ...
                                'transitorio',[]);
            obj.islas = struct('estacionario', est_islas, ...
                               'conmutacion', [], ...
                               'transitorio',[]);
            obj.elementos = obj.clases;
            obj.id_elementos = [];            
            obj.stats_caso = struct('num_puertas', [], ...
                                    'num_nodos', [], ...
                                    'num_marcas', [], ...
                                    'num_fts_ind', []);
        end

        function obj = construir(obj)
            % Metodo para crear objetos con una llamada simple al constructor  
            % de cada clase asociada a cada elemento de circuito y marca de 
            % polaridad de un caso dado, de acuerdo con handles guardados en 
            % la propiedad obj.clases. 
            
            if ~isempty(obj.clases.estacionario)
                 isla = {'DC', 'SIN', 'EXP', 'NoFuente', 'Combinada'};
                for Y = 1:numel(isla)
                    if ~isempty(obj.islas.estacionario.(isla{Y}))
                        obj.islas.estacionario.(isla{Y}) = struct('puertas',[], ...
                                                                  'marcas_pol', []);
                        % Caso DC
                        if strcmp(isla{Y},'DC')
                            if ~isempty(obj.islas.estacionario.DC.puertas)
                                for x = 1:size(obj.islas.estacionario.DC,2)  % "x" recorre todas las capas de DC
                                    num_obj = numel(obj.clases.estacionario.DC(x).puertas);
                                    obj.elementos.estacionario.DC(x).puertas = cell(num_obj,1);
                                    for p = 1:num_obj
                                        obj.elementos.estacionario.DC(x).puertas{p} = obj.clases.estacionario.DC(x).puertas{p}();                                     
                                    end
                                    if ~isempty(obj.islas.estacionario.DC(x).marcas_pol)
                                        [num_marcas,~] = size(obj.islas.estacionario.DC(x).marcas_pol);
                                        for i=1:num_marcas
                                            obj.elementos.estacionario.DC(x).marcas_pol{i,1} = obj.clases.estacionario.DC(x).marcas_pol;
                                        end
                                    end 
                                end
                            end
                        end
                        
                        % Caso sinusoidal con igual o distinta frecuencia
                        if strcmp(isla{Y},'SIN')
                            %exc = {'igual_W' 'dif_W'};
                            % E recorre igual_w y dif_W
                            
                                if ~isempty(obj.islas.estacionario.(isla{Y}).puertas)
                                    % "x" recorre todas las capas de igual_W y dif_W
                                    for x = 1:size(obj.islas.estacionario.(isla{Y}),2)
                                        num_obj = numel(obj.clases.estacionario.(isla{Y})(x).puertas);
                                        obj.elementos.estacionario.(isla{Y})(x).puertas = cell(num_obj,1);
                                        for p = 1:num_obj
                                            obj.elementos.estacionario.(isla{Y})(x).puertas{p} = obj.clases.estacionario.(isla{Y})(x).puertas{p}();
                                        end
                                        if ~isempty(obj.islas.estacionario.(isla{Y})(x).marcas_pol)
                                            for i=1:size(obj.islas.estacionario.(isla{Y})(x).marcas_pol)
                                                obj.elementos.estacionario.(isla{Y})(x).marcas_pol{i,1} = obj.clases.estacionario.(isla{Y}).marcas_pol{i}();
                                            end
                                        end
                                    end
                                end
                        end
                        
                        % Caso EXP
                        % if strcmp(isla{Y},'EXP')
                        %     if ~isempty(obj.islas.estacionario.EXP.puertas)
                        %         for x = 1:size(obj.islas.estacionario.EXP,2)  % "x" recorre todas las capas de EXP
                        %             num_obj = numel(obj.clases.estacionario.EXP(x).puertas);
                        %             obj.elementos.estacionario.EXP(x).puertas = cell(num_obj,1);
                        %             for p = 1:num_obj
                        %                 obj.elementos.estacionario.EXP(x).puertas{p} = obj.clases.estacionario.EXP(x).puertas{p}();
                        %             end
                        %             if ~isempty(obj.islas.estacionario.EXP(x).marcas_pol)
                        %                 for i=1:size(obj.islas.estacionario.EXP(x).marcas_pol)
                        %                     obj.elementos.estacionario.EXP(x).marcas_pol{i,1} = obj.clases.estacionario.EXP(x).marcas_pol{i}();
                        %                 end
                        %             end
                        %         end
                        %     end
                        % end
                        
                        % Caso No_Fuente
                        if strcmp(isla{Y},'NoFuente')
                            if ~isempty(obj.islas.estacionario.NoFuente.puertas)
                                for x = 1:size(obj.islas.estacionario.NoFuente,2)  % "x" recorre todas las capas de No_fuente
                                    num_obj = numel(obj.clases.estacionario.NoFuente(x).puertas);
                                    obj.elementos.estacionario.NoFuente(x).puertas = cell(num_obj,1);
                                    for p = 1:num_obj
                                        obj.elementos.estacionario.NoFuente(x).puertas{p} = obj.clases.estacionario.NoFuente(x).puertas{p}();
                                    end
                                    if ~isempty(obj.islas.estacionario.NoFuente(x).marcas_pol)
                                        for i=1:size(obj.islas.estacionario.NoFuente(x).marcas_pol)
                                            obj.elementos.estacionario.NoFuente(x).marcas_pol{i,1} = obj.clases.estacionario.NoFuente(x).marcas_pol{i}();
                                        end
                                    end
                                end
                            end
                        end
                        % Caso Combinada
                        if strcmp(isla{Y},'Combinada')
                            if ~isempty(obj.islas.estacionario.Combinada.puertas)
                                for x = 1:size(obj.islas.estacionario.combinada,2)  % "x" recorre todas las capas de No_fuente
                                    num_obj = numel(obj.clases.estacionario.combinada(x).puertas);
                                    obj.elementos.estacionario.combinada(x).puertas = cell(num_obj,1);
                                    for p = 1:num_obj
                                        obj.elementos.estacionario.combinada(x).puertas{p} = obj.clases.estacionario.combinada(x).puertas{p}();
                                    end
                                    if ~isempty(obj.islas.estacionario.combinada(x).marcas_pol)
                                        for i=1:size(obj.islas.estacionario.combinada(x).marcas_pol)
                                            obj.elementos.estacionario.combinada(x).marcas_pol{i,1} = obj.clases.estacionario.combinada(x).marcas_pol{i}();
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        function obj = importar(obj, caso)
            % Metodo para importar la informacion ingresada por el usuario
            % desde un caso hacia las propiedades correspondintes a cada
            % uno de los objeto asociado a una puerta o marca de polaridad 
            % los cuales estan contenidos en la propiedad obj.elementos.
            %
            %   Entradas:
            %		caso (struct): estructura que contiene la información
            %	                   proveniente de un caso de HACEOS
            
            
            [ID_P,N_ENV,N_REC,NAT_P,VAL_P,TIPO_P,ID_FTE_IND,PAR_FTE_IND,...
                ID_FTE_DEP,TIPO_FTE_DEP,ID_DEPEN,TIPO_DEPEN,PARAMETRO] = id_col_puertas;     % Definir apuntadores de columna para las puertas
            [ID_MARCA,ID_L1,N_MARCADO_L1,ID_L2,N_MARCADO_L2,VAL_ACOPLE] = id_col_marcas;     % Definir apuntadores de columna de las maracas de polaridad
            [~,~,~,~,~,~,~,~,CTE,SIN,COS,EXP] = id_col_caso;                                 % Definir apuntadores de columna para el caso
            ID_NODO = id_col_nodos;
            estado = {'estacionario'};
            isla = {'DC','EXP','SIN','NoFuente','Combinada'};
            conjunto = {'puertas','marcas_pol'};            
            for e = 1:numel(estado)           % ciclo para barrer entre estado estacionario y transitorio
                for s = 1:numel(isla)         % ciclo para barrer las islas
                    for c = 1:numel(conjunto) % ciclo para barrer entre bultos de objetos: puertas y marcas
                        if ~isempty(obj.elementos.estacionario.(isla{s}).(conjunto{c}))
                            for p = 1:numel(obj.elementos.(estado{e}).(isla{s}).(conjunto{c}))
                                id_objeto = obj.islas.(estado{e}).(isla{s}).(conjunto{c})(p);
                                objeto = obj.elementos.(estado{e}).(isla{s}).(conjunto{c}){p};
                                id_fila_P = find(caso.puertas(:,ID_P)==id_objeto);
                                id_filas_marcas = find(caso.marcas_pol(:,ID_MARCA)==id_objeto);

                                % Si el objeto no es del tipo marcas de polaridad
                                if ~isa(objeto,'hcs.marcas_polaridad') 
                                    % Importar propiedades por defecto
                                    objeto.id = id_fila_P;
                                    objeto.term1 = caso.puertas(id_fila_P,N_ENV);
                                    objeto.nombre_term1 = caso.nombre_nodos{find(objeto.term1==caso.nodos(:,ID_NODO))};
                                    objeto.term2 = caso.puertas(id_fila_P,N_REC);
                                    objeto.nombre_term2 = caso.nombre_nodos{find(objeto.term2==caso.nodos(:,ID_NODO))};
                                    objeto.nat   = caso.puertas(id_fila_P,NAT_P);
                                    objeto.nombre_puerta = caso.nombre_puertas{id_objeto};
                                    objeto.tipo  = caso.puertas(id_fila_P,TIPO_P); 
                                    
                                    % Importar propiedades especificas
                                    if isa(objeto,'md_puerta_rlc')
                                        objeto.parametro = caso.puertas(id_fila_P,VAL_P);
                                    elseif isa(objeto,'md_puerta_fte_indep')
                                        objeto.tipo_senal = caso.puertas(id_objeto,VAL_P);
                                        objeto.tipo_fuente = caso.puertas(id_objeto,NAT_P);
                                        id_fuente = find(cell2mat(caso.fuentes_ind(:,ID_FTE_IND))==id_objeto);
                                        if objeto.tipo_senal == CTE
                                            objeto.parametro = caso.fuentes_ind{id_fuente,PAR_FTE_IND};
                                        elseif objeto.tipo_senal == SIN || objeto.tipo_senal == COS
                                            objeto.parametro = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(2);
                                            % objeto.parametro.amplitud = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(1);
                                            % objeto.parametro.w        = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(2);
                                            % objeto.parametro.desfase  = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(3);
                                            % objeto.parametro.offset   = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(4);
                                        elseif objeto.tipo_senal == EXP
                                            % objeto.parametro.amplitud  = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(1);
                                            % objeto.parametro.exponente = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(2);
                                            % objeto.parametro.offset    = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(3);
                                        end

                                    elseif isa(objeto,'md_puerta_fte_dep')
                                        id_fuente = find(caso.fuentes_dep(:,ID_FTE_DEP)==id_objeto);
                                        objeto.tipo_fuente = caso.fuentes_dep(id_fuente,TIPO_FTE_DEP);
                                        objeto.id_dep      = caso.fuentes_dep(id_fuente,ID_DEPEN);
                                        objeto.tipo_dep    = caso.fuentes_dep(id_fuente,TIPO_DEPEN);
                                        objeto.parametro   = caso.fuentes_dep(id_fuente,PARAMETRO);
                                        objeto.constante   = caso.puertas(id_objeto,VAL_P);
                                    end

                                else
                                    % Si el objeto es del tipo marcas de polaridad
                                    objeto.id_marca               = id_filas_marcas;
                                    objeto.id_puerta_1_acoplada   = caso.marcas_pol(id_filas_marcas,ID_L1);
                                    objeto.id_puerta_2_acoplada   = caso.marcas_pol(id_filas_marcas,ID_L2);
                                    objeto.id_terminal_1_acoplada = caso.marcas_pol(id_filas_marcas,N_MARCADO_L1);
                                    objeto.id_terminal_2_acoplada = caso.marcas_pol(id_filas_marcas,N_MARCADO_L2);
                                    objeto.parametro              = caso.marcas_pol(id_filas_marcas,VAL_ACOPLE);
                                end
                                % Actualizar el objeto
                                obj.elementos.(estado{e}).(conjunto{c}){p} = objeto;
                            end
                        end
                    end
                end
                % isla_w = 'SIN';
                % for c = 1:numel(conjunto)
                %     if ~isempty(obj.elementos.estacionario.(isla_w).(conjunto{c}))
                %         for p = 1:numel(obj.elementos.(estado{e}).(isla_w).(conjunto{c}))
                %             id_objeto = obj.islas.(estado{e}).(isla_w).(conjunto{c})(p);
                %             objeto = obj.elementos.(estado{e}).(isla_w).(conjunto{c}){p};
                %             id_fila_P = find(caso.puertas(:,ID_P)==id_objeto);
                %             id_filas_marcas = find(caso.marcas_pol(:,ID_MARCA)==id_objeto);
                % 
                %             % Si el objeto no es del tipo marcas de polaridad
                %             if ~isa(objeto,'hcs.marcas_polaridad')
                %                 % Importar propiedades por defecto
                %                 objeto.id = id_fila_P;
                %                 objeto.term1 = caso.puertas(id_fila_P,N_ENV);
                %                 objeto.nombre_term1 = caso.nombre_nodos{find(objeto.term1==caso.nodos(:,ID_NODO))};
                %                 objeto.term2 = caso.puertas(id_fila_P,N_REC);
                %                 objeto.nombre_term2 = caso.nombre_nodos{find(objeto.term2==caso.nodos(:,ID_NODO))};
                %                 objeto.nat   = caso.puertas(id_fila_P,NAT_P);
                %                 objeto.nombre_puerta = caso.nombre_puertas{id_objeto};
                %                 objeto.tipo  = caso.puertas(id_fila_P,TIPO_P);
                % 
                %                 % Importar propiedades especificas
                %                 if isa(objeto,'md_puerta_rlc')
                %                     objeto.parametro = caso.puertas(id_fila_P,VAL_P);
                %                 elseif isa(objeto,'md_puerta_fte_indep')
                %                     objeto.tipo_senal = caso.puertas(id_objeto,VAL_P);
                %                     objeto.tipo_fuente = caso.puertas(id_objeto,NAT_P);
                %                     id_fuente = find(cell2mat(caso.fuentes_ind(:,ID_FTE_IND))==id_objeto);
                %                     if objeto.tipo_senal == CTE
                %                         objeto.parametro = caso.fuentes_ind{id_fuente,PAR_FTE_IND};
                %                     elseif objeto.tipo_senal == SIN || objeto.tipo_senal == COS
                %                         objeto.parametro = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(2);
                %                         % objeto.parametro.amplitud = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(1);
                %                         % objeto.parametro.w        = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(2);
                %                         % objeto.parametro.desfase  = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(3);
                %                         % objeto.parametro.offset   = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(4);
                %                     elseif objeto.tipo_senal == EXP
                %                         objeto.parametro.amplitud  = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(1);
                %                         objeto.parametro.exponente = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(2);
                %                         objeto.parametro.offset    = caso.fuentes_ind{id_fuente,PAR_FTE_IND}(3);
                %                     end
                % 
                %                 elseif isa(objeto,'md_puerta_fte_dep')
                %                     id_fuente = find(caso.fuentes_dep(:,ID_FTE_DEP)==id_objeto);
                %                     objeto.tipo_fuente = caso.fuentes_dep(id_fuente,TIPO_FTE_DEP);
                %                     objeto.id_dep      = caso.fuentes_dep(id_fuente,ID_DEPEN);
                %                     objeto.tipo_dep    = caso.fuentes_dep(id_fuente,TIPO_DEPEN);
                %                     objeto.parametro   = caso.fuentes_dep(id_fuente,PARAMETRO);
                %                     objeto.constante   = caso.puertas(id_objeto,VAL_P);
                %                 end
                % 
                %             else
                %                 % Si el objeto es del tipo marcas de polaridad
                %                 objeto.id_marca               = id_filas_marcas;
                %                 objeto.id_puerta_1_acoplada   = caso.marcas_pol(id_filas_marcas,ID_L1);
                %                 objeto.id_puerta_2_acoplada   = caso.marcas_pol(id_filas_marcas,ID_L2);
                %                 objeto.id_terminal_1_acoplada = caso.marcas_pol(id_filas_marcas,N_MARCADO_L1);
                %                 objeto.id_terminal_2_acoplada = caso.marcas_pol(id_filas_marcas,N_MARCADO_L2);
                %                 objeto.parametro              = caso.marcas_pol(id_filas_marcas,VAL_ACOPLE);
                %             end
                %             % Actualizar el objeto
                %             obj.elementos.(estado{e}).(conjunto{c}){p} = objeto;
                %         end
                %     end
                % end
            end
        end


        function obj_interruptores = crear_interruptores(obj,caso)
            % Metodo para identificar y crear objetos de clase hcs.interruptor
            % sencillo y compuesto de acuerdo con la informacion contenida
            % en un caso de HACEOS.
            %
            %   Entradas:
            %		caso (struct): estructura que contiene la información
            %	                   proveniente de un caso de HACEOS
            %
            %	Salidas:
            %		obj_interruptores (cell): celda que contiene los
            %		         objetos de los interruptores sencillos y 
            %                compuestos incluidos en el caso bajo analisis            
            
            [R,L,C,LM,VI,II,VD,ID,CTE,SIN,COS,EXP,INTS,INTC] = id_col_caso;  % Definir indicadores para el ingreso de información
            [ID_INT,TIPO_INT,N_INT,ESTADO] = id_col_interruptores;
            if ~isempty(caso.interruptores)
                obj_interruptores = cell(size(caso.interruptores,1),1);
                for i = 1:size(obj_interruptores,1) 
                    interruptor = caso.interruptores(i,:);
                    if interruptor{TIPO_INT} == INTS
                        obj_interruptores{i} = interruptor_sencillo();
                        obj_interruptores{i}.nat = INTS;
                        obj_interruptores{i}.id = interruptor{ID_INT};
                        obj_interruptores{i}.term1 = interruptor{N_INT}(1);
                        obj_interruptores{i}.term2 = interruptor{N_INT}(2);
                        obj_interruptores{i}.estado = interruptor{ESTADO};
                    elseif interruptor{TIPO_INT} == INTC                        
                        obj_interruptores{i} = interruptor_compuesto();
                        obj_interruptores{i}.nat = INTC;
                        obj_interruptores{i}.id = interruptor{ID_INT};
                        obj_interruptores{i}.term0 = interruptor{N_INT}(1);
                        obj_interruptores{i}.term1 = interruptor{N_INT}(2);
                        obj_interruptores{i}.term2 = interruptor{N_INT}(3);
                        obj_interruptores{i}.estado = interruptor{ESTADO};
                    end
                end
            else 
                obj_interruptores = {};
            end
        end
        
        function obj = crear_estadisticas_caso(obj,caso)
            % Metodo para calcular las estadisticas generales de un caso
            % dado, tales como el numero de nodos, puertas, entre otros.
            %
            %   Entradas:
            %		caso (struct): estructura que contiene la información
            %	                   proveniente de un caso de HACEOS
            %
            %	Salidas:
            %		obj.stats_caso (struct): estadisticas generales del caso
            %           num_puertas - numero de puertas totales del caso   
            %           num_nodos - numero de nodos totales del caso   
            %           num_marcas - numero total de pares de marcas de
            %                        acoplamientos electromagneticos
            %           num_fts_ind - numero total de fuentes independientes
            
            [~,~,~,~,VI,II] = id_col_caso;
            obj.stats_caso.num_puertas = size(caso.puertas,1);
            obj.stats_caso.num_nodos = size(caso.nodos,1);
            obj.stats_caso.num_marcas = size(caso.marcas_pol,1);
            obj.stats_caso.num_fts_ind = sum(ismember(caso.puertas(:,4),[VI II]));
        end
    end
end