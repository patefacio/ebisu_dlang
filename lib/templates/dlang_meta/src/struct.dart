part of dlang_meta;

String struct([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


 if(null != _.doc) { 
  _buf.add('''
${blockComment(_.doc)}
''');
 } 
  _buf.add('''
struct ${_.templateName} {
''');
 if(null != _.ctor) { 
  _buf.add('''
${indentBlock(_.ctor.define(_.ctorCustomBlock))}
''');
 } 
  _buf.add('''
${chomp(indentBlock(_.decls()))}
''');
 if(_.unitTest) { 
  _buf.add('''
  unittest {
${indentBlock(chomp(customBlock("unittest ${_.name}")))}
  }
''');
 } 
  _buf.add('''
}
''');
 if(_.namedUnitTest && !_.unitTest) { 
  _buf.add('''

@UT("${_.name}") unittest {
${indentBlock(chomp(customBlock("unittest ${_.name}")))}
}
''');
 } 
  return _buf.join();
}