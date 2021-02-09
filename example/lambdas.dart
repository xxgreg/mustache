import 'package:mustache/mustache.dart';

void main() {
  var t = Template('{{ foo }}');
  Function lambda = (_) => 'bar';
  var output = t.renderString({'foo': lambda}); // bar
  print(output);

  t = Template('{{# foo }}hidden{{/ foo }}');
  lambda = (_) => 'shown';
  output = t.renderString({'foo': lambda}); // shown
  print(output);

  t = Template('{{# foo }}oi{{/ foo }}');
  lambda = (LambdaContext ctx) => '<b>${ctx.renderString().toUpperCase()}</b>';
  output = t.renderString({'foo': lambda}); // <b>OI</b>
  print(output);

  t = Template('{{# foo }}{{bar}}{{/ foo }}');
  lambda = (LambdaContext ctx) => '<b>${ctx.renderString().toUpperCase()}</b>';
  output = t.renderString({'foo': lambda, 'bar': 'pub'}); // <b>PUB</b>
  print(output);

  t = Template('{{# foo }}{{bar}}{{/ foo }}');
  lambda = (LambdaContext ctx) => '<b>${ctx.renderString().toUpperCase()}</b>';
  output = t.renderString({'foo': lambda, 'bar': 'pub'}); // <b>PUB</b>
  print(output);

  t = Template('{{# foo }}{{bar}}{{/ foo }}');
  lambda = (LambdaContext ctx) => ctx.renderSource(ctx.source + '{{cmd}}');
  output = t
      .renderString({'foo': lambda, 'bar': 'pub', 'cmd': 'build'}); // pub build
  print(output);
}
