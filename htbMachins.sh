  #!/bin/bash

function ctrl_c(){
	echo -e '\n\n Saliendo...\n'
	exit 1  #Marca una salida con redireccion de error 
}


# Ctrl+C
trap ctrl_c INT #Se atrapa todo el flujo del programa al atajo ctrl_c y ejecuta la funcion con 
				#su nombre

#Variables globales 
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
	echo -e '\n Uso:'
	echo -e '\t u) Descargar o actualizar archivos necesario'
	echo -e '\t m) Buscar por un nombre de maquina'
	echo -e '\t i) Buscar por direccion ip'
	echo -e '\t d) Buscar maquina por dificultad'
	echo -e '\t o) Buscar maquina por sistema operativo'
	echo -e '\t s) Buscar maquina por skill'
	echo -e '\t y) Obtener link de resoucion de la maquina por youtube'
	echo -e '\t h) Mostrar este panel de ayuda\n'
}

#Indicadores
declare -i parameter_counter=0

function updateFiles(){
	if [ ! -f bundle.js ]; then
		echo -e "\n Descargando archivos necesarios" 
		curl -s $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js 
		echo -e "\n Todos los archivos han sido descargados..."
	else
		echo -e "\n Comprobando si hay actualizaciones pendientes..."
		curl -s $main_url > bundle_temp.js
		md5_tempValue=$(md5sum bundle_temp.js | awk '{print $1}')
		md5_originValue=$(md5sum bundle.js | awk '{print $1}')

		if [ "$md5_tempValue" == "$md5_originValue" ]; then
			echo "No hay actualizaciones"
			rm bundle_temp.js 
		else 
			echo "Si hay actualizaciones"
			rm bundle.js && bundle_temp.js bundle.js
		fi 

	fi
}

function searchMachine(){
	machineName="$1"

	machineNameChecker=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' |  tr -d "," | sed 's/^ *//')

	if [ "$machineNameChecker" ]; then

		echo -e "\n Listando las propiedades de la maquina $machineName\n"

		cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ','| sed 's/^ *//'

	else
		echo -e "\n La maquina proporcionada no existe" 
	fi 
}

function searchIp(){
	ipAdress="$1"

	machineName=$(cat bundle.js | grep "ip: \"$ipAdress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')

	if [ "$machineName" ]; then
		echo -e "\n La maquina correspondiente al IP $ipAdress es $machineName"
	else
		echo -e "\n La IP correspondiente no existe"
	fi

}

function getYoutubeLink(){
	machineName="$1"

	youtubelink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

	echo -e "\n El tutorial para la siguiente maquina se encuentra en el siguiente enlace: $youtubelink"
}

function getMachineDificulty(){
	dificulty="$1"

 	dificultyCheck="$(cat bundle.js | grep "dificultad: \"$dificulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

 	if [ "$dificultyCheck" ]; then
		echo -e "\n Representando las maquinas con la dificultad $dificulty:"
		cat bundle.js | grep "dificultad: \"$dificulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column 
 	else 
 		echo -e "\n La dificultad proporcionada no existe \n"
	fi
}

function getOSMachines(){
	os="$1"

	OSChecker="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$OSChecker" ]; then
		echo -e "\n Mostrando las maquinas cuyo sistema operativo es $OS"
		cat bundle.js | grep "so: \"$os\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
		
	else
		echo -e "\n El sistema operativo indicado no existe"
	fi

}

function getSkills(){
	skills="$1"

	nameSkill="$(cat bundle.js | grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"


	if [ "$nameSkill" ]; then
		echo -e "\n Las maquinas con la skill $skills son: "

		cat bundle.js | grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n No existen maquinas con esa skill"
	fi
}

#getops es un comando constructor que permitira agregar parametros a la ejecucion del script
while getopts 'm:ui:y:d:o:s:h' arg; do #Se declara la variable arg e iterara sobre los argumentos m y h
 	case $arg in
		m) machineName="$OPTARG"; let parameter_counter+=1;;  #$OPTARG es la manera de llamar al parametro dentro del bucle while
		u) let parameter_counter=+2;;
		i) ipAdress="$OPTARG"; let parameter_counter=+3;;
		y) machineName="$OPTARG"; let parameter_counter=+4;;
		d) dificulty="$OPTARG"; let parameter_counter=+5;;
		o) os="$OPTARG"; let parameter_counter=+6;;
		s) skills="$OPTARG"; let parameter_counter=+7;;
		h) helpPanel;;
 	esac
done


if [ $parameter_counter -eq 1 ]; then  #Se usa el parametro -eq ya que se usa para un valor mas numerico
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIp $ipAdress
elif [ $parameter_counter -eq 4 ]; then
	getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
	getMachineDificulty $dificulty
elif [ $parameter_counter -eq 6 ]; then
	getOSMachines $os
elif [ $parameter_counter -eq 7 ]; then
	getSkills "$skills"
else
	helpPanel
fi
