#!/bin/bash
#
# Test all Puppet files for syntax errors before deploying
# This work is an improvement of following script :
#   https://github.com/mig5/scripts/blob/master/puppet/puppet-test
#

pp_validation() {
    # Syntax validation of puppet manifests *. pp
    echo "[INFO] Testing the syntax of puppet manifests"
    for file in $(find . -type f -name '*.pp'); do
        puppet parser --color false validate --render-as s $file
        [ $? -ne 0 ] && echo "[ERROR] Some puppet's manifest syntax is incorrect !" && exit 1
    done
    echo "[OK] Tests passed."
}

erb_validation() {
    # Test the .erb template files for syntax errors
    echo "[INFO] Testing the syntax of puppet templates"
    error=0
    for file in $(find . -type f -name '*.erb'); do 
        output=$(erb -x -T '-' $file | ruby -c 2>&1)
        if [ $? -ne 0 ]; then
            echo "$output in $file"
            echo "[ERROR] Some puppet's template syntax is incorrect !"
            exit 1
        fi
    done
    echo "[OK] Tests passed."
}

yaml_validation() {
    # Check YAML files syntax
    echo "[INFO] Testing the yaml files syntax"
    rake ci:yaml_checker
    if [ $? -ne 0 ]; then
        echo "[ERROR] Test the yaml files syntax failed !"
        exit 1
    fi
    echo "[OK] Tests passed."

}

lint_validation() {
    echo "[INFO] Puppet lint verification"
    # Puppet-lint verification
    rake ci:lint
    if [ $? -ne 0 ]; then
        echo "[WARN] Puppet code style not respected !"
        exit 1
    fi
    echo "[OK] Tests passed."
}

pp_validation
erb_validation
yaml_validation
lint_validation
