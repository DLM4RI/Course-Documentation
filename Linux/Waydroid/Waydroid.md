# Guía de Instalación de Waydroid en Ubuntu y Red Hat / Fedora
 
Waydroid es una solución basada en contenedores para ejecutar un sistema Android completo en distribuciones GNU/Linux. Utiliza namespaces del kernel de Linux para correr Android en un entorno aislado.
 
---
 
## Requisitos Previos
 
- **Distribuciones soportadas:** Ubuntu 20.04+ / Fedora 36+ / RHEL 9+
- **Sesión gráfica:** Wayland (GNOME, KDE, Sway, etc.)
- **Kernel:** 5.10 o superior recomendado
- **Privilegios:** Acceso `sudo`
 
> NOTA: Waydroid no funciona en sesiones X11 puras, WSL ni máquinas virtuales sin virtualización anidada habilitada.
 
---
 
## Paso 1: Verificar los Módulos del Kernel
 
Waydroid necesita los módulos `binder` y `ashmem`. Verifica si están cargados:
 
```bash
lsmod | grep binder
lsmod | grep ashmem
```
 
Si no aparecen, cárgalos manualmente:
 
```bash
sudo modprobe binder_linux
sudo modprobe ashmem_linux
```
 
### Ubuntu — instalar módulos extra si faltan
 
```bash
sudo apt install linux-modules-extra-$(uname -r) -y
```
 
### Fedora / Red Hat — instalar módulos extra si faltan
 
En Fedora, los módulos `binder` y `ashmem` están incluidos en el kernel estándar desde Fedora 36. Si usas un kernel personalizado, asegúrate de tener los headers instalados:
 
```bash
sudo dnf install kernel-devel kernel-headers -y
```
 
---
 
## Paso 2: Instalar Dependencias
 
### Ubuntu
 
```bash
sudo apt update
sudo apt install curl ca-certificates lzip -y
```
 
### Fedora / Red Hat
 
```bash
sudo dnf install curl ca-certificates -y
```
 
---
 
## Paso 3: Agregar el Repositorio Oficial de Waydroid
 
### Ubuntu
 
Ejecuta el script oficial que configura el repositorio automáticamente:
 
```bash
curl https://repo.waydro.id | sudo bash
```
 
> Este script añade la clave GPG y el archivo `.list` en `/etc/apt/sources.list.d/`.
 
### Fedora / Red Hat
 
Añade el repositorio de Copr mantenido por la comunidad:
 
```bash
sudo dnf copr enable aleasto/waydroid -y
```
 
---
 
## Paso 4: Instalar Waydroid
 
### Ubuntu
 
```bash
sudo apt update
sudo apt install waydroid -y
```
 
### Fedora / Red Hat
 
```bash
sudo dnf install waydroid -y
```
 
---
 
## Paso 5: Inicializar Waydroid
 
Inicia el servicio del contenedor e inicializa las imágenes de Android:
 
```bash
sudo systemctl start waydroid-container
```
 
### Sin Google Apps (AOSP puro)
 
```bash
sudo waydroid init
```
 
### Con Google Apps (opcional)
 
```bash
sudo waydroid init -s GAPPS
```
 
> La descarga de imágenes puede tardar varios minutos dependiendo de tu conexión (~1 GB).
 
---
 
## Paso 6: Iniciar la Sesión
 
```bash
waydroid session start
```
 
En otra terminal, abre la interfaz gráfica completa de Android:
 
```bash
waydroid show-full-ui
```
 
---
 
## Paso 7: Habilitar Inicio Automático
 
Para que el contenedor arranque automáticamente con el sistema:
 
```bash
sudo systemctl enable waydroid-container
```
 
---
 
## Paso 8: Instalar Aplicaciones APK
 
```bash
waydroid app install /ruta/a/tu/app.apk
```
 
Para ver las aplicaciones instaladas:
 
```bash
waydroid app list
```
 
---
 
## Paso 9: Certificar el Dispositivo en Google Play
 
Si inicializaste Waydroid con GApps, Google Play mostrará el error "device is not certified" la primera vez. Para resolverlo debes registrar el Android ID del contenedor en Google.
 
### 9.1 Obtener el Android ID
 
Con la sesión de Waydroid activa, ejecuta:
 
```bash
sudo waydroid shell
```
 
Dentro del shell de Android:
 
```bash
sqlite3 /data/data/com.google.android.gsf/databases/gservices.db \
  "select * from main where name = 'android_id';"
```
O todo junto:
```bash
sudo waydroid shell -- sh -c "sqlite3 /data/data/*/*/gservices.db 'select value from main where name = \"android_id\";'"
```
Anota el número que aparece a la derecha del resultado. Sal del shell con:
 
```bash
exit
```
 
### 9.2 Registrar el Android ID en Google
 
Accede al siguiente enlace desde tu navegador e inicia sesión con tu cuenta de Google:
 
```
https://www.google.com/android/uncertified
```
 
Ingresa el Android ID obtenido en el paso anterior y haz clic en **Register**.
 
### 9.3 Reiniciar el contenedor
 
```bash
sudo systemctl restart waydroid-container
waydroid session stop
waydroid session start
```
 
### 9.4 Iniciar sesión en Google Play
 
Abre Google Play Store dentro de Waydroid e inicia sesión con tu cuenta de Google. Si el error persiste, espera entre 10 y 30 minutos y vuelve a intentarlo, ya que el registro puede tardar en propagarse en los servidores de Google.
 
> NOTA: Cada vez que reinicialices Waydroid con `waydroid init`, se generará un nuevo Android ID y deberás repetir este proceso.
 
---
 
## Detener Waydroid
 
#### Detener la sesión activa
```bash
waydroid session stop
```
#### Detener el servicio del contenedor
```bash
sudo systemctl stop waydroid-container
```

---
 
## Desinstalar Waydroid
 
### Ubuntu
 
```bash
sudo systemctl disable --now waydroid-container
sudo apt remove --purge waydroid -y
sudo rm -rf /var/lib/waydroid ~/.local/share/waydroid
```
 
### Fedora / Red Hat
 
```bash
sudo systemctl disable --now waydroid-container
sudo dnf remove waydroid -y
sudo rm -rf /var/lib/waydroid ~/.local/share/waydroid
```
 
---
 
## Solución de Problemas Comunes
 
| Problema | Solución |
|---|---|
| `binder: No such file or directory` | Ejecuta `sudo modprobe binder_linux` |
| Pantalla negra al iniciar | Verifica que estás en sesión Wayland, no X11 |
| Error de red en Android | Reinicia con `sudo waydroid session start` |
| `Failed to start waydroid-container` | Revisa logs: `journalctl -u waydroid-container -xe` |
| Aplicaciones que no se abren | Detén y reinicia: `waydroid session stop && waydroid session start` |
| SELinux bloquea el contenedor (Fedora/RHEL) | Ejecuta `sudo setenforce 0` temporalmente o configura una política permisiva |
 
---
 
## Recursos Útiles
 
- Sitio oficial: https://waydro.id/
- Documentación: https://docs.waydro.id/
- GitHub: https://github.com/waydroid/waydroid
- Imagenes Android: https://sourceforge.net/projects/waydroid/files/images/
- Imagenes AndroidTV: https://github.com/WayDroid-ATV/waydroid-androidtv-builds?tab=readme-ov-file

---
 
*Guía orientada a Ubuntu y Red Hat / Fedora con sesión Wayland.*
 
