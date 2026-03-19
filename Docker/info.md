# Docker Guide
## 1. Gestión de Imagenes
| Comando                               | Descrpción                        	|
|---------------------------------------|---------------------------------------|
| `docker pull <imagen>`                | Descargar imagen del registry     	|
| `docker build -t <nombre> .`          | Construir imagen desde Dockerfile	|
| `docker images`	                | Listar imágenes locales           	|
| `docker rmi <imagen>`                 | Eliminar imagen                   	|
| `docker tag <imagen> <nuevo-nombre>`  | Etiquetar imagen                  	|
| `docker push <imagen>`                | Subir imagen al registry          	|

## 2. Gestión de Contenedores
| Comando				| Descripción			    	| 
|---------------------------------------|---------------------------------------|
| `docker run <imagen>` 		| Crear y ejecutar contenedor		|
| `docker start <contenedor>` 		| Iniciar contenedor detenido		|
| `docker stop <contenedor>` 		| Detener contenedor			| 
| `docker restart <contenedor>` 	| Reiniciar contenedor			|
| `docker rm <contenedor>`		| Eliminar contenedor 			|
| `docker ps` 				| Listar contenedores activos 		|
| `docker ps -a` 			| Listar todos los contenedores		|

## 3. Parámetros de docker run
| Parámetro 				| Descripción 					| Ejemplo 			|
|---------------------------------------|-----------------------------------------------|-------------------------------|
| `-d` 					| Modo background (detached) 			| docker run -d nginx 		|
| `-p` 					| Mapeo de puertos host:contenedor		| -p 8080:80 			|
| `-v` 					| Montar volumen host:contenedor 		| -v /datos:/app/data 		|
| `-e` 					| Variable de entorno 				| -e DB_HOST=localhost 		| 
| `--name` 				| Nombre del contenedor 			| --name mi-app 		|
| `--rm` 				| Eliminar al detenerse	docker run 		| --rm alpine			| 
| `-it` 				| Modo interactivo con terminal	docker run 	| -it ubuntu bash 		|
| `--network` 				| Red a usar 					| --network mi-red 		|
| `--restart` 				| Política de reinicio 				| --restart always 		|
| `--env-file` 				| Cargar variables desde archivo 		| --env-file .env 		| 
| `-u`  				| Usuario dentro del contenedor			| -u 1000:1000 			|
| `--memory` 				| Límite de memoria RAM				| --memory 512m 		|
| `--cpus` 				| Límite de CPUs 				| --cpus 1.5 			|

## 4. Inspección y Logs
| Comando 				| Descripción 					|
|---------------------------------------|-----------------------------------------------|
| `docker logs <contenedor>` 		| Ver logs 					| 
| `docker logs -f <contenedor>` 	| Seguir logs en tiempo real 			|
| `docker inspect <contenedor>` 	| Información detallada en JSON 		|
| `docker stats` 			| Uso de recursos en tiempo real		| 
| `docker top <contenedor>` 		| Procesos dentro del contenedor 		|
| `docker diff <contenedor>` 		| Cambios en el sistema de archivos 		|

## 5. Ejecución dentro de Contenedores
Abrir shell en contenedor activo:
```bash
docker exec -it <contenedor> bash
```
Ejecutar comando puntual:
```bash
docker exec <contenedor> ls /app
```
Copiar archivos entre host y contenedor:
```bash
docker cp archivo.txt <contenedor>:/ruta/
docker cp <contenedor>:/ruta/archivo.txt ./
```

## 6. Redes
| Comando 					| Descripción					|
|-----------------------------------------------|-----------------------------------------------|
| `docker network ls` 				| Listar redes 					|
| `docker network create <nombre>` 		| Crear red 					|
| `docker network connect <red> <contenedor>` 	| Conectar contenedor a red			|
| `docker network inspect <red>` 		| Detalles de la red 				|

## 7. Volúmenes
| Comando 					| Descripción 					|
|-----------------------------------------------|-----------------------------------------------|
| `docker volume ls` 				| Listar volúmenes 				|
| `docker volume create <nombre>` 		| Crear volumen 				|
| `docker volume inspect <nombre>` 		| Detalles del volumen 				|
| `docker volume rm <nombre>` 			| Eliminar volumen 				|

## 8. Docker Compose
```bash
docker compose up -d                    # Levantar servicios en background
docker compose down                     # Detener y eliminar contenedores
docker compose down -v                  # También elimina volúmenes
docker compose logs -f                  # Ver logs de todos los servicios
docker compose ps                       # Estado de los servicios
docker compose build                    # Reconstruir imágenes
docker compose exec <svc> bash          # Shell en un servicio```
```

## 9. Limpieza del Sistema
```bash
docker system prune                     # Eliminar recursos sin uso
docker system prune -a                  # Incluye imágenes no usadas
docker image prune                      # Solo imágenes huérfanas
docker container prune                  # Solo contenedores detenidos
docker volume prune                     # Solo volúmenes sin usar
```

> Tip: Usa docker <comando> --help para ver todos los parámetros disponibles de cualquier comando.

