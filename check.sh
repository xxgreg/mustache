#!/bin/bash

# Abort if non-zero code returned.
set -e

dartanalyzer lib/mustache_no_mirrors.dart

dartanalyzer test/mustache_test.dart

dart --checked test/mustache_test.dart

