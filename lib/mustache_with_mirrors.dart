import 'dart:mirrors';

export 'mustache.dart' hide Template;
import 'mustache.dart' as m;
import 'src/template.dart' as t;

class Template extends t.Template {
  Template(String source,
      {bool lenient = false,
      bool htmlEscapeValues = true,
      String name,
      m.PartialResolver partialResolver,
      String delimiters = '{{ }}',
      m.ValueResolver valueResolver})
      : super.fromSource(source,
            lenient: lenient,
            htmlEscapeValues: htmlEscapeValues,
            name: name,
            partialResolver: partialResolver,
            delimiters: delimiters,
            valueResolver:
            valueResolver ??
                (lenient ? lenientMirrorValueResolver : mirrorValueResolver));
}

final RegExp _validTag = RegExp(r'^[0-9a-zA-Z\_\-\.]+$');
final RegExp _integerTag = RegExp(r'^[0-9]+$');

Object mirrorValueResolver(Object object, Object name) =>
    _mirrorValueResolver(object, name, lenient: false);

Object lenientMirrorValueResolver(Object object, Object name) =>
    _mirrorValueResolver(object, name, lenient: true);

//FIXME name should be string right?
// Returns the property of the given object by name. For a map,
// which contains the key name, this is object[name]. For other
// objects, this is object.name or object.name(). If no property
// by the given name exists, this method returns noSuchProperty.
Object _mirrorValueResolver(Object object, Object name,
    {bool lenient = false}) {
  if (object is Map && object.containsKey(name)) return object[name];

  if (object is List && _integerTag.hasMatch(name)) {
    return object[int.parse(name)];
  }

  if (lenient && !_validTag.hasMatch(name)) return m.noSuchProperty;

  var instance = reflect(object);
  var field = instance.type.instanceMembers[Symbol(name)];
  if (field == null) return m.noSuchProperty;

  var invocation;
  if ((field is VariableMirror) ||
      ((field is MethodMirror) && (field.isGetter))) {
    invocation = instance.getField(field.simpleName);
  } else if ((field is MethodMirror) &&
      (field.parameters.where((p) => !p.isOptional).isEmpty)) {
    invocation = instance.invoke(field.simpleName, []);
  }
  if (invocation == null) {
    return m.noSuchProperty;
  }
  return invocation.reflectee;
}
