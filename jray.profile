#Docker related aliases/env/functions that I want in my CoreOS Instance

#Aliases
alias dps='docker ps'
alias drm='docker rm'
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias dex='docker exec -it $1 /bin/bash'

#Environment Variables
export VOLUME_CONTAINER=`docker images | grep dvol | awk '{print$1}'`
export DEV_CONTAINER=`docker images | grep dbox | awk '{print$1}'`

#Functions
dvol () {
  case $1 in
    create)
      docker run -it --name dvol ${VOLUME_CONTAINER} ;;
    destroy)
      docker rm -v dvol ;;
  esac
}

dbox () {
  case $1 in
    create)
      docker run -it --name $2 -h dbox --volumes-from dvol ${DEV_CONTAINER} ;;
    destroy)
      if [ `docker inspect --format '{{.State.Running}}' $2` = 'true' ]; then
        docker stop $2 && docker rm $2
      else
        docker rm $2
      fi ;;
  esac
}

dbackup () {
  [ -d /home/core/backup ] || mkdir /home/core/backup && chmod 777 /home/core/backup
  docker run -it --rm --volumes-from dvol -v /home/core/backup:/backup yarnhoj/dbox tar cvf /backup/bu.tar $1
}

drestore () {
	docker run -it --rm --volumes-from dvol -v /home/core/backup:/backup yarnhoj/dbox tar xvf /backup/bu.tar $1
}
