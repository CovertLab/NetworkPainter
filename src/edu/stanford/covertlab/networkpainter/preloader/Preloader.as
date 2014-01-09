package edu.stanford.covertlab.networkpainter.preloader
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import mx.events.FlexEvent;
	import mx.preloaders.DownloadProgressBar;

	/**
	 * Application preloader. Displays from top to bottom:
	 * <ol>
	 * <li>Application name</li>
	 * <li>Progress bar</li>
	 * <li>Status -- "Application Downloading ..." or "Application Initializing..."</li>
	 * </ol>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */ 
    public class Preloader extends DownloadProgressBar
    {

		private var startTime:int;
		private var banner:TextField=new TextField();
        private var features:TextField = new TextField();
		private var status:Sprite = new Sprite();
		
		public function Preloader()
        {   
			super();
        }
		
		override public function initialize():void {
			// banner
			banner.text = 'NetworkPainter';
			banner.setTextFormat(new TextFormat('Arial', 30,0x666666,true,true));
			banner.autoSize = TextFieldAutoSize.CENTER;
            addChild(banner);
			
			//status			
			fillStatus(0);
			status.width = width;
			status.height = 12;
			addChild(status);
        
            // features
            features = new TextField();
			features.setTextFormat(new TextFormat('Arial', 24,0x666666,false,false));
			features.autoSize = TextFieldAutoSize.CENTER;
            addChild(features);
			
			//center
			center(stageWidth, stageHeight);
			
			//minimum preloader display time
			MINIMUM_DISPLAY_TIME = 2000;
			startTime = getTimer();
		}
		
		private function fillStatus(value:Number):void {
			var fill:Number = 0x009DFF;
			var stroke:Number = 0x666666;
			var alpha:Number = 0.6;
			
			status.graphics.clear();
			
			if (value < 1) {
				//outline
				status.graphics.lineStyle(1, stroke);
				status.graphics.drawRoundRect(0, 0, width, 12, 3, 3);
				status.graphics.lineStyle(0);
				
				//fill
				status.graphics.beginFill(fill, alpha);
				status.graphics.drawRoundRect(0, 0, width * value, 12, 4, 4);			
				status.graphics.endFill();
			}else {
				//fill and outline
				status.graphics.lineStyle(1, stroke);
				status.graphics.beginFill(fill, alpha);
				status.graphics.drawRoundRect(0, 0, width * value, 12, 4, 4);			
				status.graphics.endFill();
			}
		}
		
		override protected function center(width:Number, height:Number):void {			
			//horizontal alignment
			banner.x = (width - banner.textWidth) / 2;
			status.x = (width - status.width) / 2;
			features.x = (width - features.textWidth) / 2;			
			
			//vertical alignment
			banner.y = (height - this.height) / 2;						
			status.y = banner.y + banner.textHeight + 5;
			features.y = status.y + status.height + 5;
		}
    
        // Define the event listeners for the preloader events.
        override public function set preloader(preloader:Sprite):void {
            preloader.addEventListener(ProgressEvent.PROGRESS, downloadProgressHandler);
            preloader.addEventListener(Event.COMPLETE, downloadCompleteHandler);
            preloader.addEventListener(FlexEvent.INIT_PROGRESS, applicationInitializeProgressHandler);
            preloader.addEventListener(FlexEvent.INIT_COMPLETE, applicationInitializeCompleteHandler);
        }
    
        private function downloadProgressHandler(event:ProgressEvent):void {            
			fillStatus(event.bytesLoaded / event.bytesTotal);
			features.text = "Application Downloading...";
        }
    
        private function downloadCompleteHandler(event:Event):void {
			fillStatus(1);
            features.text = "Application Downloading...done";
        }
           
        private function applicationInitializeProgressHandler(event:FlexEvent):void {
            features.text = "Application Initializing...";
        }
    
        private function applicationInitializeCompleteHandler(event:FlexEvent):void {
            features.text = "Application Initializing...done";
			
			//make sure preloader displayed for minimum time
			if(getTimer()-startTime< MINIMUM_DISPLAY_TIME){
				var timer:Timer = new Timer(MINIMUM_DISPLAY_TIME-(getTimer()-startTime),1);
				timer.addEventListener(TimerEvent.TIMER, dispatchComplete);
				timer.start();
			}else {
				dispatchEvent(new Event(Event.COMPLETE));
			}
        }
	        
        private function dispatchComplete(event:TimerEvent):void {
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
}