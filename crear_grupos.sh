#!/bin/bash
# ESTILOS DE TEXTO

TEXT_ULINE=$(tput sgr 0 1)
TEXT_BOLD=$(tput bold)
TEXT_GREEN=$(tput setaf 2)
TEXT_BLUE=$(tput setaf 4)
TEXT_RESET=$(tput sgr0)

declare -a ARRAYUSUARIO
declare -a ARRAYGRUPOS
declare -a grupos

#FUNCIONES
instrucciones() {
    echo "${TEXT_ULINE}${TEXT_GREEN}INSTRUCCIONES DE USO${TEXT_RESET}"

    printf "${TEXT_BOLD}DESCRIPCION\n${TEXT_RESET}"
    printf "Script que crea grupos y añade usuarios \n"
    printf "${TEXT_BOLD}OPCIONES\n${TEXT_RESET}"

    printf "*******************************************************************************************************************************************************"
    printf "\n"
    printf "\t [-cg] grupo1 grupo2...                 Crea uno o varios grupos a la vez con los nombres dados por terminal.\n"
    printf "\t [-cu] usuario1 usuario2...             Crea uno o más usuarios con contraseña\n"
    printf "\t [-mu] grupo1 grupo2 ... [-u] usuario   Mueve un usuario a uno o mas grupos.\n"
    printf "\t [-ru] usuaro1 usuario2 usuario3        Borra uno o varios usuarios a la vez.\n"
    printf "\t [-rg] grupo1 grupo2 grupo3             Borra uno o varios grupos a la vez.\n"
    printf "\t [-comprobargrupos] usuario1 usuario2         Comprobar a qué grupos pertenece cada usuario\n"
    printf "\n"
    printf "*******************************************************************************************************************************************************"
    printf "\n"
}

crear_grupo() {
    for i in "${ARRAYGRUPOS[@]}"; do
        if [ "$i" != "-cg" ]; then
            printf "${TEXT_BOLD}GRUPO:${TEXT_RESET} %s\n" "$i"
            groupadd "$i"
            comprobacion=$(cut -d : -f 1 /etc/group | grep $i) 2>/dev/null
            if [ "$i" = "$comprobacion" ]; then
                echo "Grupo creado correctamente"
            fi
        fi
    donecp /bin/cat /usr/local/bin/mycat
}

crear_usuario() {
    for i in "${ARRAYUSUARIO[@]}"; do
        if [ "$i" != "-cu" ]; then
            printf "${TEXT_BOLD}USUARIO:${TEXT_RESET} %s\n" "$i"
            adduser "$i"     # creamos el usuario
            passwd "$i"      # le cambiamos la contraseña
            chage -M 90 "$i" # se establece la caducidad de la contraseña para dentro de 90 días (aprox 3 meses)
            chage -W 1 "$i"  # Se recordará un día antes de que su contraseña caduque
            chage -I 2 "$i"  # Dos días después de que la contraseña caduque, se desactivará la cuenta
        fi
    done

    printf "${TEXT_BOLD}CAMBIOS APLICADOS CORRECTAMENTE.${TEXT_RESET}\n"
    printf "\n\n${TEXT_BOLD}DATOS ACTUALIZADOS:${TEXT_RESET}\n"
    for i in "${ARRAYUSUARIO[@]}"; do
        if [ "$i" != "-cu" ]; then
            printf "\n${TEXT_BOLD}USUARIO:${TEXT_RESET} %s\n" "$i"
            chage -l "$i" # se listan los datos de los usuarios actualizados
        fi
    done
}

mover_usuario() {
    guardar=0
    seguir=true
    for i in "${ARRAYGRUPOS[@]}"; do
        if [ "$i" != "-mu" ]; then
            if [ "$seguir" = true ]; then
                if [ "$i" != "-u" ]; then
                    grupos[$guardar]=$i
                    let guardar=guardar+1
                fi
                if [ "$i" = "-u" ]; then
                    seguir=false
                fi
            else
                usuario=$i
            fi
        fi
    done
    for i in "${grupos[@]}"; do
        usermod -a -G "$i" "$usuario"
    done
}

borrar_usuario() {
    for i in "${ARRAYUSUARIO[@]}"; do
        if [ "$i" != "-ru" ]; then
            userdel -r "$i" # se eliminan los usuarios pasados por parametros
        fi
    done
}

borrar_grupo() {
    for i in "${ARRAYGRUPOS[@]}"; do
        if [ "$i" != "-rg" ]; then
            groupdel "$i" # se eliminan los grupos pasados por parametros
            if [ "$i" != "$comprobacion" ]; then
                comprobacion=$(cut -d : -f 1 /etc/group | grep $i) 2>/dev/null
                echo "Grupo borrado correctamente"
            fi
        fi
    done
}

comprobar_grupos() {
    for i in "${ARRAYUSUARIO[@]}"; do
        if [ "$i" != "-comprobargrupos" ]; then
            groups "$i"
        fi
    done
}

# MENU PRINCIPAL
if [ "$1" == "" ]; then
    instrucciones
fi

while [ "$1" != "" ]; do
    case $1 in
    -cg | -create)
        ARRAYGRUPOS=("${@}")
        crear_grupo
        exit
        ;;
    -cu | -createuser)
        ARRAYUSUARIO=("${@}")
        crear_usuario
        exit
        ;;
    -mu)
        ARRAYGRUPOS=("${@}")
        mover_usuario
        exit
        ;;
    -ru)
        ARRAYUSUARIO=("${@}")
        borrar_usuario
        exit
        ;;

    -rg)
        ARRAYGRUPOS=("${@}")
        borrar_grupo
        exit
        ;;
    -comprobargrupos)
        ARRAYUSUARIO=("${@}")
        comprobar_grupos
        exit
        ;;
    *)
        instrucciones
        # error_exit "Opción desconocida"
        ;;
    esac
    shift
done
