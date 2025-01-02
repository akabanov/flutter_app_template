#!/bin/bash

TEMPLATE_SNAKE="flutter_app_template"
TEMPLATE_CAMEL="flutterAppTemplate"

echo
echo "Checking for required tools"
REQUIRED_TOOLS=("git" "gh" "gcloud" "sed" "flutter" "shorebird" "curl" "bundle")
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    echo "Error: $tool is not installed."
    exit 1
  fi
done
echo "Done"

# Cleanup
flutter clean --quiet
rm -rf .idea .git

# Domain name
read -r -p "Enter the app domain: " DOMAIN
DOMAIN=${DOMAIN:-"sneakybird.app"}
DOMAIN_REVERSED="$(echo "$DOMAIN" | awk -F. '{for(i=NF;i>0;i--) printf "%s%s", $i, (i>1 ? "." : "")}')"

# Project name (snake_cased)
read -r -p "Enter the app name [${PWD##*/}]: " APP_SNAKE
APP_SNAKE=${APP_SNAKE:-${PWD##*/}}

# Project bundle name (camelCased)
APP_CAMEL=$(echo "$APP_SNAKE" | awk -F_ '{for(i=1;i<=NF;i++) printf "%s%s", (i==1?tolower($i):toupper(substr($i,1,1)) tolower(substr($i,2))), ""}')

echo
echo "Init Fastlane"
fastlane init
echo "Done"

read -r -p "Setup Google Cloud integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-gcloud.sh
fi

echo
echo "Replacing template names with real ones"
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_SNAKE}/${APP_SNAKE}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_CAMEL}/${APP_CAMEL}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/example.com/${DOMAIN}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/com.example/${DOMAIN_REVERSED}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/flutter-app-template-445902/${GCLOUD_PROJECT_ID}/g" {} +
echo "Done"

echo
echo "Renaming files and directories from ${TEMPLATE_SNAKE} to ${APP_SNAKE}"
find . -depth -name "*${TEMPLATE_SNAKE}*" -not -path '*/.git/*' -execdir bash -c 'mv "$1" "${1//'"${TEMPLATE_SNAKE}"'/'"${APP_SNAKE}"'}"' _ {} \;
echo "Done"

echo
echo "Renaming Java packages for Android"
JAVA_PKG_PATH="${DOMAIN_REVERSED//./\/}"
JAVA_PKG_ROOTS=("android/app/src/androidTest/java" "android/app/src/main/kotlin")
for path in "${JAVA_PKG_ROOTS[@]}"; do
# skip on subsequent runs
  if [ -d "${path}" ]; then
    mkdir -p "${path}/${JAVA_PKG_PATH}"
    mv "${path}"/com/example/* "${path}/${JAVA_PKG_PATH}"
    find "${path}" -type d -empty -delete
  fi
done
echo "Done"

echo
echo "Adding basic Flutter dependencies"
flutter pub add json_annotation
flutter pub add dev:json_serializable
flutter pub add go_router
flutter pub add dev:mocktail
flutter pub add dev:golden_screenshot
echo "Done"

echo
echo "Integrating with Shorebird"
shorebird login
flutter build apk
shorebird init
echo "Done"

echo
echo "Creating git repository"
GIT_REPO_URL="https://github.com/$(gh api user --jq '.login')/$APP_SNAKE.git"
echo "Repo URL: ${GIT_REPO_URL}"
gh auth status 2>/dev/null || gh auth login
gh repo create "$APP_SNAKE" --private --confirm
git init -b main
git add -A .
git commit -m "Initial commit"
git remote add origin "$GIT_REPO_URL"
git push -u origin main
echo "Done"

read -r -p "Setup Codemagic integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-codemagic.sh
fi
