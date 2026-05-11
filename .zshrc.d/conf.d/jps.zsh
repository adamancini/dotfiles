jps() {
  jq -r -M --arg key "$1" \
    'paths | select(.[-1]|strings|test($key;"i")) | [.[]|tostring] | join(".") | "." + .[2:]' \
    | sort -u
}
