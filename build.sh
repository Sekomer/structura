function check_error {
    if [ $1 -ne 0 ]; then
        echo "Error: $2"
        sudo kill -9 $$
    fi
}

# clean up
sudo rm -rf dist wheelhouse
check_error $? "Cleanup failed"

# build
sudo python setup.py install sdist bdist_wheel
check_error $? "Build failed"

# manylinux 
auditwheel repair dist/*.whl
check_error $? "auditwheel failed"

# remove wheel other than manylinux
sudo rm dist/*.whl
check_error $? "Failed to remove wheel"

# copy manylinux to dist
sudo cp wheelhouse/*.whl dist/
check_error $? "Failed to copy manylinux to dist"

# remove wheelhouse
sudo rm -rf wheelhouse
check_error $? "Failed to remove wheelhouse"

# upload if --upload is specified
if [ "$1" == "--upload" ]; then
    twine upload dist/*
    check_error $? "Failed to upload package"
fi


# run tests
for file in test/*.py; do
    sudo python $file
    check_error $? "Failed to run $file"
done