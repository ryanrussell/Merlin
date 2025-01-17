#!/bin/bash

container=$1
devices=$2

exit_code=0

echo "##################"
echo "# Software check #"
echo "##################"

regex="merlin-(.)*"
if [[ ! "$container" =~ $regex ]]; then
    echo "Check tritonserver for all Merlin containers"
    which tritonserver || exit_code=1
fi

if [ "$container" == "merlin-hugectr" ]; then
    echo "Check HugeCTR for ctr-training container"
    python -c "import hugectr; print(hugectr.__version__)" || exit_code=1

    # TODO: remove this block once
    # https://github.com/NVIDIA-Merlin/HugeCTR/pull/328
    # is in the hugectr release
    cd /hugectr && \
    checker_test && \
    device_map_test && \
    loss_test && \
    optimizer_test && \
    regularizers_test || exit_code=1
fi

if [ "$container" == "merlin-tensorflow" ]; then
    echo "Check TensorFlow for merlin-tensorflow container"
    python -c "import tensorflow; print(tensorflow.__version__)" || exit_code=1
    echo "Check merlin-sok for tf-training container"
    python -c "import sparse_operation_kit; print(sparse_operation_kit.__version__)" || exit_code=1
    # 2023-04-14 Removed until distributed-embeddings are re-added.
    # echo "Check distributed-embeddings for tf-training container"
    # python -c "import distributed_embeddings as tfde; print(tfde.__doc__)" || exit_code=1

    # TODO: remove this block once
    # https://github.com/NVIDIA-Merlin/HugeCTR/pull/328
    # is in the hugectr release
    pushd /hugectr/sparse_operation_kit/sparse_operation_kit/experiment/test/function_test && \
    bash run_function_test.sh && \
    popd || exit_code=1
fi

if [ "$container" == "merlin-pytorch" ]; then
    echo "Check PyTorch for torch-training container"
    python -c "import torch; print(torch.__version__)" || exit_code=1
fi

exit $exit_code
