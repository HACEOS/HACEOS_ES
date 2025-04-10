classdef md_estacionario < hcs.modelo_datos
    % md_estacionario - Subclase para administrar el modelo de datos
    % en el estado estacionario.
    %
    % Esta subclase se encarga de separar y clasificar la información de un
    % caso segun su fuente de excitacion en estructuras de datos,
    % luego asigna handles a cada elemento de circuito presente en cada isla.
    %
    % Propiedades de md_estacionario:
    %	* circuito_cero_menos - estructura donde se guarda la informacion
    %	depurada de un circuito antes de la conmutacion de sus interruptores
    %
    % Metodos de md_estacionario:
    %	* extraer_info_estacionario(obj,caso) - evalua y conmuta los
    %	interruptores, luego propaga la nueva informacion, posteriormente se
    %	dispara la rutina que elimina elementos desenergizados en el estado
    %	estacionario finalmente separa la información del circuito por islas
    %	las cuales son estructuras que contiene un subconjunto de la
    %	información del caso original
    %
    %	* inicializar_estacionario(obj) - asigna los handles para cada puerta
    %	a cada de isla existente
    %
    % See also: md_transitorio, md_conmutacion, md_completo,
    % md_estacionario_transitorio, md_estacionario_conmutacion

    %   HACEOS - Herramienta para el Analisis de Circuitos Electricos de Orden Superior
    %   Copyright (c) 2025, Grupo de Investigacion en Campos Electromagneticos y Fenomenos Energeticos - CAFE
    %				        Universidad Tecnologica de Pereira (UTP)
    %  	Por: Brandon Ospina y Brian Gordon, CAFE-UTP
    %   y Wilson Gonzalez Vanegas, CAFE-UTP y Universidad Nacional de Colombia Sede Manizales
    %
    %   Este archivo es parte del proyecto HACEOS.
    %   Cubierto por la licencia 3-clause BSD (mas detalles en el archivo LICENSE).
    %   Vea https://github.com/HACEOS/ para mayor informacion.
    %
    %   Nota: este archivo es libre de tildes para evitar posibles conflictos en sistemas sin codificacion UTF-8

    properties
        circuito_cero_menos
    end

    methods
        function obj = md_estacionario()  % Constructor
            obj@hcs.modelo_datos();
        end

        function [obj, mr] = extraer_info_estacionario(obj, caso, mr)
            % Metodo para guardar la informacion original del caso antes de
            % ser depurada por otras subrutinas
            %   Entradas:
            %		caso (struct): estructura de datos donde se almacena
            %		    toda la informacion correspondiente a un circuito
            %		    electrico
            %       mr (hcs.modelo_red) :
            %
            %	Salidas:
            %		> Ejecuta la evaluacion de interruptores
            %       > Detecta elementos energizados en el estado
            %       estacionario
            %       > Clasifica la informacion en islas por tipo de fuente
            %       > Llena el campo obj.id_elementos.estacionario.puertas
            %       con los id's de las puertas energizadas en el estado
            %       estacionario
            %       > Llena el campo de obj.id_elementos.estacionario.marcas_pol
            %       con los id's de las inductancias energizadas en el
            %       estado estacionario

            [~,~,N_INT,ESTADO] = id_col_interruptores;
            obj.interruptores = obj.crear_interruptores(caso);
            obj.circuito_cero_menos = caso;
            if ~isempty(obj.interruptores)
                if sum(cell2mat(caso.interruptores(:,ESTADO)))==0
                    memoria = [];
                else
                    int_cerrados = find(cell2mat(caso.interruptores(:,ESTADO))==1);
                    memoria = caso.interruptores{int_cerrados(1),N_INT}';
                end
                for i = 1:size(obj.interruptores,1)
                    obj_interruptor = obj.interruptores{i};
                    [obj.circuito_cero_menos,memoria] = obj_interruptor.evaluar(obj.circuito_cero_menos,memoria);
                end
            end

            % Detectar elementos energizados y desenergizados
            [gno_original, gno_depurado] = mr.detectar_elementos_energizados(obj.circuito_cero_menos);
            %[id_elementos, id_marcas] = mr.detectar_elementos_energizados_estacionario(obj.circuito_cero_menos);

            % Detectar islas en el circuito depurado
            mr.detectar_islas(gno_depurado);

            % Construir islas (subcasos) en el modelo de datos
            islas_estacionario = mr.grafico_a_islas(obj.circuito_cero_menos, gno_depurado);

            % Crear y almacenar versiones orientadas de los gráficos
            go_original = mr.crear_grafico_orientado(gno_original);
            go_depurado = mr.crear_grafico_orientado(gno_depurado);

            %obj.id_elementos.estacionario.puertas = id_elementos;  % Id de las puertas segun la columna "id_puerta" del caso
            %obj.id_elementos.estacionario.marcas_pol = id_marcas;  % Posiciones de fila en el campo .marcas_pol del caso
            mr.graficos_no_orientados.originales.estacionario = gno_original;
            mr.graficos_no_orientados.depurados.estacionario = gno_depurado;
            mr.graficos_orientados.originales.estacionario = go_original;
            mr.graficos_orientados.depurados.estacionario = go_depurado;
            obj.islas.estacionario = islas_estacionario;
        end

        function obj = inicializar_estacionario(obj)
            % Metodo para guardar la informacion original del caso antes de
            % ser depurada por otras subrutinas
            %   Entradas:
            %		obj (struct): objeto que almacena toda la informacion
            %		referente al modelo de datos.
            %   Salidas:
            %       > Recorre cada isla del circuito en el estado
            %       estacionario y etiqueta cada elemento con su
            %       respectiva clase (handle)

            [R,L,C,LM,VI,II,VD,ID] = id_col_caso;                  % Definir indicadores para el ingreso de informacion
            [~, ~, ~, NAT_P] = id_col_puertas;                     % Definir apuntadores a las columnas del campo puertas
            isla = {'DC','SIN','EXP','NoFuente' 'Combinada'};
            for Y = 1:numel(isla)
                if ~isempty(fieldnames(obj.islas.estacionario.(isla{Y})))
                    obj.islas.estacionario.(isla{Y}) = struct('puertas',[],...
                                                              'marcas_pol',[]); 
                    % Caso DC
                    if strcmp(isla{Y},'DC')
                        if ~isempty(obj.islas.estacionario.(isla{Y}).puertas)                         
                            % "x" recorre todas las capas de DC
                            for x = 1:size(obj.islas.estacionario.(isla{Y}),2)
                                for p = 1:size(obj.islas.estacionario.(isla{Y})(x).puertas,1)
                                    switch obj.islas.estacionario.(isla{Y})(x).puertas(p,NAT_P)
                                        case {R,L,C}
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_rlc;
                                        case {VI,II}
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_fte_indep;
                                        case {VD,ID}
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_fte_dep;
                                        case LM
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_rlc;
                                    end
                                end
                                if ~isempty(obj.islas.estacionario.DC(x).marcas_pol)
                                    for i = 1:size(obj.islas.estacionario.DC(x).marcas_pol,1)
                                        obj.clases.estacionario.DC(x).marcas_pol{i,1} = @hcs.marcas_polaridad;
                                    end
                                end
                            end
                        end
                    end

                    % Caso sinusoidal con igual o distinta frecuencia
                    if strcmp(isla{Y},'SIN')
                        % Recordar que en esta versión se ignoran los campos
                        % de igual y distinta frecuencia
                        % exc = {'igual_W' 'dif_W'};
                        % e recorre igual_w y dif_W

                        if ~isempty(obj.islas.estacionario.(isla{Y}).puertas)
                            % "x" recorre todas las capas de igual_W y dif_W
                            for x = 1:size(obj.islas.estacionario.(isla{Y}),2)
                                for p = 1:size(obj.islas.estacionario.(isla{Y})(x).puertas,1)
                                    switch obj.islas.estacionario.(isla{Y})(x).puertas(p,NAT_P)
                                        case {R,L,C}
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_rlc;
                                        case {VI,II}
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_fte_indep;
                                        case {VD,ID}
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_fte_dep;
                                        case LM
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_rlc;
                                    end
                                end
                                if ~isempty(obj.islas.estacionario.(isla{Y})(x).marcas_pol)
                                    for i = 1:size(obj.islas.estacionario.(isla{Y})(x).marcas_pol,1)
                                        obj.clases.estacionario.(isla{Y})(x).marcas_pol{i,1} = @hcs.marcas_polaridad;
                                    end
                                end
                            end
                        end
                    end

                    % Caso EXP
                    % if strcmp(isla{Y},'EXP')
                    %     if isempty(obj.islas.estacionario.(isla{Y}).puertas)
                    %         obj.islas.estacionario.(isla{Y}).puertas = [];
                    %     else
                    %         % "x" recorre todas las capas de EXP
                    %         for x = 1:size(obj.islas.estacionario.(isla{Y}),2)
                    %             for p = 1:size(obj.islas.estacionario.(isla{Y})(x).puertas,1)
                    %                 switch obj.islas.estacionario.(isla{Y})(x).puertas(p,NAT_P)
                    %                     case {R,L,C}
                    %                         obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_rlc;
                    %                     case {VI,II}
                    %                         obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_fte_indep;
                    %                     case {VD,ID}
                    %                         obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_fte_dep;
                    %                     case LM
                    %                         obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_rlc;
                    %                 end
                    %                 if ~isempty(obj.islas.estacionario.(isla{Y})(x).marcas_pol)
                    %                     for i = 1:size(obj.islas.estacionario.(isla{Y})(x).marcas_pol,1)
                    %                         obj.clases.estacionario.(isla{Y})(x).marcas_pol{i,1} = @hcs.marcas_polaridad;
                    %                     end
                    %                 end
                    %             end
                    %         end
                    %     end
                    % end

                    % Caso NoFuente
                    if strcmp(isla{Y},'NoFuente')
                        if ~isempty(obj.islas.estacionario.(isla{Y}))
                            %obj.islas.estacionario.(isla{Y}).puertas = [];
                            % "x" recorre todas las capas de No_fuente
                            for x = 1:size(obj.islas.estacionario.(isla{Y}),2)
                                for p = 1:size(obj.islas.estacionario.(isla{Y})(x).puertas,1)
                                    switch obj.islas.estacionario.(isla{Y})(x).puertas(p,NAT_P)
                                        case {R,L,C}
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_rlc;
                                        case {VI,II}
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_fte_indep;
                                        case {VD,ID}
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_fte_dep;
                                        case LM
                                            obj.clases.estacionario.(isla{Y})(x).puertas{p,1} = @md_puerta_rlc;
                                    end
                                end
                                if ~isempty(obj.islas.estacionario.(isla{Y})(x).marcas_pol)
                                    for i = 1:size(obj.islas.estacionario.(isla{Y})(x).marcas_pol,1)
                                        obj.clases.estacionario.(isla{Y})(x).marcas_pol{i,1} = @hcs.marcas_polaridad;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end  %% end methods
end      %% en class