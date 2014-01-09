package edu.stanford.covertlab.util 
{	
	/**
	 * Contains functions for (very limited) conversion between actionscript infix mathematical 
	 * formulae and MathML. An intermediate representation  (actionscript object representation 
	 * of prefix notation) is used in the conversion.
	 * 
	 * <p>Supports the following variable and numeric types:
	 * <table>
	 *   <tr><td>variable</td><td>&lt;ci&gt;</td></tr>
	 *   <tr><td>float</td><td>&lt;cn&gt;</td></tr>
	 *   <tr><td>integer</td><td>&lt;cn&gt;</td></tr>
	 *   <tr><td>boolean</td><td>&lt;cn&gt;</td></tr>
	 * </table></p>
	 * 
	 * <p>Supports the following operators:
	 * <table>
	 * 	 <tr><td>+</td><td>&lt;plus&gt;</td></tr>
	 * 	 <tr><td>-</td><td>&lt;minus&gt;</td></tr>
	 * 	 <tr><td>*</td><td>&lt;times&gt;</td></tr>
	 * 	 <tr><td>/</td><td>&lt;divide&gt;</td></tr>
	 * 	 <tr><td>^</td><td>&lt;power&gt;</td></tr>
	 *	 <tr><td>%</td><td>&lt;quotient&gt;</td></tr>
	 * 	 <tr><td>!</td><td>&lt;not&gt;</td></tr>
	 * 	 <tr><td>||</td><td>&lt;or&gt;</td></tr>
	 * 	 <tr><td>&amp;&amp;</td><td>&lt;and&gt;</td></tr>
	 * </table></p>
	 * 
	 * <p>Supports the following relations
	 * <table>
	 * 	 <tr><td>==</td><td>&lt;eq&gt;	(overloaded with assignment operator)</td></tr>
	 *   <tr><td>!=</td><td>&lt;neq&gt;</td></tr>
	 * 	 <tr><td>&gt;</td><td>&lt;gt&gt;</td></tr>
	 * 	 <tr><td>&lt;</td><td>&lt;lt&gt;</td></tr>
	 *	 <tr><td>&gt;=</td><td>&lt;geq&gt;</td></tr>
	 * 	 <tr><td>&lt;=</td><td>&lt;leq&gt;</td></tr>
	 * </table></p>
	 * 
	 * <p>Supports assignment
	 * <table>
	 *	 <tr><td>=</td><td>&lt;eq&gt;	(overloaded with equality relation)</td></tr>
	 * </table></p>
	 * 
	 * <p>See <a href="http://www.w3.org/TR/MathML2/">http://www.w3.org/TR/MathML2/</a> for complete definition of MathML specification.</p>
	 * 
	 * <p>Used by the CellML and SBML export methods of the network manager class.</p>
	 * 
	 * @see edu.stanford.covertlab.networkpainter.manager.NetworkManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/19/2009
	 */
	public class MathML 
	{
		
		public static function infix2MathML(infix:String, numberProperties:String = ''):String {						
			//convert infix notation to prefix
			var prefix:Object = infix2Prefix(infix);
			
			//convert prefix to MathML
			return prefix2MathML(prefix, numberProperties);
		}
		
		public static function mathML2infix(mathML:String):String {
			//convert MathML to prefix
			var prefix:Object = mathML2Prefix(new XML(mathML));
			
			//convert prefix to infix
			var infix:String = prefix2Infix(prefix);
			if (infix.charAt(0) == '(' && infix.charAt(infix.length - 1) == ')') return infix.substr(1, infix.length - 2);
			return infix;
		}
		
		protected static function infix2Prefix(infix:String):Object {
			if (infix == '') return null;
			
			infix = infix.replace('+-', '-').replace('--', '+');
			//trace(infix);
			
			var prefix:Object = { operation:'', children:[] };		
			
			var variablePattern:RegExp =/(-*!*([\w\.]+|\(.*?\)))/g;
			var variableResult:Object = variablePattern.exec(infix);
			
			var i:uint;
			var depth:uint;
			if (variableResult && variableResult[1].indexOf('(') > -1) {
				depth = 1;
				for (i = variablePattern.lastIndex; i < infix.length; i++) {
					if (infix.charAt(i) == '(') depth++;
					if (infix.charAt(i) == ')') depth--;
					if (depth == 0) {
						variablePattern.lastIndex = i + 1;
						variableResult[1] = infix.substr(variableResult.index, i - variableResult.index + 1);
						break;
					}					
				}
			}
			
			var operationPattern:RegExp =/(\|\||&&|\^|\+|-|\*|%|==|!=|>|<|>=|<=|=)/g;
			operationPattern.lastIndex = (variableResult ? variablePattern.lastIndex : infix.length);
			var operationResult:Object = operationPattern.exec(infix);
			variablePattern.lastIndex = (operationResult ? operationPattern.lastIndex : infix.length);
			var child:Object;
			var string:String;
			var number:Number;
			var boolean:Boolean;
			
			if (variableResult) {
				if (variableResult[1].charAt(0) == '!') {
					if (variableResult[1].charAt(1) == '(') {
						child = infix2Prefix(variableResult[1].substr(2, variableResult[1].length - 3));
						if (child.operation == '') {
							prefix.children = prefix.children.concat(child.children);
						}else{
							prefix.children.push( { operation:'!', children:[child] } );
						}
					}else {
						string = variableResult[1].substr(1, variableResult[1].length - 1);
						number = parseFloat(string);
						if (string == 'true') prefix.children.push( { operation:'!', children:[true] } );
						else if (string == 'false') prefix.children.push( { operation:'!', children:[false] } );
						else if (!isNaN(number)) prefix.children.push( { operation:'!', children:[number] } );
						else prefix.children.push( { operation:'!', children:[string] } );
					}
				}else {
					if (variableResult[1].charAt(0) == '(') {
						child = infix2Prefix(variableResult[1].substr(1, variableResult[1].length - 2));
						if (child.operation == '') {
							prefix.children = prefix.children.concat(child.children);
						}else {
							prefix.children.push(child);
						}
					}else {
						string = variableResult[1];
						number = parseFloat(string);						
						if (string == 'true') prefix.children.push(true);
						else if (string == 'false') prefix.children.push(false);
						else if (!isNaN(number)) prefix.children.push(number);
						else prefix.children.push(string);
					}					
				}
			}
			
			if (operationResult) {
				prefix.operation = operationResult[1];
			}
			
			if (prefix.operation == '=') {
				child = infix2Prefix(infix.substr(operationPattern.lastIndex, infix.length - operationPattern.lastIndex));
				if (child) prefix.children.push(child);
				return prefix;
			}
			
			variableResult = variablePattern.exec(infix);
			operationPattern.lastIndex = (variableResult ? variablePattern.lastIndex : infix.length);
			operationResult = operationPattern.exec(infix);
			variablePattern.lastIndex = (operationResult ? operationPattern.lastIndex : infix.length);
			
			while (variableResult) {
				if (variableResult[1].charAt(0) == '!') {
					if (variableResult[1].charAt(1) == '(') {
						child = infix2Prefix(variableResult[1].substr(2, variableResult[1].length - 3));
						if (child.operation == '') {
							prefix.children = prefix.children.concat(child.children);							
						}else{
							prefix.children.push( { operation:'!', children:[child] } );							
						}
					}else {
						string = variableResult[1].substr(1, variableResult[1].length - 1);
						number = parseFloat(string);						
						if (string == 'true') prefix.children.push( { operation:'!', children:[true] } );
						else if (string == 'false') prefix.children.push( { operation:'!', children:[false] } );
						else if (!isNaN(number)) prefix.children.push( { operation:'!', children:[number] } );
						else prefix.children.push( { operation:'!', children:[string] } );
					}
				}else {
					if (variableResult[1].charAt(0) == '(') {
						child = infix2Prefix(variableResult[1].substr(1, variableResult[1].length - 2));
						if (child.operation == '') {
							prefix.children = prefix.children.concat(child.children);
						}else {
							prefix.children.push(child);
						}
					}else {
						string = variableResult[1];
						number = parseFloat(string);
						if (string == 'true') prefix.children.push(true);
						else if (string == 'false') prefix.children.push(false);
						else if (!isNaN(number)) prefix.children.push(number);
						else prefix.children.push(string);
					}					
				}
				
				if (operationResult && operationResult[1] != prefix.operation) {
					prefix = { operation:operationResult[1], children:[prefix] };
				}
				
				variableResult = variablePattern.exec(infix);
				
				if (variableResult && variableResult[1].indexOf('(') > -1) {
					depth = 1;
					for (i = variablePattern.lastIndex; i < infix.length; i++) {
						if (infix.charAt(i) == '(') depth++;
						if (infix.charAt(i) == ')') depth--;
						if (depth == 0) {
							variablePattern.lastIndex = i + 1;
							variableResult[1] = infix.substr(variableResult.index, i - variableResult.index + 1);
							break;
						}					
					}
				}
				
				operationPattern.lastIndex = (variableResult ? variablePattern.lastIndex : infix.length);
				operationResult = operationPattern.exec(infix);
				variablePattern.lastIndex = (operationResult ? operationPattern.lastIndex : infix.length);
				
			}
			
			if (prefix.operation == '' && prefix.children.length == 1 && 
				!(prefix.children[0] is String || prefix.children[0] is Number ||
				prefix.children[0] is uint || prefix.children[0] is int || prefix.children[0] is Boolean)) {
				prefix = prefix.children[0];
			}
			
			return prefix;
		}
		
		protected static function prefix2MathML(prefix:Object, numberProperties:String=''):String {				
			var xml:String = '';
			
			if (!prefix) return xml;
			
			//open operation
			xml += '<apply>';
			
			//operator
			switch(prefix.operation) {
				case '':
					if(prefix.children[0] is String){
						return '<ci>' + prefix.children[0] + '</ci>';
					}else if (prefix.children[0] is Number || prefix.children[0] is uint || prefix.children[0] is int || prefix.children[0] is Boolean) {
						return '<cn' + (numberProperties != '' ? ' ' + numberProperties : '') + '>' + (prefix.children[0] + 0).toString() + '</cn>';
					}
					break;
				case '!': xml += '<not/>'; break;
				case '+': xml += '<plus/>'; break;
				case '-': xml += '<minus/>'; break;
				case '*': xml += '<times/>'; break;
				case '/': xml += '<divide/>'; break;
				case '^': xml += '<power/>'; break;
				case '%': xml += '<quotient/>'; break;
				case '||': xml += '<or/>'; break;
				case '&&': xml += '<and/>'; break;
				case '==': xml += '<eq/>'; break;
				case '!=': xml += '<neq/>'; break;
				case '>': xml += '<gt/>'; break;
				case '<': xml += '<lt/>'; break;
				case '>=': xml += '<geq/>'; break;
				case '<=': xml += '<leq/>'; break;
				case '=': xml += '<eq/>'; break;
			}
			
			//arguments			
			for (var i:uint = 0; i < prefix.children.length; i++) {
				if(prefix.children[i] is String){
					xml += '<ci>' + prefix.children[i] + '</ci>';
				}else if (prefix.children[i] is Number || prefix.children[i] is uint || prefix.children[i] is int || prefix.children[i] is Boolean) {
					xml += '<cn' + (numberProperties != '' ? ' ' + numberProperties : '') + '>' + (prefix.children[i] + 0).toString() + '</cn>';
				}else if (prefix.children[i] is Object) {
					xml += prefix2MathML(prefix.children[i], numberProperties);
				}
			}
			
			//close operation			
			xml += '</apply>';
			
			return xml;
		}
		
		protected static function mathML2Prefix(xml:XML):Object {			
			var prefix:Object = { operation:'', children:[] };
			
			switch (xml.localName()) {				
				case 'ci': prefix.children.push(xml.text()[0].toString()); return prefix;
				case 'cn': prefix.children.push(parseFloat(xml.text()[0].toString())); return prefix;
				case 'apply': break;
				default: return null;
			}
			
			//operator
			switch(xml.children()[0].localName()) {
				case 'not': prefix.operation = '!'; break;
				case 'plus': prefix.operation = '+'; break;
				case 'minus': prefix.operation = '-'; break;
				case 'times': prefix.operation = '*'; break;
				case 'divide': prefix.operation = '/'; break;
				case 'power': prefix.operation = '^'; break;
				case 'quotient': prefix.operation = '%'; break;
				case 'and': prefix.operation = '&&'; break;
				case 'or': prefix.operation = '||'; break;
				//case 'eq': prefix.operation = '=='; break;
				case 'neq': prefix.operation = '!='; break;
				case 'gt': prefix.operation = '>'; break;
				case 'lt': prefix.operation = '<'; break;
				case 'geq': prefix.operation = '>='; break;
				case 'leq': prefix.operation = '<='; break;
				case 'eq': prefix.operation = '='; break;
			}
			
			//operands			
			for (var i:uint = 1; i < xml.children().length(); i++) {								
				switch(xml.children()[i].localName()) {
					case 'apply': 
						var child:Object = mathML2Prefix(xml.children()[i]);
						if (child) prefix.children.push(child);
						break;
					case 'cn': 
						prefix.children.push(parseFloat(xml.children()[i].text()[0])); 
						break;
					case 'ci': 
						prefix.children.push(xml.children()[i].text()[0].toString()); 
						break;
				}
			}
			
			return prefix;
		}
		
		protected static function prefix2Infix(prefix:Object):String {
			var infix:String = '';		
			
			if (!prefix) return infix;
			
			switch(prefix.operation) {
				case '':
					if(prefix.children[0] is String){
						return prefix.children[0];
					}else if (prefix.children[0] is Number || prefix.children[0] is uint || prefix.children[0] is int || prefix.children[0] is Boolean) {
						return prefix.children[0].toString();
					}
					break;
				case '!':
					infix += prefix.operation;
					if(prefix.children[0] is String){
						infix += prefix.children[i];
					}else if (prefix.children[0] is Number || prefix.children[0] is uint || prefix.children[0] is int || prefix.children[0] is Boolean) {
						infix += prefix.children[0].toString();
					}else if (prefix.children[0] is Object) {
						infix += prefix2Infix(prefix.children[i]);
					}
					break;
				case '+':
				case '-':
				case '*':
				case '/':
				case '^':
				case '%':
				case '||':
				case '&&':
				case '==':
				case '!=':
				case '>':
				case '<':
				case '>=':
				case '<=':
				case '=':
					//open operation
					infix += '(';
						
					for (var i:uint = 0; i < prefix.children.length; i++) {
						//arguments
						if(prefix.children[i] is String){
							infix += prefix.children[i];
						}else if (prefix.children[i] is Number || prefix.children[i] is uint || prefix.children[i] is int || prefix.children[i] is Boolean) {
							infix += (prefix.children[i] + 0).toString();
						}else if (prefix.children[i] is Object) {
							infix += prefix2Infix(prefix.children[i]);
						}
						
						//operator
						if (i < prefix.children.length - 1) {
							infix += ' ' + prefix.operation + ' ';
						}
					}
					
					//close operation			
					infix += ')';
					break;
			}

			return infix;
		}
		
	}
	
}