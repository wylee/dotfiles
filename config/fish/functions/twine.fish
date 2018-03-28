# Inspired by https://glyph.twistedmatrix.com/2017/10/careful-with-that-pypi.html
function twine
    # Usage:
    #     1. python setup.py sdist
    #     2. twine upload dist/*
    begin
        set -lx TWINE_USERNAME (lpass show PyPI --username)
        set -lx TWINE_PASSWORD (lpass show PyPI --password)
        command twine $argv
    end
end
