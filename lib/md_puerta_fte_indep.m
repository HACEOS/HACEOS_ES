classdef md_puerta_fte_indep < hcs.md_puerta
% md_puerta_fte_indep - Subclase para fuentes independientes
%
% Esta subclase se encarga de asignar el objeto de tipo puerta
% independiente, hereda de la superclase md_puerta
%
% Propiedades de md_puerta_fte_indep:
%	* tipo_senal - 
%   * tipo_fuente -
%
% Metodos de md_puerta_fte_indep:
%	 
%
% See also md_puerta, formato_caso

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
        tipo_senal              % CTE, EXP, SIN, COS
        tipo_fuente             % Voltaje (VI) o corriente (II)
    end

    methods
        function obj = Puertas_v_i(tipo,senal,id) % Constructor
            obj.parametro = senal; 
            obj.tipo_de_senal = tipo;
            obj.id = id;
        end
    end
end