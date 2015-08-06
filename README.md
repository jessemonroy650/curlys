# curlys v0.9.8 #
an HTML template engine for static pages, similar to mustache.js or handlebars.js

## Basic Operation ##
Date: 2015-07-05 (1436134788)<br />
Last Update: 2015-08-06 (1438852948)<br />
For history of changes SEE [HISTORY.md](HISTORY.md)

***EXAMPLE Usage***
```
$ cat filename.curly | ./curlys.tcl > filename.html
```

There are two (2) types of constructs you can put inside your (HTML/any text) file:
> some string with a **{{name}}** that will be substituted
>
> another string with a **{{File:filename}}** that will be substituted

There are three (3) types of substitutions:

1. **name** value
2. **name** File:filename (which substitutes the file-contents)
3. **File:filename** file-contents

***Quick Examples***
*name / value pair*
(value that will be substituted)
```
a value string
```

*name / File:filename pair*<br />
(file-contents that will be substituted)
```
<ul>
	<li> item1
	<li> item2
	<li> item3
</ul>
```

*File:filename / file-contents pair*<br />
(file-contents that will be substituted)
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
The default filenames must be in the current directory,
otherwise, use the Environment Variables.

* CURLYFIXED - default-filename:curlyFIXED
* CURLYVAR   - default-filename:curlyVAR

### CURLYFIXED file ###

These MUST BE defined. There are only three (3) FIXED defined.
These three (3) "curlys" should be in your HTML file.

If you do NOT want use them in your HTML file, don't use them,
but they must be defined in your *CURLYFIXED* file.

NOTE: A blank file will delete the line the curly is on.

**"curly" that should be in the *HTML* file**

* {{META}}
* {{TITLE}}
* {{CSSLOCAL}}

**In the *CURLYFIXED* file** (example)

```
META File:curlyFiles/meta.xml
TITLE The tile for the file
CSSLOCAL File:curlyFiles/csslocal.css
```

*example of unused FIXED values*

```
META File:/dev/null
TITLE File:/dev/null
CSSLOCAL File:/dev/null
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
{{GENERATOR}} | version of 'curlys' | Curlys v0.9.8

### CURLYVAR file ###

I think most people will get the name/value pair idea. 
I also think they get the name/File:filename idea.

The *name* will translate internally to a variable name.
This means the *name* is limited to (A-Z),(a-z),(0-9),(_).
(*name* with all capitals is reserved for FIXED internals.)

*Example*<br />
```
Title This is a title.
headerImageLeft images/3menubars_black.png
```

**Blank File Rule**<br />
A blank ```File:file``` will delete the line the curly is on. That is, if the file has no data (is blank), then the line in the `.curly` file will be deleted. This is allows items to be listed, but not inserted - if the file is blank.

*Example*<br />
Using the example below, if the file *curlyFiles/JSFiles* is blank:
```
    <script type="text/javascript" charset="utf-8" src="cordova.js"></script>
    {{File:curlyFiles/JSFiles}} <!-- JSFiles -->
    <script type="text/javascript">
    </script>
```
then the result is:
```
    <script type="text/javascript" charset="utf-8" src="cordova.js"></script>
    <script type="text/javascript">
    </script>
```
If the *curlyFiles/JSFiles* does not exist, then an error is thrown. This will change in the future.


