#!/bin/bash

function postToS3() {
  local file=$1
  local bucket='hyper-procrastination'
  local resource="/${bucket}/${file}"
  local contentType="image/svg+xml"
  local dateValue=$(date -R)
  local stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
  local s3Key=$AWS_SECRET_KEY_ID
  local s3Secret=$AWS_SECRET_KEY

  echo "SENDING TO S3"
  local signature=$(echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64)
  curl -X PUT -T "${file}" \
    -H "Host: ${bucket}.s3.amazonaws.com" \
    -H "Date: ${dateValue}" \
    -H "Content-Type: ${contentType}" \
    -H "Authorization: AWS ${s3Key}:${signature}" \
    "https://${bucket}.s3.amazonaws.com/${file}"
}

function join_by {
  local d=$1
  shift
  echo -n "$1"
  shift
  printf "%s" "${@/#/$d}"
}

results=()

for file in ./results/*.json; do
  tech=$(basename "$file")
  tech=${tech%%.*}
  total=$(cat "$file" | jq '.total')
  results+=("$tech: ${total}s")
done

IFS=$'\n'
sorted=($(sort -k2 -n <<<"${results[*]}"))
unset IFS

escaped=()
for i in "${sorted[@]}"; do
  escaped+=("${i// /%20}")
done

url="https://img.shields.io/badge/results-$(join_by ',%20' ${escaped[@]})-green.svg"
echo $url
curl $url > results.svg

postToS3 results.svg
