#!/bin/bash

if [ -z ${IMAGE_PREFIX} ]; then
	echo "Must run \`source ./globals.sh\` before this script"
	exit 1
fi

# Array of Docker image names
docker_images=("${IMAGE_PREFIX}-beacon" "${IMAGE_PREFIX}-execution" "${IMAGE_PREFIX}-proxy" "${IMAGE_PREFIX}-grafana" "${IMAGE_PREFIX}-prometheus")

# Loop over each image name
for image in "${docker_images[@]}"; do
  # Check if the image exists
  if docker images -q "$image" | grep -q '.'; then
    echo "Image $image exists. Removing..."
    docker rmi "$image"
  else
    echo "Image $image does not exist. Skipping..."
  fi
done

