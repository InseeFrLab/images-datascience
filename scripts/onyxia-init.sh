#!/usr/bin/env bash

echo "start of onyxia-init.sh script as user :"
whoami

sudo true -nv 2>&1
if [ $? -eq 0 ]; then
  echo "sudo_allowed"
  SUDO=0
  sudo update-ca-certificates
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

    if [[ "$VAULT_INJECTION_SA_ENABLED" = "true" && "$VAULT_INJECTION_SA_MODE" = "jwt" ]]; then
        echo "using service account injection jwt to get vault token"
        VAULT_TOKEN=$(vault write -field="token" auth/$VAULT_INJECTION_SA_AUTH_PATH/login role=$VAULT_INJECTION_SA_AUTH_ROLE jwt=@/var/run/secrets/kubernetes.io/serviceaccount/token)
    fi

    # If a token is available (either personal Token injected by Onyxia UI, or SA token
    # obtained in the previous paragraph), proceed to read secrets and export them as envvars
    if  [[ -n "$VAULT_TOKEN" ]]; then
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
            value=$(jq -r .data.data.$i <<< $JSON)
            export $i="${value}"
            if [[ $SUDO -eq 0 ]]; then
                sudo sh -c "printf '%s=\"%s\"\n' $i \"$value\" >> /etc/environment"
                if command -v R; then
                    sudo sh -c "printf '%s=\"%s\"\n' $i \"$value\" >> ${R_HOME}/etc/Renviron.site"
                fi
            else
                sh -c "printf 'export %s=\"%s\"\n' $i \"$value\" >> ~/.bashrc"
                if command -v R; then
                    sh -c "printf '%s=\"%s\"\n' $i \"$value\" >> ${R_HOME}/etc/Renviron.site"
                fi
            fi
        done
    fi
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
    if [ -n "$GIT_USER_NAME" ]; then
        git config --global user.name "$GIT_USER_NAME"
    fi
    if [ -n "$GIT_USER_MAIL" ]; then
        git config --global user.email "$GIT_USER_MAIL"
    fi
    if [ -n "$GIT_CREDENTIALS_CACHE_DURATION" ]; then
        git config --global credential.helper "cache --timeout=$GIT_CREDENTIALS_CACHE_DURATION"
    fi
    # Default strategy when performing a git pull
    # Use Git's former default (fast-forward if possible, else merge) to avoid cryptic error message
    git config --global pull.rebase false

    # Fix permissions
    [ -d ~/.cache/git ] && chown -R ${USERNAME}:${GROUPNAME} ~/.cache/git
    [ -f ~/.gitconfig ] && chown ${USERNAME}:${GROUPNAME} ~/.gitconfig

fi

if command -v R; then
    echo "Renviron.site detected"
    echo -e "MC_HOST_s3=$MC_HOST_s3\nAWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID\nAWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY\nAWS_SESSION_TOKEN=$AWS_SESSION_TOKEN\nAWS_DEFAULT_REGION=$AWS_DEFAULT_REGION\nAWS_S3_ENDPOINT=$AWS_S3_ENDPOINT\nAWS_EXPIRATION=$AWS_EXPIRATION" >> ${R_HOME}/etc/Renviron.site
    echo -e "VAULT_ADDR=$VAULT_ADDR\nVAULT_TOKEN=$VAULT_TOKEN" >> ${R_HOME}/etc/Renviron.site
    echo -e "SPARK_HOME=$SPARK_HOME" >> ${R_HOME}/etc/Renviron.site
    echo -e "HADOOP_HOME=$HADOOP_HOME" >> ${R_HOME}/etc/Renviron.site
    echo -e "HADOOP_OPTIONAL_TOOLS=$HADOOP_OPTIONAL_TOOLS" >> ${R_HOME}/etc/Renviron.site
    if [[ -e "$JAVA_HOME" ]]; then
        echo -e "JAVA_HOME=$JAVA_HOME" >> ${R_HOME}/etc/Renviron.site
    fi
    env | grep "KUBERNETES" >> ${R_HOME}/etc/Renviron.site
    env | grep "IMAGE_NAME" >> ${R_HOME}/etc/Renviron.site
fi

if [[ "$DARK_MODE" == "true" ]]; then 
    if command -v jupyter-lab; then
        mkdir ${CONDA_DIR}/share/jupyter/lab/settings
        echo "{\"@jupyterlab/apputils-extension:themes\": {\"theme\": \"JupyterLab Dark\"}}" > ${CONDA_DIR}/share/jupyter/lab/settings/overrides.json;
    fi 
    if command -v code-server; then
        jq '. + {"workbench.colorTheme": "Default Dark Modern"}' ${HOME}/.local/share/code-server/User/settings.json > ${HOME}/tmp.settings.json  && mv ${HOME}/tmp.settings.json ${HOME}/.local/share/code-server/User/settings.json
    fi
    if command -v rstudio-server; then
        jq '. + {"editor_theme": "Vibrant Ink"}' ${HOME}/.config/rstudio/rstudio-prefs.json > ${HOME}/tmp.settings.json  && mv ${HOME}/tmp.settings.json ${HOME}/.config/rstudio/rstudio-prefs.json
        chown -R ${USERNAME}:${GROUPNAME} ${HOME}/.config
    fi
fi

# inject proxy variables
env_vars=("NO_PROXY" "no_proxy" "HTTP_PROXY" "http_proxy" "HTTPS_PROXY" "https_proxy")

if [[ $SUDO -eq 0 ]]; then
    for var in "${env_vars[@]}"; do
        if [[ -n "${!var}" ]]; then
        sudo sh -c "printf '%s=\"%s\"\n' $var \"${!var}\" >> /etc/environment"
            if command -v R; then
                sudo sh -c "printf '%s=\"%s\"\n' $var \"${!var}\" >> ${R_HOME}/etc/Renviron.site"
            fi
        fi
    done
fi


# Configure duckdb CLI
if [[ -n $AWS_S3_ENDPOINT ]] && command -v duckdb ; then
cat <<EOF > ${HOME}/.duckdbrc
-- Duck head prompt
.prompt 'duckdb > '
-- Set s3 context
CALL load_aws_credentials();
EOF
if [[ $PATH_STYLE_ACCES == 'true' ]] ; then  
echo set S3_URL_STYLE='path' >> ${HOME}/.duckdbrc
fi
if [ "$PATH_STYLE_ACCES" ]; then
    PATH_STYLE="path"
else
    PATH_STYLE="vhost"
fi
duckdb -c "CREATE OR REPLACE PERSISTENT SECRET my_persistent_secret( \
    TYPE S3, \
    KEY_ID '"$AWS_ACCESS_KEY_ID"', \
    SECRET '"$AWS_SECRET_ACCESS_KEY"', \
    REGION '"$AWS_DEFAULT_REGION"', \
    SESSION_TOKEN '"$AWS_SESSION_TOKEN"', \
    ENDPOINT '"$AWS_S3_ENDPOINT"', \
    URL_STYLE '"$PATH_STYLE"' \
  );"

chmod 600  ~/.duckdb/stored_secrets/my_persistent_secret.duckdb_secret

export DUCKDB_S3_ENDPOINT=$AWS_S3_ENDPOINT
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

# Activate Conda env by default in shell except if specified otherwise
if [[ -n "$CONDA_DIR" && "$CUSTOM_PYTHON_ENV" != "true" ]]; then
    echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate" >> ${HOME}/.bashrc ;
fi

echo "execution of $@"
exec "$@"
