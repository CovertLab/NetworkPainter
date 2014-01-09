package edu.stanford.covertlab.window 
{
	import mx.collections.ArrayCollection;
	
	/**
	 * Object for an application help or tutorial section. Each section has three properties:
	 * <ul>
	 * <li>label</li>
	 * <li>content</li>
	 * <li>array of subsections, each of type HelpSection</li>
	 * </ul>
	 * 
	 * <p>Provides methods for generating a section heading (for display in the help and tutorial 
	 * windows) which can include a table of contents listing child sections.</p>
	 * 
	 * @see HelpWindow
	 * @see TutorialWindow
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class HelpSection extends Object
	{
		[Bindable] public var label:String = '';
		[Bindable] public var content:String;
		[Bindable] public var children:Array;
		
		public function HelpSection() 
		{
			
		}
		
		public function htmlText(aboutData:Object):String {
			var text:String;
			if (content) text = contents(aboutData);
			else text = tableOfContents();
			return text;
		}

		private function contents(aboutData:Object):String {
			var text:String;
			
			//strip new lines and tabs
			text = content.replace(/[\n\t]/g, ' ').replace(/\s+/g, ' ');
			
			//force double line break after paragraph
			text = text.replace(/<\/p>/g, '</p><br/>');
			
			//convert ul to textformat
			text = text.replace(/<ul>/g, '<textformat blockindent="-18">').replace(/<\/ul><\/p><br\/>/g,'</textformat></p>').replace(/<\/ul>/g, '</textformat>');
			
			//replace contact information
			text = text.replace(/<contact\/>/g, '<a href="mailto:' + aboutData.email +'">' + aboutData.email + '</a>');
			
			//replace application name
			text = text.replace(/<applicationName\/>/g, aboutData.applicationName);
			
			return sectionHeading() + text;
		}
		
		private function tableOfContents(depth:uint=0):String {
			var toc:String = '';

			if (depth == 0) toc += sectionHeading();
			else toc += '<li>'+label+'</li>';
			
			if (children != null) {
				toc += '<textformat blockindent="'+(depth*24-8)+'">';
				for (var i:uint = 0; i < children.length; i++) {
					toc += children[i].tableOfContents(depth+1);
				}
				toc += '</textformat>';
			}
			return toc;
		}
		
		private function sectionHeading():String {
			return '<p align="center"><font size="14"><b><i>' + label + '</i></b></font></p><br/>';
		}

	}
	
}