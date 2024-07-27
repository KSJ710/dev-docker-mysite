taar () {
  terraform apply -auto-approve -replace="${1}"
}

tpt () {
  terraform plan -target="${1}"
}

tpgco () {
  terraform plan -generate-config-out="${1}"
}

taat () {
  terraform apply -auto-approve -target="${1}"
}

taatm () {
  terraform apply -auto-approve -target="module.${1}"
}