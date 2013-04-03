library mustache;

import 'scanner.dart';

var scannerTests = [
'_{{variable}}_',
'_{{variable}}',
'{{variable}}_',
'{{variable}}',
' { ',
' } ',
' {} ',
' }{} ',
'{{{escaped text}}}',
'{{&escaped text}}',
'{{!comment}}',
'{{#section}}oi{{/section}}',
'{{^section}}oi{{/section}}',
'{{>partial}}'
];

main2() {
	for (var src in scannerTests) {
		print('${_pad(src, 40)}${scan(src)}');
	}	
}

main() {
	var source = '{{#section}}_{{var}}_{{/section}}';
	var tokens = scan(source);
	var node = _parse(tokens);
	//var output = render(node, {"section": {"var": "bob"}});
	
	var t = new Template(node);
	var output = t.render({"section": {"var": "bob"}});

	//_visit(node, (n) => print('visit: $n'));
	print(source);
	print(tokens);
	print(node);
	print(output);
}

_pad(String s, int len) {
	for (int i = s.length; i < len; i++)
		s = s + ' ';
	return s;
}

// http://mustache.github.com/mustache.5.html

class Node {
	Node(this.type, this.value);
	final int type;
	final String value;
	final List<Node> children = new List<Node>();

	//FIXME
	toString() => stringify(0);

	stringify(int indent) {
		var pad = '';
		for (int i = 0; i < indent; i++)
			pad = '$pad-';
		var s = '$pad${tokenTypeString(type)} $value\n';		
		++indent;
		for (var c in children) {
			s += c.stringify(indent);
		}
		return s;
	}
}

Node _parse(List<Token> tokens) {
	var stack = new List<Node>()..add(new Node(OPEN_SECTION, 'root'));
	for (var t in tokens) {
		if (t.type == TEXT || t.type == VARIABLE) {
			stack.last.children.add(new Node(t.type, t.value));
		} else if (t.type == OPEN_SECTION || t.type == OPEN_INV_SECTION) {
			var child = new Node(t.type, t.value);
			stack.last.children.add(child);
			stack.add(child);
		} else if (t.type == CLOSE_SECTION) {
			assert(stack.last.value == t.value); //FIXME throw an exception if these don't match.
			stack.removeLast();
		} else {
			throw new UnimplementedError();
		}
	}

	return stack.last;
}

class Template {
	Template(this._root);
	final Node _root;
	final ctl = new List(); //TODO use streams.
	final stack = new List();

	render(values) {
		ctl.clear();
		stack.clear();
		stack.add(values);	
		_root.children.forEach(_renderNode);
		return ctl;
	}

	_renderNode(node) {
		switch (node.type) {
			case TEXT:
				_renderText(node);
				break;
			case VARIABLE:
				_renderVariable(node);
				break;
			case OPEN_SECTION:
				_renderSection(node);
				break;
			case OPEN_INV_SECTION:
				_renderInvSection(node);
				break;
			default:
				throw new UnimplementedError();
		}
	}

	_renderText(node) {
		ctl.add(node.value);
	}

	_renderVariable(node) {
		final value = stack.last[node.value]; //TODO optional warning if variable is null or missing.
		final s = _htmlEscape(value.toString());
		ctl.add(s);
	}

	_renderSectionWithValue(node, value) {
		stack.add(value);
		node.children.forEach(_renderNode);
		stack.removeLast();
	}

	_renderSection(node) {
		final value = stack.last[node.value];
		if (value is List) {
			value.forEach((v) => _renderSectionWithValue(node, v));
		} else if (value is Map) {
			_renderSectionWithValue(node, value);
		} else if (value == true) {
			_renderSectionWithValue(node, {});
		} else {
			print('boom!'); //FIXME
		}
	}

	_renderInvSection(node) {
		final val = stack.last[node.value];
		if ((val is List && val.isEmpty)
				|| val == null
				|| val == false) {
			_renderSectionWithValue(node, {});
		}
	}

	/*
	escape

	& --> &amp;
	< --> &lt;
	> --> &gt;
	" --> &quot;
	' --> &#x27;     &apos; not recommended because its not in the HTML spec (See: section 24.4.1) &apos; is in the XML and XHTML specs.
	/ --> &#x2F; 
	*/
	//TODO
	String _htmlEscape(String s) {
		return s;
	}
}

_visit(Node root, visitor(Node n)) {
	var stack = new List<Node>()..add(root);
	while (!stack.isEmpty) {
		var node = stack.removeLast();
		stack.addAll(node.children);
		visitor(node);
	}
}
