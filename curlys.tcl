#!/bin/sh
#
#    jscurly.tcl
#    Date: 2015-07-05
#    Jesse Monroy, Jr. (jessemonroy650@yahoo.com)
#
#----------------------------\
exec tclsh $0 "$@"

set DEBUG_DEBUG   0
#----------------------------
set    GENERATOR   "JsCurlys v0.9.5"
#----------------------------

set Home        ""
set CurlyGlobal ""
set CurlyData   ""
# Check for Environment Variables
if { [info exists env(HOME) ] } {
    set Home        $::env(HOME)
}
if { [info exists ::env(CURLYGLOBAL) ] } {
    set CurlyGlobal $::env(CURLYGLOBAL)
}
if { [info exists ::env(CURLYDATA) ] } {
    set CurlyData   $::env(CURLYDATA)
}
# Set to defaults, if we got no Envirnoment Varibles
if { $CurlyGlobal == "" } { set CurlyGlobal "curlyGLOBALS" }
if { $CurlyData   == "" } { set CurlyData   "curlyData" }

#puts [join "CurlyGlobal:\"$CurlyGlobal\"" ]
#puts [join "CurlyData:\"$CurlyData\"" ]
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
if [ file exists $CurlyGlobal ] {
    commonHashFile $CurlyGlobal

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
commonMultipleVariableFile $CurlyData

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
    if [ regexp {\{\{(File:([^\{]+))\}\}} $line theWholeMatch inCurly theFile ] {
        commonVarFile substitute $theFile
        # Double check substitution
        if { $DEBUG_DEBUG == 1 } {
            puts $inCurly
            puts $substitute
            puts "theFile:$theFile"
        }
        # Do the substitution
        regsub {\{\{([^\{]+)\}\}} $line $substitute line
        # clear out temporay variables
        set theWholeMatch {}
        set inCurly {}
        set theFile {}
        set substitute {}
    } elseif [ regexp {\{\{([^\{]+)\}\}} $line theWholeMatch inCurly ] {
        eval set substitute $$inCurly
        # Double check substitution
        if { $DEBUG_DEBUG == 1 } {
            puts $inCurly
            puts $substitute
        }
        # Do the substitution
        regsub {\{\{([^\{]+)\}\}} $line $substitute line
        # clear out temporay variables
        set theWholeMatch {}
        set inCurly {}
        set substitute {}
    }

    if [ info exists TITLE ]     { regsub -all $marker(title) $line $TITLE line }
    if [ info exists META ]      { regsub -all $marker(meta)  $line $META  line }
    if [ info exists CSSlOCAL ]  { regsub -all $marker(csslocal) $line $CSSlOCAL line }

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
set body [join $theBody "\n"]
if { $DEBUG_DEBUG == 1} {
    puts "\n----"
}
puts $body

exit
