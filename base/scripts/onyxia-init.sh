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

        while IFS= read -r key; do
            [[ -z "$key" ]] && continue
            if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
                echo "skipping Vault secret $key: not a valid environment variable name"
                continue
            fi
            echo "$key"
            value=$(jq -r --arg key "$key" '.data.data[$key]' <<< "$JSON")
            export "$key=$value"
            if [[ $SUDO -eq 0 ]]; then
                printf '%s="%s"\n' "$key" "$value" | sudo tee -a /etc/environment >/dev/null
                if command -v R &>/dev/null; then
                    printf '%s="%s"\n' "$key" "$value" | sudo tee -a "${R_HOME}/etc/Renviron.site" >/dev/null
                fi
            else
                printf 'export %s=%q\n' "$key" "$value" >> "${HOME}/.bashrc"
                if command -v R &>/dev/null; then
                    printf '%s="%s"\n' "$key" "$value" >> "${R_HOME}/etc/Renviron.site"
                fi
            fi
        done <<< "$KEYS"
    fi
fi

if command -v kubectl &>/dev/null; then
    KUBERNETES_SERVICE_ACCOUNT=$(jq -Rr 'split(".")[1] | @base64d | fromjson | .["kubernetes.io"].serviceaccount.name' /var/run/secrets/kubernetes.io/serviceaccount/token)
    KUBERNETES_NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
    export KUBERNETES_SERVICE_ACCOUNT KUBERNETES_NAMESPACE
fi

if [[ $(id -u) = 0 ]]; then
    env | sed 's/^/export /g' | grep "AWS\|VAULT\|KC\|KUB" >> /root/.bashrc
fi

if [[ -z $ROOT_PROJECT_DIRECTORY ]]; then
    ROOT_PROJECT_DIRECTORY="$WORKSPACE_DIR"
fi

# Some images start as root (RStudio): what is written in the home directory has to
# belong to the user, and the credential cache daemon has to run as the user.
git_as_user() {
    if [[ $(id -u) = 0 ]]; then
        sudo -u "$USERNAME" -H git "$@"
    else
        git "$@"
    fi
}

# Scheme, host and port of a URL: what git credentials are matched on.
git_url_origin() {
    [[ "$1" =~ ^https?://[^/]+ ]] && echo "${BASH_REMATCH[0]}"
}

# Configures an entry of GIT_PROVIDERS: the commit identity on this forge and the
# credentials that git uses for it.
configure_git_provider() {
    local provider="$1"
    local id url origin name email identity_file type

    id=$(jq -r '.id' <<< "$provider")
    url=$(jq -r '.url' <<< "$provider")
    origin=$(git_url_origin "$url")
    if [[ -z "$origin" ]]; then
        echo "skipping Git provider $id: not an http(s) URL"
        return
    fi
    echo "configuration of the Git provider $id"

    name=$(jq -r '.user.name // empty' <<< "$provider")
    email=$(jq -r '.user.email // empty' <<< "$provider")
    identity_file="${HOME}/.gitconfig-onyxia-${id//[^a-zA-Z0-9_-]/_}"
    [[ -n "$name" ]] && git_as_user config --file "$identity_file" user.name "$name"
    [[ -n "$email" ]] && git_as_user config --file "$identity_file" user.email "$email"
    if [[ -f "$identity_file" ]]; then
        git_as_user config --global "includeIf.hasconfig:remote.*.url:${url}/**.path" "$identity_file"
    fi

    type=$(jq -r '.credentials.type // empty' <<< "$provider")
    [[ -z "$type" ]] && return

    # An empty value drops the helpers configured so far for this forge, the former
    # credential.helper with a short timeout would otherwise evict the refresh token.
    git_as_user config --global --replace-all "credential.${origin}.helper" ""

    case "$type" in
        token)
            git_as_user config --global --add "credential.${origin}.helper" store
            jq -j --arg origin "$origin" \
                '"url=\($origin)\nusername=\(.credentials.username)\npassword=\(.credentials.token)\n\n"' <<< "$provider" |
                git_as_user credential-store store
            ;;
        oauth)
            local client_id scopes authorization_url token_url device_url refresh_token
            client_id=$(jq -r '.credentials.clientId' <<< "$provider")
            scopes=$(jq -r '.credentials.scopes | join(" ")' <<< "$provider")
            authorization_url=$(jq -r '.credentials.authorizationUrl' <<< "$provider")
            token_url=$(jq -r '.credentials.tokenUrl' <<< "$provider")
            device_url=$(jq -r '.credentials.deviceAuthorizationUrl // empty' <<< "$provider")
            refresh_token=$(jq -r '.credentials.refreshToken // empty' <<< "$provider")

            git_as_user config --global "credential.${origin}.oauthClientId" "$client_id"
            git_as_user config --global "credential.${origin}.oauthScopes" "$scopes"
            git_as_user config --global "credential.${origin}.oauthAuthURL" "$authorization_url"
            git_as_user config --global "credential.${origin}.oauthTokenURL" "$token_url"

            # The cache keeps the access token and, unlike the store helper, the refresh
            # token. It only lives in memory: long enough to outlive the service.
            git_as_user config --global --add "credential.${origin}.helper" "cache --timeout=$GIT_OAUTH_CACHE_TIMEOUT"
            # When it can't refresh, git-credential-oauth falls back on an interactive flow
            # and waits for it without any limit: git would hang.
            if [[ -n "$device_url" ]]; then
                git_as_user config --global "credential.${origin}.oauthDeviceAuthURL" "$device_url"
                git_as_user config --global --add "credential.${origin}.helper" "!timeout 300 git credential-oauth -device"
            else
                # The browser flow can't succeed from a service.
                git_as_user config --global --add "credential.${origin}.helper" "!timeout 30 git credential-oauth"
            fi

            # Seeds the cache with an expired password: git discards it and hands the refresh
            # token to git-credential-oauth. This has to go straight to the helper, "git
            # credential approve" ignores expired credentials.
            if [[ -n "$refresh_token" ]]; then
                printf 'url=%s\nusername=oauth2\npassword=expired\npassword_expiry_utc=1\noauth_refresh_token=%s\n\n' "$origin" "$refresh_token" |
                    git_as_user credential-cache --timeout="$GIT_OAUTH_CACHE_TIMEOUT" store
            fi
            ;;
        *)
            echo "Git provider $id: unknown credentials type $type"
            return
            ;;
    esac

    GIT_PROVIDERS_ORIGINS_WITH_CREDENTIALS+=" $origin "
}

if command -v git &>/dev/null; then
    if [[ -n "$PATH_TO_CA_BUNDLE" ]]; then
        echo "configuration of git to a custom crt"
        git config --global http.sslVerify true
        git config --global http.sslCAInfo $PATH_TO_CA_BUNDLE
    fi

    # Git config
    # NOTE: Before the Git providers, whose identity has to come later in the config to win.
    if [ -n "$GIT_USER_NAME" ]; then
        git config --global user.name "$GIT_USER_NAME"
    fi
    if [ -n "$GIT_USER_MAIL" ]; then
        git config --global user.email "$GIT_USER_MAIL"
    fi
    if [ -n "$GIT_CREDENTIALS_CACHE_DURATION" ]; then
        git config --global credential.helper "cache --timeout=$GIT_CREDENTIALS_CACHE_DURATION"
    fi
    # The ownership of the files git_as_user is about to write to, or to read
    [ -f ${HOME}/.gitconfig ] && chown ${USERNAME}:${GROUPNAME} ${HOME}/.gitconfig

    # GIT_PROVIDERS: git.providers of the Onyxia context, as JSON.
    GIT_OAUTH_CACHE_TIMEOUT=31536000
    GIT_PROVIDERS_ORIGINS_WITH_CREDENTIALS=""
    if [[ -n "$GIT_PROVIDERS" ]] && ! jq -e 'type == "array"' <<< "$GIT_PROVIDERS" &>/dev/null; then
        echo "ignoring GIT_PROVIDERS: not a JSON array"
        GIT_PROVIDERS=""
    fi
    if [[ -n "$GIT_PROVIDERS" ]]; then
        while IFS= read -r provider; do
            configure_git_provider "$provider"
        done < <(jq -c '.[] | select((.credentials.type == "oauth" and .credentials.refreshToken == null) | not)' <<< "$GIT_PROVIDERS")
    fi

    if [[ -n "$GIT_REPOSITORY" ]]; then
        CLONE_URL="$GIT_REPOSITORY"

        # With the credentials of a Git provider nothing goes in the URL: it would be saved
        # in .git/config, in the project directory, and outdated once the token is refreshed.
        if [[ -n "$GIT_PERSONAL_ACCESS_TOKEN" && "$GIT_PROVIDERS_ORIGINS_WITH_CREDENTIALS" != *" $(git_url_origin "$GIT_REPOSITORY") "* ]]; then
            URL_PREFIX=$(echo "$GIT_REPOSITORY" | grep -oE '^https?://')
            URL_NO_PREFIX=$(echo "$GIT_REPOSITORY" | sed 's|^https\?://||')
            REPO_DOMAIN=$(awk -F/ '{print $3}' <<< "$GIT_REPOSITORY")

            if [ "$REPO_DOMAIN" = "github.com" ]; then
                CLONE_URL="${URL_PREFIX}x-access-token:${GIT_PERSONAL_ACCESS_TOKEN}@${URL_NO_PREFIX}"
            elif echo "$GIT_REPOSITORY" | grep -qi "bitbucket"; then
                CLONE_URL="${URL_PREFIX}x-token-auth:${GIT_PERSONAL_ACCESS_TOKEN}@${URL_NO_PREFIX}"
            else
                CLONE_URL="${URL_PREFIX}oauth2:${GIT_PERSONAL_ACCESS_TOKEN}@${URL_NO_PREFIX}"
            fi
        fi

        if [[ -n "$GIT_BRANCH" ]]; then
            git -C "$ROOT_PROJECT_DIRECTORY" clone "$CLONE_URL" --branch "$GIT_BRANCH"
        else
            git -C "$ROOT_PROJECT_DIRECTORY" clone "$CLONE_URL"
        fi
    fi

    # Providers relying on the device flow only, once the project is cloned: nobody is there
    # to enter the code during the startup, the clone would wait for it. Without credentials
    # it fails right away on a private repository, the user can clone it from a terminal.
    if [[ -n "$GIT_PROVIDERS" ]]; then
        while IFS= read -r provider; do
            configure_git_provider "$provider"
        done < <(jq -c '.[] | select(.credentials.type == "oauth" and .credentials.refreshToken == null)' <<< "$GIT_PROVIDERS")
    fi
    # The processes of the service have no use of these credentials, they're now in the
    # helpers. The refresh token is outdated anyway after its first use.
    unset GIT_PROVIDERS

    # Default strategy when performing a git pull
    # Use Git's former default (fast-forward if possible, else merge) to avoid cryptic error message
    git config --global pull.rebase false

    # Give user ownership
    [ -d ${HOME}/.cache/git ] && chown -R ${USERNAME}:${GROUPNAME} ${HOME}/.cache/git
    [ -f ${HOME}/.gitconfig ] && chown -R ${USERNAME}:${GROUPNAME} ${HOME}/.gitconfig

fi

if command -v R &>/dev/null; then
    echo "Renviron.site detected"
    echo -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID\nAWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY\nAWS_SESSION_TOKEN=$AWS_SESSION_TOKEN\nAWS_DEFAULT_REGION=$AWS_DEFAULT_REGION\nAWS_S3_ENDPOINT=$AWS_S3_ENDPOINT\nAWS_EXPIRATION=$AWS_EXPIRATION" >> ${R_HOME}/etc/Renviron.site
    echo -e "VAULT_ADDR=$VAULT_ADDR\nVAULT_TOKEN=$VAULT_TOKEN" >> ${R_HOME}/etc/Renviron.site
    echo -e "SPARK_HOME=$SPARK_HOME" >> ${R_HOME}/etc/Renviron.site
    if [[ -e "$JAVA_HOME" ]]; then
        echo -e "JAVA_HOME=$JAVA_HOME" >> ${R_HOME}/etc/Renviron.site
    fi
    env | grep "KUBERNETES" >> ${R_HOME}/etc/Renviron.site
    env | grep "IMAGE_NAME" >> ${R_HOME}/etc/Renviron.site

    # Configure rproj in rstudio
    if command -v rstudio-server &>/dev/null; then 
        if [[ -n "$GIT_REPOSITORY" ]]; then
            REPO_DIR=$(basename "$GIT_REPOSITORY" .git)
            echo "setHook('rstudio.sessionInit', function(newSession) { if (newSession && identical(getwd(), '${WORKSPACE_DIR}')) { message('Activate RStudio project'); rstudioapi::openProject('${REPO_DIR}'); } }, action = 'append')" >> ${HOME}/.Rprofile
        fi
    fi
fi

if [[ "$DARK_MODE" == "true" ]]; then
    if command -v jupyter-lab &>/dev/null; then
        JUPYTER_APP_DIR=$(jupyter lab path | awk -F': *' '/Application directory/{print $2}')
        mkdir -p $JUPYTER_APP_DIR/settings
        echo "{\"@jupyterlab/apputils-extension:themes\": {\"theme\": \"JupyterLab Dark\"}}" > $JUPYTER_APP_DIR/settings/overrides.json
	    chown ${USERNAME}:${GROUPNAME} $JUPYTER_APP_DIR/settings/overrides.json
    fi
    if command -v code-server &>/dev/null; then
        jq '. + {"workbench.colorTheme": "Default Dark Modern"}' ${HOME}/.local/share/code-server/User/settings.json > ${HOME}/tmp.settings.json  && mv ${HOME}/tmp.settings.json ${HOME}/.local/share/code-server/User/settings.json
	    chown ${USERNAME}:${GROUPNAME} ${HOME}/.local/share/code-server/User/settings.json
    fi
    if command -v rstudio-server &>/dev/null; then
        jq '. + {"editor_theme": "Vibrant Ink"}' ${HOME}/.config/rstudio/rstudio-prefs.json > ${HOME}/tmp.settings.json  && mv ${HOME}/tmp.settings.json ${HOME}/.config/rstudio/rstudio-prefs.json
	    chown ${USERNAME}:${GROUPNAME} ${HOME}/.config/rstudio/rstudio-prefs.json
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
            KEY_ID '$AWS_ACCESS_KEY_ID', \
            SECRET '$AWS_SECRET_ACCESS_KEY', \
            REGION '$AWS_DEFAULT_REGION', \
            SESSION_TOKEN '$AWS_SESSION_TOKEN', \
            ENDPOINT '$AWS_S3_ENDPOINT', \
            URL_STYLE '$AWS_PATH_STYLE' \
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
        chown -R ${USERNAME}:${GROUPNAME} "$f"
    fi
done

# The AWS CLI apparently makes use of the $REQUESTS_CA_BUNDLE variable to configure the trust store.
# In case one is configured for a service based on these images, the variable should be set accordingly.
if [[ -n "$PATH_TO_CA_BUNDLE" ]]; then
    export REQUESTS_CA_BUNDLE=$PATH_TO_CA_BUNDLE
fi

echo "execution of $*"
exec "$@"
