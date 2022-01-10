#!/bin/bash -eu

set -o errtrace
set -o pipefail

cd "$GITHUB_WORKSPACE"
cd "$INPUT_WORKDIR"

TMPATH="$RUNNER_TEMP/.fuzzymonkey"
mkdir -p "$TMPATH"
echo "$TMPATH" >>"$GITHUB_PATH"
PATH="$TMPATH:$PATH"

echo '::group:: Installing monkey ... https://github.com/FuzzyMonkeyCo/monkey'
curl -sfL https://raw.githubusercontent.com/FuzzyMonkeyCo/monkey/master/.godownloader.sh | BINDIR="$TMPATH" sh
monkey --version
echo '::endgroup::'

if [[ -z "$INPUT_COMMAND" ]]; then
	# No command given: this is a setup action
	exit 0
fi

echo "::group:: $ cd $INPUT_WORKDIR && monkey $INPUT_COMMAND $INPUT_ARGS"
set +e
if [[ -n "$INPUT_APIKEY" ]]; then
	# shellcheck disable=SC2086
	FUZZYMONKEY_API_KEY="$INPUT_APIKEY" monkey "$INPUT_COMMAND" $INPUT_ARGS; code=$?
else
	# shellcheck disable=SC2086
	monkey "$INPUT_COMMAND" $INPUT_ARGS; code=$?
fi
set -e
echo "::set-output name=code::$code"
if [[ $code -eq 6 ]]; then
	echo "::set-output name=seed::$(monkey pastseed)"
fi
echo '::endgroup::'

rm -rf "$TMPATH"

exit $code
