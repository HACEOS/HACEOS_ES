classdef modelo_red < handle
    % modelo_red - Superclase para administrar el modelo de red.
    %
    % Esta superclase se encarga de realizar análisis de conectividad, como
    % elementos por los cuales no fluye corriente a traves de ellos, ademas
    % organiza los subconjuntos de información en categorías basadas en
    % su fuente de excitacion
    %
    % Propiedades de modelo_red:
    %	* cycles - vector con informacion de las mallas del circuito (nodos)
    %   * edgecycles - celda con informacion de las mallas del circuito (edges)
    %   * EdgeTable - tabla que almacena informacion de los edgecycles y sus puertas asociadas
    %   * table_1 - tabla que contiene informacion de las puertas incluso las desenergizadas
    %   * table_2 - tabla que contiene unicamente informacion de las puertas energizadas
    %   * Edges - objeto de tipo graph donde se almacena informacion de conectividad
    %
    % Metodos de modelo_red:
    %	* detectar_elementos_energizados_estacionario - realiza un
    %	  barrido por todo el circuito original luego de la evaluacion de
    %	  interruptores y detecta los elementos por los cuales no fluye corriente
    %   * detectar_islas - toma el circuito original y lo clasifica por subconjuntos
    %     de informacion donde el parametro de clasificacion es su tipo de fuente independiente

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
        cycles
        edgecycles
        EdgeTable
        table_1
        table_2
        Edges
        graficos
        tablas
        impropiedades
    end
    methods
        function obj = modelo_red()  % Constructor
            obj.edgecycles = [];
            obj.cycles = [];
            obj.EdgeTable = table();
            obj.Edges = table();
            obj.table_2 = table();
            obj.Edges = table();  % G.Edges

            obj.graficos = struct('estacionario',[],'conmutacion',[],'transitorio',[]);
            obj.graficos.estacionario = table();
            obj.graficos.transitorio = table();
            obj.graficos.conmutacion = struct('reducidoC',[],'reducidoL',[]);
            obj.impropiedades = struct('C',[],'L',[]);
            obj.tablas = struct('estacionario',[],'conmutacion',[],'transitorio',[]);
            obj.tablas.estacionario = struct('DC',[],'SIN',[],'COS',[],'EXP',[],'No_Fuente',[]);
            obj.tablas.estacionario.DC = table();
            obj.tablas.estacionario.SIN = struct('igual_W',[],'dif_W',[]);
            obj.tablas.estacionario.SIN.igual_W = table();
            obj.tablas.estacionario.SIN.dif_W = table();
            obj.tablas.estacionario.COS = struct('igual_W',[],'dif_W',[]);
            obj.tablas.estacionario.COS.igual_W = table();
            obj.tablas.estacionario.COS.dif_W = table();
            obj.tablas.estacionario.EXP = table();
            obj.tablas.estacionario.No_Fuente = table();
            obj.tablas.transitorio = table();
            obj.tablas.conmutacion = struct('reducidoC',[],'reducidoL',[]);
            obj.tablas.conmutacion.reducidoC.grafico = table();
            obj.tablas.conmutacion.reducidoC.nodos = table();
            obj.tablas.conmutacion.reducidoL.grafico = table();
            obj.tablas.conmutacion.reducidoL.nodos = table();
        end

        function [id_elementos, id_marcas] = detectar_elementos_energizados_estacionario(obj, circuito_cero_menos)
            % Metodo para obtener los elementos definitivos que se analizan
            % en el circuito de cero menos
            %
            %   Entradas:
            %		circuito_cero_menos (struct): estructura de datos donde
            %       se almacena toda la informacion correspondiente a un
            %       circuito electrico
            %   Salidas:
            %       id_elementos (double): vector de identificadores el
            %       cual tiene los id's de las puertas energizadas en cero
            %       menos
            %       id_marcas (double): vector de identifcadores de
            %       inductancias energizadas en cero menos

            [ID_P,N_ENV,N_REC,NAT_P,VAL_P,TIPO_P] = id_col_puertas;
            [~,~,~,LM] = id_col_caso;
            id = circuito_cero_menos.puertas(:,ID_P);
            s1 = circuito_cero_menos.puertas(:,N_ENV);
            S = arrayfun(@(x) sprintf('%d', x), s1, 'UniformOutput', false);
            t1  = circuito_cero_menos.puertas(:,N_REC);
            T = arrayfun(@(x) sprintf('%d', x), t1, 'UniformOutput', false);
            w  = circuito_cero_menos.puertas(:,TIPO_P);
            n  = circuito_cero_menos.puertas(:,NAT_P);
            labels = circuito_cero_menos.nombre_puertas;
            val_par = circuito_cero_menos.puertas(:,VAL_P);
            tabla_indc = table();

            % Se realiza la adicion de la columna NAT para saber si el
            % elemento es de naturaleza RLC o LM
            EdgeTable = table([S,T],w,labels,id,n,val_par,...
                'VariableNames',{'EndNodes' 'Weights' 'Labels' 'ID' 'NAT' 'VAL_P'});
            G = graph(EdgeTable);

            % Ordenar G.Edges segun el orden de EdgeTable
            tb1 = EdgeTable;
            tb2 = G.Edges;
            obj.Edges = G.Edges;
            [~, idx] = ismember(tb1.ID, tb2.ID);
            tb2 = tb2(idx, :);

            % Organizar los EndNodes para quedar como los originales
            tb2 = table([S,T],tb2.Weights,tb2.Labels,tb2.ID,tb2.NAT,tb2.VAL_P,...
                'VariableNames',{'EndNodes' 'Weights' 'Labels' 'ID' 'NAT' 'VAL_P'});

            obj.table_1 = tb2;

            % Rutina para quitar elementos en cortocircuito
            id_corto = [];
            for i=1:size(tb2.EndNodes,1)
                if tb2.EndNodes{i,1}==tb2.EndNodes{i,2}
                    id_corto = horzcat(tb2.ID(i),id_corto);
                end
            end
            obj.table_1(id_corto,:) = [];

            % Rutina para detectar elementos desenergizados
            C = {};
            G = graph(obj.table_1);
            [obj.cycles,obj.edgecycles] = allcycles(G);
            C = cellfun(@(x)([G.Edges.ID(x)]'),obj.edgecycles,'UniformOutput',false);
            x = cell2mat(C');
            H = setdiff(G.Edges.ID,x);  % ID's elementos desenergizados
            V = [];
            id_des_indc = [];
            for y = 1:numel(H)
                fila = find(obj.Edges.ID==H(y));
                if obj.Edges.NAT(fila,:) == LM
                    id_des_indc = [H(y),id_des_indc];
                end
                V = [H(y), V];         % Posiciones tabla elementos desenergizados G.Edges
            end

            for i=1:size(obj.Edges,1)
                if obj.Edges.NAT(i) == LM
                    marca_polaridad = table(obj.Edges.EndNodes(i),obj.Edges.Weights(i),obj.Edges.Labels(i),obj.Edges.ID(i),obj.Edges.NAT(i),obj.Edges.VAL_P(i),...
                        'VariableNames',{'EndNodes' 'Weights' 'Labels' 'ID' 'NAT' 'VAL_P'});
                    tabla_indc = [marca_polaridad;tabla_indc];
                    if obj.Edges.ID(i) == id_des_indc
                    end
                end
            end
            id_elementos = setdiff(obj.Edges.ID,H);         % resultado_1
            id_marcas = setdiff(tabla_indc.ID,id_des_indc); % resultado_2
            [filas, ~] = ismember(obj.table_1.ID,H);
            tb3 = tb2;
            tb3(filas,:) = [];
            obj.table_2 = tb3;
        end

        function md = detectar_islas(obj, circuito_cero_menos, md)

            [~,~,~,LM,VI,II,VD,ID,CTE,SIN,COS,EXP,~,~] = id_col_caso;
            % Metodo para clasificar la informacion original en
            % subconjuntos llamados "islas" los cuales contienen
            % estructuras de datos iguales que el caso original, estas
            % islas se clasifican segun su tipo de fuente independiente
            %
            %   Entradas:
            %		caso (struct): estructura de datos donde se almacena
            %		toda la informacion correspondiente a un circuito
            %		electrico
            %   Salidas:
            %       No tiene una salida, pero las clasficaciones se
            %       almacenan en md.islas.(estado)

            % Ciclo temporal para convertir cycles a celda de vectores
            cycles_nuevo = [];
            edgecycles_copy = obj.edgecycles;
            for i = 1:numel(obj.cycles)
                vector_num = cell2mat(cellfun(@str2double, obj.cycles{i}, 'UniformOutput', false));
                cycles_nuevo = vertcat(cycles_nuevo,{vector_num});
            end

            % Revisar esta rutina para los objetos {0x0 double}
            nodos_y_posiciones = horzcat(cycles_nuevo,obj.edgecycles);
            nodos_y_posiciones_copy = nodos_y_posiciones;

            % Se realiza un ciclo para clasificar los subconjuntos del
            % espacio nodos y naturaleza
            datos_conjunto = struct();
            valor_variable = {};
            posiciones_coincidentes = [];
            contador = 1;

            % Ciclo para dividir el conjunto total de elementos en
            % subconjuntos de posiciones los cuales contienen al menos dos
            % nodos coincidentes.
            if numel(nodos_y_posiciones(:,1)) == 0
            else
                i = 1;
                while i <= numel(nodos_y_posiciones(:,1))
                    for j = 1:numel(nodos_y_posiciones(:,1))
                        if sum(ismember(nodos_y_posiciones{i},nodos_y_posiciones{j})) >= 2
                            nombre_variable = sprintf('subconjunto_%d',contador);
                            valor_variable{j,1} = nodos_y_posiciones(j,:);
                            posiciones_coincidentes = [posiciones_coincidentes,j];
                        end
                    end
                    datos_conjunto.(nombre_variable) = valor_variable;
                    nodos_y_posiciones(posiciones_coincidentes,:) = [];
                    valor_variable = {};
                    posiciones_coincidentes = [];
                    contador = contador + 1;
                    i = 1;
                end
            end

            % Sub-rutina para clasificar las islas por tipo de fuente dados
            % los subconjuntos detectados
            islas = struct();
            campos = fieldnames(datos_conjunto);
            cont_igualW = 0;
            cont_difW = 0;
            cont_COS_igualW = 0;
            cont_COS_difW = 0;
            cont_DC = 0;
            cont_EXP = 0;
            cont_no_fuente = 0;
            [~, idx] = ismember(obj.Edges.ID, obj.table_1.ID);
            obj.table_1 = obj.table_1(idx, :);
            obj.Edges = table(obj.table_1.EndNodes,obj.Edges.Weights,...
                obj.Edges.Labels,obj.Edges.ID,obj.Edges.NAT,obj.Edges.VAL_P,...
                'VariableNames',{'EndNodes' 'Weights' 'Labels' 'ID' 'NAT' 'VAL_P'});

            for u = 1:length(campos)
                vecFreq = [];
                cvec = [];
                campo_actual = campos{u};
                valor_actual = datos_conjunto.(campo_actual);
                for v = 1:numel(valor_actual)
                    if isempty(valor_actual{v})
                        continue
                    end
                    cvec = [cvec, valor_actual{v}{2}];
                end
                vcom = unique(cvec(:));
                vcom = sort(vcom);     % posiciones de elementos en G.Edges
                info_table = obj.Edges(vcom,:);
                record = [];
                % Detectar fuentes independientes
                for w = 1:numel(vcom)
                    logical_FI = obj.Edges.NAT(vcom(w)) == VI ||...
                        obj.Edges.NAT(vcom(w)) == II;
                    record = [record,logical_FI];
                    if logical_FI == 1
                        if any(obj.Edges.VAL_P(vcom) == CTE) % DC
                            cont_DC = cont_DC + 1;

                            % Detectar posiciones de obj.tabla_1 para DC
                            postabla_DC = vcom;

                            % Campo nodos
                            idxs = sort(unique(obj.Edges.EndNodes(postabla_DC,:)));
                            n = zeros(size(idxs));
                            indices = [];
                            for i = 1:length(idxs)
                                n(i) = str2double(idxs{i});
                            end
                            for i = 1:size(circuito_cero_menos.nodos,1)
                                if any(circuito_cero_menos.nodos(i,1) == n)
                                    indices = [indices; i];
                                end
                            end
                            md.islas.estacionario.DC.nodos = circuito_cero_menos.nodos(indices,:);

                            % Campo nombre_nodos
                            md.islas.estacionario.DC.nombre_nodos = circuito_cero_menos.nombre_nodos(indices);

                            % Campo puertas
                            md.islas.estacionario.DC.puertas = horzcat(obj.Edges.ID(postabla_DC),str2double(obj.Edges.EndNodes(postabla_DC,:)),obj.Edges.NAT(postabla_DC),obj.Edges.VAL_P(postabla_DC),obj.Edges.Weights(postabla_DC));

                            % Campo nombre_puertas
                            md.islas.estacionario.DC.nombre_puertas = obj.Edges.Labels(postabla_DC);

                            % Campo interruptores
                            md.islas.estacionario.DC.interruptores = [];

                            % Campo fuentes_independientes
                            for i = 1:size(md.islas.estacionario.DC.puertas,1)
                                if md.islas.estacionario.DC.puertas(i,5) == CTE
                                    idx_fuentes_DC = md.islas.estacionario.DC.puertas(i,1);
                                end
                            end
                            ids_vec = cell2mat(circuito_cero_menos.fuentes_ind(:,1));
                            pointers = find(ids_vec==idx_fuentes_DC);
                            md.islas.estacionario.DC.fuentes_ind = circuito_cero_menos.fuentes_ind(pointers,:);

                            % Campo fuentes_dependientes
                            if isempty(circuito_cero_menos.fuentes_dep)
                            else
                                idx_fdep_vd = postabla_DC(obj.Edges.NAT(postabla_DC) == VD);
                                idx_fdep_id = postabla_DC(obj.Edges.NAT(postabla_DC) == ID);
                                id_fd_vd = obj.Edges.ID(idx_fdep_vd);
                                if isempty(id_fd_vd)
                                else
                                    x = find(id_fd_vd == circuito_cero_menos.fuentes_dep);
                                    md.islas.estacionario.DC.fuentes_dep = circuito_cero_menos.fuentes_dep(x,:);
                                end
                                id_fd_id = obj.Edges.ID(idx_fdep_id);
                                if isempty(id_fd_id)
                                else
                                    y = find(id_fd_id == circuito_cero_menos.fuentes_dep);
                                    md.islas.estacionario.DC.fuentes_dep = circuito_cero_menos.fuentes_dep(y,:);
                                end
                            end
                            % Campo marcas_polaridad
                            if any(obj.Edges.NAT(postabla_DC) == LM)
                                md.islas.estacionario.DC.marcas_pol = circuito_cero_menos.marcas_pol;
                            end
                        end
                        if any(obj.Edges.VAL_P(vcom) == SIN)
                            indx = find(obj.Edges.VAL_P(vcom) == SIN);
                            idFreq = info_table.ID(indx);

                            for z = 1:numel(idFreq)
                                for x = 1:size(circuito_cero_menos.fuentes_ind,1)
                                    if idFreq(z) == circuito_cero_menos.fuentes_ind{x,1}
                                        vecFreq = [vecFreq;circuito_cero_menos.fuentes_ind{x,2}(2)];
                                    end
                                end
                            end

                            % Con vector de frecuencias, determinar si la
                            % isla es de igual o diferente frecuencia
                            if all(vecFreq == vecFreq(1))
                                cont_igualW = cont_igualW + 1;

                                % Detectar posiciones de obj.tabla_1 para isla SIN
                                postabla_SIN = vcom;

                                % Campo nodos
                                idxs = sort(unique(obj.Edges.EndNodes(postabla_SIN,:)));
                                n = zeros(size(idxs));
                                indices = [];
                                for i = 1:length(idxs)
                                    n(i) = str2double(idxs{i});
                                end
                                for i = 1:size(circuito_cero_menos.nodos,1)
                                    if any(circuito_cero_menos.nodos(i,1) == n)
                                        indices = [indices; i];
                                    end
                                end
                                md.islas.estacionario.SIN.igual_W(cont_igualW).nodos = circuito_cero_menos.nodos(indices,:);

                                % Campo nombre_nodos
                                md.islas.estacionario.SIN.igual_W(cont_igualW).nombre_nodos = circuito_cero_menos.nombre_nodos(indices);

                                % Campo puertas
                                md.islas.estacionario.SIN.igual_W(cont_igualW).puertas = horzcat(obj.Edges.ID(postabla_SIN),str2double(obj.Edges.EndNodes(postabla_SIN,:)),obj.Edges.NAT(postabla_SIN),obj.Edges.VAL_P(postabla_SIN),obj.Edges.Weights(postabla_SIN));

                                % Campo nombre_puertas
                                md.islas.estacionario.SIN.igual_W(cont_igualW).nombre_puertas = obj.Edges.Labels(postabla_SIN);

                                % Campo interruptores
                                md.islas.estacionario.SIN.igual_W(cont_igualW).interruptores = [];

                                % Campo fuentes_independientes
                                idx_fuentes_SIN = [];
                                for i = 1:size(md.islas.estacionario.SIN.igual_W(cont_igualW).puertas,1)
                                    if md.islas.estacionario.SIN.igual_W(cont_igualW).puertas(i,5) == SIN
                                        idx_fuentes_SIN = [idx_fuentes_SIN;md.islas.estacionario.SIN.igual_W(cont_igualW).puertas(i,1)];
                                    end
                                end

                                ids_vec = [];
                                for h = 1:size(circuito_cero_menos.fuentes_ind,1)
                                    ids_vec = [ids_vec;circuito_cero_menos.fuentes_ind{h,1}];
                                end

                                pointers = [];
                                for i = 1:length(idx_fuentes_SIN)
                                    pos = find(ids_vec == idx_fuentes_SIN(i));
                                    pointers = [pointers; pos];
                                end
                                md.islas.estacionario.SIN.igual_W(cont_igualW).fuentes_ind = circuito_cero_menos.fuentes_ind(pointers,:);
                                idx_fuentes_SIN = [];

                                % Campo fuentes_dependientes
                                idx_fdep_vd = postabla_SIN(obj.Edges.NAT(postabla_SIN) == VD);
                                idx_fdep_id = postabla_SIN(obj.Edges.NAT(postabla_SIN) == ID);
                                id_fd_vd = obj.Edges.ID(idx_fdep_vd);
                                id_fd_id = obj.Edges.ID(idx_fdep_id);
                                if ~isempty(id_fd_vd) || ~isempty(id_fd_id)
                                    vd_find = find(id_fd_vd,circuito_cero_menos.fuentes_dep(:,1));
                                    id_find = find(id_fd_id,circuito_cero_menos.fuentes_dep(:,1));
                                    md.islas.estacionario.SIN.igual_W(cont_igualW).fuentes_dep = [circuito_cero_menos.fuentes_dep(vd_find,:);...
                                        circuito_cero_menos.fuentes_dep(id_find,:)];
                                end

                                % Campo marcas_polaridad
                                if any(obj.Edges.NAT(postabla_SIN) == LM)
                                    md.islas.estacionario.SIN.igual_W(cont_igualW).marcas_pol = circuito_cero_menos.marcas_pol;
                                end
                            else
                                cont_difW = cont_difW + 1;

                                % Detectar posiciones de obj.tabla_1 para isla SIN
                                postabla_SIN = vcom;

                                % Campo nodos
                                idxs = sort(unique(obj.Edges.EndNodes(postabla_SIN,:)));
                                n = zeros(size(idxs));
                                indices = [];
                                for i = 1:length(idxs)
                                    n(i) = str2double(idxs{i});
                                end
                                for i = 1:size(circuito_cero_menos.nodos,1)
                                    if any(circuito_cero_menos.nodos(i,1) == n)
                                        indices = [indices; i];
                                    end
                                end
                                md.islas.estacionario.SIN.dif_W(cont_difW).nodos = circuito_cero_menos.nodos(indices,:);

                                % Campo nombre_nodos
                                md.islas.estacionario.SIN.dif_W(cont_difW).nombre_nodos = circuito_cero_menos.nombre_nodos(indices);

                                % Campo puertas
                                md.islas.estacionario.SIN.dif_W(cont_difW).puertas = horzcat(obj.Edges.ID(postabla_SIN),str2double(obj.Edges.EndNodes(postabla_SIN,:)),obj.Edges.NAT(postabla_SIN),obj.Edges.VAL_P(postabla_SIN),obj.Edges.Weights(postabla_SIN));

                                % Campo nombre_puertas
                                md.islas.estacionario.SIN.dif_W(cont_difW).nombre_puertas = obj.Edges.Labels(postabla_SIN);

                                % Campo interruptores
                                md.islas.estacionario.SIN.dif_W(cont_difW).interruptores = [];

                                % Campo fuentes_independientes
                                idx_fuentes_SIN = [];
                                for i = 1:size(md.islas.estacionario.SIN.dif_W(cont_difW).puertas,1)
                                    if md.islas.estacionario.SIN.dif_W(cont_difW).puertas(i,5) == SIN
                                        idx_fuentes_SIN = [idx_fuentes_SIN;md.islas.estacionario.SIN.dif_W(cont_difW).puertas{i,1}];
                                    end
                                end

                                ids_vec = [];
                                for h = 1:size(circuito_cero_menos.fuentes_ind,1)
                                    ids_vec = [ids_vec;circuito_cero_menos.fuentes_ind{h,1}];
                                end

                                pointers = [];
                                for i = 1:length(idx_fuentes_SIN)
                                    pos = find(ids_vec == idx_fuentes_SIN(i));
                                    pointers = [pointers; pos];
                                end
                                md.islas.estacionario.SIN.dif_W(cont_difW).fuentes_ind = circuito_cero_menos.fuentes_ind(pointers,:);
                                idx_fuentes_SIN = [];

                                % Campo fuentes_dependientes
                                idx_fdep_vd = postabla_SIN(obj.Edges.NAT(postabla_SIN) == VD);
                                idx_fdep_id = postabla_SIN(obj.Edges.NAT(postabla_SIN) == ID);
                                id_fd_vd = obj.Edges.ID(idx_fdep_vd);
                                id_fd_id = obj.Edges.ID(idx_fdep_id);
                                md.islas.estacionario.SIN.dif_W(cont_difW).fuentes_dep = [circuito_cero_menos.fuentes_dep(id_fd_vd,:);...
                                    circuito_cero_menos.fuentes_dep(id_fd_id,:)];

                                % Campo marcas_polaridad
                                if any(obj.Edges.NAT(postabla_SIN) == LM)
                                    md.islas.estacionario.SIN.dif_W(cont_difW).marcas_pol = circuito_cero_menos.marcas_pol;
                                end
                            end
                            vecFreq = [];
                        end

                        if any(obj.Edges.VAL_P(vcom) == COS)
                            indx = find(obj.Edges.VAL_P(vcom) == COS);
                            idFreq = info_table.ID(indx);

                            for z = 1:numel(idFreq)
                                for x = 1:size(circuito_cero_menos.fuentes_ind,1)
                                    if idFreq(z) == circuito_cero_menos.fuentes_ind{x,1}
                                        vecFreq = [vecFreq;circuito_cero_menos.fuentes_ind{x,2}(2)];
                                    end
                                end
                            end

                            % Con vector de frecuencias, determinar si la
                            % isla es de igual o diferente frecuencia
                            if all(vecFreq == vecFreq(1))
                                cont_COS_igualW = cont_COS_igualW + 1;

                                % Detectar posiciones de obj.tabla_1 para isla COS
                                postabla_COS = vcom;

                                % Campo nodos
                                idxs = sort(unique(obj.Edges.EndNodes(postabla_COS,:)));
                                n = zeros(size(idxs));
                                indices = [];
                                for i = 1:length(idxs)
                                    n(i) = str2double(idxs{i});
                                end
                                for i = 1:size(circuito_cero_menos.nodos,1)
                                    if any(circuito_cero_menos.nodos(i,1) == n)
                                        indices = [indices; i];
                                    end
                                end
                                md.islas.estacionario.COS.igual_W(cont_COS_igualW).nodos = circuito_cero_menos.nodos(indices,:);

                                % Campo nombre_nodos
                                md.islas.estacionario.COS.igual_W(cont_COS_igualW).nombre_nodos = circuito_cero_menos.nombre_nodos(indices);

                                % Campo puertas
                                md.islas.estacionario.COS.igual_W(cont_COS_igualW).puertas = horzcat(obj.Edges.ID(postabla_COS),str2double(obj.Edges.EndNodes(postabla_COS,:)),obj.Edges.NAT(postabla_COS),obj.Edges.VAL_P(postabla_COS),obj.Edges.Weights(postabla_COS));

                                % Campo nombre_puertas
                                md.islas.estacionario.COS.igual_W(cont_COS_igualW).nombre_puertas = obj.Edges.Labels(postabla_COS);

                                % Campo interruptores
                                md.islas.estacionario.COS.igual_W(cont_COS_igualW).interruptores = [];

                                % Campo fuentes_independientes
                                idx_fuentes_COS = [];
                                for i = 1:size(md.islas.estacionario.COS.igual_W(cont_COS_igualW).puertas,1)
                                    if md.islas.estacionario.SIN.igual_W(cont_COS_igualW).puertas(i,5) == COS
                                        idx_fuentes_COS = [idx_fuentes_COS;md.islas.estacionario.COS.igual_W(cont_COS_igualW).puertas{i,1}];
                                    end
                                end

                                ids_vec = [];
                                for h = 1:size(circuito_cero_menos.fuentes_ind,1)
                                    ids_vec = [ids_vec;circuito_cero_menos.fuentes_ind{h,1}];
                                end

                                pointers = [];
                                for i = 1:length(idx_fuentes_COS)
                                    pos = find(ids_vec == idx_fuentes_COS(i));
                                    pointers = [pointers; pos];
                                end
                                md.islas.estacionario.COS.igual_W(cont_COS_igualW).fuentes_ind = circuito_cero_menos.fuentes_ind(pointers,:);
                                idx_fuentes_COS = [];

                                % Campo fuentes_dependientes
                                idx_fdep_vd = postabla_COS(obj.Edges.NAT(postabla_COS) == VD);
                                idx_fdep_id = postabla_COS(obj.Edges.NAT(postabla_COS) == ID);
                                id_fd_vd = obj.Edges.ID(idx_fdep_vd);
                                id_fd_id = obj.Edges.ID(idx_fdep_id);
                                md.islas.estacionario.COS.igual_W(cont_COS_igualW).fuentes_dep = [circuito_cero_menos.fuentes_dep(id_fd_vd,:);...
                                    circuito_cero_menos.fuentes_dep(id_fd_id,:)];

                                % Campo marcas_polaridad
                                if any(obj.Edges.NAT(postabla_COS) == LM)
                                    md.islas.estacionario.COS.igual_W(cont_COS_igualW).marcas_pol = circuito_cero_menos.marcas_pol;
                                end
                            else
                                cont_COS_difW = cont_COS_difW + 1;

                                % Detectar posiciones de obj.tabla_1 para isla COS
                                postabla_COS = vcom;

                                % Campo nodos
                                idxs = sort(unique(obj.Edges.EndNodes(postabla_COS,:)));
                                n = zeros(size(idxs));
                                indices = [];
                                for i = 1:length(idxs)
                                    n(i) = str2double(idxs{i});
                                end
                                for i = 1:size(circuito_cero_menos.nodos,1)
                                    if any(circuito_cero_menos.nodos(i,1) == n)
                                        indices = [indices; i];
                                    end
                                end
                                md.islas.estacionario.COS.dif_W(cont_COS_difW).nodos = circuito_cero_menos.nodos(indices,:);

                                % Campo nombre_nodos
                                md.islas.estacionario.COS.dif_W(cont_COS_difW).nombre_nodos = circuito_cero_menos.nombre_nodos(indices);

                                % Campo puertas
                                md.islas.estacionario.COS.dif_W(cont_COS_difW).puertas = horzcat(obj.Edges.ID(postabla_COS),str2double(obj.Edges.EndNodes(postabla_COS,:)),obj.Edges.NAT(postabla_COS),obj.Edges.VAL_P(postabla_COS),obj.Edges.Weights(postabla_COS));

                                % Campo nombre_puertas
                                md.islas.estacionario.COS.dif_W(cont_COS_difW).nombre_puertas = obj.Edges.Labels(postabla_COS);

                                % Campo interruptores
                                md.islas.estacionario.COS.dif_W(cont_COS_difW).interruptores = [];

                                % Campo fuentes_independientes
                                idx_fuentes_COS = [];
                                for i = 1:size(md.islas.estacionario.COS.dif_W(cont_COS_difW).puertas,1)
                                    if md.islas.estacionario.COS.dif_W(cont_COS_difW).puertas{i,5} == COS
                                        idx_fuentes_COS = [idx_fuentes_COS;md.islas.estacionario.COS.dif_W(cont_COS_difW).puertas{i,1}];
                                    end
                                end

                                ids_vec = [];
                                for h = 1:size(circuito_cero_menos.fuentes_ind,1)
                                    ids_vec = [ids_vec;circuito_cero_menos.fuentes_ind{h,1}];
                                end

                                pointers = [];
                                for i = 1:length(idx_fuentes_COS)
                                    pos = find(ids_vec == idx_fuentes_COS(i));
                                    pointers = [pointers; pos];
                                end
                                md.islas.estacionario.COS.dif_W(cont_COS_difW).fuentes_ind = circuito_cero_menos.fuentes_ind(pointers,:);
                                idx_fuentes_COS = [];


                                % Campo fuentes_dependientes
                                idx_fdep_vd = postabla_COS(obj.Edges.NAT(postabla_COS) == VD);
                                idx_fdep_id = postabla_COS(obj.Edges.NAT(postabla_COS) == ID);
                                id_fd_vd = obj.Edges.ID(idx_fdep_vd);
                                id_fd_id = obj.Edges.ID(idx_fdep_id);
                                md.islas.estacionario.COS.dif_W(cont_COS_difW).fuentes_dep = [circuito_cero_menos.fuentes_dep(id_fd_vd,:);...
                                    circuito_cero_menos.fuentes_dep(id_fd_id,:)];

                                % Campo marcas_polaridad
                                if any(obj.Edges.NAT(postabla_COS) == LM)
                                    md.islas.estacionario.COS.dif_W(cont_COS_difW).marcas_pol = circuito_cero_menos.marcas_pol;
                                end
                            end
                        end

                        if any(obj.Edges.VAL_P(vcom) == EXP)
                            cont_EXP = cont_EXP + 1;

                            % Detectar posiciones de obj.tabla_1 para EXP
                            postabla_EXP = vcom;

                            % Campo nodos
                            idxs = sort(unique(obj.Edges.EndNodes(postabla_EXP,:)));
                            n = zeros(size(idxs));
                            indices = [];
                            for i = 1:length(idxs)
                                n(i) = str2double(idxs{i});
                            end
                            for i = 1:size(circuito_cero_menos.nodos,1)
                                if any(circuito_cero_menos.nodos(i,1) == n)
                                    indices = [indices; i];
                                end
                            end
                            md.islas.estacionario.EXP.nodos = circuito_cero_menos.nodos(indices,:);

                            % Campo nombre_nodos
                            md.islas.estacionario.EXP.nombre_nodos = circuito_cero_menos.nombre_nodos(indices);

                            % Campo puertas
                            md.islas.estacionario.EXP.puertas = horzcat(obj.Edges.ID(postabla_EXP),str2double(obj.Edges.EndNodes(postabla_EXP,:)),obj.Edges.NAT(postabla_EXP),obj.Edges.VAL_P(postabla_EXP),obj.Edges.Weights(postabla_EXP));

                            % Campo nombre_puertas
                            md.islas.estacionario.EXP.nombre_puertas = obj.Edges.Labels(postabla_EXP);

                            % Campo interruptores
                            md.islas.estacionario.EXP.interruptores = [];

                            % Campo fuentes_independientes
                            for i = 1:size(md.islas.estacionario.EXP.puertas,1)
                                if md.islas.estacionario.EXP.puertas(i,5) == EXP
                                    idx_fuentes_EXP = md.islas.estacionario.EXP.puertas{i,1};
                                end
                            end
                            ids_vec = cell2mat(circuito_cero_menos.fuentes_ind(:,1));
                            pointers = find(ids_vec==idx_fuentes_EXP);
                            md.islas.estacionario.EXP.fuentes_ind = circuito_cero_menos.fuentes_ind(pointers,:);

                            % Campo fuentes_dependientes
                            if isempty(circuito_cero_menos.fuentes_dep)
                            else
                                idx_fdep_vd = postabla_EXP(obj.Edges.NAT(postabla_EXP) == VD);
                                idx_fdep_id = postabla_EXP(obj.Edges.NAT(postabla_EXP) == ID);
                                id_fd_vd = obj.Edges.ID(idx_fdep_vd);
                                id_fd_id = obj.Edges.ID(idx_fdep_id);
                                md.islas.estacionario.EXP.fuentes_dep = [circuito_cero_menos.fuentes_dep(id_fd_vd,:);...
                                    circuito_cero_menos.fuentes_dep(id_fd_id,:)];
                            end

                            % Campo marcas_polaridad
                            if any(obj.Edges.NAT(postabla_EXP) == LM)
                                md.islas.estacionario.EXP.marcas_pol = circuito_cero_menos.marcas_pol;
                            end
                        end
                    end
                    % Este break se pone porque en vecFreq ya se detectaron
                    % todas las fuentes de voltaje sinusoidales y no es
                    % necesario seguir recorriendo el vector vcom
                    if logical_FI == 1
                        break
                    end
                end

                if sum(record) == 0
                    % No existen fuentes independientes en el subconjunto
                    cont_no_fuente = cont_no_fuente + 1;

                    % Detectar posiciones de obj.tabla_1 para
                    % isla sin fuente
                    postabla_No_Fuente = vcom;

                    % Detectar posiciones de obj.tabla_1 para isla
                    % sin fuente
                    pos = [];
                    for i = 1:size(valor_actual,1)
                        pos = [pos,valor_actual{i}{2}];
                        postabla_No_Fuente = unique(pos);
                    end

                    % Campo nodos
                    idxs = sort(unique(obj.Edges.EndNodes(postabla_No_Fuente,:)));
                    n = zeros(size(idxs));
                    indices = [];
                    for i = 1:length(idxs)
                        n(i) = str2double(idxs{i});
                    end
                    for i = 1:size(circuito_cero_menos.nodos,1)
                        if any(circuito_cero_menos.nodos(i,1) == n)
                            indices = [indices; i];
                        end
                    end
                    md.islas.estacionario.No_Fuente.nodos = circuito_cero_menos.nodos(indices,:);

                    % Campo nombre_nodos
                    md.islas.estacionario.No_Fuente.nombre_nodos = circuito_cero_menos.nombre_nodos(indices);

                    % Campo puertas
                    md.islas.estacionario.No_Fuente.puertas = horzcat(num2cell(obj.Edges.ID(postabla_No_Fuente)),...
                        obj.Edges.EndNodes(postabla_No_Fuente,:),num2cell(obj.Edges.NAT(postabla_No_Fuente)),...
                        num2cell(obj.Edges.VAL_P(postabla_No_Fuente)),num2cell(obj.Edges.Weights(postabla_No_Fuente)));

                    % Campo nombre_puertas
                    md.islas.estacionario.No_Fuente.nombre_puertas = obj.Edges.Labels(postabla_No_Fuente);

                    md.islas.estacionario.No_Fuente.puertas = horzcat(obj.Edges.ID(postabla_No_Fuente),str2double(obj.Edges.EndNodes(postabla_No_Fuente,:)),obj.Edges.NAT(postabla_No_Fuente),obj.Edges.VAL_P(postabla_No_Fuente),obj.Edges.Weights(postabla_No_Fuente));

                    % Campo interruptores
                    md.islas.estacionario.No_Fuente.interruptores = [];

                    % Campo fuentes_dependientes
                    if isempty(circuito_cero_menos.fuentes_dep)
                    else
                        idx_fdep_vd = postabla_No_Fuente(obj.Edges.NAT(postabla_No_Fuente) == VD);
                        idx_fdep_id = postabla_No_Fuente(obj.Edges.NAT(postabla_No_Fuente) == ID);
                        id_fd_vd = obj.Edges.ID(idx_fdep_vd);
                        id_fd_id = obj.Edges.ID(idx_fdep_id);
                        md.islas.estacionario.No_Fuente.fuentes_dep = [circuito_cero_menos.fuentes_dep(id_fd_vd,:);...
                            circuito_cero_menos.fuentes_dep(id_fd_id,:)];
                    end

                    % Campo marcas_polaridad
                    if any(obj.Edges.NAT(postabla_No_Fuente) == LM)
                        md.islas.estacionario.No_Fuente.marcas_pol = circuito_cero_menos.marcas_pol;
                    end
                end
            end
            cont_igualW = 0;
            cont_difW = 0;
            cont_COS_igualW = 0;
            cont_COS_difW = 0;
            cont_DC = 0;
            cont_EXP = 0;
            cont_no_fuente = 0;
        end

        function obj = mr_auxiliar()  % Constructor
            obj.graficos = struct('estacionario',[],'conmutacion',[],'transitorio',[]);
            obj.graficos.estacionario = table();
            obj.graficos.transitorio = table();
            obj.graficos.conmutacion = struct('reducidoC',[],'reducidoL',[]);
            obj.impropiedades = struct('C',[],'L',[]);
            obj.tablas = struct('estacionario',[],'conmutacion',[],'transitorio',[]);
            obj.tablas.estacionario = struct('DC',[],'SIN',[],'COS',[],'EXP',[],'No_Fuente',[]);
            obj.tablas.estacionario.DC = table();
            obj.tablas.estacionario.SIN = struct('igual_W',[],'dif_W',[]);
            obj.tablas.estacionario.SIN.igual_W = table();
            obj.tablas.estacionario.SIN.dif_W = table();
            obj.tablas.estacionario.COS = struct('igual_W',[],'dif_W',[]);
            obj.tablas.estacionario.COS.igual_W = table();
            obj.tablas.estacionario.COS.dif_W = table();
            obj.tablas.estacionario.EXP = table();
            obj.tablas.estacionario.No_Fuente = table();
            obj.tablas.transitorio = table();
            obj.tablas.conmutacion = struct('reducidoC',[],'reducidoL',[]);
            obj.tablas.conmutacion.reducidoC.grafico = table();
            obj.tablas.conmutacion.reducidoC.nodos = table();
            obj.tablas.conmutacion.reducidoL.grafico = table();
            obj.tablas.conmutacion.reducidoL.nodos = table();
        end
        
        function obj = dibujar_graficos(obj, md, estados, opciones)
            
            tiene_ = find(estados == '_');
            if ~isempty(tiene_)

            else
                Estados = {estados};
            end

            if opciones.dibujar_graficos > 0
                for g = 1:numel(Estados)
                    obj = obj.dibujar_grafico_total(md, Estados{g});
                end                
                if opciones.dibujar_graficos > 1
                    for g = 1:numel(Estados)
                        obj = obj.dibujar_graficos_por_isla(md, Estados{g});
                    end
                end
            end
        end

        function obj = dibujar_grafico_total(obj, md , estado)
            % Metodo para construir un grafico de un circuito electrico en
            % cualquier estado de analisis (estacionario, transitorio,
            % conmutacion)
            %   Entradas:
            %		md (struct): estructura de datos donde se almacena
            %		toda la informacion correspondiente a un circuito
            %		electrico
            %       estado (char): cadena de caracteres para el estado de
            %       analisis ('estacionario', 'conmutacion', 'transitorio')
            %
            %	Salidas:
            %		Grafico del circuito de analisis, en color azul se
            %		pintan las ramas y en color rojo punteado se pintan los
            %		enlaces

            isla = {'DC','EXP','No_Fuente'};
            isla_w = {'SIN'};
            Frec = {'igual_W','dif_W'};
            switch estado
                case {'estacionario'}

                    for i = 1:numel(isla)
                        if ~isempty(md.elementos.(estado).(isla{i}).puertas)
                            for d = 1:numel(md.elementos.(estado).(isla{i}).puertas)
                                obj_elemento = md.elementos.(estado).(isla{i}).puertas{d};
                                Edges = obj_elemento.adicionar_rama_enlace(md,estado);

                                % Tabla que se le entrega al digraph de la posicion de los Edges
                                obj.graficos.(estado) = [obj.graficos.(estado); Edges];
                            end
                        end
                    end
                    for y = 1:numel(isla_w)
                        for w = 1:numel(Frec)
                            if ~isempty(md.elementos.(estado).(isla_w{y}).(Frec{w}).puertas)
                                for d=1:numel(md.elementos.(estado).(isla_w{y}).(Frec{w}).puertas)
                                    obj_elemento = md.elementos.(estado).(isla_w{y}).(Frec{w}).puertas{d};
                                    Edges = obj_elemento.adicionar_rama_enlace(md,estado);

                                    % Tabla que se le entrega al digraph de la posicion de los Edges
                                    obj.graficos.(estado) = [obj.graficos.(estado); Edges];
                                end
                            end
                        end
                    end
                    mr_Edges = obj.graficos.(estado);
                    G = digraph(mr_Edges);
                    ramas = G.Edges.Weights == 1;
                    enlaces = G.Edges.Weights == 2;

                    figure
                    E = plot(G,'EdgeLabel',G.Edges.Labels,'Layout','layered',"EdgeFontSize",18,...
                        "EdgeFontName",'Times New Roman',"EdgeLabelColor",'blue',"NodeLabel",G.Nodes.Name,...
                        "NodeLabelColor",'black',"NodeColor",'black',"NodeFontSize",12,"MarkerSize",...
                        8,"EdgeColor",'cyan',"LineWidth",1.5,"ArrowSize",17);
                    highlight(E,'Edges',ramas,'EdgeColor','blue',LineWidth=2,ArrowSize=10)
                    highlight(E,'Edges',enlaces,'EdgeColor','red','LineStyle','--',LineWidth=2,ArrowSize=10)
                    title('Gráfico en el Estado Estacionario')

                case {'transitorio'}
                    % >>>>>> --------------------------- <<<<<<
            end
        end

        function obj = dibujar_graficos_por_isla(obj, md, estado)
            % Funcion que construye un grafico dado un caso
            % estado sera un string (estacionario, conmutacion,transitorio)

            switch estado
                case {'estacionario'}
                    if  ~isempty(md.islas.(estado)) % Circuito isla DC
                        isla = {'DC','SIN','EXP','No_Fuente'};

                        % Grafico final que se mostrará al usuario
                        figure;

                        % Ciclo pata barrer entre las islas del estado estacionario
                        for i = 1:numel(isla)
                            obj.tablas.(estado).isla{i} = table();
                            if ~isempty(md.islas.(estado).(isla{i})) && (strcmp(isla{i},'SIN') || strcmp(isla{i},'COS'))
                                for p = 1:numel(md.islas.(estado).(isla{i}))
                                    Frec = {'igual_W','dif_W'};
                                    for w=1:numel(Frec)
                                        if ~isempty(md.islas.(estado).(isla{i}).(Frec{w})(p).puertas)
                                            for d = 1:size(md.islas.(estado).(isla{i}).(Frec{w})(p).puertas,1)
                                                obj_elemento = md.islas.(estado).(isla{i}).(Frec{w})(p).puertas(d,:);
                                                labels = md.islas.(estado).(isla{i}).(Frec{w})(p).nombre_puertas(d,:);
                                                EndNodes = [obj_elemento(1,2) obj_elemento(1,3)];
                                                Nodes = arrayfun(@(x) sprintf('%d',x),EndNodes,'UniformOutput', false);
                                                id = obj_elemento(1,1);
                                                nat = obj_elemento(1,4);
                                                val_p = obj_elemento(1,5);
                                                weight = obj_elemento(1,6);
                                                tabla_isla_senosuidal = table(Nodes,weight,id,labels,nat,val_p,'VariableNames', ...
                                                    {'EndNodes' 'Weights' 'ID' 'Labels' 'Nat' 'Val_P'});

                                                % Tabla que se le entrega al digraph de la posicion de los Edges
                                                obj.tablas.(estado).(isla{i}).(Frec{w}) = [obj.tablas.(estado).(isla{i}).(Frec{w}); tabla_isla_senosuidal];
                                            end
                                            mr_Edges = obj.tablas.(estado).(isla{i}).(Frec{w});
                                            G = digraph(mr_Edges);
                                            ramas = G.Edges.Weights == 1;
                                            enlaces = G.Edges.Weights == 2;
                                            subplot(ceil(length(isla)/2),2,i)
                                            E = plot(G,'EdgeLabel',G.Edges.ID,'Layout','layered',"EdgeFontSize",18,...
                                                "EdgeFontName",'Times New Roman',"EdgeLabelColor",'blue',"NodeLabel",G.Nodes.Name,...
                                                "NodeLabelColor",'black',"NodeColor",'black',"NodeFontSize",12,"MarkerSize",...
                                                8,"EdgeColor",'cyan',"LineWidth",1.5,"ArrowSize",17);
                                            highlight(E,'Edges',ramas,'EdgeColor','blue',LineWidth=2,ArrowSize=10)
                                            highlight(E,'Edges',enlaces,'EdgeColor','red','LineStyle','--',LineWidth=2,ArrowSize=10)
                                            title(sprintf('Figura %d: %s', i, isla{i}));
                                        end
                                    end
                                end
                            else
                                for p = 1:numel(md.islas.(estado).(isla{i}))
                                    if ~isempty(md.islas.(estado).(isla{i})(p).puertas)
                                        for d = 1:size(md.islas.(estado).(isla{i})(p).puertas,1)
                                            obj_elemento = md.islas.(estado).(isla{i})(p).puertas(d,:);
                                            labels = md.islas.(estado).(isla{i})(p).nombre_puertas(d,:);
                                            EndNodes = [obj_elemento(1,2) obj_elemento(1,3)];
                                            Nodes = arrayfun(@(x) sprintf('%d',x),EndNodes,'UniformOutput', false);
                                            id = obj_elemento(1,1);
                                            nat = obj_elemento(1,4);
                                            val_p = obj_elemento(1,5);
                                            weight = obj_elemento(1,6);
                                            tabla_isla = table(Nodes,weight,id,labels,nat,val_p,'VariableNames', ...
                                                {'EndNodes' 'Weights' 'ID' 'Labels' 'Nat' 'Val_P'});

                                            % Tabla que se le entrega al digraph de la posicion de los Edges
                                            obj.tablas.(estado).isla{i} = [obj.tablas.(estado).isla{i}; tabla_isla];
                                        end
                                        mr_Edges = obj.tablas.(estado).isla{i};
                                        G = digraph(mr_Edges);
                                        ramas = G.Edges.Weights == 1;
                                        enlaces = G.Edges.Weights == 2;
                                        subplot(ceil(length(isla)/2),2,i)
                                        E = plot(G,'EdgeLabel',G.Edges.ID,'Layout','layered',"EdgeFontSize",18,...
                                            "EdgeFontName",'Times New Roman',"EdgeLabelColor",'blue',"NodeLabel",G.Nodes.Name,...
                                            "NodeLabelColor",'black',"NodeColor",'black',"NodeFontSize",12,"MarkerSize",...
                                            8,"EdgeColor",'cyan',"LineWidth",1.5,"ArrowSize",17);
                                        highlight(E,'Edges',ramas,'EdgeColor','blue',LineWidth=2,ArrowSize=10)
                                        highlight(E,'Edges',enlaces,'EdgeColor','red','LineStyle','--',LineWidth=2,ArrowSize=10)
                                        title(sprintf('Figura %d: %s', i, isla{i}));
                                    end
                                end
                            end

                        end
                    end
                case {'transitorio'}
            end
        end
    end
end





