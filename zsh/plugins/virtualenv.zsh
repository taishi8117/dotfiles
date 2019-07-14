# Virtual env

function activate { export VIRTUAL_ENV_DISABLE_PROMPT='1' source ./$1/bin/activate }
function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
  }
