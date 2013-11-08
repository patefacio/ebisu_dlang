import 'dart:io';
import 'package:id/id.dart';
import 'package:ebisu/ebisu_utils.dart';
import 'package:ebisu_dlang/dlang_meta.dart';

main() {
  
  Package pkg = package('forecast')
    ..modules = [
      module('income_expense_model')
      ..imports = [ 'datetime', 'opmix.mix' ]
      ..debugImports = [ 'stdio' ]
      ..enums = [ 
        enum_('income_expense_type')
        ..doc = 'Differentiate between income and expense items'
        ..values = [ ev('income'), ev('expense') ] 
      ]
      ..unitTest = true
      ..structs = [
        struct('modeled_item_spec')
        ..members = [
          member('label')..doc = 'Describes item'..access = RO..type='string',
          member('type')..doc = 'I/E'..access = RO..type='IncomeExpenseType',
          member('growth_rate')..access = RO..type='double'..init = '3.0'
        ]
        ..aliases = [
          arr('modeled_item_spec')
          ..doc = 'Slices of modeled item spec - See blah-bahdee-blah',
        ]
      ],
    ];

  system('sample_d')
    ..packages = [ pkg ]
    ..rootPath = 'dlang_generated'
    ..generate();

}