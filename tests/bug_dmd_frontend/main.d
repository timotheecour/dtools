#!/usr/bin/env dub
/+dub.sdl:
dependency "dmd" version="~master"
+/

/+
$dmd_current_X --version
DMD64 D Compiler v2.078.2-699-g6a2db254e-dirty

DMD=$dmd_current_X dub --single main.d

file1.d(1): Error: Invalid trailing code unit
file1.d(1): Error: declaration expected, not `#`
file1.d(1): Error: character 0x7f is not a valid token
core.exception.AssertError@../../../../../.dub/packages/dmd-master/dmd/src/dmd/frontend.d(235): Parsing error occurred.

+/

void main(string[]args){
  import std.file;
  //string file=args[1];
  string file="file1.d";
  auto code=file.readText;
  process(code, file);
}

void process(string code, string file){
  import dmd.frontend;
  import std.algorithm : each;
  import std.stdio;
  initDMD;
  findImportPaths.each!addImport;
  auto m = parseModule(file, code);
}
