
export ROOT_DIR=${SCRIPT_DIR}/../
# caches
export BUILD_DIR=${ROOT_DIR}/.duplicati_build
export TEST_DIR=${ROOT_DIR}/.duplicati_test
export ARCHIVE_DIR=${ROOT_DIR}/.duplicati_zip
export PACKAGES_DIR=${ROOT_DIR}/.duplicati_packages
export SIGN_DIR=${ROOT_DIR}/.duplicati_sign
export UPLOAD_DIR=${ROOT_DIR}/.duplicati_upload


export DOCKER_USER=
export DOCKER_REPO=
export AWS_BUCKET_URI=
export AUTO_UPDATE_KEY_FILE="/keys/autoupdate.key.aes"
export GPG_CREDENTIALS_FILE="/keys/gpg_id_passphrase.key.aes"
export GPG_KEY_FILE="/keys/gpg.key.aes"


# secure
export SIGNING_KEY_FILE_PASSWORD=
export DOCKER_PASSWORD=
export AWS_ACCESS_KEY_ID=$(grep aws_access_key_id ~/.aws/credentials | cut -d= -f2 | xargs)
export AWS_SECRET_ACCESS_KEY=$(grep aws_secret_access_key ~/.aws/credentials | cut -d= -f2 | xargs )
