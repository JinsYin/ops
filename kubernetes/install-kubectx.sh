#!/bin/bash
# Author: JinsYin <github.com/jinsyin>
# https://github.com/ahmetb/kubectx

set -e

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
}

# fn::command_exists wget
fn::command_exists()
{
  command -v $@ > /dev/null 2>&1
}

fn::install_kubectx_tools()
{
  local components=(kubectx kubens utils.bash)

  for component in ${components[@]}; do
    if ! fn::command_exists ${component}; then
      wget -O /usr/bin/${component} https://raw.githubusercontent.com/ahmetb/kubectx/master/${component}
      chmod +x /usr/bin/${component}
    fi
  done
}

fn::install_completion_scripts()
{
  local scripts=(kubectx.bash kubens.bash)
  mkdir -p /etc/bash_completion.d

  for script in ${scripts[@]}; do
    if [ ! -f /etc/bash_completion.d/${script} ]; then
      wget -O /etc/bash_completion.d/${script} https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/${script}
    fi

    if ! grep "^. /etc/bash_completion.d/${script}" /etc/bash_completion > /dev/null 2>&1; then
      echo ". /etc/bash_completion.d/${script}" >> /etc/bash_completion
    fi
  done

  if ! grep "^. /etc/bash_completion" ~/.bashrc > /dev/null 2>&1; then
    echo ". /etc/bash_completion" >> ~/.bashrc
    source ~/.bashrc
  fi
}

main()
{
  fn::install_kubectx_tools $@
  fn::install_completion_scripts $@
}

main $@