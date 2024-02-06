#!/bin/bash

if [ -z "$1" ]
then
  echo "Usage: $0 <aws-profile>"
  echo "Available profiles:"
  grep '^\[\(profile \)\?' ~/.aws/config ~/.aws/credentials | tr -d '[]' | awk '{print $2}'

  exit 1
fi

destino_local="$(pwd)/S3"
profile="$1"
echo "Destination: $destino_local"
echo "Profile: $profile"
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text --profile "$profile")
echo "You are about to synchronize the following buckets:"
for bucket in $buckets; do
    echo "$bucket"
done

echo "Confirm? (y/n)"
read response
if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[sS])+$ ]]
then
    mkdir -p "$destino_local"
    for bucket in $buckets; do
        echo "Getting $bucket..."
        aws s3 sync "s3://$bucket" "$destino_local/$bucket" --profile "$profile"
    done
    echo "Download complete."
else
    echo "Canceled by the user."
fi
