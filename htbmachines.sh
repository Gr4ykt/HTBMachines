#!/bin/bash

#COLORS
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#ctrl_c
function ctrl_c(){
  echo -e "\n\n${redColour}[!]Saliendo...${endColour}\n"
  tput cnorm && exit 1
}
trap ctrl_c INT

#VARIABLES GLOBALES
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}"
		echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por nombre de maquina${endColour}"
		echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por IP de maquina${endColour}"
		echo -e "\t${purpleColour}y)${endColour} ${grayColour}Link de la resolucion de la maquina${endColour}"
		echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por dificultad${endColour}"
		echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar por Sistema Operativo${endColour}"
		echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar por Skills${endColour}"
		echo -e "\t${purpleColour}u)${endColour} ${grayColour}Actualizar y descargar archivo de maquinas${endColour}"
		echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar panel de ayuda${endColour}\n"
}

function searchMachine(){
	machineName="$1"
	detailMachine="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d "," | sed 's/^ *//')"

	if [ "$detailMachine" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando propiedades de la maquina${endColour} ${blueColour}$machineName${endColour}${grayColour}:${endColour}\n"
		echo -e "${grayColour}$detailMachine${endColour}\n"

	else
		echo -e "\n${redColour}[!] La maquina no existe${endColour}\n"
	fi

}

function updateFiles(){
	tput civis
	echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando actualizaciones o descargando bundle.js${endColour}\n"
	sleep 2
	if [ ! -f bundle.js ]; then
		echo -e "\t${yellowColour}[*]${endColour} ${grayColour}Descargando archivos requeridos${endColour}\n"
		curl -s -X GET $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\t${yellowColour}[**]${endColour} ${grayColour}Todos los archivos han sido descargados${endColour}\n"
		tput cnorm
	else
		tput civis
		echo -e "\t${redColour}[!]${endColour} ${grayColour}El archivo ya existe${endColour}\n"
		curl -s -X GET $main_url > bundle_temp.js
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
		md5_original_value=$(md5sum bundle.js |awk '{print $1}')

		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			echo -e "\t${greenColour}[+]${endColour} ${grayColour}No hay actualizaciones${endColour}\n"
			rm -rf bundle_temp.js
			sleep 1
		else
			echo -e "\t${yellowColour}[+]${endColour} ${grayColour}Hay actualizaciones${endColour}"
			rm -rf bundle.js && mv bundle_temp.js bundle.js
			echo -e "\t${greenColour}[*]${endColour} ${grayColour}Archivo actualizado${endColour}\n"
			sleep 1
		fi

		tput cnorm
	fi
}

function searchIP(){
	ipAddress="$1"
	machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}'| tr -d '"' | tr -d ",")"

	if [ "$machineName" ]; then
		echo -e "\n${greenColour}[+]${endColour} ${grayColour}La IP ${endColour}${blueColour}$ipAddress${endColour} ${grayColour}es de la maquina${endColour} ${purpleColour}$machineName${endColour}"
		#searchMachine $machineName #Un llamado a la funcion para mostrar detalles de la maquina
	else
		echo -e "\n${redColour}[!] La direccion IP no existe${endColour}\n"
	fi
}

function getYoutubeLink(){
	machineName="$1"
	youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d "," | sed 's/^ *//' | grep "youtube" | awk 'NF{print $NF}')"

	if [ $youtubeLink ]; then
		echo -e "\n\t${greenColour}[+]${greenColour} ${grayColour}El link del tutorial de la maquina${endColour} ${blueColour}$machineName${endColour}${grayColour} es${endColour} ${purpleColour}$youtubeLink${endColour}\n"
	else
		echo -e "nombre puesto: $machineName"
		echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
	fi
}

function getMachinesDifficulty(){
	difficulty="$1"
	results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 -i| grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"

	if [ "$results_check" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando maquinas con dificultad${endColour} ${blueColour}$difficulty${endColour}${grayColour}:${endColour}\n\n${purpleColour}$results_check${endColour}\n"
	else
		echo -e "\n${redColour}[!] La dificultad no existe${endColour}\n"
	fi
}

function getOSMachines(){
	os="$1"
	os_results="$(cat bundle.js | grep "so: \"$os\"" -B 5 -i| grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"

	if [ "$os_results" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando maquinas con Sistema operativo{endColour} ${blueColour}$os${endColour}${grayColour}:${endColour}\n\n${purpleColour}$os_results${endColour}\n"
	else
		echo -e "\n${redColour}[!] El Sistema operativo no existe${endColour}\n"
	fi
}

function getOSDifficultyMachines(){
	difficulty="$1"
	os="$2"
	check_results="$(cat bundle.js | grep "so: \"Linux\"" -C 4 -i | grep "dificultad: \"Media\"" -B 5 -i | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"

	if [ "$check_results" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando maquinas dificultad ${blueColour}$difficulty${endColour} ${grayColour}y Sistema operativo${endColour} ${blueColour}$os${endColour}${grayColour}:${endColour}\n\n${purpleColour}$check_results${endColour}\n"
	else
		echo -e "\n${redColour}[!] El Sistema operativo o la dificultad no existen${endColour}\n"
	fi
}

function getSkill(){
	skill="$1"
	check_skill="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"

	if [ "$check_skill" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando maquinas con skill${endColour} ${blueColour}$skill${endColour}${grayColour}:${endColour}\n\n${purpleColour}$check_skill${endColour}\n"
	else
		echo -e "\n${redColour}[!] La skill no existe${endColour}\n"
	fi
}

#INDICADORES
declare -i  parameter_counter=0

#CHIVATOS
declare -i chivato_difficulty=0
declare -i chivato_os=0

#BUCLE PARA LOS PARAMETROS
while getopts "m:ui:y:d:o:s:h" arg; do
	#CREANDO UN PARAMETRO
	case $arg in
		u)let parameter_counter+=2;;
		m)machineName="$OPTARG"; let parameter_counter+=1;;
		i)ipAddress="$OPTARG"; let parameter_counter+=3;;
		y)machineName="$OPTARG"; let parameter_counter+=4;;
		d)difficulty="$OPTARG"; chivato_difficulty=1 ;let parameter_counter+=5;;
		o)os="$OPTARG"; chivato_os=1 ;let parameter_counter+=6;;
		s)skill="$OPTARG"; let parameter_counter+=7;;
		h);;
	esac
done

if [ $parameter_counter -eq 1  ]; then
	searchMachine "$machineName"
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP "$ipAddress"
elif [ $parameter_counter -eq 4 ]; then
	getYoutubeLink "$machineName"
elif [ $parameter_counter -eq 5 ]; then
	getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
	getOSMachines "$os"
elif [ $parameter_counter -eq 7 ]; then
	getSkill "$skill"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
	getOSDifficultyMachines "$difficulty" "$os"
else
	helpPanel
fi
