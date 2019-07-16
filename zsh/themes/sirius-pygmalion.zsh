# =========================================================================== #
# Sirius Lab custom pygmalion prompt theme
# =========================================================================== #
prompt_setup_pygmalion(){
  # ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}"
  # ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
  # ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}⚡%{$reset_color%}"
  # ZSH_THEME_GIT_PROMPT_CLEAN=""
  ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
  ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%} %{$fg[yellow]%}✗%{$reset_color%}"
  ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}"

  ZSH_THEME_HG_PROMPT_PREFIX="%{$fg[magenta]%}"
  ZSH_THEME_HG_PROMPT_SUFFIX="%{$reset_color%}"
  ZSH_THEME_HG_PROMPT_DIRTY="%{$fg[magenta]%} %{$fg[yellow]%}✗%{$reset_color%}"
  ZSH_THEME_HG_PROMPT_CLEAN="%{$fg[magenta]%}"

  pt_user="%{$fg[magenta]%}%n%{$reset_color%}"
  pt_at="%{$fg[cyan]%}@%{$reset_color%}"
  pt_host="%{$fg[yellow]%}%m%{$reset_color%}"
  pt_colon="%{$fg[red]%}:%{$reset_color%}"
  pt_pwd="%{$fg[cyan]%}%0~%{$reset_color%}"
  pt_pipe="%{$fg[red]%}|%{$reset_color%}"

  base_prompt="$pt_user$pt_at$pt_host$pt_colon$pt_pwd$pt_pipe"
  base_prompt_nocolor=$(echo "$base_prompt" | perl -pe "s/%\{[^}]+\}//g")

  precmd_functions+=(prompt_pygmalion_precmd)
}

prompt_pygmalion_precmd(){
  # Change prompt if root
  if [ "$EUID" -ne 0 ]
  then
    local post_prompt="%{$fg[cyan]%}$%{$reset_color%}  "
  else
    local post_prompt="%{$fg[cyan]%}#%{$reset_color%}  "
  fi

  local post_prompt_nocolor=$(echo "$post_prompt" | perl -pe "s/%\{[^}]+\}//g")

  local gitinfo=$(git_prompt_info)
  local gitinfo_nocolor=$(echo "$gitinfo" | perl -pe "s/%\{[^}]+\}//g")

  # Disabling Mercurial because it's slow? Uncomment below to re-enable.
  # local hginfo=$(hg_prompt_info)

  local hginfo=""
  local hginfo_nocolor=$(echo "$hginfo" | perl -pe "s/%\{[^}]+\}//g")

  local exp_nocolor="$(print -P \"$base_prompt_nocolor$hginfo_nocolor$gitinfo_nocolor$post_prompt_nocolor\")"
  local prompt_length=${#exp_nocolor}


  local nl=$'\n%{\r%}'

  ## Uncomment below to change whether to add a newline
  ## before post-promt based on length
  #local nl=""

  #if [[ $prompt_length -gt 40 ]]; then
  #  nl=$'\n%{\r%}';
  #fi
  
  PROMPT="$base_prompt$hginfo$gitinfo$nl$post_prompt"
  RPROMPT="%{$fg[green]%}$(virtualenv_prompt_info)%{$reset_color%}"
}

prompt_setup_pygmalion
