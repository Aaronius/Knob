//Copyright (c) 2009 Aaron Hardy (http://aaronhardy.com)
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

package com.aaronhardy.knob
{
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	
	import mx.skins.ProgrammaticSkin;

	/**
	 * A skin for the background portion of the knob component.
	 */
	public class KnobBackgroundSkin extends ProgrammaticSkin
	{
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (!(parent is Knob))
			{
				return;
			}

			graphics.clear();
			var knob:Knob = Knob(parent);
			
			// The number of ticks to display
			const NUM_TICKS:uint = 10;
			const TICK_COLOR:uint = 0xB8B8B8;

			var tickAngleInterval:Number = knob.maxRotation / (NUM_TICKS - 1);
			var tickLength:Number = unscaledWidth / 2;

			for (var i:uint = 0; i < NUM_TICKS; i++)
			{
				var tickThickness:uint;
				
				// Make the min and max ticks a bit larger.
				if (i == 0 || i == NUM_TICKS - 1)
				{
					tickThickness = 3;
				} 
				else
				{
					tickThickness = 1;
				}
				
				graphics.lineStyle(tickThickness, TICK_COLOR, 1, false, 
						LineScaleMode.NORMAL, CapsStyle.NONE);
				var tickAngle:Number = toRadians(knob.toStandardVector(
						i * tickAngleInterval));
				var tickX:Number = (unscaledWidth / 2) + 
						Math.cos(tickAngle) * tickLength;
				var tickY:Number = (unscaledHeight / 2) + 
						Math.sin(tickAngle) * tickLength;
				graphics.moveTo(unscaledWidth / 2, unscaledHeight / 2);
				graphics.lineTo(tickX, tickY); 
			}
		}
		
		/**
		 * Converts a number from degrees to radians.
		 */				
		protected function toRadians(value:Number):Number {
			return value * (Math.PI / 180);
		}
			
		/**
		 * Converts a number from radians to degrees. 
		 */			
		protected function toDegrees(value:Number):Number {
			return value * (180 / Math.PI);
		}
	}
}