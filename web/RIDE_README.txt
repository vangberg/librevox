= ride

Documentation and support can be found at:
* http://trac.rubyists.com/trac.fcgi/ride/wiki/RIDE

== DESCRIPTION:

A Ruby-based Integrated Development Environment combining GNU screen and
VIM to create a flexible environment for working on your projects.  It
also allows multiple users to work together (ala pairs-coding) or work
on different pieces of a project at the same time within the same IDE.

== FEATURES/PROBLEMS:

* Uses screen to allow logical partitioning of pieces of a project, as
  well as multiple users to work together in the same space.
* Uses the powerful VIM text editor to work on source files and provide
  great syntax highlighting and code shortcuts (when available.)

== SYNOPSIS:

(Getting Started)
$ ride <project root>

(Getting to work)
$ script/ride

(Seeing the options)
$ script/ride --help

== REQUIREMENTS:

* screen
* vim (depends on file navigation)
* ruby (we use some ERb to make the templates work)
* gems - rubigen, hoe.

== INSTALL:

* sudo gem install ride
* read the postinstall for instructions (prints after install)

== LICENSE:

Copyright (c) 2006-8 The Rubyists.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
