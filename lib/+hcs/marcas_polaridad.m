classdef marcas_polaridad < handle
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
        id_marca
        id_puerta_1_acoplada
        id_puerta_2_acoplada
        id_terminal_1_acoplada
        id_terminal_2_acoplada
        parametro 
    end
    
    methods
        function obj = marcas_polaridad(obj)
            % Constructor
        end
    end
end