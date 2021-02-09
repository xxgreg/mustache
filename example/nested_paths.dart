import 'package:mustache/mustache.dart';

void main() {
  var template = Template('{{ author.name }}');
  var output = template.renderString({
    'author': {'name': 'Greg Lowe'}
  });
  print(output);
}
