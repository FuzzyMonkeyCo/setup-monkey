#!/bin/bash -eu

set -o errtrace
set -o pipefail

cd "$GITHUB_WORKSPACE"
cd "$INPUT_WORKDIR"

TMPATH="$(mktemp -d)"
PATH="$TMPATH:$PATH"
echo "PATH=$PATH" >>$GITHUB_ENV

echo '::group:: Installing monkey ... https://github.com/FuzzyMonkeyCo/monkey'
curl -sfL https://raw.githubusercontent.com/FuzzyMonkeyCo/monkey/master/.godownloader.sh | BINDIR="$TMPATH" sh
monkey --version
echo '::endgroup::'

if [[ -n "$INPUT_APIKEY" ]]; then
	export FUZZYMONKEY_API_KEY="$INPUT_APIKEY"
fi

echo "::group:: $ cd $INPUT_WORKDIR && monkey $INPUT_COMMAND $INPUT_ARGS"
set +e
# shellcheck disable=SC2086
monkey "$INPUT_COMMAND" $INPUT_ARGS; code=$?
set -e
echo "::set-output name=code::$code"
if [[ $code -eq 6 ]]; then
	echo "::set-output name=seed::$(monkey pastseed)"
fi
echo '::endgroup::'

rm -rf "$TMPATH"

exit $code
