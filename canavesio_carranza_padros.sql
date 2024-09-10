/*1.Mostrar el DNI, nombre y apellido de los clientes que hayan traído más de un vehículo distinto al taller durante el mes de mayo/24. Incluir en el listado nombre y apellido del cliente, marca y modelo del vehículo y el nombre y apellido del mecánico responsable en cada caso. */

SELECT C.DNI, C.Nombre, C.Apellido, V.Marca, V.Modelo, M.Nombre, M.Apellido, R.fecha_ingreso
FROM INGRESA_PARA R, 
CLIENTE C, 
VEHICULO V, 
MECANICO M, 
SERVICIO S
WHERE 
(R.Fecha_ingreso BETWEEN '01-05-2024' AND '31-05-2024') AND
R.DNI_Cliente=C.DNI AND 
R.Matricula_Vehiculo=V.Matricula AND 
R.ID_Servicio=S.ID_Servicio AND 
S.dni_Mecanico_Encargado=M.DNI
GROUP BY C.DNI, C.Nombre, C.Apellido, V.Marca, V.Modelo, M.Nombre, M.Apellido, R.fecha_ingreso
HAVING COUNT(Matricula_Vehiculo)>1

/*2. Mostrar el nombre y apellido de los mecánicos y la cantidad total de servicios programados que realizó a vehículos de la marca Ford. */

/* La siguiente consulta solo arroja los mecanicos que tienen al menos 1 servicio programado con vehículo de la marca Ford*/

/*SELECT nombre, apellido, count(id_servicio_programado) cantidad
FROM (
SELECT SP.id_servicio_programado, S.id_servicio, M.*
FROM mecanico M
INNER JOIN servicio S ON S.dni_mecanico_encargado = M.dni
INNER JOIN servicio_programado SP ON SP.id_servicio = S.id_servicio
UNION
SELECT SP.id_servicio_programado, SP.id_servicio, M.*
FROM mecanico M
INNER JOIN detalle_service DS ON DS.dni_mecanico_especializado = M.dni
INNER JOIN servicio_programado SP ON SP.id_servicio_programado = DS.id_servicio_programado
) C1
INNER JOIN ingresa_para IP ON IP.id_servicio = C1.id_servicio
INNER JOIN vehiculo V ON V.matricula = IP.matricula_vehiculo
WHERE V.marca = 'Ford'
GROUP BY C1.dni, C1.nombre, C1.apellido*/

/* La siguiente muestra todos los mecánicos aunque su cantidad sea 0 */
SELECT nombre, apellido, COUNT(CASE WHEN V.marca = 'Ford' THEN C1.id_servicio_programado ELSE NULL END) AS cantidad
FROM (
    SELECT SP.id_servicio_programado, S.id_servicio, M.*
    FROM mecanico M
    INNER JOIN servicio S ON S.dni_mecanico_encargado = M.dni
    INNER JOIN servicio_programado SP ON SP.id_servicio = S.id_servicio
    UNION
    SELECT SP.id_servicio_programado, SP.id_servicio, M.*
    FROM mecanico M
    INNER JOIN detalle_service DS ON DS.dni_mecanico_especializado = M.dni
    INNER JOIN servicio_programado SP ON SP.id_servicio_programado = DS.id_servicio_programado
) C1
INNER JOIN ingresa_para IP ON IP.id_servicio = C1.id_servicio
INNER JOIN vehiculo V ON V.matricula = IP.matricula_vehiculo
GROUP BY C1.dni, C1.nombre, C1.apellido;


/* 3. Listar la matrícula de los vehículos que están en proceso de reparación y las tareas que hay que realizarle y los repuestos que necesitan. (Considerar un atributo fecha de entrega en el servicio de reparación).*/ 
SELECT ip.matricula_vehiculo, t.id_tarea, pn.id_repuesto
FROM reparacion r, 
tarea t, 
plan_de_accion pa, 
detalle_plan_de_accion dpa, 
puede_necesitar pn, 
ingresa_para ip, 
confecciona c
WHERE r.fecha_entrega>NOW() AND 
r.id_reparacion=c.id_reparacion AND 
c.id_plan_de_accion=pa.id_plan_de_accion AND 
pa.id_plan_de_accion=dpa.id_plan_de_accion AND 
dpa.id_tarea=t.id_tarea AND 
t.id_tarea=pn.id_tarea AND 
ip.id_servicio=r.id_servicio

/* 4. Mostrar los nombres y apellidos de los mecánicos que han sido responsables de servicios de reparación, y que también han sido responsables de servicios programados. */

SELECT dni, nombre, apellido
FROM mecanico M
INNER JOIN detalle_service DS ON DS.dni_mecanico_especializado = M.dni

INTERSECT

SELECT dni, nombre, apellido
FROM mecanico M
INNER JOIN detalle_plan_de_accion DPA ON DPA.dni_mecanico_especializado = M.dni


/* 5. Encontrar el mecánico especialista que ha sido asignado para realizar tareas en más de 5 servicio programado distintos. */

SELECT dni, nombre, apellido
FROM mecanico M
INNER JOIN detalle_service DS ON DS.dni_mecanico_especializado = M.dni
GROUP BY M.dni, M.nombre, M.apellido
HAVING count(distinct DS.id_servicio_programado) >= 5

/* 6. Mostrar DNI cliente, matrícula del vehículo, de la reparación con mayor cantidad de tareas que se hubiera realizado alguna vez.*/
SELECT ip.matricula_vehiculo, ip.dni_cliente, r.id_reparacion
FROM ingresa_para ip, 
reparacion r, 
confecciona c, 
plan_de_accion pa, 
detalle_plan_de_accion dpa
WHERE ip.id_servicio=r.id_servicio AND 
r.id_reparacion=c.id_reparacion AND 
c.id_plan_de_accion=pa.id_plan_de_accion AND 
pa.id_plan_de_accion=dpa.id_plan_de_accion 
GROUP BY r.id_reparacion, ip.matricula_vehiculo, ip.dni_cliente
HAVING COUNT (*) >= all (SELECT COUNT (*)
			FROM ingresa_para ip, 
                        reparacion r, 
                        confecciona c, 
                        plan_de_accion pa, 
                        detalle_plan_de_accion dpa
			WHERE ip.id_servicio=r.id_servicio AND 
                        r.id_reparacion=c.id_reparacion AND 
                        c.id_plan_de_accion=pa.id_plan_de_accion AND 
                        pa.id_plan_de_accion=dpa.id_plan_de_accion 
			GROUP BY r.id_reparacion) 

/* 7. Listar mecánicos que han participado en al menos una tarea en cada uno de
los servicios programados realizados en el 2024. */

SELECT DISTINCT M.*,IP.fecha_ingreso FROM mecanico M 
JOIN detalle_service DS ON M.dni=DS.dni_mecanico_especializado
JOIN servicio_programado SP ON DS.id_servicio_programado=SP.id_servicio_programado
JOIN servicio S ON SP.id_servicio=S.id_servicio
JOIN ingresa_para IP ON S.id_servicio=IP.id_servicio
WHERE EXTRACT(YEAR FROM IP.fecha_ingreso)=2024 

/* 8. Realizar una nómina de clientes indicando id, nombre y dirección, cantidad de
vehículos traídos a reparación y cantidad de vehículos traídos a servicios
programados en los últimos 3 meses. Tener en cuenta que los clientes que no
han tenido ingresos de vehículos en el período deben figurar con cantidad 0.
 */
SELECT C.dni, C.nombre, C.direccion, COALESCE(R.cantidad_reparados, 0) AS cantidad_reparados, COALESCE(SP.cantidad_programados, 0) AS cantidad_programados
FROM cliente C
LEFT JOIN 
         (SELECT IP.dni_cliente, COUNT(*) AS cantidad_reparados
          FROM ingresa_para IP
          JOIN servicio S ON IP.id_servicio = S.id_servicio
          JOIN reparacion R ON S.id_servicio = R.id_servicio
          WHERE  IP.fecha_ingreso >= NOW() - INTERVAL '3 months'
          GROUP BY IP.dni_cliente) R ON C.dni = R.dni_cliente
LEFT JOIN 
         (SELECT IP.dni_cliente, COUNT(*) AS cantidad_programados
          FROM ingresa_para IP
          JOIN servicio S ON IP.id_servicio = S.id_servicio
          JOIN servicio_programado SP ON S.id_servicio = SP.id_servicio
          WHERE IP.fecha_ingreso >= NOW() - INTERVAL '3 months'
          GROUP BY IP.dni_cliente) SP ON C.dni = SP.dni_cliente



