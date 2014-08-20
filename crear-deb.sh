#!/bin/sh
echo "Bienvenido - Este Script Generar Paquetes DEB y Respalda las Fuentes"
echo "...................................................................."
echo "Ingrese Contraseña de Root"
sudo ls / >> /dev/null
Origen=$(pwd)
Usuario=$(whoami)
echo ""
if [ -d "$Origen/setup/DEBIAN/control" ]
then
 echo "Error, No se Encontro el Archivo de Control."
 exit
fi
echo "Iniciando Proceso, No Cerrar la Ventana"
while read Lineas
do 
 if [ -n "`echo $Lineas | grep -i 'Package:'`" ]
 then
  Nombre=$(echo $Lineas | sed -e 's/Package: //')
  echo "  Nombre: $Nombre"
 fi
 if [ -n "`echo $Lineas | grep -i 'Version:'`" ]
 then
  Version=$(echo $Lineas | sed -e 's/Version: //')
  echo "  Version: $Version"
 fi
 if [ -n "`echo $Lineas | grep -i 'Architecture:'`" ]
 then
  Tipo=$(echo $Lineas | sed -e 's/Architecture: //')
  echo "  Tipo: $Tipo"
 fi
done < $Origen/setup/DEBIAN/control
#
# Variables
Paquete=$Nombre'_'$Version'_'$Tipo".deb"
Fuente=$Nombre'_'$Version'_'$Tipo".tar.gz"
Temporal="/tmp/$Usuario/Paquetes/$Nombre"
#
# Carpetas
if [ ! -d "/tmp/$Usuario" ]
then
 mkdir /tmp/$Usuario
fi
if [ ! -d "/tmp/$Usuario/Paquetes" ]
then
 mkdir /tmp/$Usuario/Paquetes
fi
if [ ! -d "/tmp/$Usuario/Paquetes/$Nombre" ]
then
 mkdir /tmp/$Usuario/Paquetes/$Nombre
fi
#
# Archivos
if [ -d "$Temporal/$Paquete" ]
then
 rm $Temporal/$Paquete
fi
if [ -d "$Temporal/$Fuente" ]
then
 rm $Temporal/$Fuente
fi
if [ -d "$Origen/paquetes/$Paquete" ]
then
 rm $Origen/paquetes/$Paquete
fi
if [ -d "$Origen/fuentes/$Fuente" ]
then
 rm $Origen/fuentes/$Fuente
fi
#
# Genera Copia
if [ -d "$Temporal/setup" ]
then
 sudo chmod -R 777 $Temporal/setup
 rm -R $Temporal/setup
fi
cp -R $Origen/setup $Temporal/
#
# Genera Respaldo
tar czvf $Temporal/$Fuente setup/* >> /dev/null
mv $Temporal/$Fuente $Origen/fuentes/
echo "  Fuente: $Fuente"
#
# Genera Paquete
sudo chown -R root:root $Temporal/setup
sudo chmod -R 755 $Temporal/setup
sudo chmod 755 $Temporal/setup/DEBIAN/postinst
sudo chmod 755 $Temporal/setup/DEBIAN/control
sudo dpkg -b $Temporal/setup $Temporal/$Paquete >> /dev/null
echo "  Paquete: $Paquete"
sudo chmod 777 $Temporal/$Paquete
sudo chown -R $Usuario:$Usuario $Temporal/$Paquete
mv $Temporal/$Paquete $Origen/paquetes/
#
# Eliminando Tmporales
if [ -d "$Temporal/setup" ]
then
 sudo chmod -R 777 $Temporal/setup
 rm -R $Temporal/setup
fi
#
# Probando Paquete
echo "Instalar y Probar Paquete"
read Probar
if [ "$Probar" = "s" ]
then
 echo "Probando Paquete"
 cp $Origen/paquetes/$Paquete /tmp/$Paquete
 sudo dpkg -i /tmp/$Paquete
 rm /tmp/$Paquete
fi
#
echo "Proceso Finalizado, Ya puede Cerrar la Ventana"
sleep 20
