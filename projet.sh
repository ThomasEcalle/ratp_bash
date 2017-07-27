#! /bin/bash

API_URL='https://api-ratp.pierre-grimaud.fr/v3'
GET_ALL_LINES="$API_URL/lines/metros"
GET_ALL_STATIONS_FROM_LINE="$API_URL/stations/"
GET_DESTINATION_OF_LINE="$API_URL/destinations/"
GET_SCHEDULE="$API_URL/schedules/"
GET_TRAFFIC="$API_URL/traffic"




# Used in order to get all the informations about each metro's lines
function getAllLinesInformations()
{

 	response=`curl -s $GET_ALL_LINES | jq  -r '.result.metros'`
	echo ${response} | jq -r '.[] | {ligne: .name, destinations: .directions}' 
}

# GET all the stations on the line and Type of line passed in parameter
function getAllStationsFromLine()
{
	response=`curl -s $GET_ALL_STATIONS_FROM_LINE"$1/$2" | jq -r '.result.stations'`
	echo ${response} | jq -r '.[] ' 
}

# GET the desinations of a line and their slug
function getDestinationsOfAline()
{
	response=`curl -s $GET_DESTINATION_OF_LINE"$1/$2" | jq -r '.result.destinations'`
	echo ${response} | jq -r '.[] ' 
}

# GET the next time a metro will come
function getSchedule()
{
	
	response=`curl -s $GET_SCHEDULE"$1/$2/$3/$4" | jq -r '.result.schedules'`
	echo ${response} | jq -r '.[] '
}


function getTraffic()
{
	response=`curl -s $GET_TRAFFIC | jq -r '.result.metros'`
	if [ ! -z $1 ]
	then
	echo ${response} | jq -r ".[] | select(.line==$1)"  
	else
	echo ${response} | jq -r '.[] | {ligne: .line, titre: .title, message: .message}' 
	fi
	
	
}


# Used to print help message 
function print_help()
{

	printf "\n\n 
	**************************************************
	*  Bienvenue dans votre visualiseur RATP's like  *
	**************************************************
		\n\n

	L'objectif de cette application est de vous permettre 
	d'avoir accès aux informations que la RATP met 
	gratuitement à notre disposition.

		
	Voici les différentes routes possibles :
	
	* Récuperer l'ensemble de l'état du traffic
	renseignez l'argument -a
	exemple -> ./projet.sh -a


		
	* Avoir l'ensemble des lignes d'un transport
	renseigner l'argument -l
	exemple ->	./projet.sh -l


		

	* Avoir l'ensemble des stations d'un typer de transport
	associé à une ligne
	renseigner les arguments -t -n
	exemple ->	./projet.sh -t metros -n 3

		

	* Avoir les destinations d'une ligne
	renseigner les arguments -t -d
	exemple ->	./projet.sh -t metros -r 3 

		

	* Avoir les horaires à une station
	renseigner les arguments -t -n -s -d
	exemple ->	./projet.sh -t metros -n 3 -s anatole+france -d R 

"

}



while getopts "lt:n:d:s:ar:" opt;do
	case $opt in

		l) getAllLinesInformations;;
		t) type=$OPTARG;;
		n) number=$OPTARG;;
		d) destination=$OPTARG;;
		s) station=$OPTARG;;
		r) road=$OPTARG;;
		a) traffic=1;;
		?) print_help; exit 2;;

esac	
done

if [ ! -z $traffic ] && [ ! -z $number ]
then
getTraffic $number

elif [ ! -z $traffic ]
then
getTraffic

elif [ ! -z $type ] && [ ! -z $number ] && [ ! -z $station ] && [ ! -z $destination ]
then

	getSchedule $type $number $station $destination
	exit 1
elif [ ! -z $type ] && [ ! -z $number ]
then
	getAllStationsFromLine $type $number
	exit 1

elif  [ ! -z $type ] && [ ! -z $road ]
then
	getDestinationsOfAline $type $road
	exit 1
fi


