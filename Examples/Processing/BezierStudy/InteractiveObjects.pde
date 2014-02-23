// =============================================================================
//
// Copyright (c) 2014 Christopher Baker <http://christopherbaker.net>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// =============================================================================

public class BaseInteractiveObject extends PVector
{  
  boolean _isOver = false;
  boolean _isDragging = false;
  boolean _isPressed = false;

  public int fillColor;
  public int strokeColor;
  public int overFillColor;
  public int overStrokeColor;
  public int draggingFillColor;
  public int draggingStrokeColor;
  public int pressedFillColor;
  public int pressedStrokeColor;

  public BaseInteractiveObject(PVector position) 
  {    
    x = position.x;
    y = position.y;
    z = position.z;

    overFillColor = color(255, 255, 0, 180);
    draggingFillColor = color(255, 0, 255, 180);
    pressedFillColor = color(0, 255, 0, 180);
    fillColor = color(127, 180);

    overStrokeColor = color(255, 255, 0, 255);
    draggingStrokeColor = color(255, 0, 255, 255);
    pressedStrokeColor = color(0, 255, 0, 255);
    strokeColor = color(127, 255);
  }

  public void draw() 
  {
  }

  public int getFillColor()
  {
    if (_isDragging)
    {
      return draggingFillColor;
    }
    else if (_isPressed)
    {
      return pressedFillColor;
    }
    else if (_isOver)
    {
      return overFillColor;
    }
    else
    {
      return fillColor;
    }
  }

  public int getStrokeColor()
  {
    if (_isDragging)
    {
      return draggingStrokeColor;
    }
    else if (_isPressed)
    {
      return pressedStrokeColor;
    }
    else if (_isOver)
    {
      return overStrokeColor;
    }
    else
    {
      return strokeColor;
    }
  }

  public boolean hitTest(PVector position) 
  {
    // must override
    return false;
  }


  public void keyPressedInside() 
  {
  }

  public void keyPressedOutside() 
  {
  }

  public void keyReleasedInside() 
  {
  }

  public void keyReleasedOutside() 
  {
  }

  public void onMoveIn() 
  {
    //    println("[" + _id + "]: " + "onMoveIn");
  }

  public void onMoveOut() 
  {
    //    println("[" + _id + "]: " + "onMoveOut");
  }

  public void onDoubleClick() 
  {
  }
}


public class BaseInteractiveRectangle extends BaseInteractiveObject
{
  float _w;
  float _h;

  BaseInteractiveRectangle(PVector position, float w, float h)
  {
    super(position);
    _w = w;
    _h = h;
  }

  public boolean hitTest(PVector position) 
  {
    float halfWidth = _w / 2f;
    float halfHeight = _h / 2f;

    return position.x > x - halfWidth &&
      position.y > y - halfHeight &&
      position.x <= (x + halfWidth ) &&
      position.y <= (y + halfHeight);
  }

  public void draw() 
  {
    pushStyle();
    pushMatrix();
    translate(x, y);
    fill(getFillColor());
    stroke(getStrokeColor());
    rectMode(CENTER);
    rect(0, 0, _w, _h);
    popMatrix();
    popStyle();
  }

  public float getWidth()
  {
    return _w;
  }

  public void setWidth(float w)
  {
    _w = w;
  }

  public float getHeight()
  {
    return _h;
  }

  public void setHeight(float h)
  {
    _h = h;
  }
}

public class BaseInteractiveCircle extends BaseInteractiveObject
{
  float _radius;

  BaseInteractiveCircle(PVector position, float radius)
  {
    super(position);
    _radius = radius;
  }

  public boolean hitTest(PVector position) 
  {
    return dist(position) < _radius;
  }

  public void draw() 
  {
    pushStyle();
    pushMatrix();
    translate(x, y);
    fill(getFillColor());
    stroke(getStrokeColor());
    ellipse(0, 0, _radius * 2, _radius * 2);
    popMatrix();
    popStyle();
  }

  public float getRadius()
  {
    return _radius;
  }

  public void setRadius(float radius)
  {
    _radius = radius;
  }
}

public class BaseInteractivePolygon extends BaseInteractiveObject
{
  ArrayList<PVector> _polyline = new ArrayList<PVector>();

  BaseInteractivePolygon(PVector position, ArrayList<PVector> polyline)
  {
    super(position);
    _polyline = polyline;
    if (_polyline.size() < 3)
    {
      println("Invalid polygon, must have at least 3 points.");
      while ( _polyline.size () < 3)
      {
        _polyline.add(new PVector(0, 0, 0));
      }
    }
  }

  // This is a radial hit test.
  public boolean hitTest(PVector position) 
  {
    int counter = 0;
    int i;
    double xinters;
    PVector p1;
    PVector p2;

    int N = _polyline.size();

    if (N == 0) return false;

    p1 = _polyline.get(0);

    for (i=1; i <=N; i++) 
    {
      p2 = _polyline.get(i % N);

      if (position.y > min(p1.y, p2.y)) 
      {
        if (position.y <= max(p1.y, p2.y)) 
        {
          if (position.x <= max(p1.x, p2.x)) 
          {
            if (p1.y != p2.y) 
            {
              xinters = (position.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x;

              if (p1.x == p2.x || position.x <= xinters)
              {
                counter++;
              }
            }
          }
        }
      }
      p1 = p2;
    }
    return (counter % 2) == 0;
  }
}

public class InteractiveObjectManager 
{
  PApplet _parent;

  public ArrayList<BaseInteractiveObject> iObjects = new ArrayList<BaseInteractiveObject>();

  public BaseInteractiveObject currentInteractiveObject = null;

  PVector dragStart = null;
  PVector dragOffset = null;

  public InteractiveObjectManager(PApplet parent) 
  {
    _parent = parent;

    _parent.registerMethod("mouseEvent", this);
    _parent.registerMethod("keyEvent", this);
    _parent.registerMethod("dispose", this);
  }

  public void dispose()
  {
    _parent.unregisterMethod("mouseEvent", this);
    _parent.unregisterMethod("keyEvent", this);
    _parent.unregisterMethod("dispose", this);
  }

  public void mouseEvent(MouseEvent event)
  {
    PVector mouse = new PVector(event.getX(), event.getY());

    boolean foundOne = false;

    switch (event.getAction()) 
    {
    case MouseEvent.CLICK:
      break;
    case MouseEvent.DRAG:

      if (currentInteractiveObject != null) 
      {
        PVector newHandlePosition = PVector.sub(mouse, dragOffset);

        currentInteractiveObject.x = newHandlePosition.x;
        currentInteractiveObject.y = newHandlePosition.y;
        currentInteractiveObject.z = newHandlePosition.z;

        currentInteractiveObject._isDragging = true;

        BaseInteractiveObject handler = null;

        for (BaseInteractiveObject iObject : iObjects) 
        {
          if (handler == null && iObject.hitTest(mouse)) 
          { // re-evaluate
            handler = iObject;
            // handler.onDraggedInside(currentInteractiveObject);
          } 
          else 
          {
            // iObject.onDraggedOutside(currentInteractiveObject);
          }
        }
      } 
      else 
      {
        // nothing
      }

      break;
    case MouseEvent.ENTER:
      break;
    case MouseEvent.EXIT:
      break;
    case MouseEvent.MOVE:
      BaseInteractiveObject handler = null;

      for (BaseInteractiveObject iObject : iObjects) 
      {
        boolean didHit = iObject.hitTest(mouse);
        boolean wasAlreadyHandled = (handler != null);

        if (iObject._isOver) 
        { // was it over already?
          // if it didn't hit or was already handled,
          // then set isOver to false and move out.
          if (!didHit || wasAlreadyHandled) 
          {
            iObject._isOver = false;
            iObject.onMoveOut();
          } 
          else 
          {
            handler = iObject;
          }
        } 
        else {
          // it was not over already
          if (didHit && !wasAlreadyHandled) 
          {
            handler = iObject;
            iObject._isOver = true;
            iObject.onMoveIn();
          }
        }
      }
      break;
    case MouseEvent.RELEASE:
      for (BaseInteractiveObject iObject : iObjects) 
      {
        iObject._isPressed  = false;  // reset
        iObject._isOver     = false;  // reset
        iObject._isDragging = false;  // reset

        if (!foundOne) 
        {
          if (iObject.hitTest(mouse)) 
          {
            iObject._isOver = true;
            foundOne = true;
          }
        }
      }

      currentInteractiveObject = null;
      dragOffset = null;
      break;
    case MouseEvent.WHEEL:
      // do something...
      break;
    case MouseEvent.PRESS:
      println("clicking!");
      for (BaseInteractiveObject iObject : iObjects) 
      {
        iObject._isPressed = false; // reset
        iObject._isOver = false; // reset
        if (!foundOne) 
        {
          if (iObject.hitTest(mouse)) 
          {
            println("found one!");
            foundOne = true;
            iObject._isPressed = true; // reset
            iObject._isOver = true; // reset
            currentInteractiveObject = iObject; // set the interactive object
            dragStart = mouse.get(); // get the mouse vector (copy)
            dragOffset = PVector.sub(dragStart, iObject);
          }
        }
      }

      if (foundOne) 
      {
        iObjects.remove(currentInteractiveObject); // remove it and move it to the top of the stack
        iObjects.add(0, currentInteractiveObject); // add to the front
      }

      break;
    default:
      println("????" + event.getAction() );
    }
  }
  public void keyEvent(KeyEvent evt)
  {
  }

  public void add(BaseInteractiveObject iObject) 
  {
    iObjects.add(iObject);
  }

  public void draw() 
  {
    // render in reverse
    for (int i = iObjects.size() - 1; i >= 0; i--) 
    {
      iObjects.get(i).draw();
    }
  }

  // public void onClick() { }
  // public void onRelease() { }
  //
  // public void onPressOutside() { }
  // public void onReleaseOutside() { }

  // public void onMoveIn() { }
  // public void onMouseOut() { }

  public void keyPressed() 
  {
    for (int i = 0; i < iObjects.size(); i++) 
    {
      if (i == 0) 
      {
        iObjects.get(i).keyPressedInside();
      } 
      else 
      {
        iObjects.get(i).keyPressedOutside();
      }
    }
  }

  public void keyReleased() 
  {
    for (int i = 0; i < iObjects.size(); i++) 
    {
      if (i == 0) 
      {
        iObjects.get(i).keyReleasedInside();
      } 
      else 
      {
        iObjects.get(i).keyReleasedOutside();
      }
    }
  }
}
