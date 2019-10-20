terraform {
  backend "gcs" {
    bucket = "eu-test-backet00"
    prefix = "terraform/stage"
  }
} 