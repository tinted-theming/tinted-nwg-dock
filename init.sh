#!/bin/bash

declare -g configFile="./templates/config.yaml"
declare -g schemeSystem
declare -g schemeSlug
declare -g fileName
declare -g schemeName
declare -g schemeAuthor
declare -g schemeVariant
declare -g customConfigJson

readarray -t schemesFiles < <(find "$HOME"/projects/schemes/base16/ -type f -iname '*.yaml')

function createFile() {
	# Extract filename entry from config
	yq '.default.filename' "$configFile" "/tmp/filename-base16-nwg-dock.txt"

	fileName=$(lustache-cli -i "/tmp/filename-base16-nwg-dock.txt" --json-data "$customConfigJson")

	if [[ -e ./"$fileName" ]]; then
		return
	else
		touch ./"$fileName"
	fi
}

function getProperty() {
	yq -oy "$schemeFile" | yq -o=json -r ".$1"
}

for schemeFile in "${schemesFiles[@]}"; do
	schemeName=$(getProperty "name")
	schemeAuthor=$(getProperty "author")
	schemeSlug=$(basename "$schemeFile" .yaml)
	schemeSystem=$(yq '.default.supported-systems[0]' "$configFile")
	schemeVariant=$(getProperty "variant")

	customConfigJson=$(
		jq --null-input --arg scheme-name "$schemeName" --arg scheme-author "$schemeAuthor" --arg scheme-slug "$schemeSlug" --arg scheme-system "$schemeSystem" --arg scheme-variant "$schemeVariant" '{ "scheme-name": $scheme-name, "scheme-author": $scheme-author, "scheme-slug": $scheme-slug, "scheme-system": $scheme-system, "scheme-variant": $scheme-variant }'
	)

	echo "$schemeName"
	echo "$schemeAuthor"
	echo "$schemeSlug"
	echo "$schemeSystem"
	echo "$schemeVariant"
	echo "$customConfigJson"

	exit

	# createFile
	# lustache-cli -i ./templates/default.mustache --json-data "$customConfigJson"
done
