// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html' as dom;
import 'package:mustache/mustache.dart';

@mustache
class Version {
    final int major;
    final int minor;

    Version(this.major, this.minor);
}

@mustache
class DartLang {
    final String name;
    final Version version;
    final String message;

    DartLang(this.name, this.version, this.message);
}

void main() {
    final Template template = new Template(
        """
            <div>
            Language: {{name}}<br>
            Version: {{version.major}}.{{version.minor}}<br>
            Comment: {{message}}
            </div>
        """.trim(), lenient: false,htmlEscapeValues: false);
    final DartLang language = new DartLang("Dart",new Version(1,13),"Your Dart app is running.");

    final String content = template.renderString(language);
    final dom.Element child = new dom.Element.html(content);

  dom.querySelector('#output').append(child);
}
