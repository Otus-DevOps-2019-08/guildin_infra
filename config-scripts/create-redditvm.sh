#!/bin/bash
gcloud compute instances create reddit-full-instance\
  --boot-disk-size=10GB \
  --image-family reddit-full \
  --machine-type=f1-micro \
  --restart-on-failure
