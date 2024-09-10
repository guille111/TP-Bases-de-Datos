create table Cliente (
	DNI VARCHAR(50) PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	direccion VARCHAR(50) NOT NULL,
	telefono VARCHAR(50)
);

create table Vehiculo (
	matricula VARCHAR(50) PRIMARY KEY,
	marca VARCHAR(50) NOT NULL,
	modelo VARCHAR(50) NOT NULL,
	color VARCHAR(50) NOT NULL,
	kilometraje INT NOT NULL,
	tipo_de_combustible VARCHAR(50) NOT NULL
);

create table Especialidad (
    tipo_especialidad VARCHAR(50) PRIMARY KEY
);

create table Mecanico (
	DNI VARCHAR(50) PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	telefono VARCHAR(50),
	tipo_especialidad VARCHAR(50) REFERENCES Especialidad(tipo_especialidad)
);

create table Servicio (
	id_servicio INT PRIMARY KEY,
	dni_mecanico_encargado VARCHAR(50) REFERENCES Mecanico(DNI)
);

create table Reparacion (
	id_reparacion INT PRIMARY KEY,
	diagnostico TEXT NOT NULL,
    fecha_entrega DATE NOT NULL,
	id_servicio INT REFERENCES Servicio(id_servicio)
);

create table Service (
    id_service INT PRIMARY KEY,
    kilometros INT NOT NULL,
    tipo_de_combustible VARCHAR(9) NOT NULL
);

create table Servicio_Programado (
	id_servicio_programado INT PRIMARY KEY,
	descripcion TEXT,
	tiempo_estimado INT NOT NULL,
	costo DECIMAL(10,2) NOT NULL,
	id_servicio INT REFERENCES Servicio(id_servicio),
    id_service INT REFERENCES Service(id_service)
);

create table Tarea (
	id_tarea INT PRIMARY KEY,
	tiempo_estimado INT NOT NULL,
	costo DECIMAL(9,2) NOT NULL
);

create table Plan_De_Accion (
    id_plan_de_accion INT PRIMARY KEY,
    tipo_plan_de_accion VARCHAR(19) NOT NULL
);
create table Detalle_Plan_De_Accion (
    orden INT,
    tiempo_estimado INT,
    tiempo_final INT,
    retardo INT,
    id_plan_de_accion INT REFERENCES Plan_De_Accion(id_plan_de_accion),
    id_tarea INT REFERENCES Tarea(id_tarea),
    dni_mecanico_especializado VARCHAR(50) REFERENCES Mecanico(DNI),
    PRIMARY KEY (orden, id_plan_de_accion)
);

create table Detalle_Service (
    orden INT,
    tiempo_estimado INT,
    tiempo_final INT,
    retardo INT,
    id_servicio_programado INT REFERENCES Servicio_Programado(id_servicio_programado),
    id_service INT REFERENCES Service(id_service),
    id_tarea INT REFERENCES Tarea(id_tarea),
    dni_mecanico_especializado VARCHAR(50) REFERENCES Mecanico(DNI),
    PRIMARY KEY (orden, id_servicio_programado, id_service)
);

create table Repuesto (
	id_repuesto INT PRIMARY KEY,
	descripcion TEXT,
	marca VARCHAR(50) NOT NULL,
	precio DECIMAL(9,2) NOT NULL
);

create table Proveedor (
	id_proveedor INT PRIMARY KEY,
	razon_social VARCHAR(50) NOT NULL,
	domicilio VARCHAR(50) NOT NULL,
	ciudad VARCHAR(50) NOT NULL,
	telefono VARCHAR(50)
);

create table Pedido (
	id_pedido INT PRIMARY KEY,
	fecha DATE NOT NULL,
	cantidad INT NOT NULL,
	tiempo_de_espera INT,
	id_repuesto INT   REFERENCES Repuesto(id_repuesto),
	id_proveedor INT   REFERENCES Proveedor(id_proveedor)
);

create table Ingresa_Para (
	matricula_vehiculo VARCHAR(50)   REFERENCES Vehiculo(matricula),
	id_servicio INT   REFERENCES Servicio(id_servicio),
	dni_cliente VARCHAR(50)   REFERENCES Cliente(DNI),
	fecha_ingreso DATE NOT NULL,
    hora_ingreso TIME NOT NULL,
    PRIMARY KEY (matricula_vehiculo, id_servicio, dni_cliente)
);

create table Confecciona (
    id_reparacion INT  REFERENCES Reparacion(id_reparacion),
    id_plan_de_accion INT  REFERENCES Plan_De_Accion(id_plan_de_accion),
    dni_mecanico VARCHAR(50)  REFERENCES Mecanico(DNI),
    PRIMARY KEY (id_reparacion, id_plan_de_accion, dni_mecanico)
);

create table Compuesta_Por (
    id_service INT   REFERENCES Service(id_service),
    id_tarea INT   REFERENCES Tarea(id_tarea),
    orden_tarea INT,
    PRIMARY KEY (id_service, id_tarea, orden_tarea)
);

/*create table Utiliza (
    id_servicio_programado INT   REFERENCES Servicio_Programado(id_servicio_programado),
    id_plan_de_accion INT   REFERENCES Plan_De_Accion(id_plan_de_accion),
    id_service INT   REFERENCES Service(id_service),
    PRIMARY KEY (id_servicio_programado, id_plan_de_accion, id_service)
);*/

/*create table Service_Involucra (
    id_service INT,
    orden_detalle INT,
    id_tarea INT  REFERENCES Tarea(id_tarea),
    FOREIGN KEY (id_service, orden_detalle) REFERENCES Detalle_Service(id_service, orden),
    PRIMARY KEY (id_service, orden_detalle, id_tarea)
);

create table Plan_De_Accion_Involucra (
    id_plan_de_accion INT,
    orden_detalle INT,
    id_tarea INT  REFERENCES Tarea(id_tarea),
    FOREIGN KEY (id_plan_de_accion, orden_detalle) REFERENCES Detalle_Plan_De_Accion(id_plan_de_accion, orden),
    PRIMARY KEY (id_plan_de_accion, orden_detalle, id_tarea)
);

create table Mecanico_Realiza (
    dni_mecanico VARCHAR(50)  REFERENCES Mecanico(DNI),
    id_plan_de_accion INT  REFERENCES Plan_De_Accion(id_plan_de_accion),
    PRIMARY KEY (dni_mecanico, id_plan_de_accion)
);*/

create table Encarga (
    id_plan_de_accion INT,
    orden_detalle INT,
    id_pedido INT  REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_plan_de_accion, orden_detalle) REFERENCES Detalle_Plan_De_Accion(id_plan_de_accion, orden),
    PRIMARY KEY (id_plan_de_accion, orden_detalle, id_pedido)
);

create table Requiere (
    id_plan_de_accion INT,
    orden_detalle INT,
    id_repuesto INT  REFERENCES Repuesto(id_repuesto),
    FOREIGN KEY (id_plan_de_accion, orden_detalle) REFERENCES Detalle_Plan_De_Accion(id_plan_de_accion, orden),
    PRIMARY KEY (id_plan_de_accion, orden_detalle, id_repuesto)
);

create table Puede_Necesitar (
    id_tarea INT  REFERENCES Tarea(id_tarea),
    id_repuesto INT  REFERENCES Repuesto(id_repuesto),
    PRIMARY KEY (id_tarea, id_repuesto)
);
