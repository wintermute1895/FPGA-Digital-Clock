if {[catch {package present Tcl 8.5.0-8.6}]} { return }
package ifneeded Tk 8.5.5 [list load [file join $dir .. tk85.dll] Tk]
