classdef modelo_red < handle


    properties
        graficos_no_orientados
        graficos_orientados
        id_islas
    end

    methods
        function obj = modelo_red()
            es = struct('estacionario', [], ...
                        'conmutacion', [], ...
                        'transitorio', []);
            obj.graficos_no_orientados = struct('originales', es, ...
                                             'depurados',  es);
            obj.graficos_orientados = obj.graficos_no_orientados;

            obj.id_islas = struct('tipo', [], 'id_nodos', []);
        end

        function [gno_original, gno_depurado] = detectar_elementos_energizados(obj, circuito_original)
            % Metodo para obtener los elementos definitivos que se analizan
            % en el circuito de cero menos
            %
            %   Entradas:
            %		circuito_total (struct): estructura de datos donde
            %       se almacena toda la informacion correspondiente a un
            %       circuito electrico
            %   Salidas:
            %       id_elementos (double): vector de identificadores el
            %       cual tiene los id's de las puertas energizadas en cero
            %       menos
            %       id_marcas (double): vector de identifcadores de
            %       inductancias energizadas en cero menos
            
            % Extraer informacion del caso
            ID_NODO = id_col_nodos;
            [ID_P,N_ENV,N_REC,NAT_P,VAL_P,TIPO_P] = id_col_puertas;
            [~,~,~,LM] = id_col_caso;
            id_puertas = circuito_original.puertas(:,ID_P);
            id_nodo_envio = circuito_original.puertas(:,N_ENV);
            id_nodo_recibo  = circuito_original.puertas(:,N_REC);
            [~, id_nombre_nodo_envio] = ismember(id_nodo_envio, circuito_original.nodos(:,ID_NODO)); 
            [~, id_nombre_nodo_recibo] = ismember(id_nodo_recibo, circuito_original.nodos(:,ID_NODO));
            string_nodo_envio = circuito_original.nombre_nodos(id_nombre_nodo_envio);
            string_nodo_recibo = circuito_original.nombre_nodos(id_nombre_nodo_recibo);
            tipo  = circuito_original.puertas(:,TIPO_P);
            nat  = circuito_original.puertas(:,NAT_P);
            nombre_puertas = circuito_original.nombre_puertas;
            valor_puerta = circuito_original.puertas(:,VAL_P);

            % Se realiza la adicion de la columna NAT para saber si el
            % elemento es de naturaleza RLC o LM
            tabla_grafo = table([string_nodo_envio, string_nodo_recibo], ...
                                   tipo, ...
                                   nombre_puertas, ...
                                   id_puertas,nat, ...
                                   valor_puerta,...
                                   'VariableNames', {'EndNodes' 'Weights' 'Labels' 'ID' 'NAT' 'VAL_P'});
            
            % Construir grafico no orientado del circuito original
            gno_original = graph(tabla_grafo);
            
            % Detectar elementos biconectados 
            etiquetas_islas = biconncomp(gno_original, 'OutputForm', 'cell');

            % Constuir grafico conectado depurado
            gno_depurado = gno_original;
            for i = 1:numel(etiquetas_islas)  % remover aristas
                subgrafico = subgraph(gno_original, etiquetas_islas{i});
                if ~hascycles(subgrafico)
                   gno_depurado = gno_depurado.rmedge(subgrafico.Nodes.Name{:});
                end
            end
            
            % Remover nodos aislados
            [isla, dim_isla] = conncomp(gno_depurado);
            id_nodos_aislados = dim_isla(isla) == 1;
            if any(id_nodos_aislados)
                gno_depurado = gno_depurado.rmnode(gno_original.Nodes.Name(id_nodos_aislados));
            end
        end

        function obj = detectar_islas(obj, gno_depurado)
            [R,~,~,~,VI,II,~,~,CTE,SIN,~,EXP] = id_col_caso;
            % gno: grafico no orientado

            % Detectar elementos biconectados 
            etiquetas_islas = biconncomp(gno_depurado, 'OutputForm', 'cell');
            
            % Inicializar estructuras vacias
            obj.id_islas(1:numel(etiquetas_islas)) = obj.id_islas;

            % Barrer cada subgrafico e identificar el tipo de isla
            segmentos = {};
            for i = 1:numel(etiquetas_islas) 
                subgrafico = subgraph(gno_depurado, etiquetas_islas{i});
                obj.id_islas(i).id_nodos = etiquetas_islas{i};
                if any(subgrafico.Edges.NAT == VI) || any(subgrafico.Edges.NAT == II)
                    nat_fuente = subgrafico.Edges.VAL_P;    
                    for v = 1:length(nat_fuente)
                        num = nat_fuente(v);
                        switch num
                            case CTE
                                segmentos{end+1} = 'DC';
                            case SIN
                                segmentos{end+1} = 'SIN';
                            case EXP
                                segmentos{end+1} = 'EXP';
                        end
                    end
                    if isempty(segmentos)
                        cadena = 'NoFuente'; 
                    else
                        cadena = strjoin(segmentos, '_');
                    end
                    obj.id_islas(i).tipo = cadena;
                end
                if isempty(segmentos)
                    cadena = 'NoFuente';
                    obj.id_islas(i).tipo = cadena;
                end
                if ~isempty(find(cadena == '_'))
                    cadena = 'Combinada';
                    obj.id_islas(i).tipo = cadena;
                end
                cadena = '';
                segmentos = {};
            end
        end

        function md_islas = grafico_a_islas(obj, circuito_original, gno_depurado)
            %
            
            
            % Inicializacion de estructura e indices de columna
            [~,ID_L1,~,ID_L2] = id_col_marcas;
            st = struct();
            md_islas = struct('DC',         st,...
                              'SIN',         st,...
                              'EXP',        st,...
                              'NoFuente',   st,...
                              'Combinada',  st);

            % Rutina de exportacion principal
            for i = 1:numel(obj.id_islas)
                % Recordar cambiar la variable iteradora de cada capa por 
                % una nueva variable
                

                if isempty(fieldnames(md_islas.(obj.id_islas(i).tipo)))
                    ni = 1;
                else
                    ni = numel(md_islas.(obj.id_islas(i).tipo)) + 1;
                end

                % Extraer subgrafico asociado a la i-esima isla
                subgrafico = subgraph(gno_depurado, obj.id_islas(i).id_nodos);

                % =================== Campo nodos =========================
                [~, id_nodos] = ismember(subgrafico.Nodes.Name, circuito_original.nombre_nodos);
                md_islas.(obj.id_islas(i).tipo)(ni).nodos = circuito_original.nodos(id_nodos,:);
                                
                % ================ Campo nombre_nodos =====================
                md_islas.(obj.id_islas(i).tipo)(ni).nombre_nodos = subgrafico.Nodes.Name;
                
                % =================== Campo puertas ======================
                [~,ids] = ismember(subgrafico.Edges.ID,circuito_original.puertas(:,1));
                md_islas.(obj.id_islas(i).tipo)(ni).puertas = circuito_original.puertas(ids,:);
                
                % =============== Campo nombre_puertas ====================
                if isempty(circuito_original.nombre_puertas)
                    md_islas.(obj.id_islas(i).tipo)(ni).nombre_puertas = [];
                else
                    md_islas.(obj.id_islas(i).tipo)(ni).nombre_puertas = ...
                        circuito_original.nombre_puertas(ids,:);
                end
                
                
                % ================= Campo fuentes_ind =====================
                if isempty(circuito_original.fuentes_ind)
                    md_islas.(obj.id_islas(i).tipo)(ni).fuentes_ind = [];
                else
                    p = [];
                    md_islas.(obj.id_islas(i).tipo)(ni).fuentes_ind = [];
                    for z = 1:numel(subgrafico.Edges.ID)
                       for y = 1:size(circuito_original.fuentes_ind,1)
                           if circuito_original.fuentes_ind{y} == subgrafico.Edges.ID(z)
                               md_islas.(obj.id_islas(i).tipo)(ni).fuentes_ind...
                                   = circuito_original.fuentes_ind(y,:);
                           end
                       end
                    end
                end
                
                
                % ================== Campo fuentes_dep ====================
                if isempty(circuito_original.fuentes_dep)
                    md_islas.(obj.id_islas(i).tipo)(ni).fuentes_dep = [];
                else
                    p = [];
                    md_islas.(obj.id_islas(i).tipo)(ni).fuentes_dep = [];
                    for z = 1:numel(subgrafico.Edges.ID)
                       p = [find(circuito_original.fuentes_dep(:,1) == subgrafico.Edges.ID(z));p];
                    end
                    md_islas.(obj.id_islas(i).tipo)(ni).fuentes_dep = ... 
                        circuito_original.fuentes_dep;
                end
                
                % ================= Campo marcas_pol ======================
                if isempty(circuito_original.marcas_pol)
                    md_islas.(obj.id_islas(i).tipo)(ni).marcas_pol = [];
                else
                    p = [];
                    md_islas.(obj.id_islas(i).tipo)(ni).marcas_pol = [];
                    for z = 1:numel(subgrafico.Edges.ID)
                       for w = 1:size(circuito_original.marcas_pol,1)
                           if any(circuito_original.marcas_pol(w,ID_L1) == subgrafico.Edges.ID(z))...
                           || any(circuito_original.marcas_pol(w,ID_L2) == subgrafico.Edges.ID(z))
                               md_islas.(obj.id_islas(i).tipo)(ni).marcas_pol...
                                   = circuito_original.marcas_pol(w,:);
                               break
                           end
                       end
                    end
                end
                % =========================================================

                % Guardar md_islas en el objeto del modelo de datos
            end
        end

        function grafico_orientado = crear_grafico_orientado(obj, grafico_no_orientado)
            grafico_orientado = digraph(grafico_no_orientado.Edges);
        end

        function dibujar_graficos(obj,estados,opciones)
            tiene_ = find(estados == '_');
            if ~isempty(tiene_)
                % Partir el "_" y obtener los elementos por separado
                % armar estados por aparte
            else
                Estados = {estados};
            end

            if opciones.dibujar_graficos < 3
                if opciones.dibujar_graficos > 0
                    for g = 1:numel(Estados)
                        obj.dibujar_grafico_total(Estados{g},'gno');
                    end
                    if opciones.dibujar_graficos > 1
                        for g = 1:numel(Estados)
                            obj.dibujar_graficos_por_isla(Estados{g},'gno');
                        end
                    end
                end
            else
                if opciones.dibujar_graficos > 2
                    for g = 1:numel(Estados)
                        obj.dibujar_grafico_total(Estados{g},'go');
                    end
                    if opciones.dibujar_graficos > 3
                        for g = 1:numel(Estados)
                            obj.dibujar_graficos_por_isla(Estados{g},'gno');
                        end
                    end
                end
            end
        end
        
        function dibujar_grafico_total(obj,estado,tipo_grafico)
            if strcmp(tipo_grafico,'go')
                figure;
                G1 = obj.graficos_orientados.originales.(estado);
                ramas = G1.Edges.Weights == 1;
                enlaces = G1.Edges.Weights == 2;
                E = plot(G1,'EdgeLabel',G1.Edges.Labels,'Layout','layered',"EdgeFontSize",18,...
                        "EdgeFontName",'Times New Roman',"EdgeLabelColor",'blue',"NodeLabel",G1.Nodes.Name,...
                        "NodeLabelColor",'black',"NodeColor",'black',"NodeFontSize",12,"MarkerSize",...
                        8,"EdgeColor",'cyan',"LineWidth",1.5);
                    highlight(E,'Edges',ramas,'EdgeColor','blue',LineWidth=2)
                    highlight(E,'Edges',enlaces,'EdgeColor','red','LineStyle','--',LineWidth=2)
                    highlight(E,'Edges',enlaces,'EdgeLabelColor','red')
                    title('Estado estacionario completo')
                figure;
                G2 = obj.graficos_orientados.depurados.(estado);
                ramas = G2.Edges.Weights == 1;
                enlaces = G2.Edges.Weights == 2;
                E = plot(G2,'EdgeLabel',G2.Edges.Labels,'Layout','layered',"EdgeFontSize",18,...
                        "EdgeFontName",'Times New Roman',"EdgeLabelColor",'blue',"NodeLabel",G2.Nodes.Name,...
                        "NodeLabelColor",'black',"NodeColor",'black',"NodeFontSize",12,"MarkerSize",...
                        8,"EdgeColor",'cyan',"LineWidth",1.5);
                    highlight(E,'Edges',ramas,'EdgeColor','blue',LineWidth=2)
                    highlight(E,'Edges',enlaces,'EdgeColor','red','LineStyle','--',LineWidth=2)
                    highlight(E,'Edges',enlaces,'EdgeLabelColor','red')
                    title('Estado estacionario depurado')
            else
                figure;
                G1 = obj.graficos_no_orientados.originales.(estado);
                ramas = G1.Edges.Weights == 1;
                enlaces = G1.Edges.Weights == 2;
                E = plot(G1,'EdgeLabel',G1.Edges.Labels,'Layout','layered',"EdgeFontSize",18,...
                        "EdgeFontName",'Times New Roman',"EdgeLabelColor",'blue',"NodeLabel",G1.Nodes.Name,...
                        "NodeLabelColor",'black',"NodeColor",'black',"NodeFontSize",12,"MarkerSize",...
                        8,"EdgeColor",'cyan',"LineWidth",1.5);
                    highlight(E,'Edges',ramas,'EdgeColor','blue',LineWidth=2)
                    highlight(E,'Edges',enlaces,'EdgeColor','red','LineStyle','--',LineWidth=2)
                    highlight(E,'Edges',enlaces,'EdgeLabelColor','red')
                    title('Estado estacionario completo')
                figure;
                G2 = obj.graficos_no_orientados.depurados.(estado);
                ramas = G2.Edges.Weights == 1;
                enlaces = G2.Edges.Weights == 2;
                E = plot(G2,'EdgeLabel',G2.Edges.Labels,'Layout','layered',"EdgeFontSize",18,...
                        "EdgeFontName",'Times New Roman',"EdgeLabelColor",'blue',"NodeLabel",G2.Nodes.Name,...
                        "NodeLabelColor",'black',"NodeColor",'black',"NodeFontSize",12,"MarkerSize",...
                        8,"EdgeColor",'cyan',"LineWidth",1.5);
                    highlight(E,'Edges',ramas,'EdgeColor','blue',LineWidth=2)
                    highlight(E,'Edges',enlaces,'EdgeColor','red','LineStyle','--',LineWidth=2)
                    highlight(E,'Edges',enlaces,'EdgeLabelColor','red')
                    title('Estado estacionario depurado')
            end
        end

        function dibujar_graficos_por_isla(estados,tipo_grafico)
            obj.id_islas.id_nodos
        end
    end
end