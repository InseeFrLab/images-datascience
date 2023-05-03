#!/usr/bin/env bash


echo "start of onyxia-init.sh script en tant que :"
whoami

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
        export $i=$(eval echo $(jq -r ".data.data.$i" <<< "$JSON"))
        sudo sh -c "echo $i=\"`jq -r \".data.data.$i\" <<< \"$JSON\"`\" >> /etc/environment"
        if [[ -e "${R_HOME}/etc/" ]]; then
            sudo sh -c "echo $i=\"`jq -r \".data.data.$i\" <<< \"$JSON\"`\" >> ${R_HOME}/etc/Renviron.site"
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
    
    if [[ -n "$R_REPOSITORY" ]]; then
        echo "configuration r (add local repository)"
        # To indent a heredoc, <<- and tabs are required (no spaces allowed)
        cat <<-EOF > ${R_HOME}/etc/Rprofile.site
		# https://docs.rstudio.com/rspm/admin/serving-binaries/#binaries-r-configuration-linux
		options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))
		# Proxy repository for R
		local({
			r <- getOption("repos")
			r["LocalRepository"] <- "${R_REPOSITORY}"
			options(repos = r)
		})
		EOF

    fi

    # Configure renv to use the specified package repository
    echo 'options(renv.config.repos.override = getOption("repos"))' >> ${R_HOME}/etc/Rprofile.site
fi

if [[ -e "$HOME/work" ]]; then
  if [[ $(id -u) = 0 ]]; then
    echo "cd $HOME/work" >> /etc/profile
  else
    echo "cd $HOME/work" >> $HOME/.bashrc
  fi
fi

if [  "`which pip`" != "" ]; then
    if [[ -n "$PIP_REPOSITORY" ]]; then
        echo "configuration pip (index-url)"
        pip config set global.index-url $PIP_REPOSITORY
    fi
    if [[ -n "$PATH_TO_CA_BUNDLE" ]]; then
        echo "configuration of pip to a custom crt"
        pip config set global.cert $PATH_TO_CA_BUNDLE
    fi
fi

if [  "`which conda`" != "" ]; then
    if [[ -n "$CONDA_REPOSITORY" ]]; then
        echo "configuration conda (add channels)"
        conda config --add channels $CONDA_REPOSITORY
        conda config --remove channels conda-forge
        conda config --remove channels conda-forge --file /opt/mamba/.condarc
    fi
    if [[ -n "$PATH_TO_CA_BUNDLE" ]]; then
        echo "configuration of conda to a custom crt"
        conda config --set ssl_verify $PATH_TO_CA_BUNDLE
    fi
fi

if [  "`which python`" != "" ]; then
    if [ -n "$PATH_TO_CA_BUNDLE" ]; then
        python /opt/certifi_ca.py
    fi 
fi

if [[ -n "$FAUXPILOT_SERVER" ]]; then
    dir="$HOME/.local/share/code-server/User"
    file="settings.json"
    jq --arg key "fauxpilot.server" --arg value "$FAUXPILOT_SERVER" --indent 4 '. += {($key): $value}'  $dir/$file > $dir/$file.tmp && mv $dir/$file.tmp $dir/$file
    jq --arg key "fauxpilot.enabled" --argjson value "true" --indent 4 '. += {($key): $value}'  $dir/$file > $dir/$file.tmp && mv $dir/$file.tmp $dir/$file
fi

if [[ -n "$PERSONAL_INIT_SCRIPT" ]]; then
    echo "download $PERSONAL_INIT_SCRIPT"
    curl $PERSONAL_INIT_SCRIPT | bash -s -- $PERSONAL_INIT_ARGS
fi

echo "execution of $@"
exec "$@"
