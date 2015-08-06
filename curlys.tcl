#!/bin/sh
#
#    curlys.tcl
#    Date: 2015-07-05
#    Jesse Monroy, Jr. (jessemonroy650@yahoo.com)
#
#   2015-08-06 - v0.9.8 - Files can now be loaded from either files
#                         change default filenames to be more inline with the function
#                         curlyGlobal->curlyFIXED and curlyData->curlyVAR
#	2015-08-05 - v0.9.7.1 - removed last addition
#	2015-07-24 - v0.9.7 - Added removal of '\n' to deal with layout quirk
#	2015-07-07 - v0.9.6 - A blank file, blanks the line.
#	2015-07-06 - v0.9.5 - initial release
#
#----------------------------\
exec tclsh $0 "$@"

set DEBUG_DEBUG   0
#----------------------------
set    GENERATOR   "Curlys v0.9.8"
#----------------------------

set Home       ""
set CurlyFixed ""
set CurlyVar   ""
# Check for Environment Variables
if { [info exists env(HOME) ] } {
    set Home        $::env(HOME)
}
if { [info exists ::env(CURLYFIXED) ] } {
    set CurlyFixed $::env(CURLYFIXED)
}
if { [info exists ::env(CURLYVAR) ] } {
    set CurlyVar   $::env(CURLYVAR)
}
# Set to defaults, if we got no Envirnoment Varibles
if { $CurlyFixed == "" } { set CurlyFixed "curlyFIXED" }
if { $CurlyVar   == "" } { set CurlyVar   "curlyVAR" }

#puts [join "CurlyFixed:\"$CurlyFixed\"" ]
#puts [join "CurlyVar:\"$CurlyVar\"" ]
#exit

#============================================#
#    Static Variables
#============================================#
# See Names: http://javascript.crockford.com/code.html
array set marker {
    meta      {\{\{META\}\}}
    title     {\{\{TITLE\}\}}
    csslocal  {\{\{CSSLOCAL\}\}}

    date      {\{\{DATE\}\}}
    date2     {\{\{DATE2\}\}}
    date3     {\{\{YYYYMMDD\}\}}
    time      {\{\{TIME\}\}}
    epoch     {\{\{EPOCH\}\}}
    year      {\{\{YEAR\}\}}
    generator {\{\{GENERATOR\}\}}
}

#============================================#
#    Temporal Variables
#============================================#
set    DATE    [clock format [clock seconds] -format "%e-%b-%Y"]
set    DATE2   [clock format [clock seconds] -format "%D"]
set    DATE3   [clock format [clock seconds] -format "%Y-%m-%d"]
set    TIME    [clock format [clock seconds] -format %T]
set    EPOCH   [clock format [clock seconds] -format %s]
set    YEAR    [clock format [clock seconds] -format %Y]

#============================================#
#    Libraries
#============================================#
#source    ./cvarload.tcl
#source    ./chashload.tcl
#source    ./cmvarload.tcl
#source    $Lib/stack.tcl;        # As of 2015-02-04

#@    Loads Variable from a file. That is, the entire file is the variable.
proc commonVarFile { var filename } {
    upvar $var lvar

    set fileId [open $filename "r"]
	# 2015-07-24 - Added removal of '\n' to deal with layout quirk
    #set lvar [regsub -all {\n} [ read $fileId ] {}]
    set lvar [ read $fileId ]
    close $fileId
}
#@    Loads self defined variables from a file. 
#@    That is, every line is a 'variable name', followed by the 'variable value'.
#
proc commonMultipleVariableFile { filename } {

    set fileId [open $filename "r"]
    while { [gets $fileId ldata] >=0  } {
        regexp {([^\s]+)\s+(.+)} $ldata theWholeMatch hkey hdata
        #puts "$hkey $hdata"
        uplevel #0 set $hkey \"$hdata\"
    }
    close $fileId
}
#@    Loads hash from a file. 
#@    That is, every line is a 'hash key', followed by the 'hash data'.
#
proc commonHashFile { filename } {
    global theHash

    set fileId [open $filename "r"]
    while { [gets $fileId ldata] >=0  } {
        regexp {([^\s]+)\s+(.+)} $ldata theWholeMatch hkey hdata
        #puts "$hkey $hdata"
        array set theHash [ list $hkey $hdata ]
    }
    close $fileId
}

#============================================#
#    Instance Variables
#============================================#
# load (global) Document Meta Variables
if [ file exists $CurlyFixed ] {
    commonHashFile $CurlyFixed

    set TITLE     $theHash(TITLE)
    set META      $theHash(META)
    set CSSLOCAL  $theHash(CSSLOCAL)

    #
    # Search all fields to see if the string indicates to use a file.
    #
    foreach vv [ array names theHash ] { 
        if [ regexp {^(\S+):(.+)} $theHash($vv) theWholeMatch type parm ] {
            if [ expr {{File} eq "$type"} ] {
                commonVarFile tempvar $parm
                set $vv $tempvar
            }
        }
    }
}


# Load user data
commonMultipleVariableFile $CurlyVar

#puts $TITLE
#puts $META
#puts $CSSLOCAL
#puts $AppName
#puts $CopyrightHolder
#exit

set    lineno    0
set    oflag    0

#============================================#
#        M  A  I  N
#============================================#
while { [gets stdin line ] >= 0 } {
    incr lineno
    # 
    ####################
    # SUBSTITUTE GLOBAL
    ####################
    if [ info exists TITLE ]     { regsub -all $marker(title) $line $TITLE line }
    if [ info exists META ]      {
        if [regexp $marker(meta) $line ] {
            # There should be a better way
            if { [ string length $META ] == 0 } { continue }
            regsub -all $marker(meta)  $line $META  line
        }
    }
    if [ info exists CSSlOCAL ]  {
        if [regexp $marker(csslocal) $line ] {
            # There should be a better way
            if { [ string length $CSSlOCAL ] == 0 } { continue }
            regsub -all $marker(csslocal) $line $CSSlOCAL line
        }
    }
    ##################
    # SUBSTITUTE FILE
    ##################
    if [ regexp {\{\{(File:([^\{]+))\}\}} $line theWholeMatch inCurly theFile ] {
        commonVarFile substitute $theFile
        # Double check substitution
        if { $DEBUG_DEBUG == 1 } {
            puts $inCurly
            puts $substitute
            puts "theFile:$theFile"
        }
        # Do the substitution
        if { [ string length $substitute ] == 0 } {
            # Blank the line, if theFile is blank
            set line ""
            # There should be a better way
            continue
        } else {
            regsub {\{\{([^\{]+)\}\}} $line $substitute line
        }
        # clear out temporay variables
        set theWholeMatch {}
        set inCurly {}
        set theFile {}
        set substitute {}
    ##################
    # SUBSTITUTE NAME
    ##################
    } elseif [ regexp {\{\{([^\{]+)\}\}} $line theWholeMatch inCurly ] {
        eval set substitute $$inCurly
        # Double check substitution
        if { $DEBUG_DEBUG == 1 } {
            puts $inCurly
            puts $substitute
            if [ regexp {File:(.+)} $substitute theWholeMatch theFile ] {
                puts "theFile: $theFile"
                commonVarFile fileSubstitute $theFile
                puts $fileSubstitute
            }
        }
        # See if we are substituting a file or the line
        if [ regexp {File:(.+)} $substitute theWholeMatch theFile ] {
            # Substitue a file for the line
            commonVarFile fileSubstitute $theFile
            # if the file is blank, skip this line
            if { [ string length $fileSubstitute ] == 0 } {
                continue
            }
            regsub {\{\{([^\{]+)\}\}} $line $fileSubstitute line
        } else {
            # Substitue the line
            regsub {\{\{([^\{]+)\}\}} $line $substitute line
        }
        # clear out temporay variables
        set theWholeMatch {}
        set inCurly {}
        set substitute {}
    }

    ######################
    # SUBSTITUTE TEMPORAL
    ######################
    # These are all global and defined a run-time.
    # moved to last so other text strings can use "date", "time" & "epoch"
    regsub -all $marker(date)    $line $DATE  line
    regsub -all $marker(date2)   $line $DATE2 line
    regsub -all $marker(date3)   $line $DATE3 line
    regsub -all $marker(time)    $line $TIME  line
    regsub -all $marker(epoch)   $line $EPOCH line
    regsub -all $marker(year)    $line $YEAR  line
    regsub -all $marker(generator) $line $GENERATOR line

    # append line to list
    lappend theBody $line
}

#============================================#
#        
#============================================#
# An empty item in the list, means a empty item outputs a blank line - HERE
# This is the quirk, I make note of in various places.
set body [join $theBody "\n"]
if { $DEBUG_DEBUG == 1} {
    puts "\n----"
}
puts $body

exit
