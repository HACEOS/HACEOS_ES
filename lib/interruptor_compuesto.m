classdef interruptor_compuesto < hcs.interruptor
% md_estacionario - Subclase para administrar el modelo de datos
% en el estado estacionario.
%
% Esta subclase se encarga de separar y clasificar la información de un
% caso (circuito) segun su fuente de excitacion en estructuras de datos,
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
% See also md_transitorio, md_conmutacion, md_completo, 
% md_estacionario_transitorio, md_estacionario_conmutacion

%   HACEOS - Herramienta para el Analisis de Circuitos Electricos de Orden Superior
%   Copyright (c) 2022-2025, Grupo de Investigacion en Campos Electromagneticos y Fenomenos Energeticos - CAFE
%						     Universidad Tecnologica de Pereira (UTP)
%  	Por: Brandon Ospina y Brian Gordon, CAFE-UTP
%   y Wilson Gonzalez Vanegas, Universidad Nacional de Colombia Sede Manizales y CAFE-UTP
%
%   Este archivo es parte del proyecto HACEOS.
%   Cubierto por la licencia 3-clause BSD (mas detalles en el archivo LICENSE).
%   Vea https://github.com/HACEOS/ para mayor informacion.
% 	
%   Nota: este archivo es libre de tildes para evitar posibles conflictos en sistemas sin codificacion UTF-8

    properties
        id
        term0
        term1
        term2
        estado
    end

    methods
        function caso_nuevo = conmutar(obj,caso)
            [~,~,~,ESTADO] = id_col_interruptores;
            if obj.estado == 1
               obj.estado = 0;
            elseif obj.estado == 0
               obj.estado = 1;
            end
            caso_nuevo = caso;
            caso_nuevo.interruptores{obj.id,ESTADO}(1) = obj.estado;
        end
        function [caso_nuevo,memoria] = evaluar(obj,caso,memoria)
            [~,N_ENV,N_REC] = id_col_puertas;
            [~,N_MARCADO_L1,~,N_MARCADO_L2] = id_col_marcas;
            [~,~,N_INT,~] = id_col_interruptores;
            caso_nuevo = caso;
            if obj.estado == 1 
                nodo_menor = min(obj.term0,obj.term1);
                nodo_mayor = max(obj.term0,obj.term1); 
                if ismember(nodo_mayor,memoria)||ismember(nodo_menor,memoria)
                    memoria = [memoria;[nodo_menor; nodo_mayor]];
                    nodo_menor = min(memoria);
                end
                enc = find(nodo_mayor == caso_nuevo.nodos(:,1));
                caso_nuevo.nodos(enc,:) = [];
                caso_nuevo.nombre_nodos(enc) = [];
                cols_nueva_p = caso_nuevo.puertas(:,[N_ENV N_REC]);
                cols_nueva_p(cols_nueva_p==nodo_mayor) = min(memoria);
                caso_nuevo.puertas(:,[N_ENV N_REC]) = cols_nueva_p;
                cols_nueva_mp = caso_nuevo.marcas_pol(:,[N_MARCADO_L1 N_MARCADO_L2]);
                cols_nueva_mp(cols_nueva_mp==nodo_mayor) = min(memoria);
                caso_nuevo.marcas_pol(:,N_MARCADO_L1) = cols_nueva_mp(:,1);
                caso_nuevo.marcas_pol(:,N_MARCADO_L2) = cols_nueva_mp(:,2);
                
            elseif obj.estado == 0
                nodo_menor = min(obj.term0,obj.term2);
                nodo_mayor = max(obj.term0,obj.term2);
                if ismember(nodo_mayor,memoria)||ismember(nodo_menor,memoria)
                    memoria = [memoria;[nodo_menor; nodo_mayor]];
                    nodo_menor = min(memoria);
                end
                enc = find(nodo_mayor==caso_nuevo.nodos(:,1));
                caso_nuevo.nodos(enc,:)=[];
                caso_nuevo.nombre_nodos(enc)=[];
                cols_nueva_p=caso_nuevo.puertas(:,[N_ENV N_REC]);
                cols_nueva_p(cols_nueva_p==nodo_mayor) = nodo_menor;
                caso_nuevo.puertas(:,[N_ENV N_REC])=cols_nueva_p;
                cols_nueva_mp = caso_nuevo.marcas_pol(:,[N_MARCADO_L1 N_MARCADO_L2]);
                cols_nueva_mp(cols_nueva_mp==nodo_mayor) = nodo_menor;
                caso_nuevo.marcas_pol(:,N_MARCADO_L1)=cols_nueva_mp(:,1);
                caso_nuevo.marcas_pol(:,N_MARCADO_L2)=cols_nueva_mp(:,2);
            end
            for int = 1:size(caso_nuevo.interruptores,1)
                enc = (nodo_mayor == caso_nuevo.interruptores{int,N_INT});
                nodos = caso_nuevo.interruptores{int,N_INT};
                nodos(enc) = nodo_menor;
                caso_nuevo.interruptores{int,N_INT} = nodos;
            end
        end
    end
end