part of dlang_meta;

/// Access for member variable - ia - inaccessible, ro - read/only, rw read/write
class Access {
  static const IA = const Access._(0);
  static const RO = const Access._(1);
  static const RW = const Access._(2);

  static get values => [
    IA,
    RO,
    RW
  ];

  final int value;

  const Access._(this.value);

  String toString() {
    switch(this) {
      case IA: return "IA";
      case RO: return "RO";
      case RW: return "RW";
    }
  }

  static Access fromString(String s) {
    switch(s) {
      case "IA": return IA;
      case "RO": return RO;
      case "RW": return RW;
    }
  }


}

/// Pass const(T), or immutable(T) - if null then just T
class PassType {
  static const C = const PassType._(0);
  static const I = const PassType._(1);

  static get values => [
    C,
    I
  ];

  final int value;

  const PassType._(this.value);

  String toString() {
    switch(this) {
      case C: return "C";
      case I: return "I";
    }
  }

  static PassType fromString(String s) {
    switch(s) {
      case "C": return C;
      case "I": return I;
    }
  }


}

/// Access in the D sense
class DAccess {
  static const PUBLIC = const DAccess._(0);
  static const PRIVATE = const DAccess._(1);
  static const PACKAGE = const DAccess._(2);
  static const PROTECTED = const DAccess._(3);
  static const EXPORT = const DAccess._(4);

  static get values => [
    PUBLIC,
    PRIVATE,
    PACKAGE,
    PROTECTED,
    EXPORT
  ];

  final int value;

  const DAccess._(this.value);

  String toString() {
    switch(this) {
      case PUBLIC: return "PUBLIC";
      case PRIVATE: return "PRIVATE";
      case PACKAGE: return "PACKAGE";
      case PROTECTED: return "PROTECTED";
      case EXPORT: return "EXPORT";
    }
  }

  static DAccess fromString(String s) {
    switch(s) {
      case "PUBLIC": return PUBLIC;
      case "PRIVATE": return PRIVATE;
      case "PACKAGE": return PACKAGE;
      case "PROTECTED": return PROTECTED;
      case "EXPORT": return EXPORT;
    }
  }


}

/// User defined data type
class Udt {
  static const ALIAS = const Udt._(0);
  static const ENUM = const Udt._(1);
  static const STRUCT = const Udt._(2);
  static const UNION = const Udt._(3);

  static get values => [
    ALIAS,
    ENUM,
    STRUCT,
    UNION
  ];

  final int value;

  const Udt._(this.value);

  String toString() {
    switch(this) {
      case ALIAS: return "ALIAS";
      case ENUM: return "ENUM";
      case STRUCT: return "STRUCT";
      case UNION: return "UNION";
    }
  }

  static Udt fromString(String s) {
    switch(s) {
      case "ALIAS": return ALIAS;
      case "ENUM": return ENUM;
      case "STRUCT": return STRUCT;
      case "UNION": return UNION;
    }
  }


}

class BasicType {

  BasicType(this._name, this._init);

  String get name => _name;
  dynamic get init => _init;

// custom <class BasicType>

  String toString() => _name;

// end <class BasicType>
  String _name;
  dynamic _init;
}

/// Holder for packages, apps, and the root path
class System {

  System(this._id);

  /// Id for this system
  Id get id => _id;
  /// Documentation for this system
  String doc;
  /// Top level path to which code is generated
  String rootPath;
  /// List of apps in the system
  List<App> apps = [];
  /// List of apps in the system
  List<Package> packages = [];
  /// Set to true when system is finalized
  bool get finalized => _finalized;

// custom <class System>

  void finalize() {
    if(!_finalized) {
      if(packages != null) packages.forEach((pkg) => pkg._finalize(this)); 
      if(apps != null) apps.forEach((app) => app._finalize(this)); 
      _finalized = true;
    }
  }

  void generate() {
    finalize();
    packages.forEach((pkg) => pkg.generate());
  }

  dynamic get root => this;
  String get pkgPath => "${rootPath}";

// end <class System>
  final Id _id;
  bool _finalized = false;
}

/// Meta data required for D package
class Package {

  Package(this._id);

  /// Id for this D package
  Id get id => _id;
  /// Documentation for this D package
  String doc;
  /// Reference to parent of this D package
  dynamic get parent => _parent;
  /// The generated name for enum
  String get name => _name;
  /// List of modules in the package
  List<Module> modules = [];
  /// List of packages in the package
  List<Package> packages = [];

// custom <class Package>

  void _finalize(dynamic parent) {
    if(modules != null) modules.forEach((module) => module._finalize(this)); 
    if(packages != null) packages.forEach((pkg) => pkg._finalize(this)); 
    _parent = parent;
  }

  void generate() {
    if(_parent == null) 
      throw new StateError("Finalize the system before generating Package ${_id}");
    if(null != modules)
      modules.forEach((module) => module.generate());
    if(null != packages)
      packages.forEach((pkg) => pkg.generate());
  }

  dynamic get root => _parent.root;
  String get pkgPath => "${_parent.pkgPath}/${_id.snake}";

// end <class Package>
  final Id _id;
  dynamic _parent;
  String _name;
}

/// Meta data required for D module
class Module extends Decls {

  Module(this._id);

  /// Id for this D package
  Id get id => _id;
  /// Documentation for this D package
  String doc;
  /// Reference to parent of this D struct
  dynamic get parent => _parent;
  /// List of modules to import
  List<String> imports = [];
  /// List of modules to import publicly
  List<String> publicImports = [];
  /// List of modules to import under the debug
  List<String> debugImports = [];

// custom <class Module>

  String get name => _id.snake;

  bool get anyImports => (imports.length + publicImports.length + debugImports.length) > 0;

  void _finalize(Package parent) {
    finalizeDecls(this);
    _parent = parent;

    List<String> orderImports(List<String> listImports) {
      listImports = 
        new Set.from(listImports.map((i) => 
                standardImports.contains(i)?            
                "std.${i}" : i)).toList();

      listImports.sort();
      // Put std imports at end
      listImports = listImports.where((i) => !i.contains('std.')).toList()
        ..addAll(listImports.where((i) => i.contains('std.')));
      return listImports;
    }

    imports = orderImports(imports);
    publicImports = orderImports(publicImports);
    debugImports = orderImports(debugImports);
  }

  String get contents => decls();

  void generate() {
    if(_parent == null) 
      throw new StateError("Finalize the system before generating Module ${_id}");

    String targetFile = "${pkgPath}/${_id.snake}.d";
    mergeWithFile(META.module(this), targetFile);
  }

  dynamic get root => _parent.root;
  String get pkgPath => "${_parent.pkgPath}";
  String get rootRelativePath => 
    path.split(path.relative(pkgPath, from:root.pkgPath)).join('.');
  String get qualifiedName => "${rootRelativePath}.$name";

// end <class Module>
  final Id _id;
  dynamic _parent;
}

/// An entry in an enum
class EnumValue {

  EnumValue(this._id);

  /// Id for this enum value
  Id get id => _id;
  /// The generated name for enum value
  String get name => _name;
  /// Documentation for this enum value
  String doc;
  /// Set value of the enum value only if required
  String value;

// custom <class EnumValue>

  void _finalize() {
    _name = _id.capCamel;
  }

  String get decl {
    String result = (null != doc)? (blockComment(doc)+'\n') : '';
    if(null == value) {
      result += '$name';
    } else {
      result += '$name = $value';
    }
    return result;
  }

// end <class EnumValue>
  final Id _id;
  String _name;
}

/// A template mixin
class TMixin {

  TMixin(this.name);

  /// Textual name of template mixin
  String name;
  /// D langauge access for this template mixin
  DAccess dAccess = DAccess.PUBLIC;
  /// List of template args
  List<String> tArgs = [];

// custom <class TMixin>

  String get argsDecl => 
    tArgs.length>1 ? "!(${tArgs.join(',')})" : 
    (tArgs.length==1 ? "!${tArgs[0]}" : '');

  String get decl => 'mixin ${name}${argsDecl}';

// end <class TMixin>
}

class Enum {

  Enum(this._id);

  /// Id for this enum
  Id get id => _id;
  /// Documentation for this enum
  String doc;
  /// Reference to parent of this enum
  dynamic get parent => _parent;
  /// The generated name for enum
  String get name => _name;
  /// D langauge access for this enum
  DAccess dAccess = DAccess.PUBLIC;
  /// List if Id's that constitute the values
  List<EnumValue> values = [];

// custom <class Enum>

  String define() {
    return META.enum(this);
  }

  void _finalize(dynamic parent) {
    _name = _id.capCamel;
    values.forEach((v) => v._finalize());
    _parent = parent;
  }

// end <class Enum>
  final Id _id;
  dynamic _parent;
  String _name;
}

class Constant {

  Constant(this._id);

  /// Id for this constant
  Id get id => _id;
  /// Documentation for this constant
  String doc;
  /// Reference to parent of this constant
  dynamic get parent => _parent;
  /// The generated name for constant
  String get name => _name;
  /// D langauge access for this constant
  DAccess dAccess = DAccess.PUBLIC;
  /// True if constant is static
  bool isStatic = false;
  /// True if constant is requires static this
  bool hasStaticThis = false;
  /// Type of the constant
  String type = 'String';
  /// Value to initialize the constant with
  dynamic init;

// custom <class Constant>

  void _finalize(dynamic parent) {
    _name = _id.capCamel;
    _parent = parent;
    if(null != init) 
      init = init.toString();
  }

  String define() {
    return META.constant(this);
  }

// end <class Constant>
  final Id _id;
  dynamic _parent;
  String _name;
}

class Union extends Decls {

  Union(this._id);

  /// Id for this union
  Id get id => _id;
  /// Documentation for this union
  String doc;
  /// Reference to parent of this union
  dynamic get parent => _parent;
  /// The generated name for union
  String get name => _name;
  /// D langauge access for this D struct
  DAccess dAccess = DAccess.PUBLIC;
  /// List of members of this class
  List<Member> members = [];

// custom <class Union>

  void _finalize(dynamic parent) {
    _name = _id.capCamel;
    _parent = parent;
    finalizeDecls(this);
    members.forEach((member) => member._finalize(this));
  }

  String define() {
    return META.union(this);
  }

// end <class Union>
  final Id _id;
  dynamic _parent;
  String _name;
}

/// TODO: add support for apps
class App {

  // custom <class App>
  // end <class App>
}

/// Declaration for an alias
class Alias {

  Alias(this._id);

  /// Id for this alias
  Id get id => _id;
  /// Documentation for this alias
  String doc;
  /// The generated name for alias
  String get name => _name;
  /// D langauge access for this D struct
  DAccess dAccess = DAccess.PUBLIC;
  /// What the alias is aliased to
  String aliased;

// custom <class Alias>

  String get decl {
    String result = (null != doc)? (blockComment(doc)+'\n') : '';
    result += "alias ${aliased} ${name}";
    return result;
  }

  void _finalize(dynamic parent) {
    _name = _id.id == 'this'? 'this' : _id.capCamel;
  }

// end <class Alias>
  final Id _id;
  String _name;
}

/// Declaration for an alias to an array
class ArrAlias {

  ArrAlias(this._id);

  /// Id for this array alias
  Id get id => _id;
  /// Documentation for this array alias
  String doc;
  /// The generated name for array alias
  String get name => _name;
  /// D langauge access for this array alias
  DAccess dAccess = DAccess.PUBLIC;
  /// Type which the list is of e.g. "Foo" means create alias "Foo[]".
  /// If this is not set, the id is used to form consistent alias.
  /// ArrAlias('foo') => "alias immutable(Foo)[] FooArr"
  /// ArrAlias('foo')..immutable = false => "alias Foo[] FooArr"
  String aliased;
  /// If true aliased type will have an immutable e.g. "immutable(Foo)[]"
  bool immutable = true;

// custom <class ArrAlias>

  String get decl {
    if(immutable) {
      return "alias immutable(${aliased})[] ${name}Arr";
    } else {
      return "alias ${aliased}[] ${name}Arr";
    }
  }

  void _finalize(dynamic parent) {
    _name = _id.capCamel;
    aliased = _name;
  }

// end <class ArrAlias>
  final Id _id;
  String _name;
}

/// Declaration for an alias to an associative array
class AArrAlias {

  AArrAlias(this._id);

  /// Id for this array alias
  Id get id => _id;
  /// Documentation for this array alias
  String doc;
  /// The generated name for array alias
  String get name => _name;
  /// D langauge access for this array alias
  DAccess dAccess = DAccess.PUBLIC;
  /// Type of the key
  String key;
  /// Type of the value
  String value;

// custom <class AArrAlias>

  String get decl {
    return "alias ${value}[${key}] ${name}Map";
  }

  void _finalize(dynamic parent) {
    _name = _id.capCamel;
  }

// end <class AArrAlias>
  final Id _id;
  String _name;
}

class TemplateParm {

  TemplateParm(this._id);

  /// Id for this template parm
  Id get id => _id;
  /// Documentation for this template parm
  String doc;
  /// Reference to parent of this template parm
  dynamic get parent => _parent;
  /// The generated name for template parm
  String get name => _name;
  /// Name of the type
  String typeName;
  /// True if template parm is an alias
  bool isAlias = false;
  /// A default value for the parameter
  String init;

// custom <class TemplateParm>

  void _finalize(dynamic parent) {
    _name = isAlias? _id.camel : _id.capCamel;
    _parent = parent;
  }

  String get decl {
    String initialized = (init == null)? _name : "${_name} = ${init}";
    if(isAlias) {
      return "alias ${initialized}";
    } else {
      return initialized;
    }
  }

// end <class TemplateParm>
  final Id _id;
  dynamic _parent;
  String _name;
}

/// Defines a D template
class Template extends Decls {

  Template(this._id);

  /// Id for this template
  Id get id => _id;
  /// Documentation for this template
  String doc;
  /// Reference to parent of this template
  dynamic get parent => _parent;
  /// The generated name for template
  String get name => _name;
  List<TemplateParm> templateParms = [];
  /// D langauge access for this D struct
  DAccess dAccess = DAccess.PUBLIC;

// custom <class Template>

  void _finalize(dynamic parent) {
    templateParms.forEach((tp) => tp._finalize(this));
    _parent = parent;
  }  

// end <class Template>
  final Id _id;
  dynamic _parent;
  String _name;
}

/// Container for generated code
class CodeBlock {

  CodeBlock(this.code);

  /// D langauge access for this code block
  DAccess dAccess = DAccess.PUBLIC;
  /// Block of code to be placed in a container
  String code;

// custom <class CodeBlock>

// end <class CodeBlock>
}

/// Container for declarations
class Decls {
  List mixins = [];
  List<Alias> aliases = [];
  List<Constant> constants = [];
  List<Struct> structs = [];
  List<Enum> enums = [];
  List<Union> unions = [];
  List<Template> templates = [];
  List<CodeBlock> codeBlocks = [];
  List<Member> members = [];
  bool privateSection = false;
  bool publicSection = false;
  bool unitTest = false;

// custom <class Decls>

  Decls(){}

  bool empty() {
    return (
        mixins.length + aliases.length + constants.length+
        structs.length + enums.length + unions.length +
        templates.length + codeBlocks.length + members.length)==0;
  }

  FilteredDecls filter(DAccess access) {
    FilteredDecls result = new FilteredDecls.fromDecls(name, this, access);
    return result;
  }

  void finalizeDecls(dynamic parent) {
    // mixins don't require finalize
    aliases.forEach((alias) => alias._finalize(this));
    constants.forEach((constant) => constant._finalize(this));
    structs.forEach((struct) => struct._finalize(this));
    enums.forEach((enum) => enum._finalize(this));
    unions.forEach((union) => union._finalize(this));
    templates.forEach((template) => template._finalize(this));
    // codeBlocks don't require finalize
    // members are finalized by their "owner"
  }

  String decls() {
    String publicCustomBlock = 
      (publicSection)? "\n${customBlock('${runtimeType.toString().toLowerCase()} public $name')}\n" : '';
    String privateCustomBlock = 
      (privateSection)? "\n${customBlock('${runtimeType.toString().toLowerCase()} private $name')}\n" : '';

    List<String> result = [ META.decls(this.filter(DAccess.PUBLIC)), publicCustomBlock ];
    Decls d = this.filter(DAccess.EXPORT);
    if(!d.empty()) {
      result.add('''
export {
${indentBlock(chomp(META.decls(d)))}
}
''');
    }
    d = this.filter(DAccess.PACKAGE);
    if(!d.empty()) {
      result.add('''
package {
${indentBlock(chomp(META.decls(d)))}
}
''');
    }

    d = this.filter(DAccess.PROTECTED);
    if(!d.empty()) {
      result.add('''
protected {
${indentBlock(chomp(META.decls(d)))}
}
''');
    }

    d = this.filter(DAccess.PRIVATE);
    if(!d.empty() || privateSection) {
      result.add('''
private {
${indentBlock(chomp(META.decls(d)))}
$privateCustomBlock}
''');
    }

    return result.join('');
  }

// end <class Decls>
}

/// The set of decls of given access from specific instance of
/// item extending Decls (e.g. Module, Union, Template, Struct)
class FilteredDecls extends Decls {
  /// The generated name for filtered decls
  String get name => _name;
  /// D langauge access for this filtered decls
  DAccess dAccess = DAccess.PUBLIC;

// custom <class FilteredDecls>

  FilteredDecls.fromDecls(String name, Decls decls, DAccess access) : _name = name {
    mixins = decls.mixins.where((e) => e.dAccess == access).toList();
    aliases = decls.aliases.where((e) => e.dAccess == access).toList();
    constants = decls.constants.where((e) => e.dAccess == access).toList();
    structs = decls.structs.where((e) => e.dAccess == access).toList();
    enums = decls.enums.where((e) => e.dAccess == access).toList();
    unions = decls.unions.where((e) => e.dAccess == access).toList();
    templates = decls.templates.where((e) => e.dAccess == access).toList();
    codeBlocks = decls.codeBlocks.where((e) => e.dAccess == access).toList();
    members = decls.members.where((e) => e.dAccess == access).toList();
    dAccess = access;
    if(access == DAccess.PUBLIC) {
      privateSection = decls.privateSection;
      publicSection = decls.publicSection;
      unitTest = decls.unitTest;
    }
  }

// end <class FilteredDecls>
  String _name;
}

/// What is required to know how to generate a constructor
class Ctor {

  Ctor(this.name);

  /// Name of struct being constructed
  String name;
  /// Ordered list of members either included directly, etiher as is or with default init
  List<Member> members = [];

// custom <class Ctor>

  String define() {
    List<String> parts = [];
    List<String> assignments = [];
    members.forEach((m) {
      String passType = 
        (m.passType == null)? m.type :
        ((m.passType == PassType.C) ? 'const(${m.type})' :
            'immutable(${m.type})');
      String part = m.byRef? "ref ${passType} ${m.name}" :
        "${passType} ${m.name}";
      if(m.ctorDefaulted) {
        if(null == m.init) {
          part += " = ${m.type}.init";
        } else {
          part += " = ${m.init}";
        }
      }
      parts.add(part);
      String rhs = m.castDup? 
        "(cast(${m.type})${m.name}).dup" :
        (m.gDup? "${m.name}.gdup" : m.name);

      assignments.add("this.${m.vName} = ${rhs}");
    });
    
    return '''
//! ${name} member initializing ctor
this(${parts.join(',\n     ')}) {
  ${assignments.join(';\n  ')};
}''';
  }

// end <class Ctor>
}

/// Meta data required for D struct
class Struct extends Decls {

  Struct(this._id);

  /// Id for this D struct
  Id get id => _id;
  /// Documentation for this D struct
  String doc;
  /// Reference to parent of this D struct
  dynamic get parent => _parent;
  /// The generated name for D struct
  String get name => _name;
  /// D langauge access for this D struct
  DAccess dAccess = DAccess.PUBLIC;
  /// Constructor for this struct
  Ctor ctor;
  /// List of template parms for this struct.
  /// Existance of any _tParms_ implies this struct is a template struct.
  List<TemplateParm> templateParms = [];
  /// List of members of this class
  List<Member> members = [];

// custom <class Struct>

  void _finalize(dynamic parent) {
    _name = _id.capCamel;
    _parent = parent;
    templateParms.forEach((tp) => tp._finalize(this));
    finalizeDecls(this);
    members.forEach((member) => member._finalize(this));
    List<Member> ctorMembers = members.where((m) => m.ctor || m.ctorDefaulted).toList();
    if(ctorMembers.length>0) {
      ctor = new Ctor(_name)..members = ctorMembers;
    }
  }

  String get templateDecl {
    List<String> parts = [];
    templateParms.forEach((tp) {
      parts.add(tp.decl);
    });
    if(parts.length>0) {
      return "(${parts.join(', ')})";
    }
    return '';
  }
  
  String get templateName => "${name}${templateDecl}";

  String define() {
    return META.struct(this);
  }

// end <class Struct>
  final Id _id;
  dynamic _parent;
  String _name;
}

/// Meta data required for D member
class Member {

  Member(this._id);

  /// Id for this D member
  Id get id => _id;
  /// Documentation for this D member
  String doc;
  /// Reference to parent of this D member
  dynamic get parent => _parent;
  /// The generated name for D member
  String get name => _name;
  /// D langauge access for this D struct
  DAccess dAccess = DAccess.PUBLIC;
  /// Name of member as stored in struct/class/union
  String get vName => _vName;
  /// D developer access for this D member
  Access access = Access.RW;
  Access usage = Access.RW;
  /// The type for this member
  dynamic type;
  /// What to initialize member to
  dynamic init;
  /// If set preferred pass type is by ref
  bool byRef = false;
  /// How this member should be passed
  PassType passType;
  /// If set and ctor is true will be duped
  bool gDup = false;
  /// If set and dup is perform an const cast is provided.
  ///  This allows duping things like maps from const into non-const since safel
  bool castDup = false;
  /// If set this member is included in the ctor
  bool ctor = false;
  /// If set this member is included in the ctor with `init` member as the default.
  /// It only makes sense to use either `ctor` or `ctor_defaulted` and if using
  /// `ctor_defaulted` init should be set.
  bool ctorDefaulted = false;
  /// If true this data is reference data held on by the instance.
  /// It will be passed to ctor and stored as immutable
  bool isReference = false;

// custom <class Member>

  void _finalize(dynamic parent) {
    if(_parent != null) {
      throw new StateError("Finalize must be called only once on $this => $id");
    }
    _name = _id.camel;
    _parent = parent;
    if(access == Access.RO || access == Access.IA) {
      _vName = '_$_name';
      dAccess = DAccess.PRIVATE;
      if(access == Access.RO) {
        parent.mixins.add(new TMixin('ReadOnly')..tArgs = [ _vName ]);
      }
    } else {
      if(access == Access.RW) {
        dAccess = DAccess.PUBLIC;
      } else {
        dAccess = DAccess.PRIVATE;
      }
      _vName = _name;
    }
    if(isReference) {
      usage = Access.RO;
      if(passType == null) passType = PassType.I;
    }
    if(null == type) {
      type = _id.capCamel;
    }
  }

  String get decl {
    String result = '';
    if(null != doc) {
      result += (blockComment(doc) + '\n');
    }
    var t = isReference? 'immutable($type)' : type;
    if(null != init) {
      result += '${t} ${_vName} = ${init}';
    } else {
      result += '${t} ${_vName}';
    }
    return result;
  }

// end <class Member>
  final Id _id;
  dynamic _parent;
  String _name;
  String _vName;
}
// custom <part dlang_meta>

Id id(String _id) => new Id(_id);
System system(String _id) => new System(id(_id));
Package package(String _id) => new Package(id(_id));
Module module(String _id) => new Module(id(_id));
Struct struct(String _id) => new Struct(id(_id));
Member member(String _id) => new Member(id(_id));
Alias alias(String _id) => new Alias(id(_id));
Alias aliasThis(String text) => new Alias(id('this'))..aliased = text;
ArrAlias arrAlias(String _id) => new ArrAlias(id(_id));
AArrAlias aArrAlias(String _id, String key, String value) => 
  new AArrAlias(id(_id))..key = key..value = value;
Constant constant(String _id) => new Constant(id(_id));
Union union(String _id) => new Union(id(_id));
Enum enum_(String _id) => new Enum(id(_id));
EnumValue ev(String _id) => new EnumValue(id(_id));
TMixin tmixin(String mixinName) => new TMixin(mixinName);
TemplateParm tparm(String _id) => new TemplateParm(id(_id));
CodeBlock codeBlock(String code) => new CodeBlock(code);


Alias arr(String type, { bool mutable : false, String of }) {
  String aliasedType;

  if(of != null) {
    aliasedType = "${of}Arr";
  } else {
    aliasedType = id(type).capCamel;
  }

  String aliased = mutable? 
    "${aliasedType}[]" :
    "immutable(${aliasedType})[]";    
  Alias result = (alias("${type}_arr")..aliased = aliased);
  return result;
}

final Access ia = Access.IA;
final Access ro = Access.RO;
final Access rw = Access.RW;

final DAccess public = DAccess.PUBLIC;
final DAccess private = DAccess.PRIVATE;
final DAccess protected = DAccess.PROTECTED;
final DAccess export = DAccess.EXPORT;

Set _standardImports = new Set.from([
  'algorithm', 'array', 'ascii', 'base64', 'bigint', 'bitmanip', 'compiler',
  'complex', 'concurrency', 'container', 'conv', 'cpuid', 'cstream', 'csv',
  'ctype', 'datetime', 'demangle', 'encoding', 'exception', 'file', 'format',
  'functional', 'getopt', 'json', 'math', 'mathspecial', 'md5', 'metastrings',
  'mmfile', 'numeric', 'outbuffer', 'parallelism', 'path', 'perf', 'process',
  'random', 'range', 'regex', 'regexp', 'signals', 'socket', 'socketstream',
  'stdint', 'stdiobase', 'stdio', 'stream', 'string', 'syserror', 'system',
  'traits', 'typecons', 'typetuple', 'uni', 'uri', 'utf', 'uuid', 'variant',
  'xml', 'zip', 'zlib',
]);

Set get standardImports => _standardImports;

String importPackage(String i) {
  if(_standardImports.contains(i)) {
    return "std.${i}";
  } else {
    return i;
  }
}

String importStatement(String i) => "import ${importPackage(i)}";

var I = PassType.I;
var C = PassType.C;

// end <part dlang_meta>

