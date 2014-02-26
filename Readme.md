# FRDLivelyButton

`FRDLivelyButton` is a simple UIButton subclass intended to be used inside a UIBarButtonItem,
even though it can be used anywhere you can use a UIButton. It is entirely Core Graphics driven,
and it supports 5 possible common types used in navigation bar.

![demo](images/screenshot.gif)

## Requirements

`FRDLivelyButton` uses ARC and requires iOS 7.0+.

It could probably be used in iOS 6, I have not tried but I is not using any iOS7 specific APIs..

Works for iPhone and iPad.

## Installation

### CocoaPods

`pod 'FRDLivelyButton', '~> 1.0'`

### Manual

Copy the folder `FRDLivelyButton` to your project.

## Usage

Add a FRDLivelyButton either in code or using interface builder:

```
// in code 
```

To change the button style, just called:

```

```

## Customizing Appearance

Basic button style can be defines using an option NSDictionary, those include colors, animation durations, etc...

See FRDLivelyButton.h for list of possible attributes.

Example:

```

```


## License

    The MIT License (MIT)

    Copyright (c) 2014 Sebastien Windal

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.


