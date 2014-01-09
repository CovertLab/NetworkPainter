package edu.stanford.covertlab.util 
{
	import mx.collections.ArrayCollection;
	
	/**
	 * Utility class for operations on HTML-like text markup. Supports superscript (&lt;sup&gt;), 
	 * subscript (&lt;sub&gt;), and Greek characters (eg &amp;alpha;). Does not support italics,
	 * bold, underline, or any other HTML markup. Also doesn't support decimal or hexadecimal
	 * markup of Greek characters.
	 * 
	 * Contains several functions
	 * <ul>
	 * <li>Validate marked up text (and return error messages)
	 *     used by BiomoleculesPanel and 
	 *     EditBiomoleculeWindow</li>
	 * <li>Substitute greek character entities with decimal notation in marked up text
	 *     used by SupSubRasterText, SupSubDataGridItemRenderer, Biomolecule</li>
	 * <li>Escape marked up text for use in an XML document or MySQL statement
	 *     used by SVGRenderer, NetworkManager</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.graphics.SupSubRasterText
	 * @see edu.stanford.covertlab.controls.SupSubDataGridItemRenderer
	 * @see edu.stanford.covertlab.graphics.renderer.SVGRenderer
	 * @see edu.stanford.covertlab.networkpainter.manager.NetworkManager
	 * @see edu.stanford.covertlab.diagram.core.Biomolecule
	 * @see edu.stanford.covertlab.diagram.panel.BiomoleculesPanel
	 * @see edu.stanford.covertlab.diagram.window.EditBiomoleculeWindow
	 * @see edu.stanford.covertlab.control.GreekKeyboard
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class HTML 
	{
		
		public static const ENTITIES:Array = [
				{entity:'Alpha', decimal:913 },				
				{entity:'Beta', decimal:914 },				
				{entity:'Gamma', decimal:915 },				
				{entity:'Delta', decimal:916 },				
				{entity:'Epsilon', decimal:917},
				{entity:'Zeta', decimal:918 },
				{entity:'Eta', decimal:919 },
				{entity:'Theta', decimal:920 },
				{entity:'Iota', decimal:921 },
				{entity:'Kappa', decimal:922 },
				{entity:'Lambda', decimal:923 },
				{entity:'Mu', decimal:924 },
				{entity:'Nu', decimal:925 },
				{entity:'Xi', decimal:926 },
				{entity:'Omicron', decimal:927 },
				{entity:'Pi', decimal:928 },
				{entity:'Rho', decimal:929 },
				{entity:'Sigma', decimal:931 },
				{entity:'Tau', decimal:932 },
				{entity:'Upsilon', decimal:933 },
				{entity:'Phi', decimal:934 },
				{entity:'Chi', decimal:935 },
				{entity:'Psi', decimal:936 },
				{entity:'Omega', decimal:937 },
				{entity:'alpha', decimal:945 },
				{entity:'beta', decimal:946 },
				{entity:'gamma', decimal:947 },
				{entity:'delta', decimal:948 },
				{entity:'epsilon', decimal:949 },
				{entity:'zeta', decimal:950 },
				{entity:'eta', decimal:951 },
				{entity:'theta', decimal:952 },
				{entity:'iota', decimal:953 },
				{entity:'kappa', decimal:954 },
				{entity:'lambda', decimal:955 },
				{entity:'mu', decimal:956 },
				{entity:'nu', decimal:957 },
				{entity:'xi', decimal:958 },
				{entity:'omicron', decimal:959 },
				{entity:'pi', decimal:960 },
				{entity:'rho', decimal:961 },
				{entity:'sigma', decimal:963 },
				{entity:'tau', decimal:964 },
				{entity:'upsilon', decimal:965 },
				{entity:'phi', decimal:966 },
				{entity:'chi', decimal:967 },
				{entity:'psi', decimal:968 },
				{entity:'omega', decimal:969 } ];
				
		public static const GREEK_CHARACTERS:ArrayCollection = new ArrayCollection([
				{entity:'Alpha', upperCase:913, lowerCase:945 },				
				{entity:'Beta', upperCase:914, lowerCase:946 },				
				{entity:'Gamma', upperCase:915, lowerCase:947 },				
				{entity:'Delta', upperCase:916, lowerCase:948 },				
				{entity:'Epsilon', upperCase:917, lowerCase:949 },
				{entity:'Zeta', upperCase:918, lowerCase:950 },
				{entity:'Eta', upperCase:919, lowerCase:951 },
				{entity:'Theta', upperCase:920, lowerCase:952 },
				{entity:'Iota', upperCase:921, lowerCase:953 },
				{entity:'Kappa', upperCase:922, lowerCase:954 },
				{entity:'Lambda', upperCase:923, lowerCase:955 },
				{entity:'Mu', upperCase:924, lowerCase:956 },
				{entity:'Nu', upperCase:925, lowerCase:957 },
				{entity:'Xi', upperCase:926, lowerCase:958 },
				{entity:'Omicron', upperCase:927, lowerCase:959 },
				{entity:'Pi', upperCase:928, lowerCase:960 },
				{entity:'Rho', upperCase:929, lowerCase:961 },
				{entity:'Sigma', upperCase:931, lowerCase:963 },
				{entity:'Tau', upperCase:932, lowerCase:964 },
				{entity:'Upsilon', upperCase:933, lowerCase:965 },
				{entity:'Phi', upperCase:934, lowerCase:966 },
				{entity:'Chi', upperCase:935, lowerCase:967 },
				{entity:'Psi', upperCase:936, lowerCase:968 },
				{entity:'Omega', upperCase:937, lowerCase:969 } ]);
		
		/**
		 * supports the following
		 * - superscript, subscript
		 * - greek characters 913-937, 945-969 using html entities
		 * 
		 *does not support
		 * - underline, bold, italic
		 */
		public static function validate(text:String):String {
			//allow only valid tags
			var regExp:RegExp = /<\/(.*?)>/ig;
			var result:Object = regExp.exec(text);
			while (result) {
				if (!(result[1] == 'sup' || result[1] == 'sub'))
					return 'Invalid HTML markup tag <'+result[1]+'>. Only <sup>, and <sub> are allowed.';
				result = regExp.exec(text);
			}
			
			//make sure all tags match
			try{
				var xml:XML = new XML('<xml>' + text + '</xml>');
			}catch (error:Error) {
				return error.message.replace(/Error #\d+: /,'');
			}
			
			//make sure decimal, hex entities not being used
			regExp = /&#(x[0-9ABCDEF]{3,3}|\d{1,4});/ig;
			if (regExp.test(text)) return 'Invalid unicode reference. Please use HTML entities.' ;
			
			return null;
		}
		
		public static function entitiesToDecimal(text:String):String {
			for (var i:uint = 0; i < ENTITIES.length; i++)
				text = text.replace(new RegExp ('&' + ENTITIES[i].entity + ';','g'), '&#' + ENTITIES[i].decimal + ';');
			return text;
		}
		
		public static function escapeMySQL(text:String):String {
			return text.replace(/'/g, "\'");
		}
		
		public static function escapeXML(text:String):String {
			return text.replace(/[&<>]/g, function replFN():String {
				switch(arguments[0]) {					
					case '>': return '&gt;';
					case '<': return '&lt;';
					case '&': return '&amp;';
					case '"': return '&quot;';
					default: return arguments[0];
				}
			});
		}
		
		public static function unescapeXML(text:String):String {
			return text.replace(/&(lt|gt|amp|quot);/g, function replFN():String {
				switch(arguments[1]) {					
					case 'lt': return '<';
					case 'gt': return '>';
					case 'amp': return '&';
					case 'quot': return '"';
					default: return arguments[0];					
				}
			});
		}
		
	}
	
}