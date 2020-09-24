provider "google" {
  project = "{YOUR_PROJECT_ID}"
  region  = "us-central1"
  zone    = "us-central1-c"
}

# google storage buckets must have unique IDs.
# We generate a random ID to alleviate namespace collisions of an entire class doing this project
resource "random_id" "bucket_name_part" {
  byte_length = 8
}

# We create a bucket (or storage area) to store our function's code
resource "google_storage_bucket" "code_bucket" {
  name = "seis664-code-bucket-${random_id.bucket_name_part.hex}"
}

# We push our zipped code file into our bucket
resource "google_storage_bucket_object" "code" {
  name   = "multiply.zip"
  bucket = google_storage_bucket.code_bucket.name
  source = "./multiply.zip"
}

# Here is our function definition.
resource "google_cloudfunctions_function" "math_function" {
  name        = "math-function-${random_id.bucket_name_part.hex}"
  description = "Does math and other things"
  runtime     = "python37"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.code_bucket.name
  source_archive_object = google_storage_bucket_object.code.name
  trigger_http          = true
  entry_point           = "entry"
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