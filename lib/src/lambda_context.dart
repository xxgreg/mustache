library mustache.lambda_context;

import 'package:mustache/mustache.dart' as m;

import 'node.dart';
import 'parser.dart' as parser;
import 'renderer.dart';
import 'template_exception.dart';

/// Passed as an argument to a mustache lambda function.
class LambdaContext implements m.LambdaContext {
  final Node _node;
  final Renderer _renderer;
  bool _closed = false;

  LambdaContext(this._node, this._renderer);

  void close() {
    _closed = true;
  }

  void _checkClosed() {
    if (_closed) throw _error('LambdaContext accessed outside of callback.');
  }

  TemplateException _error(String msg) {
    return TemplateException(
        msg, _renderer.templateName, _renderer.source, _node.start);
  }

  /// Render the current section tag in the current context and return the
  /// result as a string.
  @override
  String renderString({Object? value}) {
    _checkClosed();
    if (_node is! SectionNode) {
      _error(
          'LambdaContext.renderString() can only be called on section tags.');
    }
    var sink = StringBuffer();
    _renderSubtree(sink, value);
    return sink.toString();
  }

  void _renderSubtree(StringSink sink, Object? value) {
    var renderer = Renderer.subtree(_renderer, sink);
    var section = _node as SectionNode;
    if (value != null) renderer.push(value);
    renderer.render(section.children);
  }

  @override
  void render({Object? value}) {
    _checkClosed();
    if (_node is! SectionNode) {
      _error('LambdaContext.render() can only be called on section tags.');
    }
    _renderSubtree(_renderer.sink, value);
  }

  @override
  void write(Object object) {
    _checkClosed();
    _renderer.write(object);
  }

  /// Get the unevaluated template source for the current section tag.
  @override
  String get source {
    _checkClosed();

    if (_node is! SectionNode) return '';

    var node = _node as SectionNode;

    var nodes = node.children;

    if (nodes.isEmpty) return '';

    if (nodes.length == 1 && nodes.first is TextNode) {
      return (nodes.single as TextNode).text;
    }

    return _renderer.source.substring(node.contentStart, node.contentEnd);
  }

  /// Evaluate the string as a mustache template using the current context.
  @override
  String renderSource(String source, {Object? value}) {
    _checkClosed();
    var sink = StringBuffer();

    // Lambdas used for sections should parse with the current delimiters.
    String? delimiters = '{{ }}';
    if (_node is SectionNode) {
      var node = _node as SectionNode;
      delimiters = node.delimiters;
    }

    var nodes = parser.parse(
        source, _renderer.lenient, _renderer.templateName, delimiters);

    var renderer =
        Renderer.lambda(_renderer, source, _renderer.indent, sink, delimiters);

    if (value != null) renderer.push(value);
    renderer.render(nodes);

    return sink.toString();
  }

  /// Lookup the value of a variable in the current context.
  @override
  Object? lookup(String variableName) {
    _checkClosed();
    return _renderer.resolveValue(variableName);
  }
}
