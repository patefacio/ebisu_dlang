import 'dart:io';
import 'package:id/id.dart';
import 'package:ebisu/ebisu_utils.dart';
import 'package:ebisu_dlang/dlang_meta.dart';

main() {
  
  Package pkg = package('m_c_i')
    ..modules = [
      module('m_c_i')
      ..publicSection = true
      ..aliases = [
        aArr('text', 'string', 'string')
      ]
      ..imports = [ 'conv', 'stdio' ]
      ..structs = [
        struct('a')
        ..publicSection = true
        ..members = [
          member('a_arr')..type='string[string]',
        ],
        struct('b')
        ..publicSection = true
        ..members = [
          member('a')
        ],
        struct('c')
        ..publicSection = true
        ..members = [
          member('b')
        ]
      ],
    ];

  system('m_c_i')
    ..packages = [ pkg ]
    ..rootPath = 'dlang_generated'
    ..generate();

}