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
	import flash.display.GradientType;
	import flash.display.LineScaleMode;
	import flash.geom.Matrix;
	
	import mx.skins.ProgrammaticSkin;

	/**
	 * A skin for the thumb portion of the knob component.
	 */
	public class KnobThumbSkin extends ProgrammaticSkin
	{
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.clear();
			
			var knobRadius:Number = (unscaledWidth * .85) / 2;
			
			// Draw the gradient circle
			var gradient:Matrix = new Matrix();
			gradient.createGradientBox(unscaledWidth, unscaledHeight, 0);
			graphics.beginGradientFill(
					GradientType.RADIAL,
					[0xFFFFFF, 0xCCCCCC],
					[1, 1],
					[0, 255],
					gradient);
			graphics.drawCircle(unscaledWidth / 2, unscaledHeight / 2, knobRadius);
			
			// Draw the needle.
			graphics.lineStyle(2, 0xff0000, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			graphics.moveTo(unscaledWidth / 2, unscaledHeight / 2);
			graphics.lineTo(unscaledWidth / 2 + knobRadius, unscaledHeight / 2);
		}
	}
}