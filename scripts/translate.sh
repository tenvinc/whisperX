#!/bin/bash

# Function to display help/usage info.
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] FILE

Options:
  -h, --help          Show this help message.
  --task VALUE        Specify the task to perform. Valid values: "transcribe" or "translate".

Example:
  $(basename "$0") --task transcribe /path/to/file
EOF
  exit 1
}

# Check if any argument is -h or --help and display help if found.
for arg in "$@"; do
  if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
    usage
  fi
done

if [ "$1" != "--task" ]; then
  echo "Error: The first argument must be '--task'."
  usage
else
  task=$2
  if [[ "$task" != "translate" && "$task" != "transcribe" ]]; then
      usage
  fi
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
chunk_size=10
filepath=$3

docker run -it --gpus=all \
    -v "$filepath:$filepath" \
    -v "$script_dir/..:/app/whisperx" \
    -v "./.cache:/root/.cache/huggingface/hub" \
    whisperx:latest whisperx "${filepath}" \
    --model large-v3 --language ja \
    --task $task --chunk_size ${chunk_size} --output_dir /app/whisperx/output