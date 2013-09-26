library test_code_generation;

import 'dart:io';
import 'package:ebisu_dlang/dlang_meta.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:unittest/unittest.dart';
import 'utils.dart';
// custom <additional imports>
// end <additional imports>


final _logger = new Logger("test_code_generation");

String _scratchRemoveMeFolder;

// custom <library test_code_generation>

String get tempPath {
  if(_scratchRemoveMeFolder == null) {
    _scratchRemoveMeFolder = 
      joinAll([packageRootPath, 'test', 'scratch_remove_me']);
  }

  return _scratchRemoveMeFolder;
}

System _testSystem;
Package _testPackage;
Module _testModule;

System _makeTestSystem() {
  _testModule = module('test_module');

  _testPackage = package('test_package')
  ..modules = [ _testModule ];
  
  _testSystem = system('test_system')
  ..rootPath = tempPath
  ..packages = [ _testPackage ];
  
  return _testSystem;
}

void destroyTempData() {
  var dir = new Directory(tempPath);
  _logger.info("Destroying $tempPath");
  if(dir.existsSync()) {
    dir.deleteSync(recursive : true);
  }
}

String _readModule() {
  var result = 
    new File(join(tempPath, 'test_package', 'test_module.d'))
    .readAsStringSync();
  _logger.fine('Module Contents:\n$result');
  return result;
}

_generate() {
  destroyTempData();
  _testSystem..finalize()..generate();
}


pattern(String s) => new RegExp(s, multiLine:true);

get line => '\n--------------------------------------------------------\n';

genTest(label, updates(), 
    { want : const [],  dontWant : const [] }) {
  test(label, () {
    _makeTestSystem();
    updates();
    _generate();
    var modText = _readModule();
    _logger.info('<$label>$line\n$modText$line');
    want.forEach((p) {
      expect(modText.contains(pattern(p)), true);
    });
    dontWant.forEach((p) {
      expect(modText.contains(pattern(p)), false);
    });
  }); 
}

// end <library test_code_generation>

main() { 
// custom <main>

  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));

  group('test pkg/module naming', () {
    _makeTestSystem();
    _generate();
    var modText = _readModule();
    _logger.info('Module Contents:\n$modText');
    test('module statement is correct', () =>
        expect(modText
            .contains(pattern(r'module\s+test_package.test_module')), true));
  });

  group('test module sections', () {
    genTest('has no public/private section by default', (){}, 
        dontWant:['public', 'private', 'unittest']);
    genTest('has public and private when asked',
        () { _testModule..publicSection = true..privateSection = true; },
        want: [ 
          r'custom\s+<module public test_module>',
          r'custom\s+<module private test_module>',
        ]);
    genTest('has unittest when asked',
        () =>  _testModule..unitTest = true,
        want: [ 
          r'static\s+if\(1\)\s+unittest',
          r'//\s+custom\s+<unittest test_module>\s*'
          r'//\s+end\s+<unittest test_module>',
        ]);
  });

  group('test enums', () {
    genTest('simple enums generated',
        () => _testModule
        ..enums = [
          enum_('x')..values = [ ev('foo'), ev('bar'), ev('goo') ],
          enum_('color')..values = [ 
            ev('red')..value = '1', 
            ev('green')..value = '2'
            ..doc = 'Setting suns and lonely lovers free',
            ev('blue')..value = '42' ]
        ],
        want: [
          r'enum\s+X\s+{\s+Foo,\s+Bar,\s+Goo\s+}',
          r'Red\s*=\s*1', r'Green\s*=\s*2', r'Blue\s*=\s*42',
          r'Setting suns and lonely lovers free\s+\*/\s+Green'
        ]);
  });

  group('test struct members', () {
    genTest('members typed correctly',
        () => _testModule..structs = [
          struct('s')
          ..members = [
            member('i')..type = 'int',
            member('d')..type = 'double',
            member('f')..type = 'float',
            member('s')..type = 'string'
          ]
        ],
        want: [
          r'int\s+i',
          r'double\s+d',
          r'float\s+f',
          r'string\s+s',
        ]);
  });

  group('test class aliases defined', () {
    genTest('aliases typed correctly',
        () => _testModule..structs = [
          struct('s')
          ..aliases = [
            alias('foo')..aliased = 'Moo',
            arr('i'),
            arr('j', mutable:true),
            arr('donkey', mutable:true, of:'Dog'),
            aArr('goo', 'string', 'double'),
          ]
        ],
        want: [
          r'alias\s+Moo\s+Foo',
          r'alias\s+immutable\(I\)\[\]\s+IArr',
          r'alias\s+J\[\]\s+JArr',
          r'alias\s+Dog\[\]\s+DonkeyArr',
          r'alias\s+double\[string\]\s+GooMap',          
        ]);
  });


// end <main>

}
