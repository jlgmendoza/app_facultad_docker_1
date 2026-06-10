"""
Es crucial que importes tus modelos (Alumno, Asignatura, etc.) antes
 de ejecutar la creación de tablas; 
de lo contrario, SQLModel no sabrá qué tablas tiene que generar.
"""
from contextlib import asynccontextmanager
from typing import Sequence
from fastapi import FastAPI, HTTPException, Request
# esta Aplicación se encarga de inicializar la base de datos al arrancar el servidor FastAPI
from BBDD.Conexion.database_facultad import inicializar_base_de_datos, create_db_and_tables, session_dep
from fastapi.templating import Jinja2Templates
from sqlmodel import select, text
from fastapi.encoders import jsonable_encoder


# ¡IMPORTANTE! Importa aquí tus modelos para que SQLModel los registre
#from models import Alumno, Asignatura, Matricula 
# Importar la clase `Alumno` desde el submódulo donde está definida
from BBDD.Modelo.Alumno import Alumno, AlumnoBase
from BBDD.Modelo.Asignatura import Asignatura, AsignaturaBase
from BBDD.Modelo.Profesor import Profesor, ProfesorBase
from BBDD.Modelo.Matricula import Matricula, MatriculaBase
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Esto se ejecuta al arrancar el servidor FastAPI antes de recibir peticiones
    print("Reiniciando el servidor FastAPI... Verificando/Creando base de datos y tablas...")
    inicializar_base_de_datos()
    create_db_and_tables()  # Crea las tablas basándose en los modelos importados
    yield

app = FastAPI(lifespan=lifespan)
# una vez que el servidor esté arrancado, la base de datos y 
# las tablas estarán listas para usarse en los endpoints de la API.
# Por lo tanto, puedes definir tus endpoints aquí sin preocuparte por la 
# inicialización de la base de datos, siendo inncesario para el uso del API Rest 
# el reinicio del servidor tras la invocación de un endpoint.

templates = Jinja2Templates(directory="templates")

# una vez referida la carpeta de plantillas, se pueden crear endpoints que 
# devuelvan HTML renderizado con Jinja2, en este caso para mostrar los alumnos matriculados en una asignatura concreta.

# Aquí se devuelve una template y no un objeto JSON
# Para poder diferencia entre los endpoints que devuelven JSON y los 
# que devuelven HTML, se puede usar un prefijo en la ruta, por ejemplo:
# para dejar sin prefijo los endpoints que devuelven HTML (/alumnos/), y usar el prefijo "/api" para los endpoints que devuelven JSON, por ejemplo:
# @app.get("/api/alumnos/{alumno_id}", response_model=Alumno)


@app.get("/")
async def name(request: Request):
#   return {"mensaje": "Servidor listo y base de datos verificada/creada"} # para probar que el servidor arranca correctamente y la base de datos se inicializa sin problemas
    return templates.TemplateResponse(request, "home.html", {"mensaje_bienvenida": "Bienvenido a la Facultad de Informática"}) 

# End point para obtener un alumno por su ID
@app.get("/alumnos/{alumno_id}", response_model=Alumno)
async def obtener_alumno(alumno_id: int, request: Request, session: session_dep):
    alumno = session.get(Alumno, alumno_id)
    if alumno is None:
        raise HTTPException(status_code=404, detail="Alumno no encontrado")
    return templates.TemplateResponse(request, "home.html", { 
                                                    "nombre": alumno.nombre, 
                                                    "fecha_nacimiento": alumno.fechaNacimiento, 
                                                    "NIF": alumno.NIF
                                                    })

# Endpoint para consultar todos los alummos para mostrar en una tabla HTML:
@app.get("/alumnos/", response_model=list[Alumno])
async def obtener_alumnos(session: session_dep, request: Request):
    alumnos = session.exec(select(Alumno)).all()  
    print(f"Alumnos obtenidos de la base de datos: {alumnos}")  # Imprime los alumnos obtenidos para depuración
    alumnos_serializados = jsonable_encoder(alumnos) 
    if alumnos is None:
        raise HTTPException(status_code=404, detail="No hay alumnos registrados")
    return templates.TemplateResponse(request, "alumnos.html", {"alumnos": alumnos_serializados})

# EJERCICIO 1: HACER UN FORMULARIO HTML QUE EJECUTE LA CONSULTA DE LOS ALUMNOS POR EL CRITERIO DE 
# ESTAR O NO BECADO
# EJERCICIO 2: HACER UN FORMULARIO HTML QUE EJECUTE LA CONSULTA DE LOS ALUMNOS 
# POR EL CRITERIO DE PRIMER APELLIDO 
# (POR EJEMPLO, QUE MUESTRE SOLO LOS ALUMNOS CON APELLIDO QUE EMPICE POR "G"")
# EJERCICIO 3: HACER UN FORMULARIO HTML QUE EJECUTE LA CONSULTA DE LOS ALUMNOS 
# POR EL CRITERIO DE EDAD (POR EJEMPLO, QUE MUESTRE SOLO LOS ALUMNOS MAYORES DE 25 AÑOS",
#  O LOS ALUMNOS QUE TIENEN EXACTAMENTE 20 AÑOS, ETC.)")
# PARA TODOS LOS EJERCICIOS SE DEBE MOSTRAR UNA TABLA HTML CON LOS RESULTADOS DE LA CONSULTA,
# Y SE DEBE MOSTRAR UN MENSAJE DE AVISO SI NO HAY ALUMNOS QUE CUMPLAN EL CRITERIO DE LA CONSULTA, 
# O SI NO HAY ALUMNOS REGISTRADOS EN LA BASE DE DATOS.

# Solución al ejercicio 1:

@app.get("/alumnos/formulario_beca/")
async def mostrar_formulario_beca(request: Request):
    return templates.TemplateResponse(request, "formulario_alumnos.html", {"request": request})

@app.get("/alumnos/becados/", response_model=list[Alumno])
async def obtener_alumnos_becados(session: session_dep, request: Request):
    # el criterio debe recuperar el valor de la variable 'beca' del formulario HTML, 
    # que se envía como un parámetro de consulta (query parameter) en la URL, 
    # por ejemplo: /alumnos/becados/?beca=1 para obtener los alumnos becados y 
    # /alumnos/becados/?beca=0 para obtener los alumnos no becados.
    if 'beca' not in request.query_params:
        raise HTTPException(status_code=400, detail="Falta el parámetro de consulta 'beca'. Debe ser 1 para becados o 0 para no becados.")
    beca_value = request.query_params['beca']
    if beca_value in ('1','0'):
        alumnos: Sequence[Alumno] = session.exec(select(Alumno).where(Alumno.beca == int(beca_value))).all()
    else:    
        raise HTTPException(status_code=400, detail="El parámetro 'beca' debe ser 1 para becados o 0 para no becados.")
    print(f"Alumnos becados obtenidos de la base de datos: {alumnos}")  # Imprime los alumnos obtenidos para depuración
    alumnos_serializados = jsonable_encoder(alumnos)
    print(type(alumnos_serializados))  # Imprime el tipo de datos de los alumnos becados serializados para depuración   
    if not alumnos:
        raise HTTPException(status_code=404, detail="No hay alumnos becados ni no becados registrados")
    return templates.TemplateResponse(request, "alumnos_becados.html", {"alumnos": alumnos_serializados})




@app.post("/alumnos/", response_model=Alumno)
def crear_alumno(alumnoBase: AlumnoBase, session: session_dep):
    # FastAPI ya valida y convierte la entrada a una instancia de `Alumno`.
    # No es necesario llamar a `model_validate` (esa es una API de pydantic v2
    # y además aquí `Alumno` podría referirse al módulo si se importó mal).
    alumnoInvalido = False
    try:
        print(f"***************************")
        print(f"****************************NIF: {alumnoBase.NIF}")
        print(alumnoBase.email)
        if alumnoBase.validar_NIF(alumnoBase.NIF) and alumnoBase.validar_correo_regex(alumnoBase.email):  # Valida el NIF y el correo antes de guardar
            # ¿****devuelve un alumno*****?
            #Alumno alumno_db = alumnoBase + id
            print(f"Alumno válido: {alumnoBase.NIF} y {alumnoBase.email} han pasado las validaciones.")
            db_alumno = Alumno.model_validate(alumnoBase)  # Convierte el AlumnoBase a Alumno para la base de datos
            print(f"id de Alumno: {db_alumno.id}")
            session.add(db_alumno)
            session.commit()
            session.refresh(db_alumno) # esto es necesario para que `db_alumno` tenga el ID 
            # generado por la base de datos después de la inserción
            return db_alumno
        else:
            alumnoInvalido = True
            print(f"-----------------Alumno no válido: {alumnoBase.NIF} o {alumnoBase.email} han fallado las validaciones.")
            raise ValueError("Alumno no válido: NIF o correo electrónico no cumplen con las validaciones.")
    except (Exception, ValueError) as e:
        print(f"+++++++++++++++++++++Error al crear alumno: {e}")
        session.rollback()
        raise e
    finally:
        if alumnoInvalido:
            print(f"Alumno no válido: {alumnoBase.NIF} o {alumnoBase.email} han fallado las validaciones. No se ha guardado en la base de datos.")
        else:
            print(f"****Alumno creado exitosamente: {alumnoBase.NIF} y {alumnoBase.email} han pasado las validaciones y se han guardado en la base de datos.")
        session.close()

