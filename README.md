# jscurlys #
an HTML template engine for static pages, similar to mustache.js or handlebars.js

## Basic Operation ##
Date: 2015-07-05 (1436134788)

***EXAMPLE Usage***
> cat filename.curly | ./jscurlys.tcl > filename.html

Inside your (HTML/any text) file you have:
```
some string with a {{name}} that will be substituted
```

There are two types of substitutions:

* name value
* name File:[/FQFN/|RQFN/]filename

```
name a value string
name File:filename
```


## Technical Details ##
JsCurly a simple HTML template engine, written in tclsh.

### Environment Variables ###

The Environment Variables are the filenames of text files.
If no values given, then *jscurlys* uses the default filenames.
The default filenames must be in the current directory.

* CURLYGLOBAL - default-filename:curlyGLOBALS
* CURLYDATA   - default-filename:curlyData

### CURLYGLOBAL file ###

These MUST BE defined. There are only three (3) GLOBALS defined.
These three (3) "curlys" should be in your HTML file.

If you do NOT want use them in your HTML file, don't use them,
but they must be defined in your *CURLYGLOBAL* file.

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
 -----------------------------------------
 {{DATE}}      | %e-%b-%Y        | 6-Jul-2015
 {{DATE2}}     | %D              | 07/06/2015
 {{YYYYMMDD}}  | %Y-%m-%d        | 2015-07-06
 {{TIME}}      | %T              | 01:20:25
 {{EPOCH}}     | %s              | 1436170825
 {{YEAR}}      | %Y              | 2015
 {{GENERATOR}} | version of 'jscurlys' | JsCurlys v0.9.5

### CURLYDATA file ###

I think most people will get the name/value pair idea. 
I also think the get the name/File:filename idea.

The name will translate internally to a variable name.
This means the *name* is limited to (A-Z),(a-z),(0-9),(_).
*name* with all capitals is reserved for GLOBAL internals.

**Examples**

```
Title This is a title.
Ads File:fileWithAds.js
headerImageLeft images/3menubars_black.png
```

