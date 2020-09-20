provider "google" {
  project = "carscraper-219420"
  region  = "us-central1"
  zone    = "us-central1-c"
}

# google storage buckets must have unique IDs.
# We generate a random ID to alleviate namespace collisions of an entire class doing this project
resource "random_id" "bucket_name_part" {
  byte_length = 8
}

resource "google_storage_bucket" "code_bucket" {
  name = "code-bucket-${random_id}"
}

resource "google_storage_bucket_object" "code" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./path/to/zip/file/which/contains/code" # TODO: SET THIS
}

resource "google_cloudfunctions_function" "math_function" {
  name        = "math-function-${random_id}"
  description = "Adds some numbers"
  runtime     = "python37"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.code_bucket.name
  source_archive_object = google_storage_bucket_object.code.name
  trigger_http          = true
  entry_point           = "helloGET"
  timeout               = 30
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.math_function.project
  region         = google_cloudfunctions_function.math_function.region
  cloud_function = google_cloudfunctions_function.math_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}