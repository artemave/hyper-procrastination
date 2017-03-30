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
    -H 'Cache-Control: no-cache' \
    -H "Expires: ${dateValue}" \
    -H "Authorization: AWS ${s3Key}:${signature}" \
    "https://${bucket}.s3.amazonaws.com/${file}"
}

function round() {
  if [[ $1 =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    printf "%0.1f" $1
  else
    echo -n $1
  fi
}

results=()

for file in ./results/*.json; do
  tech=$(basename "$file")
  tech=${tech%%.*}
  total=$(round $(cat "$file" | jq -r '.total'))
  request=$(round $(cat "$file" | jq -r '.request'))
  parse=$(round $(cat "$file" | jq -r '.parse'))
  process=$(round $(cat "$file" | jq -r '.process'))
  results+=("$tech $request $parse $process $total")
done

IFS=$'\n'
sorted=($(sort -k5 -n <<<"${results[*]}"))
unset IFS

table_rows=$(for row in "${sorted[@]}"; do \
  cell_values=($row)
  echo "<tr>"
    echo "<td>${cell_values[0]}</td>"
    echo "<td class='value'>${cell_values[1]}s</td>"
    echo "<td class='value'>${cell_values[2]}s</td>"
    echo "<td class='value'>${cell_values[3]}s</td>"
    echo "<td class='total value'>${cell_values[4]}s</td>"
  echo "</tr>"
done)

cat << EOL > results.svg
<?xml version="1.0" standalone="yes"?>
<svg xmlns="http://www.w3.org/2000/svg">
  <foreignObject x="0" y="0" width="375" height="250">
    <body xmlns="http://www.w3.org/1999/xhtml">
      <style type="text/css" media="screen">
        body {
          font-family: arial;
          margin: 0;
        }
        table {
          border-collapse: collapse;
          width: 100%;
        }
        tr {
          border-bottom: 1px solid lightgrey;
        }
        th {
          width: 20%;
          background-color: lightcyan;
          padding: 5px;
        }
        td {
          padding: 5px;
        }
        .total {
          font-weight: bold;
        }
        .value {
          text-align: right;
        }
        .tech {
          text-align: left;
        }
      </style>
      <table>
        <thead>
          <tr>
            <th class='tech'>Tech</th>
            <th class='value'>Request</th>
            <th class='value'>Parse</th>
            <th class='value'>Process</th>
            <th class='value'>Total</th>
          </tr>
        </thead>
        <tbody>
          $table_rows
        </tbody>
      </table>
    </body>
  </foreignObject>
</svg>
EOL

postToS3 results.svg
