if [ -f /etc/default/locale ]; then
  . /etc/default/locale
  export LANG
else
  export LANG="en_US.UTF-8"
fi
