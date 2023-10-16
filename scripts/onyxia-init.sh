#!/usr/bin/env bash

echo "start of onyxia-init.sh script en tant que :"
whoami

sudo true -nv 2>&1
if [ $? -eq 0 ]; then
  echo "sudo_allowed"
  SUDO=0
else
  echo "no_sudo"
  SUDO=1
fi

if [[ -n "$REGION_INIT_SCRIPT" ]]; then
    echo "download $REGION_INIT_SCRIPT"
    # The insecure flag is used as a temporary fix to accomodate Onyxia instances
    # not open to the internet. This should be removed as soon as region-specific
    # configurations are properly handled.
    # See : https://github.com/InseeFrLab/onyxia/issues/56
    curl --insecure $REGION_INIT_SCRIPT | bash
fi

if  [[ -n "$VAULT_RELATIVE_PATH" ]]; then

    JSON=$(wget -qO- \
        --header="X-Vault-Token: $VAULT_TOKEN" \
        $VAULT_ADDR/v1/$VAULT_MOUNT/data/$VAULT_TOP_DIR/$VAULT_RELATIVE_PATH )

    KEYS=""

    if [ "$(jq -r '.data.data.".onyxia"' <<< "$JSON")" == "null" ]
    then
        KEYS=$(jq -r '.data.data | keys | .[]' <<< "$JSON")
    else
        KEYS=$(jq -r '.data.data.".onyxia".keysOrdering | .[]' <<< "$JSON")
    fi

    for i in $KEYS; 
    do 
        echo $i
        export "$i=$(eval echo $(jq -r ".data.data.$i" <<< "$JSON"))"
        if [[ $SUDO -eq 0 ]]; then
            echo "sudo alternative"
            sudo sh -c "echo $i=\"`jq -r \".data.data.$i\" <<< \"$JSON\"`\" >> /etc/environment"
            if [[ -e "${R_HOME}/etc/" ]]; then
                sudo sh -c "echo $i=\"`jq -r \".data.data.$i\" <<< \"$JSON\"`\" >> ${R_HOME}/etc/Renviron.site"
            fi
        else
            echo "not sudo alternative"
            sh -c "echo export $i=\"`jq -r \".data.data.$i\" <<< \"$JSON\"`\" >> ~/.bashrc"
            if [[ -e "${R_HOME}/etc/" ]]; then
                sh -c "echo $i=\"`jq -r \".data.data.$i\" <<< \"$JSON\"`\" >> ${R_HOME}/etc/Renviron.site"
            fi
        fi
    done
fi

if [  "`which kubectl`" != "" ]; then
    kubectl config set-cluster in-cluster --server=https://kubernetes.default --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    kubectl config set-credentials user --token `cat /var/run/secrets/kubernetes.io/serviceaccount/token`
    kubectl config set-context in-cluster --user=user --cluster=in-cluster --namespace=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`
    kubectl config use-context in-cluster
    export KUBERNETES_SERVICE_ACCOUNT=`cat /var/run/secrets/kubernetes.io/serviceaccount/token | tr "." "\n" | head -2 | tail -1 | base64 --decode | jq -r ' .["kubernetes.io"].serviceaccount.name'`
    export KUBERNETES_NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`
    # Fix permissions on kubectl config file
    chown -R onyxia:users ${HOME}/.kube 
fi



if [  "`which mc`" != "" ]; then
    export MC_HOST_s3=https://$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY:$AWS_SESSION_TOKEN@$AWS_S3_ENDPOINT
fi

if [[ $(id -u) = 0 ]]; then
    env | sed 's/^/export /g' | grep "AWS\|VAULT\|KC\|KUB\|MC" >> /root/.bashrc
fi


if [  "`which git`" != "" ]; then
    if [[ -n "$PATH_TO_CA_BUNDLE" ]]; then
        echo "configuration of git to a custom crt"
        git config --global http.sslVerify true
        git config --global http.sslCAInfo $PATH_TO_CA_BUNDLE
    fi
    if [[ -n "$GIT_REPOSITORY" ]]; then
        if [[ -n "$GIT_PERSONAL_ACCESS_TOKEN" ]]; then
            REPO_DOMAIN=`echo "$GIT_REPOSITORY" | awk -F/ '{print $3}'`
            if [  $REPO_DOMAIN = "github.com" ]; then
                COMMAND=`echo git clone $GIT_REPOSITORY | sed "s/$REPO_DOMAIN/$GIT_PERSONAL_ACCESS_TOKEN@$REPO_DOMAIN/"`
            else
                COMMAND=`echo git clone $GIT_REPOSITORY | sed "s/$REPO_DOMAIN/oauth2:$GIT_PERSONAL_ACCESS_TOKEN@$REPO_DOMAIN/"`
            fi
        else
            COMMAND=`echo git clone $GIT_REPOSITORY`
        fi

        if [[ -n "$GIT_BRANCH" ]]; then
            COMMAND="$COMMAND --branch $GIT_BRANCH"
        fi

        if [[ -n "$ROOT_PROJECT_DIRECTORY" ]]; then
            if [[ `ls $ROOT_PROJECT_DIRECTORY | grep -v "lost+found"` = "" ]]; then
                cd $ROOT_PROJECT_DIRECTORY 
                $COMMAND               
                for f in *; do
                    echo $f
                    if [[ -d "$f" && $f != "lost+found" ]]; then
                        echo directory
                        chown -R $PROJECT_USER:$PROJECT_GROUP $f
                    fi
                done
                cd $HOME  
            fi

        fi
    fi

    # Git config
    if [[ $(id -u) = 0 ]]; then
        git_config="system"
    else
        git_config="global"
    fi
    if [ -n "$GIT_USER_NAME" ]; then
        git config --"$git_config" user.name "$GIT_USER_NAME"
    fi
    if [ -n "$GIT_USER_MAIL" ]; then
        git config --"$git_config" user.email "$GIT_USER_MAIL"
    fi
    if [ -n "$GIT_CREDENTIALS_CACHE_DURATION" ]; then
        git config --"$git_config" credential.helper "cache --timeout=$GIT_CREDENTIALS_CACHE_DURATION"
    fi
fi

if command -v R; then
    echo "Renviron.site detected"
    echo -e "MC_HOST_s3=$MC_HOST_s3\nAWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID\nAWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY\nAWS_SESSION_TOKEN=$AWS_SESSION_TOKEN\nAWS_DEFAULT_REGION=$AWS_DEFAULT_REGION\nAWS_S3_ENDPOINT=$AWS_S3_ENDPOINT\nAWS_EXPIRATION=$AWS_EXPIRATION" >> ${R_HOME}/etc/Renviron.site
    echo -e "VAULT_ADDR=$VAULT_ADDR\nVAULT_TOKEN=$VAULT_TOKEN" >> ${R_HOME}/etc/Renviron.site
    echo -e "SPARK_HOME=$SPARK_HOME" >> ${R_HOME}/etc/Renviron.site
    echo -e "HADOOP_HOME=$HADOOP_HOME" >> ${R_HOME}/etc/Renviron.site
    echo -e "HADOOP_OPTIONAL_TOOLS=$HADOOP_OPTIONAL_TOOLS" >> ${R_HOME}/etc/Renviron.site
    echo -e "PATH=$JAVA_HOME/bin:$SPARK_HOME/bin:$HADOOP_HOME/bin:$PATH" >> /etc/environment
    echo -e "export PATH=$JAVA_HOME/bin:$SPARK_HOME/bin:$HADOOP_HOME/bin:$PATH" >> /etc/profile
    if [[ -e "/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64" ]]; then
        echo -e "JAVA_HOME=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64" >> ${R_HOME}/etc/Renviron.site
    fi
    env | grep "KUBERNETES" >> ${R_HOME}/etc/Renviron.site
    env | grep "IMAGE_NAME" >> ${R_HOME}/etc/Renviron.site
fi

if [[ -n "$DARK_MODE" ]]; then 
    if command -v jupyter lab; then
        echo "{\"@jupyterlab/apputils-extension:themes\": {\"theme\": \"JupyterLab Dark\"}}" > ${MAMBA_DIR}/share/jupyter/lab/settings/overrides.json;
    fi
    if command -v vscode; then
        jq '.|= . + {"workbench.colorTheme": "Default Dark Modern", }' vscode/settings/User.json 
    fi
    if command -v R; then
        touch ${R_HOME}/etc/Rprofile.site
        echo "if (Sys.getenv('DARK_MODE')=='TRUE'){
            setHook('rstudio.sessionInit', function(newSession) {
            rstudioapi::applyTheme("Dracula")
            }, action = 'append')
        }" >> ${R_HOME}/etc/Rprofile.site
    fi
fi

if [[ -e "$HOME/work" ]]; then
  if [[ $(id -u) = 0 ]]; then
    echo "cd $HOME/work" >> /etc/profile
  else
    echo "cd $HOME/work" >> $HOME/.bashrc
  fi
fi

if [[ -n "$FAUXPILOT_SERVER" ]]; then
    dir="$HOME/.local/share/code-server/User"
    file="settings.json"
    jq --arg key "fauxpilot.server" --arg value "$FAUXPILOT_SERVER" --indent 4 '. += {($key): $value}'  $dir/$file > $dir/$file.tmp && mv $dir/$file.tmp $dir/$file
    jq --arg key "fauxpilot.enabled" --argjson value "true" --indent 4 '. += {($key): $value}'  $dir/$file > $dir/$file.tmp && mv $dir/$file.tmp $dir/$file
fi

# The commands related to setting the various repositories (R/CRAN, pip, conda)
# are located in specific script
source /opt/onyxia-set-repositories.sh

if [[ -n "$PERSONAL_INIT_SCRIPT" ]]; then
    echo "download $PERSONAL_INIT_SCRIPT"
    curl $PERSONAL_INIT_SCRIPT | bash -s -- $PERSONAL_INIT_ARGS
fi

echo "execution of $@"
exec "$@"
