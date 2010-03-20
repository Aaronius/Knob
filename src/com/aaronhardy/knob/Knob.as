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
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.core.IFlexDisplayObject;
	import mx.core.IInvalidating;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.styles.ISimpleStyleClient;
	
	/**
	 * Dispatched when the value is changed either programmatically or
	 * through user interaction.
	 * 
	 * @eventType mx.events.FlexEvent.VALUE_COMMIT
	 */
	[Event(name="valueCommit", type="mx.events.FlexEvent")]
	
	/**
	 * Dispatched when the value is changed through user interaction.
	 * 
	 * @eventType flash.events.Event.CHANGE
	 */
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * The skin to be used as the backgrond for the knob.  This would include
	 * anything that shouldn't be rotated when the thumb is 
	 * rotated (e.g., tick marks.)
	 */
	[Style(name="backgroundSkin",type="Class",inherit="no")]
	
	/**
	 * The skin to be used as the thumb for the knob which the user interacts
	 * with.  This portion will be rotated as the user interacts, values
	 * are changed programmatically, etc.
	 */
	[Style(name="thumbSkin",type="Class",inherit="no")]
	public class Knob extends UIComponent
	{
		/**
		 * The background skin instance.
		 */
		protected var background:IFlexDisplayObject;
		
		/**
		 * Whether the background skin style has changed.
		 */
		protected var backgroundSkinChanged:Boolean = true;
		
		/**
		 * The thumb skin instance.
		 */
		protected var thumb:IFlexDisplayObject;
		
		/**
		 * A container for the thumb.  Used to catch mouse events
		 * on behalf of the thumb skin.
		 */
		protected var thumbContainer:UIComponent;
		
		/**
		 * Whether the thumb skin style has changed.
		 */
		protected var thumbSkinChanged:Boolean = true;

		//-------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _value:Number = 0;
		
		/**
		 * @private
		 */
		protected var valueChanged:Boolean = true;
		
		/**
		 * @private
		 * Whether the value was set since the last render cycle through
		 * user interaction.  If false, the value was only changed
		 * programmatically.
		 */
		protected var valueChangedByInteraction:Boolean = false;
		
		[Bindable]
		/**
		 * The current value of the knob.  This can be set through
		 * user interaction with the knob or programmatically.
		 * This value should be between the minimum and maximum.
		 * 
		 * @default 0
		 * @see #minimum
		 * @see #maximum
		 */
		public function get value():Number
		{
			return _value;
		}
		
		/**
		 * @private
		 */
		public function set value(val:Number):void
		{
			if (_value != val)
			{
				_value = val;
				valueChanged = true;
				invalidateProperties();
				invalidateDisplayList();
			}
		}
		
		//-------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _zeroAngle:Number = 180;
		
		/**
		 * @private
		 */
		protected var zeroAngleChanged:Boolean = true;
		
		[Bindable]
		/**
		 * The angle, in degrees at which the knob's minimum value
		 * should be placed. Suggested values are between -180 to 180 
		 * though any number is supported.  0 indicates straight
		 * to the right from the center of the knob while 180
		 * indicates stright to the left.
		 * 
		 * @default 180
		 */
		public function get zeroAngle():Number
		{
			return _zeroAngle;
		}
		
		/**
		 * @private
		 */
		public function set zeroAngle(value:Number):void
		{
			if (_zeroAngle != value)
			{
				_zeroAngle = value;
				zeroAngleChanged = true;
				invalidateProperties();
				invalidateDisplayList();
			}
		}
		
		//-------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _maxRotation:Number = 180;
		
		/**
		 * @private
		 */
		protected var maxRotationChanged:Boolean = true;
		
		[Bindable]
		/**
		 * The number of degrees the knob should be able to rotate.
		 * 
		 * @default 180
		 */
		public function get maxRotation():Number
		{
			return _maxRotation;
		}
		
		/**
		 * @private
		 */
		public function set maxRotation(value:Number):void
		{
			if (_maxRotation != value)
			{
				_maxRotation = value;
				maxRotationChanged = true;
				invalidateProperties();
				invalidateDisplayList();
			}
		}
		
		//-------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _minimum:Number = 0;
		
		/**
		 * @private
		 */
		protected var minimumChanged:Boolean = true;
		
		[Bindable]
		/**
		 * The minimum allowed value.
		 * 
		 * @default 0
		 * @see #value
		 */
		public function get minimum():Number
		{
			return _minimum;
		}
		
		/**
		 * @private
		 */
		public function set minimum(value:Number):void
		{
			if (_minimum != value)
			{
				_minimum = value;
				minimumChanged = true;
				invalidateDisplayList();
			}
		}
		
		//-------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _maximum:Number = 100;
		
		/**
		 * @private
		 */
		protected var maximumChanged:Boolean = true;
		
		[Bindable]
		/**
		 * The maximum allowed value
		 * 
		 * @default 100
		 * @see #value
		 */
		public function get maximum():Number
		{
			return _maximum;
		}
		
		/**
		 * @private
		 */
		public function set maximum(value:Number):void
		{
			if (_maximum != value)
			{
				_maximum = value;
				maximumChanged = true;
				invalidateDisplayList();
			}
		}
		
		//-------------------------------------------------------------------
		
		[Bindable]
		/**
		 * Whether the knob should snap (move to) to the user's cursor when the 
		 * user mouses down on the thumb.
		 * 
		 * @default false
		 */
		public var snapToCursor:Boolean = false;
		
		//-------------------------------------------------------------------
		
		[Bindable]
		/**
		 * When the user rotates past the maximum rotation, whether to allow 
		 * the thumb to loop to the minimum and continue rotating.  This
		 * is especially useful, for example, when your knob can rotate 
		 * 360 degrees and the user can continue rotating indefinitely.
		 */ 
		public var allowLooping:Boolean = false;
		
		//-------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			var allStyles:Boolean = (!styleProp || styleProp == 'styleName');
			
			if (!allStyles|| styleProp == 'backgroundSkin')
			{
				backgroundSkinChanged = true; 
				invalidateProperties();
			}
			
			if (!allStyles || styleProp == 'thumbSkin')
			{
				thumbSkinChanged = true;
				invalidateProperties();
			}
			
			invalidateDisplayList();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			// The thumb skin is most likely a ProgrammaticSkin or 
			// something similar that is not an InteractiveObject.
			// Therefore, we wrap the skin using a container
			// that receives mouse events on its behalf.
			thumbContainer = new UIComponent();
			addChild(thumbContainer);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			// When the background skin style changes, replace
			// the old skin with the new skin.
			if (backgroundSkinChanged)
			{
				if (background && contains(DisplayObject(background)))
				{
					removeChild(DisplayObject(background));
				}
				
				background = createSkin('backgroundSkin');
				
				if (background)
				{
					addChildAt(DisplayObject(background), 0);
				}
				
				backgroundSkinChanged = false;
			}
			
			// When the background skin style changes, replace
			// the old skin with the new skin.
			// The thumb skin is most likely a ProgrammaticSkin or 
			// something similar that is not an InteractiveObject.
			// Therefore, we wrap the skin using a container
			// that receives mouse events on its behalf.
			if (thumbSkinChanged)
			{
				if (thumb && thumbContainer.contains(DisplayObject(thumb)))
				{
					thumbContainer.removeEventListener(MouseEvent.MOUSE_DOWN, thumbContainer_mouseDownHandler);
					thumbContainer.removeChild(DisplayObject(thumb));
				}
				
				thumb = createSkin('thumbSkin');
				
				if (thumb)
				{
					thumbContainer.addEventListener(MouseEvent.MOUSE_DOWN, thumbContainer_mouseDownHandler);
					thumbContainer.addChild(DisplayObject(thumb));
				}
			}
			
			// Make sure maxRotation is a valid value.
			if (maxRotationChanged)
			{
				if (maxRotation <= 0 || maxRotation > 360)
				{
					throw new Error('maxRotation must be an positive number less than 360.');
				}
			}
			
			// Dispatch Event.CHANGE and FlexEvent.VALUE_COMMIT events
			// as necessary.
			if (valueChanged)
			{
				// In accordance with Flex standards, only dispatch 
				// change events if the value was changed through 
				// user interaction.
				if (valueChangedByInteraction)
				{
					dispatchEvent(new Event(Event.CHANGE));
				}
				dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
				valueChangedByInteraction = false;
			}
			
			// Assuming that the thumb skin or background skin may
			// need to change when the zeroAngle or maxRotation
			// properties have changed, the thumb and background
			// skin display lists will be invalidated.
			if (zeroAngleChanged || maxRotationChanged)
			{
				if (thumb && thumb is IInvalidating)
				{
					IInvalidating(thumb).invalidateDisplayList();
				}
				
				if (background && background is IInvalidating)
				{
					IInvalidating(background).invalidateDisplayList();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function measure():void
		{
			super.measure();
			measuredMinWidth = 1;
			measuredMinHeight = 1;
			measuredWidth = 100;
			measuredHeight = 100;
		}
		
		/**
		 * @inheritDoc
		 */ 
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Size the thumb container and its contained thumb skin
			// to the full size of the component.
			thumbContainer.setActualSize(unscaledWidth, unscaledHeight);
			
			if (thumb)
			{
				thumb.setActualSize(unscaledWidth, unscaledHeight);
			}
			
			// Size the background to the full size of the component.
			if (background)
			{
				background.setActualSize(unscaledWidth, unscaledHeight);
			}
			
			// If anything has changed that may affect thumb rotation,
			// re-rotate the thumb.
			if (valueChanged || minimumChanged || maximumChanged || zeroAngleChanged ||
					maxRotationChanged || thumbSkinChanged)
			{
				adjustThumb();
				valueChanged = false;
				minimumChanged = false;
				maximumChanged = false;
				zeroAngleChanged = false;
				maxRotationChanged = false;
				thumbSkinChanged = false;
			}
		}
		
		//-------------------------------------------------------------------
		
		/**
		 * The angle of the cursor on MOUSE_DOWN in degrees in 
		 * the custom vector.
		 */
		protected var startCursorAngle:Number = NaN;
		
		/**
		 * The difference between the cursor's angle and the 
		 * thumb's angle.  When snapToCursor is true, this is 0
		 * because they are the same.
		 */
		protected var gripAngleOffset:Number = NaN;
		
		/**
		 * The angle of the cursor on the previous MOUSE_MOVE event.
		 * This is used to track whether the user is rotating the
		 * thumb clockwise or counter-clockwise.
		 */
		protected var previousCursorAngle:Number = NaN;
		
		/**
		 * How far the cursor has travelled total since the
		 * MOUSE_DOWN event. If positive, the user has rotated
		 * the thumb clockwise since the last MOUSE_DOWN event.
		 * If negative, counter-clockwise.
		 */
		protected var cursorAngleDelta:Number = 0;
		
		/**
		 * On MOUSE_DOWN, the difference in degrees between 
		 * the thumb's angle and the minimum angle.  Should 
		 * be 0 or negative.  
		 */
		protected var startAngleToMinDifference:Number = 0;
		
		/**
		 * On MOUSE_DOWN, the difference in degrees between 
		 * the thumb's angle and the maximum angle.  Should 
		 * be 0 or positive.
		 */
		protected var startAngleToMaxDifference:Number = 0;
		
		/**
		 * Handle when the user mouses down on the thumb.  Sets up
		 * event listeners and various variables needed for rotation.
		 */
		protected function thumbContainer_mouseDownHandler(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			
			// The often misunderstood MOUSE_LEAVE event will fire when
			// the user mouses up when outside of the stage.
			stage.addEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
			
			startCursorAngle = getCursorAngle(event);
			
			// If snapToCursor is true, make the thumb reflect
			// the cursor's current position.
			if (snapToCursor)
			{
				// If the cursor is outside the min-max range,
				// snap to either the max or the min depending
				// on which side of the knob the cursor is
				// on compared to the current angle of the knob.
				if (startCursorAngle > maxRotation)
				{
					var currentThumbAngle:Number = getAngleFromValue(value);
					var oppositeCurrentAngle:Number = currentThumbAngle + 180;
					
					if (startCursorAngle > oppositeCurrentAngle)
					{
						startCursorAngle = 0;
					}
					else
					{
						startCursorAngle = maxRotation;
					}
				}
				
				setValueForAngle(startCursorAngle);
				
				// No grip offset because the thumb angle and
				// the cursor angle are now the same.
				gripAngleOffset = 0;
			}
			// If snapToCursor is false, set the grip angle
			// the difference between the cursor angle and the current
			// thumb angle.
			else
			{
				gripAngleOffset = startCursorAngle - getAngleFromValue(value);
			}
			
			// Reset variables used across MOUSE_MOVE events.
			previousCursorAngle = startCursorAngle;
			cursorAngleDelta = 0;
			startAngleToMinDifference = -(startCursorAngle - gripAngleOffset);
			startAngleToMaxDifference = maxRotation - (startCursorAngle - gripAngleOffset);
		}
		
		/**
		 * Handle when the user drags the thumb.  Takes appropriate
		 * action on rotating the thumb.
		 */
		protected function stage_mouseMoveHandler(event:MouseEvent):void
		{
			// The mouse angle in degrees in the custom vector.
			var mouseAngle:Number = getCursorAngle(event);
			
			// The new thumb angle in degrees in the custom vector.
			var newThumbAngle:Number = mouseAngle - gripAngleOffset;
			
			// Ensure the new thumb angle is between 0 and 360.
			newThumbAngle = sanitize360(newThumbAngle);
			
			// Determine if we are moving clockwise/counter-clockwise
			// and adjust our cursorAngleDelta accordingly.
			var oppositePreviousAngle:Number = (previousCursorAngle + 180) % 360;
			var movingClockwise:Boolean = containsAngle(
					mouseAngle, previousCursorAngle, oppositePreviousAngle);
			
			if (movingClockwise)
			{
				cursorAngleDelta += subtractAngle(mouseAngle, previousCursorAngle);
			} 
			else
			{
				cursorAngleDelta -= subtractAngle(previousCursorAngle, mouseAngle);
			}
			
			// If looping is allowed and the new thumb angle is outside of the
			// min-max range, snap to the min or max depending on which one
			// is closest.
			if (allowLooping && newThumbAngle > maxRotation)
			{
				var snapDividingAngle:Number = maxRotation + (360 - maxRotation) / 2;
				
				if (newThumbAngle <= snapDividingAngle)
				{
					newThumbAngle = maxRotation;
				}
				else
				{
					newThumbAngle = 0;
				} 
			}
			
			// If looping isn't allowed, make sure the thumb is constrained
			// to the min-max range based off which way the user has been
			// rotating the thumb.
			if (!allowLooping)
			{
				if (cursorAngleDelta < startAngleToMinDifference)
				{
					newThumbAngle = 0;
				}
				else if (cursorAngleDelta > startAngleToMaxDifference)
				{
					newThumbAngle = maxRotation;
				}
			}
			
			// Set the new value and store the current cursor
			// angle to be used the next time around.
			setValueForAngle(newThumbAngle);
			previousCursorAngle = mouseAngle;
		}
		
		/**
		 * Ensures an angle is between 0 and 360.
		 * 
		 * @param value The angle to sanitize.
		 * @return The angle between 0 and 360.
		 */
		protected function sanitize360(value:Number):Number
		{
			value %= 360;
			
			if (value < 0)
			{
				value = 360 + value;
			}
			
			return value
		}
		
		/**
		 * Sets the knob's value based on an angle in degrees
		 * in the custom vector.
		 * 
		 * @param angle The angle in degrees in the custom vector.
		 * @see #toCustomVector()
		 */
		protected function setValueForAngle(angle:Number):void
		{
			var anglePercentage:Number = angle / maxRotation;
			var valueForAngle:Number = minimum + 
					anglePercentage * (maximum - minimum);
			
			// Ensure it's between the minimum-maximum range.
			valueForAngle = Math.max(minimum, valueForAngle);
			valueForAngle = Math.min(maximum, valueForAngle); 
			
			value = valueForAngle;
			valueChangedByInteraction = true;
		}
		
		/**
		 * Whether an angle is between two other angles.
		 * The two containing angles are described as leftBoundAngle
		 * and rightBoundAngle to describe the search direction.
		 * The contained angle will be searched clockwise from
		 * the leftBoundAngle to the rightBoundAngle.
		 * 
		 * @param angle The angle, in degrees, to search for.
		 * @param leftBoundAngle The angle, in degrees,
		 *        to search clockwise from.
		 * @param rightBoundAngle The angle, in degrees, to 
		 *        search clockwise to.
		 */
		protected function containsAngle(angle:Number, 
				leftBoundAngle:Number, rightBoundAngle:Number):Boolean
		{
			if (rightBoundAngle <= leftBoundAngle)
			{
				if (angle <= rightBoundAngle)
				{
					angle += 360;
				}
				rightBoundAngle += 360;
			}
			
			return (angle >= leftBoundAngle && angle <= rightBoundAngle);
		}
		
		/**
		 * Gets the difference between two angles.
		 * 
		 * @param rightAngle The angle, in degrees, from which 
		 *        the leftAngle will be subtracted.
		 * @param leftAngle The angle, in degrees, to be
		 *        subtracted from the rightAngle.
		 * @return The difference in degrees.
		 */
		protected function subtractAngle(rightAngle:Number, leftAngle:Number):Number
		{
			if (rightAngle >= leftAngle)  // equals sign important
			{
				return rightAngle - leftAngle;
			}
			else
			{
				return (360 - leftAngle) + rightAngle;
			}
		}
		
		/**
		 * Gets the angle from the center of the thumb
		 * to the user's cursor in degrees in the custom
		 * vector.
		 * 
		 * @see #toCustomVector()
		 * @return The angle in degrees in the custom vector
		 */
		protected function getCursorAngle(event:MouseEvent):Number
		{
			var knobCenter:Point = new Point(width / 2, height / 2);
			knobCenter = localToGlobal(knobCenter);
			return toCustomVector(toDegrees(Math.atan2(
					event.stageY - knobCenter.y, 
					event.stageX - knobCenter.x)));
		}
		
		/**
		 * Rotates the thumb to match the current knob value.
		 */
		protected function adjustThumb():void
		{
			if (thumb)
			{
				var knobCenter:Point = new Point(width / 2, height / 2);
				var m:Matrix = new Matrix();
				m.tx -= knobCenter.x;
				m.ty -= knobCenter.y;
				m.rotate(toRadians(toStandardVector(getAngleFromValue(value))));
				m.tx += knobCenter.x;
				m.ty += knobCenter.y;
				thumb.transform.matrix = m;
			}
		}
		
		/**
		 * Gets the thumb angle in degrees in the custom vector
		 * that would represent the value.
		 * 
		 * @param value The value for which we are retrieving
		 *        a representative angle.
		 * @return The angle in degrees in the custom vector
		 */
		protected function getAngleFromValue(value:Number):Number
		{
			if (value < minimum || value > maximum)
			{
				throw new Error('Invalid value found when attempting to retrieve angle.');
			}

			var valuePercentage:Number = (value - minimum) / (maximum - minimum);
			var angleForValue:Number = valuePercentage * maxRotation;
			return angleForValue;
		}
		
		/**
		 * The custom vector starts at zero at zeroAngle and spans to
		 * 360 in a clockwise direction.  To simplify logic, most of
		 * this class's logic is in terms of the custom vector.
		 * This function converts an angle from the standard vector
		 * to the custom vector.
		 * 
		 * This function is left public as a convenient way for
		 * skins to convert angles if needed.
		 * 
		 * @param angle An angle in the standard vector to convert
		 *        to the custom vector.
		 * @see #toStandardVector
		 */
		public function toCustomVector(angle:Number):Number
		{
			if (angle < -180 || angle > 180)
			{
				throw new Error('Angle should be between -180 and 180');
			}
			
			if (angle < 0)
			{
				angle = 360 + angle;
			}
			
			var comparativeZeroAngle:Number = zeroAngle;
			
			if (zeroAngle < 0)
			{
				comparativeZeroAngle = 360 + zeroAngle;
			}
			
			if (angle < comparativeZeroAngle)
			{
				angle += 360;
			}
			
			angle -= comparativeZeroAngle;
			
			return angle;
		}
		
		/**
		 * The standard vector starts at zero going directly to the
		 * right of the center of the thumb.  It spans to -180 degrees
		 * moving counter-clockwise and spans to 180 degrees moving 
		 * clockwise. This is a standard trigonomic vector.
		 * 
		 * This function is left public as a convenient way for
		 * skins to convert angles if needed.
		 * 
		 * @param angle An angle in the custom vector to convert
		 *        to the standard vector.
		 * @see #toCustomVector
		 */ 
		public function toStandardVector(angle:Number):Number
		{
			if (angle < 0 || angle > 360)
			{
				throw new Error('Angle should be between 0 and 360');
			}
			
			angle %= 360;
			
			if (angle < 0)
			{
				angle = 360 - Math.abs(angle);
			}
			
			angle += zeroAngle;
			
			angle %= 360;
			
			if (angle > 180)
			{
				angle = -180 + (angle - 180);
			}
			
			return angle;
		}
		
		/**
		 * Remove event listeners on MOUSE_UP.
		 */
		protected function stage_mouseUpHandler(event:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			stage.removeEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
		}
		
		/**
		 * Creates a skin instance based off the skin style name.
		 * 
		 * @param skinName The style name of the skin.
		 * @return The skin instance.
		 */
		protected function createSkin(skinName:String):IFlexDisplayObject
		{
			var newSkin:IFlexDisplayObject;
			var newSkinClass:Class = Class(getStyle(skinName));
			
			if (newSkinClass)
			{
				newSkin = IFlexDisplayObject(new newSkinClass());
				newSkin.name = skinName;
				
				if (newSkin is ISimpleStyleClient) {
					ISimpleStyleClient(newSkin).styleName = this;
				}
			}
			
			return newSkin;
		}		
		
		/**
		 * Converts an angle from degrees to radians.
		 * 
		 * @param value The angle in degrees to convert.
		 * @return The angle in radians.
		 */				
		protected function toRadians(value:Number):Number
		{
			return value * (Math.PI / 180);
		}
			
		/**
		 * Converts an angle from radians to degrees.
		 * 
		 * @param value The angle in radians to convert.
		 * @return The angle in degrees. 
		 */			
		protected function toDegrees(value:Number):Number
		{
			return value * (180 / Math.PI);
		}
	}
}