# START Anaconda #
export PATH="~/anaconda3/bin:$PATH"
alias condaenv='source activate'
alias condaexit='source deactivate'
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/anaconda3/lib
# END Anaconda #

# START Golang #
export GOPATH=~/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
# END Golang #

# START Openshift #
eval $(minishift oc-env)
# END Openshift #