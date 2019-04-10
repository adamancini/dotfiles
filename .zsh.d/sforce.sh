function sforce {
docker run -it \
  --user $(id -u):$(id -g) \
  --env-file="$HOME/opt/sforce/sforce.env" \
  -e SFCUSTOM="$(tmux list-panes -F '#{session_name}:#{window_index}')" \
  -v $HOME/opt/sforce:/host \
  -v $HOME/docker/issues:/host/sforce/attachments \
  -v sforcetmp:/tmp \
support/sforce:dev
}

function update_sforce {
docker pull support/sforce:dev && docker pull support/sforce:latest
}
