part of mustache;

/// Passed as an argument to a mustache lambda function.
class _LambdaContext implements LambdaContext {
  
  final _Node _node;
  final _Renderer _renderer;
  final bool _isSection;
  final bool _isHelper;
  final List<String> _arguments;
  bool _closed = false;
  
  //FIXME remove isSection parameter, can just check node.type instead.
  // Perhaps for isHelper too, once implemented.
  _LambdaContext(this._node, this._renderer,
       {bool isSection: true,
        bool isHelper: false,
        List<String> arguments: const <String>[]})
      : _isSection = isSection,
        _isHelper = isHelper,
        _arguments = arguments;
  
  void close() {
    _closed = true;
  }
  
  _checkClosed() {
    if (_closed) throw new _TemplateException(
        'LambdaContext accessed outside of callback.', 
        _renderer._templateName, _renderer._source, _node.start);
  }

  bool get isSection => _isSection;
  
  bool get isHelper => _isHelper;
  
  List<String> get arguments => _arguments;
  
  //TODO is allowing adding value to the stack a good idea?? Not sure.
  String renderString({Object value}) {
    _checkClosed();
    var buffer = new StringBuffer();
    _renderer._renderSubtree(_node, buffer, value: value);
    return buffer.toString();
  }

  //TODO is allowing adding value to the stack a good idea?? Not sure.
  void render({Object value}) {
    _checkClosed();
    _renderer._renderSubtree(_node, _renderer._sink, value: value);
  }

  void write(Object object) {
    _checkClosed();
    _renderer._sink.write(object);
  }

  String get source {
    _checkClosed();
    
    var nodes = _node.children;
    
    if (nodes.isEmpty) return '';
    
    if (nodes.length == 1 && nodes.first.type == _TEXT)
      return nodes.first.value;
    
    var source = _renderer._source.substring(
        _node.contentStart, _node.contentEnd);
    
    return source;
  }

  //TODO is allowing adding value to the stack a good idea?? Not sure.
  String renderSource(String source, {Object value}) {
    _checkClosed();
    var sink = new StringBuffer();
    // Lambdas used for sections should parse with the current delimiters.
    var delimiters = _isSection ? _renderer._delimiters : '{{ }}';
    var node = _parse(source,
        _renderer._lenient,
        _renderer._templateName,
        delimiters,
        _renderer._helpers);
    var renderer = new _Renderer.lambda(
        _renderer,
        node,
        source,
        _renderer._indent,
        sink,
        _renderer._delimiters);
    
    if (value != null) renderer._stack.add(value);
    renderer.render();
    if (value != null) renderer._stack.removeLast();
    
    return sink.toString();
  }

  /// Lookup the value of a variable in the current context.
  Object lookup(String variableName) {
    _checkClosed();
    return _renderer._resolveValue(variableName);
  }

}