# curlys v0.9.6 #
an HTML template engine for static pages, similar to mustache.js or handlebars.js

## Basic Operation ##
Date: 2015-07-05 (1436134788)

***EXAMPLE Usage***
```
$ cat filename.curly | ./curlys.tcl > filename.html
```

There are two types of constructs you can put inside your (HTML/any text) file:
> some string with a **{{name}}** that will be substituted
>
> another string with a **{{File:filename}}** that will be substituted

There are two types of substitutions:

1. name value
2. File:filename file-contents

***Quick Examples***
*name / value pair*
```
name a value string
```

*file that will be substituted*
```
<ul>
	<li> item1
	<li> item2
	<li> item3
</ul>
```

## Technical Details ##
curly.tcl is a dirt-simple HTML template engine, written in tclsh.

### Environment Variables ###

The Environment Variables are the filenames of text files.
If no values given, then *curlys.tcl* uses the default filenames.
The default filenames must be in the current directory.

* CURLYGLOBAL - default-filename:curlyGLOBALS
* CURLYDATA   - default-filename:curlyData

### CURLYGLOBAL file ###

These MUST BE defined. There are only three (3) GLOBALS defined.
These three (3) "curlys" should be in your HTML file.

If you do NOT want use them in your HTML file, don't use them,
but they must be defined in your *CURLYGLOBAL* file.

NOTE: A blank file will delete the line the curly is on.

**"curly" that should be in the *HTML* file**

* {{META}}
* {{TITLE}}
* {{CSSLOCAL}}

**In the *CURLYGLOBAL* file** (example)

```
META File:curlyfiles/meta.xml
TITLE The tile for the file
CSSLOCAL File:curlyfiles/csslocal.css
```

*example of an unused*

```
META .
TITLE .
CSSLOCAL .
```

### CURLYGLOBAL pre-defined ###

These are temporal values. The values 

curlys        | internal format | example output
--------------|-----------------|--------
{{DATE}}      | %e-%b-%Y        | 6-Jul-2015
{{DATE2}}     | %D              | 07/06/2015
{{YYYYMMDD}}  | %Y-%m-%d        | 2015-07-06
{{TIME}}      | %T              | 01:20:25
{{EPOCH}}     | %s              | 1436170825
{{YEAR}}      | %Y              | 2015
{{GENERATOR}} | version of 'curlys' | Curlys v0.9.5

### CURLYDATA file ###

I think most people will get the name/value pair idea. 
I also think the get the name/File:filename idea.

The *name* will translate internally to a variable name.
This means the *name* is limited to (A-Z),(a-z),(0-9),(_).
(*name* with all capitals is reserved for GLOBAL internals.)

NOTE: A blank file will delete the line the curly is on.

**Example**

```
Title This is a title.
headerImageLeft images/3menubars_black.png
```
