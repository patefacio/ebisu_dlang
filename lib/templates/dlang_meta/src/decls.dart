part of dlang_meta;

String decls([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


 for(var mixin in _.mixins) { 
  _buf.add('''
${mixin.decl};
''');
 } 
 for(var constant in _.constants) { 
  _buf.add('''
${chomp(constant.define())}
''');
 } 
 for(var alias in _.aliases) { 
  _buf.add('''
${alias.decl};
''');
 } 
 for(var e in _.enums) { 
  _buf.add('''
${e.define()}
''');
 } 
 for(var struct in _.structs) { 
  _buf.add('''
${struct.define()}
''');
 } 
 for(var union in _.unions) { 
  _buf.add('''
${union.define()}
''');
 } 
 for(var t in _.templates) { 
  _buf.add('''
template(${t.id})
''');
 } 
 for(var codeBlock in _.codeBlocks) { 
  _buf.add('''
${chomp(codeBlock.code)}
''');
 } 
 for(var member in _.members) { 
  _buf.add('''
${member.decl};
''');
 } 
  return _buf.join();
}