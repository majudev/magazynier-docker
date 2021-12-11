#!/bin/bash
DESTINATION="$(dirname "$(readlink -f "$0")")"

cd /tmp
mkdir docker-zip
cd docker-zip
git clone https://github.com/majudev/magazynier.git
cd magazynier
echo "Enter tag:"
read tag
if [[ "$tag" == "dev" ]]; then
	git checkout dev
elif [[ "$tag" == "master" ]]; then
	git checkout master
else
	git checkout tags/$tag
fi
./gradlew bootJar
./gradlew generateSchema
cd ..
mkdir zip
cd zip
cp ../magazynier/build/libs/Magazynier*.jar Magazynier.jar
cp ../magazynier/schema.sql .
cp -r ../magazynier/frontend magazynier
zip Magazynier-$tag.zip *.jar *.sql magazynier/* magazynier/*/* magazynier/*/*/*
cd $DESTINATION
cp /tmp/docker-zip/zip/Magazynier-$tag.zip .
rm -rf /tmp/docker-zip

echo "Alter Dockerfile? (y/n)"
read alter

if [[ "$alter" == "y" ]]; then
	sed -i -E 's/(Magazynier-).+(\.zip .+)/\1'$tag'\2/g' Dockerfile
	sed -i -E 's_(majudev/magazynier:).+( )_\1'$tag'\2_g' README.md
	echo "echo $tag" > scripts/version.sh
fi
