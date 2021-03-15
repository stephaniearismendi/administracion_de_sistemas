#!/bin/bash
# ESTILOS DE TEXTO

TEXT_ULINE=$(tput sgr 0 1)
TEXT_BOLD=$(tput bold)
TEXT_GREEN=$(tput setaf 2)
TEXT_BLUE=$(tput setaf 4)
TEXT_RESET=$(tput sgr0)

#FUNCIONES
instrucciones() {
    echo "${TEXT_ULINE}${TEXT_GREEN}INSTRUCCIONES DE USO${TEXT_RESET}"

    printf "${TEXT_BOLD}DESCRIPCION\n${TEXT_RESET}"
    printf "Script que crea directorios y modifica permisos \n"
    printf "${TEXT_BOLD}OPCIONES\n${TEXT_RESET}"

    printf "*******************************************************************************************************************************************************"
    printf "\n"
    printf "Modo de uso: ./crear_directorio directorio -g grupo"
    printf "\n"
    printf "*******************************************************************************************************************************************************"
    printf "\n"
}

crear_directorios() {
    mkdir /export/proyectos/"$nombre_directorio"                 # creamos el directorio
    chgrp "$nombre_grupo" /export/proyectos/"$nombre_directorio" # cambiamos grupo propietario
    chmod -R o-rwx,g+rwx /export/proyectos/"$nombre_directorio"  # cambiamos los permisos
    chmod g+s /export/proyectos/"$nombre_directorio"             # añadimos el permiso sgid
}
# MENU PRINCIPAL

if [ "$1" == "" ]; then
    instrucciones
fi

if [ "$1" == "--help" ]; then
    instrucciones
elif [ "$1" == "-h" ]; then
    instrucciones
elif [ "$1" != "" ]; then
    nombre_directorio="$1"
    nombre_grupo="$3"
    crear_directorios $nombre_directorio $nombre_grupo
else
    instrucciones
fi
