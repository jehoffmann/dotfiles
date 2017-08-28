### Check OS ###
platform=$(uname |tr "[:upper:]" "[:lower:]")

host=$(hostname -s)

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

# source platform specific rc
[ -e "${HOME}/.bashrc_${platform}" ] && source "${HOME}/.bashrc_${platform}"
[ -e "${HOME}/.bashrc_local" ] && source "${HOME}/.bashrc_local"
