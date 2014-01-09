package edu.stanford.covertlab.util 
{
	import flash.display.Sprite;
	
	/**
	 * Test class for MathML class. Tests conversion from infix notation to MathML,
	 * and from MathML to infix notation.
	 * 
	 * @see MathML
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/19/2009
	 */
	public class MathMLTest extends Sprite
	{
		
		public function MathMLTest() 
		{
			var i:uint;
			var tests:Array = [
				'a',
				'a+-(b+c)-d',
				'a+b--2.1+c',
				'a+b+-2.1+c',
				'a+b+2.1+c',
				'a+b+false+c',
				'a+b+true+c',				
				'a+b+c',
				'a+b-c',
				'a||b||c',
				'a||b&&c',
				'a || b && c',
				'a || !b && c',
				'!a || b',
				'(a || b) && c',
				'a || b && c || d',
				'a || b || c && d',
				'(a || b) || (c || d)',
				'!(a || b || c) && !(d && e)',
				'!a || (b && !c) || d',
				'(a || !(b && c) && !(d || (f || !g)))',
				'(a || !(b && c) && !(d || (f || !g))) || h || i',				
				'h || i || (a || !(b && c) && !(d || (f || !g)))',
				'h || i || (a || !(b && c) && !(d || (f || !g))) || j',
				'h || i || (a || !(b && c) && !(d || (f || !g))) || j || k && (l && !m)',
				'sp2'];
				
			//test infix to prefix to MathML
			for (i = 0; i < tests.length; i++) {
				trace('## Test ' + (i + 1) + ': ' + tests[i]);
				var xml:XML = new XML(MathML.infix2MathML(tests[i]));
				trace(xml.toXMLString() + '\n');
			}
			
			//test infix to prefix to MathML to prefix to infix
			for (i = 0; i < tests.length; i++) {
				trace('## Test ' + (i + 1) + ': ' + tests[i]);
				var infix:String = MathML.mathML2infix(MathML.infix2MathML(tests[i]));
				trace(infix + '\n');
			}
		}
		
	}
	
}