{

  /* Help taken from javascript.pegjs sample from peg.js distribution 
  *  
  *  @Author: KSA7
  *  
  *  Version 1.0
  *  Created : 12 June 2019
  *
  *  History
  *  12 June 2019   First version commited
  *  14 June 2019   Added Support for $ variable syntax
  */

 function filledArray(count, value) {
    var result = new Array(count), i;

    for (i = 0; i < count; i++) {
      result[i] = value;
    }

    return result;
  }

  function extractList(list, index) {
    var result = new Array(list.length), i;

    for (i = 0; i < list.length; i++) {
      result[i] = list[i][index];
    }

    return result;
  }

  function buildList(head, tail, index) {
    return [head].concat(extractList(tail, index));
  }


  function extractOptional(optional, index) {
    return optional ? optional[index] : null;
  }

  function optionalList(value) {
    return value !== null ? value : [];
  }

}


Start 
  = __ program: Program __ {return program;}


NewLine
 = "\n"
  / "\r\n"
  / "\r"

LineTerminator
  = "\n"
  / "\r\n"
  / "\r"
  / ";"


WhiteSpace
  = "\t"
  / " "

_
 = WhiteSpace*

__
  = (WhiteSpace / LineTerminator)*

DecimalDigit
  = [0-9]

NonZeroDigit
  = [1-9]

ExponentIndicator
  = "e"i

SignedInteger
  = [+-]? DecimalDigit+

ExponentPart
  = ExponentIndicator SignedInteger


DecimalIntegerLiteral
  = "0"
  / NonZeroDigit DecimalDigit*


Number
  = DecimalIntegerLiteral "." DecimalDigit* ExponentPart? {
      return { type: "real", value: parseFloat(text()) };
    }
  / "." DecimalDigit+ ExponentPart? {
      return { type: "real", value: parseFloat(text()) };
    }
  / DecimalIntegerLiteral exp: ExponentPart? {
      if(exp){
        return { type: "real", value: parseFloat(text()) };
      }
      return { type: "int", value: parseInt(text()) };
    }


QuoteCharacter = !("'" / LineTerminator ) . { return text();}

QuotedString = QuoteCharacter+ { return text()}

Name
 = head:[a-zA-Z] tail:[a-zA-Z_0-9]* { 
      return head + tail.join("")
    }

PseudoIdentifier
  = id:Name 
  / "'" head:QuotedString tail:("." QuotedString)*  "'"{
    return buildList(head, tail, 1).join(".");
  }

Identifier
  = head: PseudoIdentifier tail: ("." PseudoIdentifier)* {
    var val = buildList(head, tail, 1).join(".");
    return {
      type: 'variable',
      value: val
    }
  }

Variable
  = Array 
  / Identifier


String = '"' chars:DoubleStringCharacter* '"'{
	return { type: "string", value: chars.join("") };
}
 

DoubleStringCharacter
	= !('"' / "\\") . { return text() }
    / "\\" seq: EscapeSequence { return seq;}
    

EscapeSequence
	= '"' 
    / !('"') . { return text();}

Array
  = id: Identifier _ "[" _ indices:ArrayIndex  _ "]" {
    return {
      type: 'array',
      name: id.value,
      indices: indices
    }
  }
 
ArrayIndex
  = head: Expression _  tail: ArrayTail {
    return [head].concat(tail || []);
  }

ArrayTail
  = &"]" list:("]" _ "[" _ Expression _)* {
    return extractList(list, 4);
  }
  /
  &"," list:("," _ Expression _)* {
    return extractList(list, 2);
  }

VariableAddr
  = symbol: Variable {
    return {
      type: 'symbol',
      value: symbol
    }
  }


Program
  = __ head:Statement _ tail:(LineTerminator __ Statement _)*  __ {
      return {
        type: 'program',
        statements: buildList(head, tail, 2)
      }
  }

Statement
  = assign: Assignment {
    assign.source = text();
    return assign;
  }
  / expr: LogicalExpression {
    expr.source = text();
    return expr;
  }
  / Comment


Comment
  = "//" (!NewLine .)* {
    return {
      type: 'comment',
      source : text().substring(2)
    }
  }
  / "#" (!NewLine .)* {
    return {
      type: 'comment',
      source : text().substring(1)
    }
  }



Assignment
  = _ left: VariableAddr _ "=" __ tail: (VariableAddr _ $("=" !"=") __)* right: LogicalExpression {
    var list  = buildList(left, tail, 0).concat(right);
    return list.reduceRight(function(result, exp){
      return {
        type: 'assignment',
        operator: '=',
        left: exp,
        right: result
      }
    })
  }

LogicalExpression
  = _ head: EqualityExpression tail: ( _ LogicalOperators __ LogicalExpression)* {
    return tail.reduce(function(result, element) {
        return {
          type: "logical",
          operator: element[1],
          left: result,
          right: element[3]
        }
      }, head);
  }


LogicalOperators
  = "&&"
  / "||"


EqualityExpression
  = head: Expression tail:(_  EqualityOperators __ Expression)? {
     var right = extractOptional(tail, 3);
     var operator = extractOptional(tail, 1);
     if(!operator) {
       return head;
     }
     else {
       return {
         type: "equality",
         operator: operator,
         left: head,
         right: right
       }
     }
  }

EqualityOperators
  = "<="
   / ">="
   / "<"
   / ">"
   / "!="
   / "=="


Expression
  = head:Term tail:(_ ("+" / "-") __ Term)* {
      return tail.reduce(function(result, element) {
        return {
          type: "expression",
          operator: element[1],
          left: result,
          right: element[3]
        }
      }, head);
    }

Term
  = head:PowerTerm tail:(_ ($("*" !"*") / "/" / "%" ) __ PowerTerm)* {
      return tail.reduce(function(result, element) {
       return {
          type: "term",
          operator: element[1],
          left: result,
          right: element[3]
        }
      }, head);
    }

PowerTerm
  = prefix: ("+" / "-" / "!")? _ left:PostExpression _ op:("^"/"**") __ right:PowerTerm {
    var result = {
    	type: 'exponent',
      operator: op,
      left: left,
      right: right
    };

    if(prefix){
      result = {
        type: 'unary',
        operator: prefix,
        value: result
      }
    }
    return result;
  } 
  /
  prefix: ("+" / "-" / "!")? _ head:PostExpression {
    if(prefix){
	    return{
         type : 'unary',
         operator: prefix,
         value: head
      }
    }
    else return head;
  }

FunctionCall
  = head:Variable _ "(" __ args:(ArgList)? __ ")" {
    return {
      type: 'function',
      name: head.value,
      args: optionalList(args)
    }
  }

ArgList
   = head:LogicalExpression tail:(_ "," __ LogicalExpression)* {
     var args = buildList(head, tail, 3);
     return args;
   }

PostExpression
  =  "(" __ expr:LogicalExpression __ ")" _ "[" _ indices:ArrayIndex  _ "]" {
    return {
      type: 'arrayExp',
      expression: expr,
      indices: indices
    }
  }
  / "(" __ expr:LogicalExpression __ ")" { return expr; }
  / String
  / Number
  / FunctionCall
  / Variable
  / ExtVar



/**
Author: KSA7

This handles external variables that will be substituted at runtime.

We don't even try to evaluate a program that contains these kind of variables, since they
are not known till execution time.

Only the synatx is checked.

Example expressions:

${ATTRIBUTE[name]} , ${ATTRIBUTE[1-dim-param[1]]} , ${ATTRIBUTE[3-dim-param[1,2,3]]} etc

${Parameter[name]} , ${Parameter[name[1]]} , ${Parameter[name[1,2,3]]} etc

${ENV[name]} etc

${name} , ${name[1,2]} etc

${../OBJECT[title]/name} , ${../OBJECT[title, name, revision]/TITLE} , ${../OBJECT[activity]/ATTRIBUTE[name]}, ${../OBJECT[activity]/OBJECT[context]/OBJECT[doc]/TITLE} etc

${../TITLE}, ${../PARAMETER[name]} etc

*/
ExtVar = '${' _ $('Attribute['i) ExtParameter  _ ']}' { return {type: '$var', pattern: text()};}
  / '${' _ $('Parameter['i) ExtParameter _ ']}' { return {type: '$var', pattern: text()};}
  / '${' _ $('ENV['i) ExtName _ ']}' { return {type: '$var', pattern: text()};}
  / '${' _ ExtParameter _ '}' { return {type: '$var', pattern: text()};}
  / '${' _ '\.\.' _ '/' _ head: OBJECT _ tail: ( '/' _ OBJECT _)* _ '/' _ ( 'PARAMETER['i _ ExtParameter _ ']' / 'ATTRIBUTE['i _ ExtParameter _ ']' / ExtParameter) '}'  {   
      return {type: '$var', pattern: text()};
  }
  / '${' _ '\.\.' _ '/' ( 'PARAMETER['i _ ExtParameter _ ']' / 'ATTRIBUTE['i _ ExtParameter _ ']' / ExtParameter ) '}'  {   
      return {type: '$var', pattern: text()};
  }

ExtName = [a-zA-Z0-9_\-\.]+

OBJECT = $('OBJECT['i) _ OBJECT_ARGS _ ']' 

ExtParameter = ExtName ('[' _ DIGIT_ARGS _']')?

OBJECT_ARGS = ExtName _ ( ',' _ ExtName)* 

DIGIT_ARGS = [0-9]+ _ (',' [0-9]+)*

