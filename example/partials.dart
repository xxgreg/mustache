import 'package:mustache/mustache.dart';

void main() {
  var partial = Template('{{ foo }}', name: 'partial');

  var resolver = (String name) {
    if (name == 'partial-name') {
      // Name of partial tag.
      return partial;
    }
  };

  var t = Template('{{> partial-name }}', partialResolver: resolver);

  var output = t.renderString({'foo': 'bar'}); // bar
  print(output);
}
