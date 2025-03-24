function opciones = hcs_opciones(varargin)
% HCS_OPCIONES - gestiona todas las opciones disponibles en la herramienta HACEOS para 
% personalizar su funcionamiento.

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

    if nargin > 0
        opt1 = varargin{1};
        if isstruct(opt1)
    
        elseif isstring(opt1) || ischar(opt1)
            nparejas = numel(varargin);
            if rem(nparejas,2) ~= 0
                error('hcs_opciones: las entradas de esta funcion pueden ser parejas (propiedad, valor). Una pareja esta incompleta.')
            else
                nopt = nparejas / 2;
                opt = struct();
                for c = 1:nopt
                    campo = varargin{2*c-1};
                    valor = varargin{2*c};
                    [opt_ok, mensaje, valor] = validar_opcion(campo, valor);
                    if opt_ok
                        opt.(campo) = valor;
                    else
                        error(mensaje);
                    end
                end
                [vpd, todos_los_campo] = valores_por_defecto;
                opciones_usuario = fieldnames(opt);
                campos_presentes = ismember(todos_los_campo, opciones_usuario);
                opciones_faltantes = todos_los_campo(~campos_presentes);
                if ~isempty(opciones_faltantes)
                    for c = 1:numel(opciones_faltantes)
                        opt.(opciones_faltantes{c}) = vpd.(opciones_faltantes{c});
                    end
                end
            end
            opciones = opt;
        end
    else
        opciones = valores_por_defecto;
    end    
end

function [vpd, cpd] = valores_por_defecto()
    vpd = struct('estado_de_analisis', 'estacionario', ...
                 'dibujar_graficos', 0);
    if nargout > 1
        cpd = fieldnames(vpd);
    end    
end

function [resultado, mensaje, nuevo_valor] = validar_opcion(campo, valor)
    nuevo_valor = valor;
    switch campo
        case {'estado_de_analisis'}
            if ~isstring(valor) && ~ischar(valor)
                resultado = false;
                msm = ' la opcion ''estado_de_analisis'' debe ser un valor tipo char o tipo string.';
            else
                nuevo_valor = char(valor);
                if ismember(nuevo_valor, {'estacionario','conmutacion','transitorio','estacionario_conmutacion', ...
                                          'conmutacion_estacionario','conmutacion_transitorio', ...
                                          'transitorio_conmutacion','completo'})
                    resultado = true;
                    msm = ' valor correcto';
                else
                    resultado = false;
                    msm = sprintf(':estado_de_analisis: ''%s'' no es una opcion valida.', nuevo_valor);
                end
            end
        case {'dibujar_graficos'}
            if ~ismember(valor, [0 1 2])
                resultado = false;
                msm = ' la opcion ''dibujar_graficos'' debe ser 0, 1 o 2.';
            else
                resultado = true;
                msm = ' valor correcto';
            end
        otherwise
            resultado = false;
            msm = sprintf(' ''%s'' no es una opcion valida.', campo);
    end

    mensaje = ['hcs_opciones:' msm];
end