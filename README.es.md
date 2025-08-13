# HTTP DSL 🚀 Tu Navaja Suiza para Seguridad e Integración de APIs

> *Porque asegurar e integrar APIs no debería requerir un doctorado en DevOps*

¡Hola! 👋 

¿Alguna vez has pasado horas escribiendo scripts para validar los headers de seguridad de tu API? ¿Has luchado con workflows de integración complejos entre múltiples servicios? ¿O necesitaste auditar rápidamente una API en busca de vulnerabilidades pero te perdiste en herramientas complicadas?

**Nosotros también hemos pasado por eso.** Por eso construimos HTTP DSL - un lenguaje poderoso y legible por humanos para validación de seguridad de APIs, integración de servicios y flujos de trabajo automatizados.

## 💭 Por Qué Construimos Esto

Imagínate esto: Necesitas validar que tu API esté correctamente asegurada contra vulnerabilidades comunes. O estás orquestando un workflow complejo entre múltiples microservicios. Con herramientas tradicionales, necesitarías múltiples scripts, frameworks y horas de configuración. ¿Con HTTP DSL?

```
# Validación de seguridad en segundos
GET "https://api.tuservicio.com/admin"
assert status 401  # Asegurar que el acceso no autorizado está bloqueado

GET "https://api.tuservicio.com/login"
assert header "X-Frame-Options" exists  # Protección contra clickjacking
assert header "X-Content-Type-Options" "nosniff"  # Protección contra MIME sniffing
assert header "Strict-Transport-Security" exists  # Aplicación de HTTPS
```

**Eso es todo.** Validación de seguridad instantánea. Sin configuración compleja. Sin necesidad de ser experto en seguridad.

## 🎁 ¿Qué Hace Esto Especial?

No solo creamos otro cliente HTTP. Construimos una herramienta que **piensa como tú**:

```
# ¿Recuerdas ese molesto flujo de autenticación que siempre tienes que probar?
POST "https://api.ejemplo.com/login" json {
    "email": "usuario@ejemplo.com",
    "password": "secreto123"
}
extract jsonpath "$.token" as $token

# Ahora úsalo en todas partes, automáticamente
GET "https://api.ejemplo.com/perfil" 
    header "Authorization" "Bearer $token"
    
# Y realmente valida las cosas importantes
assert status 200
assert response contains "Bienvenido de vuelta"
```

### 🛡️ Construido para Profesionales de Seguridad e Integración

- **Validación de Seguridad**: Verificaciones integradas para las vulnerabilidades OWASP Top 10
- **Orquestación de Servicios**: Encadena múltiples APIs con lógica condicional
- **Automatización de Cumplimiento**: Valida requisitos GDPR, HIPAA, SOC2
- **Monitoreo de Rendimiento**: Porque las APIs lentas son riesgos de seguridad
- **Pistas de Auditoría**: Registro completo de solicitudes/respuestas para cumplimiento

## 🤝 Esto es Parte de Algo Más Grande

HTTP DSL está impulsado por [**go-dsl**](https://github.com/arturoeanton/go-dsl), nuestro framework para crear lenguajes específicos de dominio en Go. Si alguna vez has querido construir tu propio mini-lenguaje para tus necesidades específicas, ¡échale un vistazo! Estamos construyendo todo un ecosistema de herramientas que hacen la vida de los desarrolladores más fácil.

## 🚦 Estado Actual: v1.0.0 - ¡Listo para Producción!

¡Estamos orgullosos de decir que hemos alcanzado v1.0.0! 🎉 Esto significa:
- ✅ 95% de cobertura de pruebas (¡probamos nuestras pruebas!)
- ✅ Probado en batalla en proyectos reales
- ✅ API estable que no romperá tus scripts
- ✅ Tu feedback ayudó a dar forma a cada característica

Pero no hemos terminado. Apenas estamos comenzando.

## 🚀 Inicio Rápido (¡30 Segundos para Tu Primera Prueba!)

```bash
# Clonar y construir
git clone https://github.com/arturoeanton/httpdsl
cd httpdsl
go build -o httpdsl ./cmd/httpdsl/main.go

# ¡Ejecuta tu primera prueba!
./httpdsl scripts/demos/01_basic.http
```

¡Eso es todo! Sin archivos de configuración. Sin dependencias para instalar. Simplemente funciona. ✨

## 🎯 Casos de Uso del Mundo Real

### 🛡️ Suite de Validación de Seguridad
```
# auditoria_seguridad.http - Ejecuta antes de cada despliegue
GET "https://api.produccion.com/api/v1/usuarios"
assert status 401  # El acceso sin autenticación debe estar bloqueado

# Verificar vulnerabilidades de inyección SQL
GET "https://api.produccion.com/buscar?q='; DROP TABLE usuarios--"
assert status 400  # Debe rechazar entrada maliciosa
assert response not contains "SQL"  # No filtrar detalles de error

# Validar límite de tasa
repeat 20 times do
    GET "https://api.produccion.com/api/endpoint"
endloop
assert status 429  # El límite de tasa debe activarse

# Verificar headers de seguridad
GET "https://api.produccion.com/"
assert header "Content-Security-Policy" exists
assert header "X-XSS-Protection" "1; mode=block"
assert response time less 1000 ms  # Verificación de rendimiento
```

### 🔄 Orquestación de Integración de Microservicios
```
# integracion_servicios.http
# Workflow complejo entre múltiples servicios

# Paso 1: Autenticar con el Servicio de Auth
POST "https://auth.empresa.com/token" json {
    "grant_type": "client_credentials",
    "scope": "inventario:leer pedidos:escribir"
}
extract jsonpath "$.access_token" as $token_auth

# Paso 2: Verificar servicio de inventario
GET "https://inventario.empresa.com/productos/SKU-123/disponibilidad"
    header "Authorization" "Bearer $token_auth"
extract jsonpath "$.cantidad_disponible" as $stock

if $stock > 0 then
    # Paso 3: Crear pedido en el Servicio de Pedidos
    POST "https://pedidos.empresa.com/pedidos" json {
        "producto_id": "SKU-123",
        "cantidad": 1,
        "prioridad": "alta"
    }
    extract jsonpath "$.pedido_id" as $id_pedido
    
    # Paso 4: Activar workflow de cumplimiento
    POST "https://cumplimiento.empresa.com/procesar/$id_pedido"
    assert status 202  # Aceptado para procesamiento
else
    # Activar workflow de reabastecimiento
    POST "https://inventario.empresa.com/solicitudes-reabastecimiento" json {
        "producto_id": "SKU-123",
        "urgencia": "alta"
    }
endif
```

### 🔍 Automatización de Cumplimiento y Auditoría
```
# verificacion_cumplimiento.http - Validación GDPR/HIPAA

# Probar cumplimiento de privacidad de datos
POST "https://api.empresa.com/usuarios/solicitud-eliminacion" json {
    "usuario_id": "usuario-prueba-123",
    "razon": "GDPR Artículo 17"
}
assert status 200
assert response contains "eliminacion_programada"

# Verificar que los datos realmente se eliminan
wait 5000 ms
GET "https://api.empresa.com/usuarios/usuario-prueba-123"
assert status 404  # El usuario debe haber desaparecido

# Verificación de registro de auditoría
GET "https://auditoria.empresa.com/logs?accion=eliminacion_usuario&id=usuario-prueba-123"
assert status 200
assert response contains "eliminado_por"
assert response contains "timestamp_eliminacion"
assert response contains "base_legal"
```

## 🛠️ Características Que Realmente Importan

### Lo Que Hemos Construido (Con Amor 💙)

**Lo Básico** (porque debería ser fácil):
- Todos los métodos HTTP - `GET`, `POST`, `PUT`, `DELETE`, lo que necesites
- Headers que se encadenan naturalmente - ¡no más objetos de headers!
- JSON que maneja símbolos @ y caracteres especiales (¡finalmente!)

**Lo Inteligente** (porque eres inteligente):
- Variables con `$` - como bash, pero más amigable
- Matemáticas reales - `set $total $precio * $cantidad * 1.08`
- If/else que tiene sentido - incluso anidados
- Loops - `while`, `foreach`, `repeat` con `break`/`continue`

**Los Ahorradores de Tiempo** (porque el tiempo es precioso):
- Extrae cualquier cosa - JSONPath, regex, headers
- Valida todo - estado, tiempo de respuesta, contenido
- Arrays con indexación - `$usuarios[0]`, `$items[$indice]`
- Argumentos CLI - pasa configuraciones sin editar scripts

**El "Gracias a Dios Alguien Construyó Esto"**:
- Sin configuración, sin archivos de config
- Los scripts son portables - comparte con tu equipo
- Legible por humanos - incluso los no-programadores lo entienden
- Errores que realmente te dicen qué salió mal

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/arturoeanton/httpdsl
cd httpdsl

# Construir la herramienta CLI
go build -o httpdsl ./cmd/httpdsl/main.go

# O instalar globalmente
go install github.com/arturoeanton/httpdsl/cmd/httpdsl@latest
```

## 🎨 Integrar en Tu Proyecto Go

¿Quieres agregar superpoderes de HTTP DSL a tu propia aplicación Go? Es ridículamente fácil:

### Instalar el Módulo
```bash
go get github.com/arturoeanton/httpdsl
```

### Úsalo en Tu Código
```go
package main

import (
    "fmt"
    "log"
    "httpdsl/core"
)

func main() {
    // Crear una nueva instancia de HTTP DSL
    dsl := core.NewHTTPDSLv3()
    
    // Tu script DSL como string (puede venir de un archivo, BD, o API)
    script := `
        # Probar la salud de nuestra API
        GET "https://api.ejemplo.com/health"
        assert status 200
        
        # Login y obtener token
        POST "https://api.ejemplo.com/login" json {
            "username": "usuarioprueba",
            "password": "claveprueba"
        }
        extract jsonpath "$.token" as $token
        
        # Usar el token para peticiones autenticadas
        GET "https://api.ejemplo.com/usuarios/yo"
            header "Authorization" "Bearer $token"
        
        if status == 200 then
            print "✅ ¡Todos los sistemas operativos!"
        else
            print "❌ Algo salió mal"
        endif
    `
    
    // Ejecutar el script
    result, err := dsl.ParseWithBlockSupport(script)
    if err != nil {
        log.Fatal("El script falló:", err)
    }
    
    // Acceder a variables después de la ejecución
    token := dsl.GetVariable("token")
    fmt.Printf("Token obtenido: %v\n", token)
}
```

### Ejemplos de Integración del Mundo Real

**1. Chequeos de Salud Automatizados**
```go
func chequeoSalud(apiURL string) error {
    dsl := core.NewHTTPDSLv3()
    script := fmt.Sprintf(`
        GET "%s/health"
        assert status 200
        assert time less 1000 ms
    `, apiURL)
    
    _, err := dsl.ParseWithBlockSupport(script)
    return err
}
```

**2. Ejecutor de Tests Dinámico**
```go
func ejecutarSuiteDePruebas(archivoPrueba string, env map[string]string) {
    dsl := core.NewHTTPDSLv3()
    
    // Establecer variables de entorno
    for clave, valor := range env {
        dsl.SetVariable(clave, valor)
    }
    
    // Cargar y ejecutar script de prueba
    script, _ := os.ReadFile(archivoPrueba)
    result, err := dsl.ParseWithBlockSupport(string(script))
    
    if err != nil {
        log.Printf("Prueba falló: %v", err)
    }
}
```

**3. Integración con Pipeline CI/CD**
```go
func validadorDespliegue(urlDespliegue string) bool {
    dsl := core.NewHTTPDSLv3()
    
    scriptValidacion := `
        set $intentos 0
        set $saludable false
        
        while $intentos < 5 and $saludable == false do
            GET "%s"
            if status == 200 then
                set $saludable true
            else
                wait 2000 ms
                set $intentos $intentos + 1
            endif
        endloop
        
        if $saludable == false then
            print "Validación del despliegue falló después de 5 intentos"
        endif
    `
    
    script := fmt.Sprintf(scriptValidacion, urlDespliegue)
    _, err := dsl.ParseWithBlockSupport(script)
    
    return dsl.GetVariable("saludable") == true
}
```

### Acceder a Componentes del DSL

```go
// Obtener todas las variables después de la ejecución
vars := dsl.GetVariables()

// Establecer variables iniciales antes de la ejecución
dsl.SetVariable("baseURL", "https://api.produccion.com")
dsl.SetVariable("apiKey", os.Getenv("API_KEY"))

// Acceder al motor HTTP para configuraciones personalizadas
engine := dsl.GetHTTPEngine()
engine.SetTimeout(30 * time.Second)
```

### ¿Por Qué Integrar HTTP DSL?

- **No Más Mantenimiento de Código de Pruebas**: Las pruebas se vuelven datos, no código
- **No-Desarrolladores Pueden Escribir Pruebas**: Gerentes de producto, QA, ¡cualquiera!
- **Generación Dinámica de Pruebas**: Genera pruebas basadas en especificaciones OpenAPI
- **Bibliotecas de Pruebas Reutilizables**: Comparte archivos `.http` entre proyectos
- **Pruebas con Recarga en Caliente**: Cambia pruebas sin recompilar

## Uso

### Ejemplo de Producción (¡Todo Funcionando!)

```
# ¡Todo este script FUNCIONA en v1.0.0!
set $base_url "https://jsonplaceholder.typicode.com"
set $api_version "v3"

# Múltiples headers - ¡FUNCIONA!
GET "$base_url/posts/1" 
    header "Accept" "application/json"
    header "X-API-Version" "$api_version"
    header "X-Request-ID" "test-123"
    header "Cache-Control" "no-cache"

assert status 200
extract jsonpath "$.userId" as $user_id

# JSON con símbolos @ - ¡FUNCIONA!
POST "$base_url/posts" json {
    "title": "Notificaciones por email",
    "body": "Enviar a usuario@ejemplo.com con @menciones y #tags",
    "userId": 1
}

assert status 201
extract jsonpath "$.id" as $post_id

# Expresiones aritméticas - ¡FUNCIONANDO!
set $puntaje_base 100
set $bonus 25
set $total $puntaje_base + $bonus
set $final $total * 1.1
print "Puntaje final: $final"

# Condicionales - ¡FUNCIONANDO!
if $post_id > 0 then set $estado "ÉXITO" else set $estado "FALLO"
print "Estado de creación: $estado"

# Loops con break/continue - ¡FUNCIONANDO!
set $contador 0
while $contador < 10 do
    if $contador == 5 then
        break
    endif
    set $contador $contador + 1
endloop

# Operaciones con arrays - ¡NUEVO en v1.0.0!
set $frutas "[\"manzana\", \"banana\", \"naranja\"]"
set $primera $frutas[0]  # Indexación de arrays con corchetes
set $longitud length $frutas  # Función length
foreach $item in $frutas do
    print "Fruta: $item"
endloop

# Argumentos CLI - ¡NUEVO en v1.0.0!
if $ARGC > 0 then
    print "Primer argumento: $ARG1"
endif

print "¡Todas las pruebas completadas exitosamente!"
```

### Usando el Ejecutor

```bash
# Ejecutar un archivo de script
./httpdsl scripts/demos/demo_complete.http

# Pasar argumentos de línea de comandos al script
./httpdsl script.http arg1 arg2 arg3

# Con salida detallada
./httpdsl -v scripts/demos/06_loops.http

# Detener en el primer fallo
./httpdsl -stop scripts/demos/04_conditionals.http

# Ejecución en seco (validar sin ejecutar)
./httpdsl --dry-run scripts/demos/05_blocks.http

# Validar solo la sintaxis
./httpdsl --validate scripts/demos/02_headers_json.http
```

## 💝 ¡Te Necesitamos! (Sí, a Ti!)

Este proyecto existe porque desarrolladores como tú dijeron "tiene que haber una mejor manera". Y tenían razón.

### Cómo Puedes Ayudar a Hacer las Pruebas Mejores para Todos

**🐛 ¿Encontraste un Bug?** 
¡No sufras en silencio! [Abre un issue](https://github.com/arturoeanton/httpdsl/issues) y arreglémoslo juntos. Ningún bug es demasiado pequeño.

**💡 ¿Tienes una Idea?**
¿Esa característica que desearías que existiera? ¡Construyámosla! Abre una discusión y comparte tus pensamientos.

**📝 ¿Mejorar la Documentación?**
Si algo te confundió, confundirá a otros. ¡Ayúdanos a hacerlo más claro!

**⭐ ¡Solo Danos una Estrella!**
En serio, ayuda más de lo que crees. Nos dice que vamos por buen camino.

### Contribuyendo Código

```bash
# Haz fork, clona y crea tu rama de característica
git checkout -b mi-caracteristica-increible

# Haz tus cambios y pruébalos
go test ./...

# ¡Push y crea un PR!
```

Prometemos:
- 🚀 Revisar PRs rápidamente (usualmente en 48h)
- 💬 Proporcionar feedback constructivo y amable
- 🎉 Celebrar tu contribución públicamente
- 📝 Darte crédito en nuestros releases

### 🌟 Nuestros Increíbles Contribuidores

Cada persona que contribuye hace esto mejor. Ya sea código, documentación, reportes de bugs, o simplemente correr la voz - **tú importas**.

## 🤲 Únete a Nuestra Comunidad

**No estamos construyendo una herramienta. Estamos construyendo una comunidad de desarrolladores que creen que las pruebas deberían ser simples.**

- 🐦 Comparte tus scripts y consejos con #httpdsl
- 💬 [Únete a nuestras discusiones](https://github.com/arturoeanton/httpdsl/discussions)
- 📧 Contáctanos directamente - ¡realmente respondemos!

## 🎭 El Panorama General

HTTP DSL está orgullosamente impulsado por [**go-dsl**](https://github.com/arturoeanton/go-dsl) - nuestro framework para construir lenguajes específicos de dominio. Juntos, estamos haciendo herramientas de desarrollo que respetan tu tiempo e inteligencia.

## 📜 Licencia

MIT - Porque las grandes herramientas deberían ser gratis para todos.

## 🙏 Pensamientos Finales

Construimos esto porque lo necesitábamos. Lo mantenemos porque tú también lo necesitas. Cada issue que abres, cada PR que envías, cada estrella que das - todo nos recuerda por qué hacemos esto.

**Gracias por ser parte de este viaje.**

¡Hagamos las pruebas agradables otra vez! 🚀

---

<p align="center">
Hecho con ❤️ por desarrolladores que estaban cansados de pruebas complejas
<br>
<b>HTTP DSL v1.0.0</b> - Tu compañero de pruebas
<br>
<i>"Herramientas simples para problemas complejos"</i>
</p>

<p align="center">
  <a href="https://github.com/arturoeanton/httpdsl">⭐ Danos una estrella</a> •
  <a href="https://github.com/arturoeanton/httpdsl/issues">🐛 Reportar Bug</a> •
  <a href="https://github.com/arturoeanton/httpdsl/discussions">💬 Discusiones</a> •
  <a href="https://github.com/arturoeanton/go-dsl">🔧 go-dsl</a>
</p>