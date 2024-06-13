#!/bin/bash

#installs the pkcs11 libraries.
set -e

DEFAULT_ZIP_PATH=artifactory/libs-release-local/cloudhsm/cloudhsm.zip
[ -z "$hsm_zip_file_path" ] && zip_path="$DEFAULT_ZIP_PATH" || zip_path="$hsm_zip_file_path"

DEFAULT_JAR_PATH=artifactory/libs-release-local/cloudhsm/aws-cloudhsm-keystore-impl.jar
[ -z "$cloudhsm_keystore_impl_url_env" ] && jar_path="$artifactory_url_env/$DEFAULT_JAR_PATH" || jar_path="$cloudhsm_keystore_impl_url_env"

echo "Download the client from $artifactory_url_env"
echo "Zip File Path: $zip_path"
echo "Jar File Path: $jar_path"

wget -q --show-progress "$artifactory_url_env/$zip_path"
echo "Downloaded $artifactory_url_env/$zip_path"
wget -q --show-progress "$jar_path" -O "${loader_path_env}"/aws-cloudhsm-keystore-impl.jar
echo "Downloaded $jar_path"

FILE_NAME=${zip_path##*/}

DIR_NAME=$hsm_local_dir_name

CLOUDHSM_IP_ADDRESS=$cloudhsm_ip_address_env

ADDITIONAL_JARS=$loader_path_env

has_parent=$(zipinfo -1 "$FILE_NAME" | awk '{split($NF,a,"/");print a[1]}' | sort -u | wc -l)
if test "$has_parent" -eq 1; then
  echo "Zip has a parent directory inside"
  dirname=$(zipinfo -1 "$FILE_NAME" | awk '{split($NF,a,"/");print a[1]}' | sort -u | head -n 1)
  echo "Unzip directory"
  unzip $FILE_NAME
  echo "Renaming directory"
  mv -v $dirname $DIR_NAME
else
  echo "Zip has no parent directory inside"
  echo "Creating destination directory"
  mkdir "$DIR_NAME"
  echo "Unzip to destination directory"
  unzip -d "$DIR_NAME" $FILE_NAME
fi

echo "Attempting to install"
echo $DIR_NAME
cd ./$DIR_NAME
chmod +x install.sh
chmod +x cloudhsm-client_latest_u18.04_amd64.deb
chmod +x libjson-c3_0.12.1-1.3ubuntu0.3_amd64.deb
chmod +x openssl1.0_1.0.2n-1ubuntu5.10_amd64.deb
chmod +x libedit2_3.1-20170329-1_amd64.deb
chmod +x libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb
ls -ltr
sudo ./install.sh $CLOUDHSM_IP_ADDRESS $ADDITIONAL_JARS
echo "Installation complete"
cd $work_dir

exec "$@"