#!/usr/bin/env bash

echo "start of onyxia-init.sh script as user :"
whoami

sudo true -nv 2>&1
if [ $? -eq 0 ]; then
  echo "sudo_allowed"
  export SUDO=0
  sudo update-ca-certificates
else
  echo "no_sudo"
  export SUDO=1
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
        VAULT_TOKEN=$(curl -s --request POST \
        --data "{\"role\": \"$VAULT_INJECTION_SA_AUTH_ROLE\", \"jwt\": \"$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)\"}" \
        $VAULT_ADDR/v1/auth/$VAULT_INJECTION_SA_AUTH_PATH/login | jq -r .auth.client_token)
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
                if command -v R &>/dev/null; then
                    sudo sh -c "printf '%s=\"%s\"\n' $i \"$value\" >> ${R_HOME}/etc/Renviron.site"
                fi
            else
                sh -c "printf 'export %s=\"%s\"\n' $i \"$value\" >> ${HOME}/.bashrc"
                if command -v R &>/dev/null; then
                    sh -c "printf '%s=\"%s\"\n' $i \"$value\" >> ${R_HOME}/etc/Renviron.site"
                fi
            fi
        done
    fi
fi

if command -v kubectl &>/dev/null; then
    kubectl config set-cluster in-cluster --server=https://kubernetes.default --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    kubectl config set-credentials user --token `cat /var/run/secrets/kubernetes.io/serviceaccount/token`
    kubectl config set-context in-cluster --user=user --cluster=in-cluster --namespace=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`
    kubectl config use-context in-cluster
    export KUBERNETES_SERVICE_ACCOUNT=$(jq -Rr 'split(".")[1] | @base64d | fromjson | .["kubernetes.io"].serviceaccount.name' /var/run/secrets/kubernetes.io/serviceaccount/token)
    export KUBERNETES_NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`
    # Give user ownership on kubectl config file
    chown -R ${USERNAME}:${GROUPNAME} ${HOME}/.kube
fi



if command -v mc &>/dev/null; then
    export MC_HOST_s3=https://$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY:$AWS_SESSION_TOKEN@$AWS_S3_ENDPOINT
fi

if [[ $(id -u) = 0 ]]; then
    env | sed 's/^/export /g' | grep "AWS\|VAULT\|KC\|KUB\|MC" >> /root/.bashrc
fi

if [[ -z $ROOT_PROJECT_DIRECTORY ]]; then
    ROOT_PROJECT_DIRECTORY="$WORKSPACE_DIR"
fi

if command -v git &>/dev/null; then
    if [[ -n "$PATH_TO_CA_BUNDLE" ]]; then
        echo "configuration of git to a custom crt"
        git config --global http.sslVerify true
        git config --global http.sslCAInfo $PATH_TO_CA_BUNDLE
    fi
    if [[ -n "$GIT_REPOSITORY" ]]; then
        if [[ -n "$GIT_PERSONAL_ACCESS_TOKEN" ]]; then
            REPO_DOMAIN=`echo "$GIT_REPOSITORY" | awk -F/ '{print $3}'`
            if [ $REPO_DOMAIN = "github.com" ]; then
                GIT_REPOSITORY=`echo $GIT_REPOSITORY | sed "s/$REPO_DOMAIN/$GIT_PERSONAL_ACCESS_TOKEN@$REPO_DOMAIN/"`
            else
                GIT_REPOSITORY=`echo $GIT_REPOSITORY | sed "s/$REPO_DOMAIN/oauth2:$GIT_PERSONAL_ACCESS_TOKEN@$REPO_DOMAIN/"`
            fi
        fi

        if [[ -n "$GIT_BRANCH" ]]; then
            git -C $ROOT_PROJECT_DIRECTORY clone $GIT_REPOSITORY --branch $GIT_BRANCH
        else
            git -C $ROOT_PROJECT_DIRECTORY clone $GIT_REPOSITORY
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

    # Give user ownership
    [ -d ${HOME}/.cache/git ] && chown -R ${USERNAME}:${GROUPNAME} ${HOME}/.cache/git
    [ -f ${HOME}/.gitconfig ] && chown -R ${USERNAME}:${GROUPNAME} ${HOME}/.gitconfig

fi

if command -v R &>/dev/null; then
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
    if command -v jupyter-lab &>/dev/null; then
        JUPYTER_APP_DIR=$(jupyter lab path | awk -F': *' '/Application directory/{print $2}')
        mkdir -p $JUPYTER_APP_DIR/settings
        echo "{\"@jupyterlab/apputils-extension:themes\": {\"theme\": \"JupyterLab Dark\"}}" > $JUPYTER_APP_DIR/settings/overrides.json
    fi
    if command -v code-server &>/dev/null; then
        jq '. + {"workbench.colorTheme": "Default Dark Modern"}' ${HOME}/.local/share/code-server/User/settings.json > ${HOME}/tmp.settings.json  && mv ${HOME}/tmp.settings.json ${HOME}/.local/share/code-server/User/settings.json
    fi
    if command -v rstudio-server &>/dev/null; then
        jq '. + {"editor_theme": "Vibrant Ink"}' ${HOME}/.config/rstudio/rstudio-prefs.json > ${HOME}/tmp.settings.json  && mv ${HOME}/tmp.settings.json ${HOME}/.config/rstudio/rstudio-prefs.json
    fi
fi

# inject proxy variables
env_vars=("NO_PROXY" "no_proxy" "HTTP_PROXY" "http_proxy" "HTTPS_PROXY" "https_proxy")

if [[ $SUDO -eq 0 ]]; then
    for var in "${env_vars[@]}"; do
        if [[ -n "${!var}" ]]; then
        sudo sh -c "printf '%s=\"%s\"\n' $var \"${!var}\" >> /etc/environment"
            if command -v R &>/dev/null; then
                sudo sh -c "printf '%s=\"%s\"\n' $var \"${!var}\" >> ${R_HOME}/etc/Renviron.site"
            fi
        fi
    done
fi

# Configure duckdb CLI
if command -v duckdb &>/dev/null; then
    echo ".prompt 'duckdb > '" > ${HOME}/.duckdbrc
    chown ${USERNAME}:${GROUPNAME} ${HOME}/.duckdbrc
    if [[ -n $AWS_S3_ENDPOINT ]] ; then
        if [[ -n $AWS_PATH_STYLE_ACCESS ]]; then
            AWS_PATH_STYLE="path"
        else
            AWS_PATH_STYLE="vhost"
        fi
        duckdb -c "CREATE OR REPLACE PERSISTENT SECRET s3_onyxia_connection( \
            TYPE S3, \
            KEY_ID '"$AWS_ACCESS_KEY_ID"', \
            SECRET '"$AWS_SECRET_ACCESS_KEY"', \
            REGION '"$AWS_DEFAULT_REGION"', \
            SESSION_TOKEN '"$AWS_SESSION_TOKEN"', \
            ENDPOINT '"$AWS_S3_ENDPOINT"', \
            URL_STYLE '"$AWS_PATH_STYLE"' \
        );" >/dev/null
        chown -R ${USERNAME}:${GROUPNAME} ${HOME}/.duckdb
    fi
fi

# The commands related to setting the various repositories (R/CRAN, pip)
# are located in specific script
source /opt/onyxia-set-repositories.sh

if [[ -n "$PERSONAL_INIT_SCRIPT" ]]; then
    echo "download $PERSONAL_INIT_SCRIPT"
    curl $PERSONAL_INIT_SCRIPT | bash -s -- $PERSONAL_INIT_ARGS
fi

echo "Fixing ownership in project directory: $ROOT_PROJECT_DIRECTORY"
for f in "$ROOT_PROJECT_DIRECTORY"/*; do
    if [[ -d "$f" && "$(basename $f)" != "lost+found" ]]; then
        chown -R ${USERNAME}:${GROUPNAME} $f
    fi
done

echo "execution of $@"
exec "$@"
