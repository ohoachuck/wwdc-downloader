#! /usr/bin/perl -w
#
# Class name: 	ParserState
# Synopsis: 	Used by headerDoc2HTML.pl to hold parser state
# Last Updated: $Date: 2014/03/05 14:20:15 $
# 
# Copyright (c) 1999-2004 Apple Computer, Inc.  All rights reserved.
#
# @APPLE_LICENSE_HEADER_START@
#
# This file contains Original Code and/or Modifications of Original Code
# as defined in and that are subject to the Apple Public Source License
# Version 2.0 (the 'License'). You may not use this file except in
# compliance with the License. Please obtain a copy of the License at
# http://www.opensource.apple.com/apsl/ and read it before using this
# file.
# 
# The Original Code and all software distributed under the License are
# distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
# EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
# INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
# Please see the License for the specific language governing rights and
# limitations under the License.
#
# @APPLE_LICENSE_HEADER_END@
#
######################################################################

# /*! @header
#     @abstract
#         <code>ParserState</code> class package file.
#     @discussion
#     This header contains the <code>ParserState</code> class, the
#     core data structure used by the parser.
#
#     For more details, see the class documentation below.
#     @indexgroup HeaderDoc Parser Pieces
#  */

# /*!
#    @abstract
#         Core data structure for the parser.
#    @discussion
#         The <code>ParserState</code> object represents an almost-complete
#         view of the state machine inside the parser.
#         (There are a few local variables in the parser that
#         contain additional transient state information.)
#
#         <code>ParserState</code> object instances are routinely stored
#         on a stack to provide the ability to fully parse
#         and interpret one declaration that appears inside
#         another declaration (variable declarations within
#         the parameter list of a function, for example).
#
#    @vargroup Key variables used to determine names/types
#
#         @var sodname
#                 The <code>sodname</code> variable contains the parsed name.
#
#                 The <code>sod</code> stands for "start of declaration".  This variable, along with
#                 <code>sodtype</code>, <code>sodname</code>, and <code>sodclass</code>
#                 are used for parsing functions and
#                 callbacks (but not the names of callbacks).
#
#                 These parser variables are controlled by the <code>startOfDec</code>
#                 counter variable.  With a few exceptions (callback names, in particular,
#                 come to mind), the <code>startOfDec</code> parser takes precedence over
#                 the other parsers.
#
#         @var sodtype
#                 The <code>sodtype</code> variable contains code symbols that may be used for
#                 various purposes.
#
#                 The <code>sod</code> stands for "start of declaration".  This variable, along with
#                 <code>sodtype</code>, <code>sodname</code>, and <code>sodclass</code>
#                 are used for parsing functions and
#                 callbacks (but not the names of callbacks).
#
#                 These parser variables are controlled by the <code>startOfDec</code>
#                 counter variable.  With a few exceptions (callback names, in particular,
#                 come to mind), the <code>startOfDec</code> parser takes precedence over
#                 the other parsers.
#
#         @var sodclass
#                 The <code>sodclass</code> variable contains a standardixed name for the type
#                 being parsed, specifically one of: <code>variable</code>, <code>function</code>,
#                 <code>enum</code>, or <code>class</code>.
#
#                 The <code>sod</code> stands for "start of declaration".  This variable, along with
#                 <code>sodtype</code>, <code>sodname</code>, and <code>sodclass</code>
#                 are used for parsing functions and
#                 callbacks (but not the names of callbacks).
#
#                 These parser variables are controlled by the <code>startOfDec</code>
#                 counter variable.  With a few exceptions (callback names, in particular,
#                 come to mind), the <code>startOfDec</code> parser takes precedence over
#                 the other parsers.
#
#         @var ISFORWARDDECLARATION
#             Indicates whether a class declaration is a forward declaration
#             (1) or the actual class declaration (0).  That way, the
#             resulting object is a {@link //apple_ref/perl/cl/HeaderDoc::Var Var}
#             object instead of a {@link //apple_ref/perl/cl/HeaderDoc::CPPClass CPPClass}
#             object.
#         @var forceClassName
#             When the parser sees a colon (indicating a superclass name is coming),
#             or the keywords <code>extends</code> or <code>implements</code> in Java,
#             etc., this gets a copy of the class name so that it doesn't get overwritten.
#         @var forceClassSuper
#             Holds the superclass information after a colon token.  Used in
#             conjunction with <code>forceClassName</code>.
#         @var forceClassDone
#             Set to 1 after reaching the left brace after a class.  This
#             essentially tells the parser to stop appending superclass tokens
#             to <code>forceClassSuper</code>.
#         @var simpleTypedef
#             Indicates a typedef without braces (0/1).  This is used for three things:
#
#                 <ul>
#                     <li>To determine whether the next brace starts field parsing or not.
#                         (Field parsing starts at the first brace.)</li>
#                     <li>To determine whether the namelist variable contains tag names
#                         for a complex typedef.  (Tag names appear after <code>struct</code> and
#                         before the opening curly brace.)  In the case of a simple
#                         typedef, this would contain bogus data.</li>
#                     <li>In parsing MIG declarations, to determine whether a return
#                         type was specified.</li>
#                </ul>
#         @var name
#             The name of a data type parsed by the main (<code>namePending</code>) parser.
#                 This is the lowest priority name; it gets overridden by the sodname name
#                 more often than not.
# 
#         @var inMacro
#             Indicates that the current declaration is a <code>#define</code> macro or similar.  Values are:
#
#                 <ul>
#                     <li>0 &mdash; Not in a macro.</li>
#                     <li>1 &mdash; Got leading #.</li>
#                     <li>2 &mdash; Got something else after # (error case).</li>
#                     <li>3 &mdash; Got <code>#define</code>.</li>
#                     <li>4 &mdash; Got another C preprocessor token, including
#                           <code>#if</code>, <code>#ifdef</code>,
#                           <code>#ifndef</code>, <code>#endif</code>,
#                           <code>#else</code>, <code>#undef</code>,
#                           <code>#elif</code>, <code>#error</code>,
#                           <code>#warning</code>, <code>#pragma</code>,
#                           <code>#import</code>, and <code>#include</code>.</li>
#                 </ul>
#
#             See also <code>inMacroLine</code>.
#         @var callbackName
#             The name of this callback.  This takes priority over all other names,
#                 including the sodname.
#         @var cbsodname
#             When a second open parenthesis is encountered in parsing
#             the callback name, this tells the parser that it is really
#             seeing a function that returns a callback instead of a
#             callback variable.  The original sodname value is stored
#             here, and the <code>functionReturnsCallback</code> flag
#             is set so that this value can be restored later.
#
#             If a typedef contains a second set of parentheses and is
#             <b>not</b> identiified as a function returning a callback, the
#             name inside the first set is the callback name, so this
#             gets cleared.
#         @var functionReturnsCallback
#             Indiciates that the parser has seen a function that
#             returns a callback.  If sest, the parser restores the
#             value from <code>cbsodname</code> into the
#             <code>sodname</code> field.
#
#             This is incremented to 2 while parsing the parameters 
#             for the callback, and decremented back to 1 at the end.
#         @var callbackIsTypedef
#             Indicates whether the callback is wrapped in a typedef (1) or not (0).
#                 Sets priority order of type matching (up one level in {@link blockParseOutside}).
#         @var isConstructor
#             Set to 1 after the <code>constructor</code> token is seen in TCL
#             (or equivalent in other languages).  (Not used in C++.)
#         @var seenTilde
#             Indicates that we are in a C++ destructor.
#         @var availability
#             Contains the contents of an availability macro that was seen by the parser.
#         @var prekeywordsodtype
#             If <code>startofDec</code> is 2, the parser has
#             seen <code>proc</code>, <code>sub</code>, <code>function</code>, or
#             equivalent keyword or has seen the first token of the
#             declaration.  Either way, the start-of-declaration
#             parser is expecting a name.  If it sees a
#             keyword, the <code>sodtype</code> variable is copied
#             into <code>prekeywordsodtype</code> and
#             the <code>sodname</code> variable is copied into
#             <code>prekeywordsodname</code>.
#
#             This basically fixed a bug where the <code>setter</code> keyword
#             wrecked things if it appeared after the name of an
#             Objective-C property.
#         @var prekeywordsodname
#             See prekeywordsodtype.
#         @var preclasssodtype
#             The contents of <code>sodtype</code> when <code>class</code>
#             or other similar keyword is encountered.  This is used to
#             restore things when <code>class</code> appears as part of a
#             function's return type (e.g. <code>static class
#             foo *returnsfoo();</code>).
#         @var frozensodname
#             A copy of the sodname variable frozen at a particular point in time.
#                 Freezing occurs when the parser enters certain contexts like parameter parsing
#                 because the sodname field would otherwise get overwritten by other things.
#         @var stackFrozen
#             Once the parser passes the opening curly brace of a function body, the
#                 parsed parameter stack is frozen.  This prevents other things that loook
#                 like parameter lists (e.g. the expression of an if or while statement)
#                 from getting parsed.
#         @var freezereturn
#             Once the parser passes the opening curly brace of a function body, the
#                 return type information is frozen.  This prevents other things that loook
#                 too much like function declarations from overwriting the return type info.
#
#         @var occSuper
#             The superclass of an Objective-C class.
#         @var categoryClass
#             The owning class for an Objective-C category.
#         @var isProperty
#             Set to 1 after a keyword is parsed that indicates that this
#             variable is an Objective-C property.
#         @var occmethod
#             Value is 1 if this is an Objective-C method, else 0/undefined.
#         @var occmethodname
#             The name of this Objective-C method.  As new fragments get parsed, this gets
#             extended to be foo:bar:baz:
#         @var occmethodreturntype
#             Stores the return type for an Objective-C method.
#         @var preTemplateSymbol
#             Used primarily for determining whether this is a function or a function template.
#         @var preEqualsSymbol
#             The last symbol before the equals sign.  Used to obtain the name of a variable
#             with an initial value.
#         @var kr_c_function
#             Indicates that the current code is a K&R-style C function (with separate
#             parameter type declarations, e.g.
#
#             <pre> @textblock
#             int foo(a, b)
#             int a;
#             char *b;
#             { ... function body ... }
#             @/textblock </pre>
#
#         @var kr_c_name
#             Contains the name of a K&R C function.  The normal function name detection
#             code would fail hard because of the existence of multiple declarations.
#         @var basetype
#             The type name in a simple typedef, e.g. <code>foo</code> in
#             <code>typedef struct foo bar;</code>.
#         @var typestring
#             The outer type keyword (in C, <code>struct</code>, <code>union</code>,
#             <code>enum</code>, or <code>typedef</code>).
#         @var posstypes
#             List of type names that follow after a complex typedef, e.g.
#             <code>bar</code> and <code>baz</code> in the declaration
#             <code>typedef struct foo { ...} bar, baz;</code>.
#         @var constKeywordFound
#             Set to 1 after the <code>const</code> keyword is found.
#         @var value
#             The parsed value of a constant.
#         @var nameList
#             In Pascal, upon seeing a colon (after a variable name),
#             the <code>sodname</code> and <code>sodtype</code>
#             fields are concatenated together (with a space)
#             into this field.  This later becomes the
#             variable name.
#
#         @var structClassName
#             The last symbol before a colon in a struct declaration.
#             Used for structs that look like this:
#
#             <code>struct foo : bar {...}</code>
#
#             In this case, the actual name of the struct is
#             <code>foo</code>, so that token gets stored in 
#             <code>structClassName</code> and restored later.
#
#         @var isStatic
#             Set to 1 when <code>static</code> or equivalent
#             (e.g. <code>my</code> in perl) is seen.  Used to
#             determine whether a variable is file-scoped or
#             global.
#
#         @var variablenames
#             Contains a hash table mapping variable names to
#             values when parsing variable declarations that
#             define more than one variable.
#
#         @var variablestars
#             Contains a hash table mapping variable names to
#             the number of leading <code>*</code> characters
#             before them.  By separating this from the type
#             information, it ensures that variables within
#             declarations that contain a mixture of pointer
#             and nonpointer types (<code>char *a, b, **c;</code>,
#             for example) are typed correctly.
#
#             The variable {@link curvarstars} is used for
#             temporary storage of subsequent groups of asterisks.
#
#         @var curvarstars
#             Temporary storage for asterisks before each variable
#             name in a declaration with more than one name.
#             This variable is reset to empty when the parser
#             encounters a comma in such a declaration.
#
#             See {@link curvarstars} for more information.
#
#         @var variabletype
#             Temporary storage of the variable type (e.g. int)
#             used to prevent its destruction when parsing variable
#             declarations that define more than one variable.
#
#         @var cppMacroHasArgs
#             Indicates that the <code>#define</code> macro described by the parser state
#             object has an argument list associated with it.  Used to
#             determine the definetype attribute for the macro in XML output.
#
#    @vargroup Key parser state variables
#
#         @var namePending
#             Set to 1 when the parser expects a name:
#                 <ul>
#                     <li>After the keyword <code>function</code>, <code>procedure</code>, <code>sub</code>, or other similar
#                         function delimiter tokens.</li>
#                     <li>Set to 2 after the keyword <code>typedef</code>, <code>struct</code>, <code>union</code>, and so on
#                         because the name is the second non-keyword token after this one.
#                         Decremented at the end of the token loop.</li>
#                 </ul>
#         @var onlyComments
#             Initially, this is set to 1.  As soon as the parser sees a valid code token,
#             this variable is set to 0.  This serves two purposes.  If the parser sees an
#             opening curly brace before this gets set to 0, it restarts parsing without
#             returning.  (See continue_no_return in {@link blockParse}.)  Also, once the parser has seen
#             a code token, it will not allow the C preprocessing code to take over
#             and return a <code>#define</code> that appears in the middle of a declaration.
#         @var seenMacroPart
#             Indicates that we've seen at least one non-whitespace token after
#             the <code>#define</code>.  (This means the name should be locked, among
#             other things.)
#         @var inMacroLine
#             Used for handling macros in the middle of declarations.
#         @var seenMacroStart
#             Set high after a <code>#define</code> token has been parsed.  Once set,
#             the {@link seenMacroName} key is set on the next word token.
#         @var seenMacroName
#             Set high after the macro name has been parsed.
#             If this is set and {@link inMacroTail} is not set,
#             if a parenthesis is encountered, it represents
#             the start of an argument list, which causes
#             {@link cppMacroHasArgs} to be set.
#         @var inMacroTail
#             Set high upon encountering the first whitespace after
#             a macro name.  Once this key is set, the value of the
#             {@link cppMacroHasArgs} key is no longer set upon
#             encountering an open parenthesis.
#         @var ignoreAvailabilityMacros
#             Set high within the definition for any of the built-in
#             availability macros so that those macro definitions can
#             be properly parsed even if they refer to other
#             availability macros.
#         @var inBrackets
#             Indicates the number of levels of nested square brackets the current
#             token is within.
#         @var inComment
#             Indicates whether we are in a multi-line comment.  See also
#             the <code>ppSkipOneToken</code> local variable in
#             {@link blockParse}.
#         @var inInlineComment
#             Indicates whether we are in a single-line comment (i.e. one
#             beginning with a hash or two slashes).
#
#             Initial value is 4.  Decremented to 3 at end of loop.
#             Decremented to 2 after next token, then 1, increased to 3
#             if 1 and saw exclamation point.  I don't remember what this
#             code does, and it is probably wrong.
#         @var inString
#             Inside a double-quoted string literal if 1, else 0.
#             Set to 13 for a multi-line string (e.g. FOO &lt;&lt;EOF...).
#         @var inChar
#             Inside a single-quoted character/string literal.
#         @var inTemplate
#             Within C++ template braces (&lt; and &gt;).  Also used for
#             IDL bracket notation.
#         @var inOperator
#             In a C++ operator declaration.
#         @var inPrivateParamTypes
#             Set to 1 after the colon in a C++ method declaration.
#             Indicates that the parser is parsing the private parameter
#             declarations for the method.
#         @var inRuby
#             In a Ruby quote.  Quotes in Ruby are much more complex
#             than in any sane language, so they get their own
#             variable....
#         @var callbackNamePending
#             In a typedef of a callback, indicates that the next word token
#             is the name of a callback.  (Non-typedef callback names get
#             picked up naturally by the parameter parsing code---if a second
#             set of parsed parameters appear, the first set becomes the
#             callback name.)  Values are:
#
#             <ul>
#                 <li>0 &mdash; Normal state.</li>
#                 <li>1 &mdash; Just saw leading <code>typedef</code> token.</li>
#                 <li>2 &mdash; Saw first word after typedef.</li>
#                 <li>3 &mdash; Saw parenthesis after first word.  Capture
#                     the name now.</li>
#                 <li>4 &mdash; Saw name token after parenthesis.
#                     (Further word tokens mean it's not a callback.)</li>
#                 <li>5 &mdash; Saw :: after name.  Continue to capture
#                     the name here.</li>
#             </ul>
#         @var backslashcount
#             The number of backslashes since the last non-backslash
#             token.  Modified by {@link resetBackslash} and
#             {@link addBackslash}.
#
#         @var posstypesPending
#             The next token should go into the posstypes variable.
#         @var seenBraces
#             The opening brace of functions/methods and function-like macros
#             has been seen by the parser, so the parser is now in a state
#             where it does nothing but walk to the matching close brace.
#         @var startOfDec
#             The control variable for the startOfDec parser.  Used to
#             control when the variables <code>sodname</code> and
#             <code>sodtype</code> get filled.
#         @var valuepending
#             This variable goes high after an equals sign, indicating that
#             the next tokens contain the value of the constant.
#         @var rollbackPending
#             Set to 1 during parsing to indicate that the state should be
#             rolled back when done handling this token.  After this token,
#             the parser calls {@link rollback} to roll back to the
#             previously saved state.
#         @var rollbackState
#             A temporary copy of the parser state that the parser can roll
#             back to under certain circumstances.  Set by {@link rollbackSet}
#             and used by {@link rollback}.
#         @var inEnum
#             Set to 1 while inside an enumeration.
#         @var inTypedef
#             Set to 1 while inside a C typedef.
#         @var inProtocol
#             Possible values are:
#             <ul>
#                 <li>0 &mdash; Not in a protocol.</li>
#                 <li>1 &mdash; Saw <code>\@protocol</code> token.</li>
#                 <li>2 &mdash; After next word token after <code>\@protocol</code>.  Returns to
#                     this state after closing <code>&gt;</code> token.
#                     In this state, it is capturing tokens into
#                     the <code>extendsProtocol</code> field.</li>
#                 <li>3 &mdash; Inside conforming angle braces (<code>&lt;</code>).</li>
#             </ul>
#
#         @var inRubyClass
#             Normally 0.
#
#             Set to 1 when a Ruby class declaration is encountered.
#
#             Set to 2 when the first newline after a Ruby class is encountered.
#         @var inRubyBlock
#             The character that began the current Ruby block.  For example, the
#             <code>&lt;&lt;</code> token.
#         @var inBitfield
#             Indicates that we are at a token that <b>might</b> be the start of
#             a C bitfield.  This goes high when a colon occurs.  If the next
#             token is a non-colon (i.e. it's not <code>::</code>),
#             <code>startOfDec</code> gets reset to zero to lock the name and
#             stuff..
#         @var inExtends
#             Set to 1 when the <code>extends</code> keyword is encountered in
#             Java. Reset to 0 when an <code>implements</code> keyword occurs.
#         @var inImplements
#             Set to 1 when the <code>implements</code> keyword is encountered
#             in Java. Reset to 0 when an <code>extends</code> keyword occurs.
#         @var inOfIn
#             Set to 1 when AppleScript <code>of</code> or <code>in</code> token
#             is encountered. Reset to 0 on newline or after encountering the
#             next word token and appending it to <code>OfIn</code>.
#         @var OfIn
#             Set to the actual <code>of</code> or <code>in</code> token
#             encountered when parsing AppleScript.  The word token after it is
#             appended to this variable (delimited by a space).
#         @var ASINELSE
#             Set to 1 at an "else" statement.  If the next word token is "if",
#             we don't treat it as opening a new brace.
#         @var ASLBRACEPRECURSOR
#             In an <code>if</code> or <code>tell</code> statement, stores
#             the <code>if</code> or <code>tell</code> token.  Used to determine
#             whether to treat the following newline as a brace.
#         @var ASLBRACEPRECURSORTAG
#             In an <code>if</code> or <code>tell</code> statement, stores
#             the <code>then</code> or <code>to</code> token.  Used to determine
#             whether to treat the following newline as a brace.
#         @var inUnion
#             Set to 1 when the union keyword is encountered.  Remains high
#             until the end of this declaration.
#         @var inClass
#             Indicates whether we are in a class.  Possible values are:
#             <ul>
#                 <li>0 &mdash; Not in a class declaration.</li>
#                 <li>1 &mdash; Enters this state when a class keyword is
#                     encountered (except <code>\@protocol</code> or
#                     <code>\@interface</code>.</li>
#                 <li>2 &mdash; Enters this state when the <code>\@interface</code>
#                     class keyword is encountered.  Returns to 1 when a colon or
#                     close parenthesis is encountered.</li>
#                 <li>3 &mdash; Enters this state on the first word token found while in state 2.
#                     Returns to 1 when colon or close parenthesis is encountered.</li>
#             </ul>
#         @var inClassConformingToProtocol
#             Set to 1 when a conforming left angle bracket (<code>&lt;</code>) is seen in an
#             <code>\@protocol</code> declaration.
#
#             Set to 2 after that token.  While this value is 2, tokens are
#             gathered in the <code>conformsToList</code> string.
#
#             Reset to 0 upon seeing the matching right angle bracket (<code>&gt;</code>).
#         @var classIsObjC
#             Set to 1 when an Objective-C class token is encountered.
#             In addition to playing a key role in parsing decisions,
#             this also causes <code>sublang</code> to be set to
#             <code>occ</code>.
#         @var conformsToList
#             The list where the list of classes to which this protocol
#             conforms is stored.  This variable contains a string.
#         @var inGiven
#             Set to 1 when a <code>given</code> token is seen in AppleScript.  Reset to 0
#             at the following newline.
#         @var inLabel
#             Set to 1 when a label token is seen in AppleScript.  (See the
#             <code>labelregexp</code> variable in
#  {@link //apple_ref/perl/instm/HeaderDoc::Utilities/parseTokens//() parseTokens} for
#             a list of these tokens.)
#
#             Reset to 0 after the next word token, at the following newline,
#             or when a <code>given</code> token is encountered.
#         @var INIF
#             Inside an <code>if</code> statement.  Only used if the <code>HeaderDoc::parseIfElse</code>
#             variable is set to 1.
#         @var INMODULE
#             Indicates that the parser is in a module declaration.
#             Possible values are:
#
#             <ul>
#                 <li>0 &mdash; Not in a module declaration.</li>
#                 <li>1 &mdash; Saw the module token.</li>
#                 <li>2 &mdash; Unused vestigial state.</li>
#                 <li>3 &mdash; Unused vestigial state.</li>
#             </ul>
#         @var classNameFound
#             Set to 1 after a class name has been parsed.  (Set back
#             to 0 if double colons are seen.)  If a second word token
#             is encountered in this state, it's a variable instead of
#             a class (e.g. <code>class foo *foo_instance;</code>).
#         @var classNameConcat
#             Set to 1 on encountering a period while parsing the name of an
#             IDL class.  This causes the next token to be interpreted as an
#             additional part of the name rather than turning the whole thing
#             into a class instance.  Set to 0 after encountering the next
#             token.
# 
#             The bleeding of JavaScript-specific syntax into IDL files is
#             really something of an abuse of the language, but supporting
#             it is necessary to parse certain content.
#         @var variableNameConcat
#             Tells the parser to concatenate extra bits onto the name of
#             a function, variable, etc.  For example, foo.bar is
#             (ostensibly) a valid name in Java, JavaScript, and IDL.
#
#             Set to 2 on encountering a period while parsing the name of
#             a variable, function, etc.  Goes down to 1 when the period is
#             concatenated, zero when the next word token is concatenated.
#         @var declarationEndsAtNewLine
#             TCL variables, AppleScript variables, and TCL
#             functions end at a newline character.  When
#             these are detected (by token matching), this
#             variable is set to 1.
#
#         @var temponlyComments
#             When a semicolon is encountered, if the parser might
#             be parsing a parameter list that is semicolon-delimited
#             (<code>parsedParamParse</code> &lt;= 2), this gets
#             the value of the <code>onlyComments</code> field,
#             and the value is replaced at the end of the loop.
#
#             If this was not the first character in the overall
#             declaration, this has the effect of preventing the
#             <code>onlyComments</code> value from being reset by
#             the semicolon handler.
#
#             If this was the first character in the overall
#             declaration, the value of <code>onlyComments</code>
#             was already zero, so this has no effect.
#
#             Note: this could probably be replaced by a flag
#             to simply tell the various bits of code not to
#             change the <code>onlyComments</code> value, but
#             it's probably not worth the effort for the
#             limited simplification this would cause.
#
#         @var leavingComment
#             Set to 1 on an end-of-comment token so that
#             the ending comment token won't get added to
#             the return type.
#
#         @var treePopTwo
#             This gets set to 1 when a token is encountered that causes the tree to be nested
#             but has no explicit ending token (e.g. +, -, or :).  Thus, when the enclosing
#             context ends and the parse tree gets popped from the <code>treeStack</code> stack,
#             the code pops a second time for this token.
#
#         @var bracePending
#             Normally 0.
#
#             Set to 1 if the parser is expecting a brace
#             at the end of the first part of a struct, union,
#             or enum declaration.  If it gets a word token
#             instead, the parser is parsing a variable
#             declaration rather than a type declaration.
#
#             Set 2 if the parser is expecting another
#             word token before changing this variable to 1.
#             For example, if the parser encounters a
#             double colon (<code>::</code>), the next word
#             token is part of the structure name, but a
#             subsequent word token after that would make it
#             a structure variable instead.
#
#         @var externC
#             In C, when the <code>extern</code> is encountered,
#             this flag is set to 1 and the {@link rollbackSet}
#             function is called to set a rollback point.  The
#             declaration to date is also stored in the
#             <code>preExternCdeclaration</code> field at this
#             time.
#
#             If what comes after this token is <code>C</code>,
#             then the previous declaration is restored and the
#             parser state is rolled back to this point.
#
#         @var preExternCcurline
#             The value of <code>curline</code> is stored in this
#             variable when the <code>extern</code> token is
#             encountered.  This value is rolled back when
#             <code>rollbackPending</code> is set.  See
#             <code>externC</code> for details.
#
#         @var preExternCdeclaration
#             In C, when the <code>extern</code> is encountered,
#             the declaration to date is stored here.  See
#             <code>externC</code> for details.
#             
#         @var initbsCount
#             Contains the number of braces on the brace stack
#             when this parser state was created.  When the
#             number of braces drops below this level, this
#             parser state must go away.
#             
#         @var pushedfuncbrace
#             Set to 1 when a <code>sofunction</code> token is seen
#             in the few languages that both use this token and 
#             do not precede the function body with any other
#             opening brace.
#
#         @var afterNL
#             A nondestructive variant of {@link firstpastnl} that is available to
#             any programming language (and currently used in TCL).
#             Set to 2 after a newline, 1 during the first non-space
#             token, 0 after.  Also set to 2 initially.
#
#         @var inrbraceargument
#             Some languages take an additional argument for their equivalent of
#             a right brace.  For example, in AppleScript, a <code>tell</code>
#             block ends with <code>end tell</code>.  In effect, <code>end</code>
#             terminates the block, but the next token does not start the next
#             block.
#
#             If {@link //apple_ref/doc/functionvar/HeaderDoc::Utilities/parseTokens/rbracetakesargument rbracetakesargument}
#             is set in the object returned by a call to
#             {@link //apple_ref/perl/instm/HeaderDoc::Utilities/parseTokens//() parseTokens},
#             then that trailing <code>tell</code> is included in the
#             trailer for the block.
#
#    @vargroup Parameter, attribute, asm, and availability parsing
#
#         @var parsedParamParse
#                Indicates parameter parsing is in progress.  Possible values are:
#
#                 <ul>
#                     <li>0 &mdash; Not parsing parameters</li>
#                     <li>1 &mdash; Parsing semicolon-delimited parameters.</li>
#                     <li>2 &mdash; About to parse semicolon-delimited parameters.</li>
#                     <li>3 &mdash; Parsing comma-delimited parameters.Not parsing parameters</li>
#                     <li>4 &mdash; About to parse comma-delimited parameters.</li>
#                     <li>5 &mdash; Parsing whitespace-delimited parameters.</li>
#                     <li>6 &mdash; About to parse space-delimited parameters.</li>
#                 </ul>
#
#                    The value is set to the even-numbered variant first, which causes the current
#                    token (usually a brace or parenthesis) to be skipped and the value to be
#                    decremented by 1, after which all future tokens are parsed.
#
#         @var parsedParam
#                    Temporary storage for the parsed parameter being parsed.  Used only by the
#                    Python parser.  (The main block parser uses a local variable,
#                    <code>$parsedParam</code> instead.)
#
#         @var occparmlabelfound
#             Possible values are:
#             <ul>
#                 <li>-2 &mdash; Colon encountered without seeing a label.
#                     In this state, the token is captured as the name of the
#                     parameter because the parameter has no label.  After
#                     a word token is captured, the state returns to 0
#                     because the next token is the name of the next
#                     parameter.</li>
#                 <li>-1 &mdash; Colon encountered while in state 1.  The
#                     paramter name follows.  After a word token is
#                     captured, this gets incremented to 0 because the next
#                     token is the name of the next parameter.</li>
#                 <li>0 &mdash; Default state.  If colon is encountered, goes to state -2.</li>
#                 <li>1 &mdash; Enters this state on first word token that's not in parentheses (thus skipping types in Objective-C methods).  If colon is
#                     encountered, go to state -1.</li>.
#             </ul>
#
#         @var ASlabel
#             The AppleScript label currently being parsed.  Each
#             label is treated as a parsed parameter.
#
#         @var attributeState
#             Used when parsing the GCC <code>__attribute__</code>
#             info, <code>__asm__</code> declarations, and other
#             similar pieces of info (certain availability macros,
#             for example).
#
#             Legal values are:
#
#             <ul>
#                 <li>0 &mdash; Not parsing an attribute.</li>
#                 <li>1 &mdash; Just saw the leading token.</li>
#                 <li>-1 &mdash; Got the leading open parenthesis.
#                     Decremented to smaller negative values as
#                     additional open parentheses are parsed.
#                     Incremented towards 0 as close parentheses
#                     are parsed.  When it reaches zero, the tree
#                     is popped up a level, and attribute parsing
#                     is complete.</li>
#             </ul>
#
#         @var parsedParamAtBrace
#             Any in-progress parsed parameters when we enter a brace.
#
#         @var parsedParamStateAtBrace
#             The state of parameter parsing when we enter a brace.
#
#    @vargroup Token variables
#
#         @var lastsymbol
#             The last token, wiped by braces, parentheses, and so on.  It is used primarily
#             for handling names of typedefs.  In general, when writing code, except in a few
#             specific contexts, you probably want the local variable
#             <code>lasttoken</code> in {@link blockParse} instead.  Also
#             related are the local variables <code>lastnspart</code> and
#             <code>lastchar</code>.
#
#    @vargroup Parser state insertion
#
#         @var hollow
#             This variable holds a reference to the node in
#             the parse tree where the parser state should be stored when the current declaration
#             has been fully parsed.
#         @var noInsert
#             Set high to indicate that the next curly brace should not
#             result in a parser state insertion.  Used when, for example,
#             a curly brace appears on its own prior to any actual
#             declaration.
#         @var skiptoken
#             Set to 1 when the parser state has just been
#             pushed so that the <code>hollow</code> value won't
#             point to (at least) the next token.
#
#    @vargroup Parser stacks
#
#         @var braceStack
#             Stack for brace tokens, including the left curly brace, the start-of-template
#             (<code>sotemplate</code>) value, the left square bracket, the left parenthesis
#             and the opening class marker for class markers that aren't followed by a left
#             curly brace (Objective-C <code>\@interface</code>, for example).
#
#             This is currently used exclusively for Python.
#             Other languages use a local variable in {@link blockParse}.
#         @var parsedParamList
#             An array of parsed parameter strings.  When parsing a function, these are the
#             parameters to the function.  When parsing a struct or similar, these are the
#             fields in the structure.
#         @var pplStack
#             A stack of parsed parameter lists.  Used to handle fields and parameters in
#             nested structures/callbacks.
#         @var freezeStack
#             Copy of the pplStack when the stack is frozen by <code>stackFrozen</code>.
#         @var treeStack
#             A stack of parse trees.  These are pushed and popped at various points during
#             the parse process as braces, colons, parentheses, etc.  The behavior is
#             controlled by the variables <code>treeNest</code>, <code>treeSkip</code>,
#             <code>treePopTwo</code>, and <code>treePopOnNewLine</code>
#             (most of which are local variables in {@link blockParse}
#             and/or 
#  {@link //apple_ref/perl/instm/HeaderDoc::PythonParse/pythonParse//() pythonParse}.
#
#             This is currently used exclusively for Python.
#             Other languages use a local variable in {@link blockParse}
#             by the same name.
#
#         @var availabilityNodesArray
#             Temporary storage scribbled into by {@link blockParse}.
#             Each token in this array is the top of a subtree
#             that begins with one of the "Magic" availability
#             macros in Availability.list (e.g.
#             <code>__OSX_AVAILABLE_BUT_DEPRECATED</code> or
#             <code>__OSX_AVAILABLE_STARTING</code>).
#
#    @vargroup Additional data
#
#         @var functionContents
#             The contents of a function (or, when parsing a switch
#             statement, the contents of the struct body).
#
#         @var lastDisplayNode
#             The last node in the parse tree rooted at this node that
#             should be displayed.  Used only in AppleScript, to hide
#             content nested inside functions while still parsing them
#             fully.  Unlike lastTreeNode, this node's children
#             <b>should</b> be included in the output.
#
#         @var lastTreeNode
#             The last node in the parse tree rooted at this node.
#             This node is marked with EODEC in parse tree dumps.
#
#             For example, the <code>lastTreeNode</code> value for
#             a class declaration would point to the closing brace
#             or semicolon at the end of the class.
#
#             Note that nodes within the class, each nested
#             declaration also has a <code>lastTreeNode</code>
#             value that points to the end of that nested
#             declaration.
#             
#         @var classtype
#             Contains the token that began the current class
#             declaration with any leading <code>\@</code> sign merged.
#             Returned to the caller.
#
#         @var returntype
#             The return type of a function, callback, or
#             (non-Objective-C) method.
#
#         @var lang
#             The language that the parser was parsing when
#             this parser state was created.
#         @var sublang
#             The language dialect that the parser was parsing
#             when this parser state was created (e.g. <code>cpp</code>
#             for C++).
#
#         @var inputCounter
#             The input counter.  Used for restoring the
#             value during a subparse (reprocessing a
#             declaration within an already-parsed class).
#             
#         @var sodtypeclasstoken
#             Contains the token that began the current class
#             declaration.  Used to restore the <code>class</code> token
#             if it is really just the start of a variable name.
#
#         @var FULLPATH
#             The full path for the file containing the
#             declaration that this parser state describes.
#             By storing the info here, it is available for
#             debug messages during subparse operations
#             (reprocessing declarations nested within
#             class declarations).
#
#         @var APIODONE
#             Set on parser state objects that represent declarations
#             within classes so that it does not get processed twice.
#
#         @var optionalOrRequired
#             Either \@optional or \@required, depending on the current
#             state of the parser.
#
#    @vargroup Parsing actual code
#         @var seenIf
#             If <code>$HeaderDoc::parseIfElse</code> is 1, this
#             flag is set to indicate that the tree associated
#             with this parser state contains an <code>if</code> clause.
#         @var seenElse
#             If <code>$HeaderDoc::parseIfElse</code> is 1, this
#             flag is set to indicate that the tree associated
#             with this parser state contains an <code>else</code> clause.
#         @var ifContents
#             The contents of the <code>if</code> part of an <code>if/else</code> conditional
#             (not including the test expression).  Only valid if
#             <code>$HeaderDoc::parseIfElse</code> is 1.
#         @var elseContents
#             The contents of the <code>else</code> part of an <code>if/else</code> conditional.
#             Only valid if <code>$HeaderDoc::parseIfElse</code> is 1.
#
#    @vargroup C preprocessing variables
#
#         @var macroNoTrunc
#             Set to 1 to avoid truncating the body of macros that
#             don't begin with a parenthesis or brace.  Otherwise 0.
#
#         @var NEXTTOKENNOCPP
#             Turns off the C preprocessor temporarily.
#             <ul>
#                 <li>0 &mdash; Normal operation.</li>
#                 <li>1 &mdash; Just saw <code>#if</code>.  Goes to 3 if you get a <code>defined</code> token.</li>
#                 <li>2 &mdash; Just saw <code>#ifdef</code>.  Don't do C preprocessing for the symbol that follows.  Goes to 0 after the next word token.</li>
#                 <li>3 &mdash; In <code>#if defined</code>.  Don't do c preprocessing fr the symbol that follows, and drop back to state 1 after a word token.</li>
#             </ul>
#
#    @vargroup Objective-C-specific variables
#
#         @var gatheringObjCReturnType
#             While parsing an Objective-C method, this gets
#             set to 1 upon seeing an open parenthesis, 2 at
#             the bottom of the loop.  While at 2 or greater,
#             tokens are appended to the
#             <code>occmethodreturntype</code> variable.
#
#             This value is incremeneted when additional open
#             parentheses are encountered, and is decremented
#             when close parentheses are encountered.  When it
#             reaches 1 again, it is reset to 0.
#
#         @var extendsProtocol
#             Stores the name of the Objective-C protocol that
#             this protocol extends (the tokens within angle
#             brackets).
#
#         @var occmethodtype
#             The Objective-C method type.  Contains either a
#             <code>-</code> or <code>+</code> character.
#
#    @vargroup IDL-specific variables
#
#         @var MODULE
#             Temporary storage for the name of a module.
#             The <code>module</code> token is treated much
#             like an <code>\@indexgroup</code> tag.
#
#         @var sodbrackets
#             Captures the data between square brackets when
#             <code>startOfDec</code> is 2.  This state typically
#             occurs after the first non-symbol token in the line.
#             Used for temporarily storing the bracketed
#             attributes in an IDL file.
#
#    @vargroup Perl/Shell-specific variables
#
#         @var perlClassName
#             Stores a Perl class name (this::that::the_other).
#             When a <code>::</code> token is encountered,
#             <code>::</code> is appended (if this variable is
#             nonempty), followed by <code>sodname</code>.
#             
#    @vargroup Python-specific variables
#
#         @var namepending
#             Python-specific parser state variable.
#             The initial value is 1.  Set high after
#             A <code>Class</code> keyword or a <code>def</code> keyword.
#             Set low after a word token (the name).
#
#         @var setleading
#             In python, indicates that this is the first
#             line of nonempty declaration encountered, so
#             the next leading space should not result in
#             any comparisons of indentation.
#
#         @var seenLeading
#             The number of leading spaces on the current line.
#
#             If this indentation drops to be at or below the
#             indentation in <code>leadspace</code> (the
#             indentation of the first line inside this nesting
#             level) or if <code>leadspace</code> is -1 (and
#             thus uncheckable) and this value drops to be at
#             or below the value in <code>parentLeading</code>
#             (the neting level above this one), the block is
#             done.
#
#         @var leadspace
#             The number of leading spaces in the first line
#             since the parser state was created.
#
#             Initial value is -1 indicating that the value
#             has not yet been determined.  This value does
#             not get set until the first line that
#             contains at least one non-space token after
#             that whitespace and before the trailing newline.
#
#             If the current line's leading space (in
#             <code>seenLeading</code> drops to this level or
#             lower, the end of block is considered to have been
#             reached.
#
#         @var parentLeading
#             Holds the number of leading spaces at the beginning
#             of the line for the enclosing block.
#
#             If the current line's  leading space drops to this
#             level or lower, the end of block is considered to
#             have been reached.
#
#         @var seenToken
#             Used by the Python parser to determine whether
#             it has seen the first non-space token in a line.
#             This disables leading space counting.
#
#         @var justLeftStringToken
#             After an empty string (""), this gets set high
#             in Python.  That way, if the next token is
#             also a double quote mark, the opening triple
#             quote of a triple-quoted tring can be easily
#             detected.
#
#         @var endOfTripleQuote
#             The number of quote tokens in a row when
#             potentially leaving a triple-quoted string.
#
#             This value is reset to zero upon
#             encountering a non-quote token.
#
#             If this reaches 2, the next quote mark causes
#             the three quotes to be combined into a single
#             token, and the value is reset to 0.
#
#         @var endOfTripleQuoteToken
#             When a quote mark is seen, the object is
#             added here so that the parser can easily
#             go back to it later if it turns out to be
#             a triple quote.  This is used to merge the
#             three quote marks into a single token in
#             the parse tree.
#
#         @var setHollowAfter
#             Used by the Python parser to indicate that after this
#             token has been inserted into the tree, the
#             <code>hollow</code> field should be set to the resulting
#             tree node.
#
#         @var popAfter
#             In the Python parser, indicates that a new
#             <code>$treeCur</code> should be popped from
#             the stack (<code>treeStack</code> field)
#             after inserting this node.
#
#         @var lastpart
#             Holds the last part before the one being processed
#             by the Python parser.  Similar to the local variable
#             of the same name in {@link blockParse}.
#
#         @var popAtEnd
#             Set to 1 if parser sees a colon while <code>bracePending</code>
#             is set.  This indicates that if this declaration
#             ends at the end of this line, the parse tree (which has
#             become nested by the colon) needs to be poped back out.
#
#         @var nestAfter
#             Indicates that after inserting this token into the parse
#             tree, future tokens should be nested under this one.
#
#         @var endgame
#             In Python, this variable determines whether the
#             declaration is done after this token, in which case
#             a new parser state (sibling) must be added.
#
#             <ul>
#                 <li>0 &mdash; Nope.</li>
#                 <li>1 &mdash; In this state if we got a newline and
#                     <code>autoContinue</code> is 0 (we're not in
#                     a nested block).  We're done after this token,
#                     but it should be added to the parse tree.</li>
#                 <li>2 &mdash; <code>seenLeading is less than
#                     <code>leadspace</code>.  Don't add this token
#                     to the parse tree because it's part of the
#                     next declaration.</li>
#                 <li>3 &mdash; <code>seenLeading is Less than
#                     <code>parentLeading</code>.  Don't add this
#                     token to the parse tree because it's part of
#                     the next declaration.</li>
#             </ul>
#         @var autoContinue
#             In Python, this indicates the number of block
#             nesting levels deep the parser is (e.g. the start
#             of a function sets this to 1, an if statement
#             inside that function increases it to 2, and so on).
#
#         @var lastNLWasQuoted
#             In Python, set to 1 if the last newline was preceded
#             by a backslash, else unset.  Used to determine
#             whether to care about the leading whitespace count.
#
#         @var pushParserStateOnBrace
#             Set to 1 when a keyword is encountered that should
#             cause the parser state to be pushed the next time the
#             tree is nested (a class keyword, specifically).
#
#             Set to 2 when the colon at the end of the class
#             declaration is parsed.  After the token is pushed
#             onto the tree, the parser state is pushed onto
#             the parser stack, and the value is incremented
#             to 3 so that it does not get pushed again.
#
#    @vargroup Ruby-specific variables
#
#         @var waitingForExceptions
#             Set to 1 when Ruby parsing encounters a left angle
#             bracket (<code>&lt;</code>) in a class declaration.
#
#         @var followingrubyrbrace
#             A while or other statement right after
#             an end statement (on the same line) is
#             treated as applying to the preceding
#             block instead of starting a new one.
#
#             Set to 1 when end is encounered, 0 at
#             following newline.
#
#         @var pendingBracedParameters
#             Used in languages where parameters are wrapped in
#             curly braces.  A value of 1 indicates that the next
#             curly brace should start parameter parsing.  A value
#             of 2 indicates that such a brace has been parsed.
#             The default value is 0.
#
#         @var newlineIsSemi
#             In Ruby, an <code>end</code> marks the end of a function,
#             so treat the newline after it as the end of the declaration.
#
#    @vargroup Java-specific variables
#
#         @var implementsClass
#             The name of the abstract class that this class
#             implements.
#
#         @var extendsClass
#             The name of the class that this class extends.
#
#    @vargroup Pascal-specific variables
#
#         @var waitingForTypeInformation
#             By default, 0.
#
#             Set to 2 on a colon within a variable declaration.
#
#             If 2, set to 1 on non-space.
#
#             If 1, set to 3 on open parenthesis, else -1 if non-space.
#
#             Basically, if this goes to 3, the variable is a
#             Pascal enumerated type, e.g.
#
#             <code>pascal_var_e: (apple, pear, banana, orange, lemon);</code>
#
#             Otherwise, the declaration is just a normal variable.
#
#         @var firstpastnl
#             In shell (and Perl), set to 1 after a newline until the
#             first non-space token.
#
#         @var inCase
#             In shell, initially 0, incremented upon entering a case
#             statement, and decremented on exit.
#
#         @var endOfString
#             In shell (and Perl), set to the token after a &lt;&lt; that is
#             treated as the start of a multi-line string.  Reset to
#             an empty string upon leaving the multi-line string.  While
#             in this state, <code>inString</code> is set to 13.
#
#         @var afterSemi
#             In shell, initially 0, set to 2 after a double-semicolon or
#             1 after a semicolon (but never set to 1 after it is already 2).
#             Reset to 0 after the first non-space token.  Used in case/esac
#             parsing.
#
#    @vargroup TCL-specific variables
#
#         @var inTCLRegExpCommand
#             In TCL, set to 1 when a command is encountered that takes an
#             unquoted (non-string) regular expression as an argument.
#
#             Set to 0 upon entering the regular expression or when a
#             newline or carriage return is encountered.
#
#    @vargroup Legacy junk variables
# 
#         @var simpleTDcontents
#             The guts of a simple typedef.
#
#         @var storeDec
#             Temporary storage for nested declarations, used
#             to build up the vestigial plain text declaration.
#
#  */
package HeaderDoc::ParserState;

use strict;
use vars qw($VERSION @ISA);
use HeaderDoc::Utilities qw(isKeyword casecmp);
use HeaderDoc::BlockParse qw(bracematching);
use Carp qw(cluck);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::ParserState::VERSION = '$Revision: 1394058015 $';
################ General Constants ###################################
my $debugging = 0;

my $treeDebug = 0;

my $backslashDebug = 0;

my %defaults = (
	frozensodname => "",
	stackFrozen => 0, # set to prevent fake parsed params with inline funcs
	returntype => "",
	freezereturn => 0,       # set to prevent fake return types with inline funcs
	availability => "",      # holds availability string if we find an av macro.
	lang => "C",

	inComment => 0,
	inInlineComment => 0,
	inString => 0,
	inChar => 0,
	# inRuby => 0,             # %{ -> "1".  %Q{ -> "2".  <<BLOCK -> "3"
	# inRubyBlock => "",       # inRubyBlock == "BLOCK" in example above.
	inTemplate => 0,
	inOperator => 0,
	inPrivateParamTypes => 0,  # after a colon in a C++ function declaration.
	onlyComments => 1,         # set to 0 to avoid switching to macro parse.
                                  # mode after we have seen a code token.
	inMacro => 0,
	inMacroLine => 0,          # for handling macros in middle of data types.
	seenMacroPart => 0,        # used to control dropping of macro body.
	macroNoTrunc => 1,         # used to avoid truncating body of macros
	inBrackets => 0,           # square brackets ([]).
    # $self->{inPType} = 0;              # in pascal types.
    # $self->{inRegexp} = 0;             # in perl regexp.
    # $self->{regexpNoInterpolate} = 0;  # Don't interpolate (e.g. tr)
    # $self->{inRegexpTrailer} = 0;      # in the cruft at the end of a regexp.
    # $self->{ppSkipOneToken} = 0;       # Comments are always dropped from parsed
                                  # parameter lists.  However, inComment goes
                                  # to 0 on the end-of-comment character.
                                  # This prevents the end-of-comment character
                                  # itself from being added....

    # $self->{lastsymbol} = "";          # Name of the last token, wiped by braces,
                                  # parens, etc.  This is not what you are
                                  # looking for.  It is used mostly for
                                  # handling names of typedefs.
	name => "",                # Name of a basic data type.
	callbackNamePending => 0,  # 1 if callback name could be here.  This is
                                  # only used for typedef'ed callbacks.  All
                                  # other callbacks get handled by the parameter
                                  # parsing code.  (If we get a second set of
                                  # parsed parameters for a function, the first
                                  # one becomes the callback name.)
	callbackName => "",        # Name of this callback.
	callbackIsTypedef => 0,    # 1 if the callback is wrapped in a typedef---
                                  # sets priority order of type matching (up
                                  # one level in headerdoc2HTML.pl).

	namePending => 0,          # 1 if name of func/variable is coming up.
	basetype => "",            # The main name for this data type.
	posstypes => "",           # List of type names for this data type.
	posstypesPending => 1,     # If this token could be one of the
                                  # type names of a typedef/struct/union/*
                                  # declaration, this should be 1.
	sodtype => "",             # 'start of declaration' type.
	sodname => "",             # 'start of declaration' name.
	sodclass => "",            # 'start of declaration' "class".  These
                                  # bits allow us keep track of functions and
                                  # callbacks, mostly, but not the name of a
                                  # callback.

	simpleTypedef => 0,        # High if it's a typedef w/o braces.
	simpleTDcontents => "",    # Guts of a one-line typedef.  Don't ask.
	seenBraces => 0,           # Goes high after initial brace for inline
                                  # functions and macros -only-.  We
                                  # essentially stop parsing at this point.
	kr_c_function => 0,        # Goes high if we see a K&R C declaration.
	kr_c_name => "",           # The name of a K&R function (which would
                                  # otherwise get lost).

    # $self->{lastchar} = "";            # Ends with the last token, but may be longer.
    # $self->{lastnspart} = "";          # The last non-whitespace token.
    # $self->{lasttoken} = "";           # The last token seen (though [\n\r] may be
                                  # replaced by a space in some cases).
	startOfDec => 1,           # Are we at the start of a declaration?
    # $self->{prespace} = 0;             # Used for indentation (deprecated).
    # $self->{prespaceadjust} = 0;       # Indentation is now handled by the parse
                                  # tree (colorizer) code.
    # $self->{scratch} = "";             # Scratch space.
    # $self->{curline} = "";             # The current line.  This is pushed onto
                                  # the declaration at a newline and when we
                                  # enter/leave certain constructs.  This is
                                  # deprecated in favor of the parse tree.
    # $self->{curstring} = "";           # The string we're currently processing.
    # $self->{continuation} = 0;         # An obscure spacing workaround.  Deprecated.
    # $self->{forcenobreak} = 0;         # An obscure spacing workaround.  Deprecated.
	occmethod => 0,            # 1 if we're in an ObjC method.
    # $self->{occspace} = 0;             # An obscure spacing workaround.  Deprecated.
	occmethodname => "",       # The name of an objective C method (which
                                  # gets augmented to be this:that:theother).
	preTemplateSymbol => "",   # The last symbol prior to the start of a
                                  # C++ template.  Used to determine whether
                                  # the type returned should be a function or
                                  # a function template.
	preEqualsSymbol => "",     # Used to get the name of a variable that
                                  # is followed by an equals sign.
	valuepending => 0,         # True if a value is pending, used to
                                  # return the right value.
	value => "",               # The current value.
	parsedParamParse => 0,
    # $self->{parsedParam} = "";         # The current parameter being parsed.
    # $self->{postPossNL} = 0;           # Used to force certain newlines to be added
                                  # to the parse tree (to end macros, etc.)
	categoryClass => "",
	classtype => "",
	inClass => 0,

	seenTilde => 0,          # set to 1 for C++ destructor.

	# parsedParamList => undef, # currently active parsed parameter list.
	# pplStack => undef, # stack of parsed parameter lists.  Used to handle
                       # fields and parameters in nested callbacks/structs.
	# freezeStack => undef, # copy of pplStack when frozen.

	initbsCount => 0,
	# hollow => undef,      # a spot in the tree to put stuff.
	noInsert => 0,
	bracePending => 0,	# set to 1 if lack of a brace would change
				# from being a struct/enum/union/typedef
				# to a variable.
	backslashcount => 0,

	afterNL => 2,

	functionReturnsCallback => 0

);

# print STDERR "DEFAULTS: startOfDec: ".$defaults{startOfDec}."\n";
# print STDERR "DEFAULTS: inClass: ".$defaults{inClass}."\n";

# /*!
#     @abstract
#         Creates a new <code>ParserState</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::ParserState->new()</code> to allocate
#         a new instance of this class).
#  */
sub new {
    my($param) = shift;
    my($class) = ref($param) || $param;
    my %selfhash = %defaults;
    my $self = \%selfhash;

    # print STDERR "startOfDec: ".$self->{startOfDec}."\n";
    # print STDERR "startOfDecX: ".$defaults{startOfDec}."\n";

	# cluck("New parser state $self generated\n");

# print STDERR "CREATING NEW PARSER STATE!\n";

    bless($self, $class);
    $self->_initialize();

    my (%attributeHash) = @_;

    if ($attributeHash{lang} eq "python") {
	$self->{leadspace} = -1;
	$self->{endOfTripleQuote} = 0;
	$self->{autoContinue} = 0;
	$self->{namepending} = 1;

	my @temp = ();
	$self->{braceStack} = \@temp;

	my @tempb = ();
	$self->{treeStack} = \@tempb;
    }

    if (length $HeaderDoc::OptionalOrRequired) {
	$self->{optionalOrRequired} = $HeaderDoc::OptionalOrRequired;
    }

    # Now grab any key => value pairs passed in
    foreach my $key (keys(%attributeHash)) {

        $self->{$key} = $attributeHash{$key};

	# print STDERR "SET $key => ".$attributeHash{$key}."\n";
    }  
    return ($self);
}

# /*!
#     @abstract
#         Initializes an instance of a <code>ParserState</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    my @arr1 = ();
    my @arr2 = ();
    my @arr3 = ();
    my @arr4 = ();
    my @arr5 = ();

    $self->{parsedParamList} = \@arr1; # currently active parsed parameter list.
    $self->{pplStack} = \@arr2; # stack of parsed parameter lists.  Used to handle
                       # fields and parameters in nested callbacks/structs.
    $self->{freezeStack} = \@arr3; # copy of pplStack when frozen.
    $self->{parsedParamAtBrace} = \@arr4; # Any in-progress parsed parameters when we enter a brace.
    $self->{parsedParamStateAtBrace} = \@arr5; # The state of parameter parsing when we enter a brace.

    my %orighash = %{$self};

    return;

    # my($self) = shift;

    $self->{frozensodname} = "";
    $self->{stackFrozen} = 0; # set to prevent fake parsed params with inline funcs
    $self->{returntype} = "";
    $self->{freezereturn} = 0;       # set to prevent fake return types with inline funcs
    $self->{availability} = "";      # holds availability string if we find an av macro.
    $self->{lang} = "C";

    $self->{inComment} = 0;
    $self->{inInlineComment} = 0;
    $self->{inString} = 0;
    $self->{inChar} = 0;
    $self->{inRuby} = 0;
    $self->{inTemplate} = 0;
    $self->{inOperator} = 0;
    $self->{inPrivateParamTypes} = 0;  # after a colon in a C++ function declaration.
    $self->{onlyComments} = 1;         # set to 0 to avoid switching to macro parse.
                                  # mode after we have seen a code token.
    $self->{inMacro} = 0;
    $self->{inMacroLine} = 0;          # for handling macros in middle of data types.
    $self->{seenMacroPart} = 0;        # used to control dropping of macro body.
    $self->{macroNoTrunc} = 1;         # used to avoid truncating body of macros
    $self->{inBrackets} = 0;           # square brackets ([]).
    # $self->{inPType} = 0;              # in pascal types.
    # $self->{inRegexp} = 0;             # in perl regexp.
    # $self->{regexpNoInterpolate} = 0;  # Don't interpolate (e.g. tr)
    # $self->{inRegexpTrailer} = 0;      # in the cruft at the end of a regexp.
    # $self->{ppSkipOneToken} = 0;       # Comments are always dropped from parsed
                                  # parameter lists.  However, inComment goes
                                  # to 0 on the end-of-comment character.
                                  # This prevents the end-of-comment character
                                  # itself from being added....

    # $self->{lastsymbol} = "";          # Name of the last token, wiped by braces,
                                  # parens, etc.  This is not what you are
                                  # looking for.  It is used mostly for
                                  # handling names of typedefs.
    $self->{name} = "";                # Name of a basic data type.
    $self->{callbackNamePending} = 0;  # 1 if callback name could be here.  This is
                                  # only used for typedef'ed callbacks.  All
                                  # other callbacks get handled by the parameter
                                  # parsing code.  (If we get a second set of
                                  # parsed parameters for a function, the first
                                  # one becomes the callback name.)
    $self->{callbackName} = "";        # Name of this callback.
    $self->{callbackIsTypedef} = 0;    # 1 if the callback is wrapped in a typedef---
                                  # sets priority order of type matching (up
                                  # one level in headerdoc2HTML.pl).

    $self->{namePending} = 0;          # 1 if name of func/variable is coming up.
    $self->{basetype} = "";            # The main name for this data type.
    $self->{posstypes} = "";           # List of type names for this data type.
    $self->{posstypesPending} = 1;     # If this token could be one of the
                                  # type names of a typedef/struct/union/*
                                  # declaration, this should be 1.
    $self->{sodtype} = "";             # 'start of declaration' type.
    $self->{sodname} = "";             # 'start of declaration' name.
    $self->{sodclass} = "";            # 'start of declaration' "class".  These
                                  # bits allow us keep track of functions and
                                  # callbacks, mostly, but not the name of a
                                  # callback.

    $self->{simpleTypedef} = 0;        # High if it's a typedef w/o braces.
    $self->{simpleTDcontents} = "";    # Guts of a one-line typedef.  Don't ask.
    $self->{seenBraces} = 0;           # Goes high after initial brace for inline
                                  # functions and macros -only-.  We
                                  # essentially stop parsing at this point.
    $self->{kr_c_function} = 0;        # Goes high if we see a K&R C declaration.
    $self->{kr_c_name} = "";           # The name of a K&R function (which would
                                  # otherwise get lost).

    # $self->{lastchar} = "";            # Ends with the last token, but may be longer.
    # $self->{lastnspart} = "";          # The last non-whitespace token.
    # $self->{lasttoken} = "";           # The last token seen (though [\n\r] may be
                                  # replaced by a space in some cases.
    $self->{startOfDec} = 1;           # Are we at the start of a declaration?
    # $self->{prespace} = 0;             # Used for indentation (deprecated).
    # $self->{prespaceadjust} = 0;       # Indentation is now handled by the parse
                                  # tree (colorizer) code.
    # $self->{scratch} = "";             # Scratch space.
    # $self->{curline} = "";             # The current line.  This is pushed onto
                                  # the declaration at a newline and when we
                                  # enter/leave certain constructs.  This is
                                  # deprecated in favor of the parse tree.
    # $self->{curstring} = "";           # The string we're currently processing.
    # $self->{continuation} = 0;         # An obscure spacing workaround.  Deprecated.
    # $self->{forcenobreak} = 0;         # An obscure spacing workaround.  Deprecated.
    $self->{occmethod} = 0;            # 1 if we're in an ObjC method.
    # $self->{occspace} = 0;             # An obscure spacing workaround.  Deprecated.
    $self->{occmethodname} = "";       # The name of an objective C method (which
                                  # gets augmented to be this:that:theother).
    $self->{preTemplateSymbol} = "";   # The last symbol prior to the start of a
                                  # C++ template.  Used to determine whether
                                  # the type returned should be a function or
                                  # a function template.
    $self->{preEqualsSymbol} = "";     # Used to get the name of a variable that
                                  # is followed by an equals sign.
    $self->{valuepending} = 0;         # True if a value is pending, used to
                                  # return the right value.
    $self->{value} = "";               # The current value.
    $self->{parsedParamParse} => 0,
    # $self->{parsedParam} = "";         # The current parameter being parsed.
    # $self->{postPossNL} = 0;           # Used to force certain newlines to be added
                                  # to the parse tree (to end macros, etc.)
    $self->{categoryClass} = "";
    $self->{classtype} = "";
    $self->{inClass} = 0;

    $self->{seenTilde} = 0;          # set to 1 for C++ destructor.

    #my @emptylist = ();
    #$self->{parsedParamList} = \@emptylist; # currently active parsed parameter list.
    #my @emptylistb = ();
    #$self->{pplStack} = \@emptylistb; # stack of parsed parameter lists.  Used to handle
                       # fields and parameters in nested callbacks/structs.
    #my @emptylistc = ();
    #$self->{freezeStack} = \@emptylistc; # copy of pplStack when frozen.

    $self->{initbsCount} = 0;
    $self->{hollow} = undef;      # a spot in the tree to put stuff.
    $self->{noInsert} = 0;
    $self->{bracePending} = 0;	# set to 1 if lack of a brace would change
				# from being a struct/enum/union/typedef
				# to a variable.
    $self->{backslashcount} = 0;

    # foreach my $key (keys %{$self}) {
	# if ($self->{$key} != $orighash{$key}) {
		# print STDERR "HASH DIFFERS FOR KEY $key (".$self->{$key}." != ".$orighash{$key}.")\n";
	# } else {
		# print STDERR "Hash keys same for key $key\n";
	# }
    # }

    return $self;
}

# For consistency.
# /*!
#     @abstract
#         Prints object for debugging purposes.
#     @param self
#         This object.
#  */
sub dbprint
{
    my $self = shift;
    return $self->print();
}

# /*!
#     @abstract
#         Rolls back the parser state to the last state
#         saved by a call to {@link rollbackSet}.
#     @param self
#         This object.
#  */
sub rollback
{
    my $self = shift;

    my $localDebug = 0;

    my $cloneref = $self->{rollbackState};
    my $clone = ${$cloneref};
    my %selfhash = %{$self};
    my %clonehash = %{$clone};

    if ($localDebug) {
	print STDERR "BEGIN PARSER STATE ($self):\n";
	foreach my $key (keys(%clonehash)) {
		if ($self->{$key} ne $clone->{$key}) {
			print STDERR "$key: ".$self->{$key}." != ".$clone->{$key}."\n";
		}
	}
	print STDERR "END PARSER STATE\n";
    }
    foreach my $key (keys(%selfhash)) {
	# print STDERR "$key => $self->{$key}\n";
	$self->{$key} = undef;
    }
    foreach my $key (keys(%clonehash)) {
	$self->{$key} = $clone->{$key};
    }
    $self->{rollbackState} = undef;
}

# /*!
#     @abstract
#         Creates a clone of the object for future rollbacks.
#     @param self
#         This object.
#  */
sub rollbackSet
{
    my $self = shift;

    my $clone = HeaderDoc::ParserState->new();
    my %selfhash = %{$self};

    # print STDERR "BEGIN PARSER STATE ($self):\n";
    foreach my $key (keys(%selfhash)) {
	# print STDERR "$key => $self->{$key}\n";
	$clone->{$key} = $self->{$key};
    }
    $self->{rollbackState} = \$clone;
    # print STDERR "END PARSER STATE\n";
}

# /*!
#     @abstract
#         Alias for
#         {@link //apple_ref/perl/instm/HeaderDoc::ParserState/dbprint//() dbprint}.
#     @param self
#         This object.
#  */
sub print
{
    my $self = shift;
    my %selfhash = %{$self};

    print STDERR "BEGIN PARSER STATE ($self):\n";
    foreach my $key (keys(%selfhash)) {
	print STDERR "$key => $self->{$key}\n";
    }
    print STDERR "END PARSER STATE\n";
}

# /*!
#     @abstract
#         Resets the backslash couter to zero.
#     @param self
#         This object.
#  */
sub resetBackslash
{
    my $self = shift;
    $self->{backslashcount}=0;

    print STDERR "RESET BACKSLASH. COUNT NOW ".$self->{backslashcount}."\n" if ($backslashDebug);
}

# /*!
#     @abstract
#         Increments the backslash counter.
#     @param self
#         This object.
#  */
sub addBackslash
{
    my $self = shift;

    $self->{backslashcount}++;

    print STDERR "ADD BACKSLASH. COUNT NOW ".$self->{backslashcount}."\n" if ($backslashDebug);

}

# /*!
#     @abstract
#         Increments the backslash counter.
#     @param self
#         This object.
#     @param lang
#         The current programming language.
#     @param sublang
#         The current language dialect.
#  */
sub isQuoted
{
    my $self = shift;
    my $lang = shift;
    my $sublang = shift;

    my $inSingle = $self->{inChar};
    my $inString = $self->{inString};
    my $count = $self->{backslashcount};

	print STDERR "LANG: $lang INSINGLE: $inSingle INSTRING: $inString\n" if ($backslashDebug);

    # Shell scripts treat single quotes as raw data.  Backslashes
    # inside are not treated as quote characters, so to put a single
    # quote, you have to put it inside a double quote contest, e.g.
    # "It's" or 'It'"'"'s'
    if ($inSingle && $lang eq "shell") {
	print STDERR "isQuoted: Shell script single quote backslash: not quoted.  Returning 0 (count is $count).\n" if ($backslashDebug);
	return 0;
    }

    # C shell scripts don't interpret \ within a string.
    if ($inString && $lang eq "shell" && $sublang eq "csh") {
	print STDERR "isQuoted: C Shell script backslash in double quotes: not quoted.  Returning 0 (count is $count).\n" if ($backslashDebug);
	return 0;
    }


    if ($count % 2) {
	print STDERR "isQuoted: Returning 1 (count is $count).\n" if ($backslashDebug);
	return 1;
    }
    print STDERR "isQuoted: Returning 0 (count is $count).\n" if ($backslashDebug);
    return 0;
}

# /*!
#     @abstract
#         Returns whether a token should be interpreted as
#         a Ruby open quote mark.
#     @param self
#         This object.
#     @param part
#         The string to check.
#     @discussion
#         The value returned, if nonzero, indicates the value
#         that should be stored in the {@link inRuby} variable
#         in this parser state instance.  If already in a
#         Ruby string, this returns zero.
#  */
sub isRubyOpenQuote
{
	my $self = shift;
	my $part = shift;

	if ($self->{inRuby}) { return 0; }
	if ($part eq "%{") { return 1; }
	if ($part eq "%Q{") { return 2; }
	if ($part eq "<<") { return 3; }
	if ($part eq "%/") { return 4; }

	return 0;
}

# /*!
#     @abstract
#         Returns whether a token should be interpreted as
#         a Ruby close quote mark.
#     @param self
#         This object.
#     @param part
#         The string to check.
#     @discussion
#         The value returned depends on whether the close token
#         matches the open token.  This is determined based on
#         the value store in the {@link inRuby} variable
#         in this parser state instance.  If not in a
#         Ruby string, this returns zero.
#  */
sub isRubyCloseQuote
{
	my $self = shift;
	my $part = shift;

	if (!$self->{inRuby}) { return 0; }
	
	if (($self->{inRuby} == 1) || ($self->{inRuby} == 2)) {
		if ($part eq "}") { return 1; }
	} elsif ($self->{inRuby} == 4) {
		if ($part eq "/") { return 1; }
	} elsif ($self->{inRuby} == 3) {
		if ($part eq $self->{inRubyBlock}) {
			# print STDERR "BlockMatch\n";
			return 1;
		}
	}
	return 0;
}

# /*!
#     @abstract Enables some extra debugging for AppleScript.
#  */
$HeaderDoc::AppleScriptDebug = 0;

# /*!
#     @abstract Clears the left brace precursor token.
#     @result Returns whether to treat the newline as a brace.
#  */
sub clearLeftBracePrecursor
{
	my $self = shift;

	my $retval = $self->{ASLBRACEPRECURSOR};

	$self->{ASLBRACEPRECURSOR} = "";
	$self->{ASLBRACEPRECURSORTAG} = "";
	print STDERR "Cleared ASLBRACEPRECURSOR\n" if ($HeaderDoc::AppleScriptDebug);

	return $retval;
}

# /*!
#     @abstract
#         Returns whether or not this token should be
#         treated as a left brace.
#     @param self
#         This object.
#     @param part
#         The token to check.
#     @param lang
#         The programming language.
#     @param parseTokensRef
#         A parse token hash obtained from a call to {@link parseTokens}.
#     @param case_sensitive
#         Set to 1 for most languages.  Set to 0 if the
#         language uses case-insensitive token matching
#         (e.g. Pascal).
#     @param curBraceCount
#         The current brace count.  This is used to prevent
#         nesting of braces in languages that don't work that way.
#     @var lbrace
#         The primary left brace character.
#     @var lbraceunconditionalre
#         A regular expression containing other patterns that
#         are always considered left braces.  Currently used
#         for for/if in Python and Ruby, and tell in AppleScript.
#     @var lbraceconditionalre
#         In Ruby/Python, a set of tokens that are treated as
#         left braces unless they are immediately after a
#         right brace.  Basically, this handles
#         begin/while/until when used at the end of a line
#         in Ruby/Python.
#
#         In AppleScript, this handles tokens that are treated as
#         braces only if they are at the beginning of a line.
#     @var lbraceprecursorre
#         In AppleScript, this handles "then" after an "if"
#         on the same line or "to" after a "tell" on the
#         same line.
#     @var classisbrace
#         Set to 1 if a class declaration is treated as an
#         open brace.  (This is <b>not</b> used for ObjC clases;
#         they are special.)
#     @var functionisbrace
#         Set to 1 if a function declaration is treated as an
#         open brace.
#  */
sub isLeftBrace
{
	my $self = shift;
	my $part = shift;
	my $lang = shift;
	my $parseTokensRef = shift;
	my $case_sensitive = shift;
	my $curBraceCount = shift;

	my $localDebug = 0;

	my %parseTokens = ();

	my $lbrace;
	my $lbracepreventerre;
	my $lbraceunconditionalre;
	my $lbraceconditionalre;
	my $lbraceprecursorre;
	my $classisbrace;
	my $functionisbrace;
	my $lbraceprecursor;

	print STDERR "IN LEFT BRACE CHECK\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);

	# Backwards compatibility hack.
	if (@_) {
		warn("The calling pattern for isLeftBrace has changed.  Please update your code.\n");

		$lbrace = $parseTokensRef;
		$parseTokensRef = undef;
		$lbraceunconditionalre = $case_sensitive;
		$lbraceconditionalre = $curBraceCount;
		$classisbrace = shift;
		$classisbrace = shift;
		$case_sensitive = shift;
		$curBraceCount = shift;
		$lbraceprecursor = "";
		$lbraceprecursorre = "";
		$lbracepreventerre = "";
	} else {
		# New-style calling: use the value as a reference.
		%parseTokens = %{$parseTokensRef};

		$lbrace = $parseTokens{lbrace};
		$lbraceunconditionalre = $parseTokens{lbraceunconditionalre};
		$lbraceconditionalre = $parseTokens{lbraceconditionalre};
		$lbracepreventerre = $parseTokens{lbracepreventerre};
		$lbraceprecursorre = $parseTokens{lbraceprecursorre};
		$classisbrace = $parseTokens{classisbrace};
		$functionisbrace = $parseTokens{functionisbrace};
		$lbraceprecursor = $parseTokens{lbraceprecursor};
	}

	# print STDERR "\$self: $self \$part: $part \$lbrace: $lbrace \$lbraceunconditionalre: $lbraceunconditionalre \$lbraceconditionalre: $lbraceconditionalre \$classisbrace: $classisbrace \$functionisbrace: $functionisbrace \$case_sensitive: $case_sensitive\n";

	if ($lang eq "perl" && $self->{inTemplate}) { return 0; }

	if ($lang ne "applescript") {
		if ($classisbrace && (($curBraceCount - $self->{initbsCount}) > 1)) {
			print STDERR "CBC: $curBraceCount INIT: ".$self->{initbsCount}."\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
			return 0;
		}
	}

	if (casecmp($part, $lbrace, $case_sensitive)) {
		print STDERR "BARE LBRACE\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
		if ($self->{pendingBracedParameters}) { return 0; }
		return 1;
	}

	print STDERR "IN LEFT BRACE CHECK 2\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);

	print STDERR "INRBR: ".$self->{inrbraceargument}."\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);

	if ($lbraceunconditionalre && ($part =~ /$lbraceunconditionalre/)) {
		print STDERR "UNCONDITIONALRE MATCH\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
		return 1;
	}

	if ($lbracepreventerre && ($part =~ /$lbracepreventerre/)) {
		print STDERR "ASINELSE -> 1\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
		$self->{ASINELSE} = 1;
	} elsif ($self->{ASINELSE} && $part =~ /\w/) {
		print STDERR "ASINELSE -> 0\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
		$self->{ASINELSE} = 0;
		if ($part eq "if") {
			print STDERR "IGNORING IF\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
			return 0;
		}
	}

	if ($lang eq "applescript" && !($self->{inString} || $self->{inComment} || $self->{inInlineComment} || $self->{inLabel} || $self->{inrbraceargument})) {
		print STDERR "ASPART: \"$part\" PC: ".$self->{ASLBRACEPRECURSOR}." PCTAG: ".$self->{ASLBRACEPRECURSORTAG}."\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);

		# After an if/then or a tell/to, if we see a non-space, non-comment token,
		# then it is a simple-style "if" or "tell" statement.  Clear the precursor data
		# so that a subsequent call to {@link clearLeftBracePrecursor} will return
		# an empty string.
		if (($self->{ASLBRACEPRECURSORTAG}) && $part =~ /\S/) {
			print STDERR "Cleared ASLBRACEPRECURSOR (simple statement)\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
			$self->{ASLBRACEPRECURSOR} = "";
			$self->{ASLBRACEPRECURSORTAG} = "";
		}

		# If we see the "if" or "tell" token, store it away, but be prepared to reverse
		# that decision later, if it's right after a newline and turns into a conditional
		# regex match.
		my $oldprecursor = $self->{ASLBRACEPRECURSOR};
		if ($lbraceprecursor && $part =~ /$lbraceprecursor/) {
			$self->{ASLBRACEPRECURSOR} = $part;
			print STDERR "Set ASLBRACEPRECURSOR to \"$part\"\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
		}

		# If we see the "then" or "to" token, store it away.
		if ($lbraceprecursorre && $part =~ /$lbraceprecursorre/) {
			print STDERR "AS conditional lbrace: \"$part\"\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
			if ($part eq "then" && $self->{ASLBRACEPRECURSOR} eq "if") {
				print STDERR "IF THEN\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
				$self->{ASLBRACEPRECURSORTAG} = $part;
			}
			if ($part eq "to" && $self->{ASLBRACEPRECURSOR} eq "tell") {
				print STDERR "TELL TO\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
				$self->{ASLBRACEPRECURSORTAG} = $part;
			}
			print STDERR "Nope.\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
			return 0;
		} elsif ($self->{afterNL} && $lbraceconditionalre && $part =~ /$lbraceconditionalre/) {
			print STDERR "CONDITIONALRE MATCH\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
			$self->{ASLBRACEPRECURSOR} = $oldprecursor;
			return 1;
		}
	} elsif ($lang eq "applescript" && ($self->{inString} || $self->{inComment} || $self->{inInlineComment} || $self->{inLabel} || $self->{inrbraceargument})) {
		print STDERR "RETURNING 0 BECAUSE IN RBRACE ARGUMENT (".$self->{inrbraceargument}.")\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
		return 0;
	} else {
		if ($lbraceconditionalre && (!$self->{followingrubyrbrace}) && ($part =~ /$lbraceconditionalre/)) { return 1; }
	}

	if (!$self->{newlineIsSemi}) {
		if ($classisbrace && $self->{sodclass} eq "class" && ($self->{inRubyClass} != 2) && $part =~ /[\n\r]/) {
			print STDERR "Class is a brace.  Returning 1 at newline.\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
			return 1;
		}
		if ($functionisbrace && $self->{pushedfuncbrace} == 1 && $part =~ /[\n\r]/) {
			print STDERR "Function is a brace.  Returning 1 at newline.\n" if ($localDebug || $HeaderDoc::AppleScriptDebug);
			return 1;
		}
	}

	return 0;
}

# /*!
#     @abstract
#         Returns whether or not this token should be
#         treated as a right brace.
#     @param self
#         This object.
#     @param part
#         The token to check.
#     @param lang
#         The programming language.
#     @param parseTokensRef
#         A parse token hash obtained from a call to {@link parseTokens}.
#     @param case_sensitive
#         Set to 1 for most languages.  Set to 0 if the
#         language uses case-insensitive token matching
#         (e.g. Pascal).
#     @var rbrace
#         The primary left brace character.
#     @var rbraceconditionalre
#         In AppleScript, this handles "end".
#  */
sub isRightBrace
{
    my $self = shift;

    my $part = shift;
    my $lang = shift;
    my $parseTokensRef = shift;
    my $case_sensitive = shift;

    my %parseTokens = %{$parseTokensRef};

    my $localDebug = 0;

    if ($lang eq "applescript") {
	print STDERR "Checking token \"$part\" for rbrace\n" if ($HeaderDoc::AppleScriptDebug || $localDebug);

	print STDERR "afterNL: ".$self->{afterNL}."\n" if ($HeaderDoc::AppleScriptDebug || $localDebug);

	my $rbraceconditionalre = $parseTokens{rbraceconditionalre};
	if ($self->{afterNL} && $rbraceconditionalre && $part =~ /$rbraceconditionalre/) {
		print STDERR "Yes.\n" if ($HeaderDoc::AppleScriptDebug || $localDebug);
		return 1;
	} else {
		print STDERR "No.\n" if ($HeaderDoc::AppleScriptDebug || $localDebug);
		return 0;
	}
    }
    print STDERR "Checking token \"$part\" for non-AppleScript rbrace\n" if ($HeaderDoc::AppleScriptDebug || $localDebug);

    my $retval = casecmp($part, $parseTokens{rbrace}, $case_sensitive);

    print STDERR ($retval ? "Yes\n" : "No\n") if ($HeaderDoc::AppleScriptDebug || $localDebug);

    return $retval;
}

# /*!
#     @abstract Returns whether an AppleScript on/to should be treated as a handler or just a normal token.
#  */
sub appleScriptFunctionLegalHere
{
    my $self = shift;
    my $braceStackRef = shift;

    my @braceStack = @{$braceStackRef};

    # It's only a handler if it is the first on a line.
    if (!$self->{afterNL}) { return 0; }

    # It isn't legal inside other stuff, e.g. a try block.
    if (scalar(@braceStack)-$self->{initbsCount}) { return 0; }

    return 1;
}

# /*!
#     @abstract
#         Pushes a token onto the brace stack.
#     @param self
#         This object.
#     @param token
#         The token to push.
#     @discussion
#         This is currently only used for the Python
#         parser.  Eventually, the main parser should
#         be modified to share this stack instead of
#         using a local variable.
#  */
sub pushBrace
{
	my $self = shift;
	my $token = shift;

	# print STDERR "PUSHBRACE\n";

	push(@{$self->{braceStack}}, $token);
	$self->{autoContinue}++;
}

# /*!
#     @abstract
#         Looks at the top token on the brace stack.
#     @param self
#         This object.
#     @discussion
#         This is currently only used for the Python
#         parser.  Eventually, the main parser should
#         be modified to share this stack instead of
#         using a local variable.
#  */
sub peekBrace
{
	my $self = shift;
	my $temp = $self->popBrace();

	$self->pushBrace($temp);
	return $temp;
}

# /*!
#     @abstract
#         Looks at the top token on the brace stack and
#         returns the closing token that would match it.
#     @param self
#         This object.
#     @discussion
#         This is currently only used for the Python
#         parser.  Eventually, the main parser should
#         be modified to share this stack instead of
#         using a local variable.
#  */
sub braceCount
{
	my $self = shift;
	return scalar(@{$self->{braceStack}});
}

# /*!
#     @abstract
#         Returns whether the current line is a Python continuation line.
#     @discussion
#         In Python, if you are inside a string, a multiline string,
#         a parenthesized expression, an array, etc., subsequent lines
#         are treated as part of the current line implicitly.  Those
#         subsequent lines are called continuation lines.
#
#         A continuation line also occurs explicitly when the previous
#         line ends with a backslash.
#  */
sub isContinuationLine
{
	my $self = shift;
	my $localDebug = 0;

	if ($self->braceCount()) {
		print STDERR "In isContinuationLine: brace count is ".$self->braceCount()."\n" if ($localDebug);
		if ($localDebug > 1) {
			print STDERR "begin stack dump\n";
			foreach  my $item (@{$self->{braceStack}}) {
				print STDERR "ITEM: $item\n";
			}
			print STDERR "end stack dump\n";
		}

		return 1;
	}
	if ($self->{lastNLWasQuoted}) {
		print STDERR "In isContinuationLine: lastNLWasQuoted.\n" if ($localDebug);
		return 1;
	}

	print STDERR "In isContinuationLine: returning 0.\n" if ($localDebug);

	return 0;
}

# /*!
#     @abstract
#         Looks at the top token on the brace stack and
#         returns the closing token that would match it.
#     @param self
#         This object.
#     @discussion
#         This is currently only used for the Python
#         parser.  Eventually, the main parser should
#         be modified to share this stack instead of
#         using a local variable.
#  */
sub peekBraceMatch
{
	my $self = shift;
	my $temp = $self->popBrace();

	$self->pushBrace($temp);
	return bracematching($temp, $self->{lang});
}

# /*!
#     @abstract
#         Pops a token off of the brace stack and returns it.
#     @param self
#         This object.
#     @discussion
#         This is currently only used for the Python
#         parser.  Eventually, the main parser should
#         be modified to share this stack instead of
#         using a local variable.
#  */
sub popBrace
{
	my $self = shift;

	# print STDERR "POPBRACE\n";
	$self->{autoContinue}--;
	return pop(@{$self->{braceStack}});
}

# /*!
#     @abstract
#         Pushes a tree onto the tree stack.
#     @param self
#         This object.
#     @param tree
#         The token to push.
#     @discussion
#         This is currently only used for the Python
#         parser.  Eventually, the main parser should
#         be modified to share this stack instead of
#         using a local variable.
#  */
sub treePush
{
	my $self = shift;
	my $token = shift;

	# print STDERR "PUSHTREE\n";

	push(@{$self->{treeStack}}, $token);
}

# /*!
#     @abstract
#         Pops a tree from the tree stack.
#     @param self
#         This object.
#     @discussion
#         This is currently only used for the Python
#         parser.  Eventually, the main parser should
#         be modified to share this stack instead of
#         using a local variable.
#  */
sub treePop
{
	my $self = shift;

	# print STDERR "POPTREE\n";

	my $tree = pop(@{$self->{treeStack}});
	while (($tree) && ($tree->next())) {
		# print STDERR "TREE: $tree NEXT: ".$tree->next()."\n";
		$tree = $tree->next();
	}
	return $tree
}

# /*!
#     @abstract
#         Sets the {@link hollow} field in this object,
#         and sets the input counter and block offset values
#         for the tree node.
#     @param self
#         This object.
#     @param treeCur
#         The tree node to modify, and also the tree node
#         that the {@link hollow} field should reference.
#     @param blockOffset
#         The block offset value to set in the tree node.
#     @param inputCounter
#         The input counter value to set in the tree node.
#  */
sub setHollowWithLineNumbers
{
	my $self = shift;
	my $treeCur = shift;
	my $blockOffset = shift;
	my $inputCounter = shift;

	$treeCur->{BLOCKOFFSET} = $blockOffset;
	$treeCur->{INPUTCOUNTER} = $inputCounter;

	$self->{hollow} = $treeCur;
}

# /*!
#     @abstract
#         Releases resources associated with a parsers state object.
#     @param self
#         The <code>ParserState</code> object.
# */
sub free
{
	my $self = shift;

	$self->{hollow} = undef;
	$self->{parsedParamList} = undef;
	$self->{pplStack} = undef;
	$self->{freezeStack} = undef;
	$self->{treeStack} = undef;
	$self->{lastTreeNode} = undef;

	$self = ();
}

1;
