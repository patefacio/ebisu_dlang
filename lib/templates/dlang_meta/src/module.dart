part of dlang_meta;

String module([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


 if(_.doc != null) { 
  _buf.add('''
${blockComment(_.doc)}
''');
 } 
  _buf.add('''
module ${_.qualifiedName};

''');
 for(String i in _.publicImports) { 
  _buf.add('''
public ${d_meta.importStatement(i)};
''');
 } 
 for(String i in _.imports) { 
  _buf.add('''
${d_meta.importStatement(i)};
''');
 } 
 for(String i in _.debugImports) { 
  _buf.add('''
debug ${d_meta.importStatement(i)};
''');
 } 
 if (_.requiresUtinit) { 
  _buf.add('''
mixin UTInit!__MODULE__;
''');
 } 
 if (_.customImports) { 
  _buf.add('''
${chomp(customBlock("custom imports ${_.name}"))}
''');
 } 
 if (_.anyImports) { 
  _buf.add('''

''');
 } 
  _buf.add('''
${chomp(_.contents)}
''');
 if(_.unitTest) { 
   if(_.requiresUtinit) { 
  _buf.add('''
@UT("${_.name}") unittest {
''');
   } else { 
  _buf.add('''
unittest {
''');
   } 
  _buf.add('''
${indentBlock(chomp(customBlock("unittest ${_.name}")))}
}
''');
 } 
  _buf.add('''
version(unittest) {
  import specd.specd;
}
''');
  return _buf.join();
}