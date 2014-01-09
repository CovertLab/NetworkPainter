package edu.stanford.covertlab.diagram.toolbar 
{
	import caurina.transitions.Tweener;
	import edu.stanford.covertlab.controls.ToolBarButton;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flexlib.controls.VSlider;
	import mx.binding.utils.BindingUtils;
	import mx.containers.HBox;
	import mx.controls.HSlider;
	import mx.controls.Label;
	import mx.events.SliderEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * Container for animation play, pause, stop, and timeline controls. Embedded in the animation
	 * toolbar in the main application and in the digram in the viewer.
	 * 
	 * @see AnimationToolBar
	 * @see edu.stanford.covertlab.diagram.core.Diagram
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class AnimationBar extends HBox
	{
	
		[Embed(source = '../../image/control_play_blue.png')] private var playImg:Class;
		[Embed(source = '../../image/control_pause_blue.png')] private var pauseImg:Class;
		[Embed(source = '../../image/control_stop_blue.png')] private var stopImg:Class;
		[Embed(source = '../../image/control_fastforward.png')] private var speedOpenImg:Class;
		[Embed(source = '../../image/control_fastforward_blue.png')] private var speedClosedImg:Class;
		[Embed(source = '../../image/control_repeat_blue.png')] private var repeatImg:Class;		
		[Embed(source = '../../image/control_repeat.png')] private var noRepeatImg:Class;
		
		private var diagram:Diagram;
		private var playPauseButton:ToolBarButton;
		private var stopButton:ToolBarButton;
		private var slider:HSlider;
		private var time:Label;
		private var frameRateSliderToggle:ToolBarButton;
		private var frameRateSlider:VSlider;
		public var repeatButton:ToolBarButton;		
		
		public function AnimationBar(diagram:Diagram, standalone:Boolean = true) 		
		{				
			this.diagram = diagram;
			
			if (standalone) {
				percentWidth = 100;
				styleName = 'dockingArea';
				setStyle('paddingTop', 4);
				setStyle('paddingBottom', 4);
				setStyle('paddingLeft', 4);
				setStyle('paddingRight', 4);
				visible = !diagram.editingEnabled || diagram.fullScreenMode;
				addEventListener(MouseEvent.ROLL_OVER, rollOver);
				addEventListener(MouseEvent.ROLL_OUT, rollOut);			
				BindingUtils.bindSetter(function(value:Number):void { y = diagram.height - height; }, diagram, 'height');
				BindingUtils.bindSetter(function(value:Number):void { y = diagram.height - height; }, this, 'height');
			}
			
			//play/pause button
			playPauseButton = new ToolBarButton('Play/Pause', playImg, pauseImg);
			playPauseButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.playPauseAnimation(); } );
			addChild(playPauseButton);
			
			//stop button
			stopButton = new ToolBarButton('Stop', stopImg);
			stopButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.stopAnimation(); } );
			addChild(stopButton);
			
			//slider
			slider = new HSlider();
			slider.percentWidth = 100;
			slider.height = 10;
			slider.setStyle('showTrackHighlight', true);
			slider.setStyle('dataTipPlacement', 'botton');
			slider.setStyle('thumbOffset', -2);
			slider.minimum = 0;
			slider.snapInterval = 0;
			slider.dataTipFormatFunction = function(pos:Number):String { return diagram.getAnimationTime(pos).toString(); };
			slider.addEventListener(SliderEvent.THUMB_PRESS, function(event:SliderEvent):void { event.target.value = Math.round(event.target.value); } );
			slider.addEventListener(SliderEvent.THUMB_DRAG, function(event:SliderEvent):void { diagram.pauseAnimation(); event.target.snapInterval = 1; } );
			slider.addEventListener(SliderEvent.THUMB_RELEASE, function(event:SliderEvent):void { event.target.snapInterval = 0; } );
			slider.addEventListener(SliderEvent.CHANGE, function(event:SliderEvent):void { diagram.updateAnimationTween(event.target.value); } );
			addChild(slider);
			
			//time label
			time = new Label();
			time.width = 75;
			time.height = 16;
			time.setStyle('textAlign', 'right');
			addChild(time);
			
			//frame rate slide
			frameRateSlider = new VSlider();
			frameRateSlider.minimum = 1;
			frameRateSlider.maximum = 100;
			frameRateSlider.snapInterval = 1;
			frameRateSlider.height = 100;
			frameRateSlider.alpha = 0;
			frameRateSlider.addEventListener(SliderEvent.CHANGE, function(evt:SliderEvent):void {
				diagram.animationFrameRate = frameRateSlider.value;
			});
			
			frameRateSliderToggle = new ToolBarButton('Frame rate', speedClosedImg, speedOpenImg);
			frameRateSliderToggle.selected = false;
			frameRateSliderToggle.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void {
				frameRateSliderToggle.selected = !frameRateSliderToggle.selected;
				if (frameRateSliderToggle.selected) {					
					var pt:Point = diagram.globalToLocal(localToGlobal(new Point(
						frameRateSliderToggle.x + frameRateSliderToggle.width / 2, 
						frameRateSliderToggle.y)));					
					diagram.addChild(frameRateSlider);
					frameRateSlider.x = pt.x - 10;
					frameRateSlider.y = pt.y - 5 - frameRateSlider.height;
					Tweener.addTween(frameRateSlider, { 
						alpha: 1, 
						time: 1, 
						transition: "easeOutExpo"
						});
				} else {
					Tweener.addTween(frameRateSlider, { 
						alpha: 0, 						
						time: 0.5, 
						transition: "easeOutExpo",
						onComplete: function ():void { 
								diagram.removeChild(frameRateSlider);
							}
						});
				}
			});
			addChild(frameRateSliderToggle);
			
			//repeat button
			repeatButton = new ToolBarButton('Repeat', noRepeatImg, repeatImg);
			repeatButton.addEventListener(MouseEvent.CLICK, function (evt:MouseEvent):void { 
				diagram.loopAnimation = !diagram.loopAnimation;
				} );
			addChild(repeatButton);
			
			//binding
			BindingUtils.bindProperty(playPauseButton, 'enabled', diagram, 'measurementLoaded');
			BindingUtils.bindProperty(playPauseButton, 'selected', diagram, 'animationPlaying');
			BindingUtils.bindProperty(stopButton, 'enabled', diagram, 'animationNotStopped');
			BindingUtils.bindProperty(slider, 'enabled', diagram, 'measurementLoaded');
			BindingUtils.bindProperty(slider, 'maximum', diagram, 'animationPosMax');
			BindingUtils.bindProperty(slider, 'value', diagram, 'animationPos');
			BindingUtils.bindSetter(setTime, diagram, 'animationTime');
			BindingUtils.bindSetter(setTime, diagram, 'animationTimeMax');
			BindingUtils.bindProperty(frameRateSliderToggle, 'enabled', diagram, 'measurementLoaded');
			BindingUtils.bindProperty(frameRateSlider, 'value', diagram, 'animationFrameRate');
			BindingUtils.bindProperty(repeatButton, 'enabled', diagram, 'measurementLoaded');
			BindingUtils.bindProperty(repeatButton, 'selected', diagram, 'loopAnimation');			
		}
		
		private function setTime(val:Number):void {
			time.text = diagram.animationTime + '/' + diagram.animationTimeMax;
		}
		
		private function rollOver(event:MouseEvent):void {
			if (diagram.fullScreenMode && enabled) 
				alpha = 1;
		}
		
		private function rollOut(event:MouseEvent):void {
			if (diagram.fullScreenMode && enabled) 
				alpha = 0;
		}
		
		public function hideButtons():void {
			removeChild(playPauseButton);
			removeChild(stopButton);
			removeChild(frameRateSliderToggle)
			removeChild(repeatButton);
		}
	}
	
}