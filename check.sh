#!/bin/bash

# Abort if non-zero code returned.
set -e

dart_analyzer --type-checks-for-inferred-types lib/mustache.dart
dart_analyzer --type-checks-for-inferred-types test/mustache_test.dart

dart --checked test/mustache_test.dart

