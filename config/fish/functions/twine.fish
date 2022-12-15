# Inspired by https://glyph.twistedmatrix.com/2017/10/careful-with-that-pypi.html
#
# This assumes that credentials are stored in ~/.pypirc by default.
#
# PyPI tokens should be used for all uploads. These tokens are created
# at https://pypi.org/manage/account/token/, and then added to
# ~/.pypirc, like so:
#
# [distutils]
# index-servers =
#     runcommands
#
# [runcommands]
# repository = https://upload.pypi.org/legacy/
# username = __token__
# password = pypi-<token>
#
# Usage:
#     1. `poetry build` (or `python setup.py sdist`, etc)
#     2. `twine upload dist/*`
function twine
    set -l twine_args $argv
    set -l options "r/repository="
    argparse --name="twine" $options -- $argv or return

    begin
        if set -q _flag_repository
            echo "PyPI repository: $_flag_repository"
        else
            set -x TWINE_REPOSITORY (basename (pwd))
            echo "PyPI repository (derived from directory name): $TWINE_REPOSITORY"
            echo
            echo "NOTE: You can use the -r/--repository option to override this"
        end

        echo
        echo "> twine $twine_args"

        command twine $argv
    end
end
