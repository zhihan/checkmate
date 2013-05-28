Current Version: CheckMate 3.6
Update information is appended consecutively to this file
*******************************************************************
10/20/2007
*******************************************************************
* Updated some functionalities in polylib
* Tested for all demos
* Fixed a couple of bugs in explore and verify

*******************************************************************
06/26/2007
*******************************************************************
* Fix bugs in piha.m and install.m
* Remove the tools/ directory


*******************************************************************
3.61 Release: 04/05/2004
*******************************************************************
* Added capability of using gradient function of linear dynamics in the 
   optimization routines.


*******************************************************************
3.6 Release: 02/23/2004
*******************************************************************
* New routines in polylib (using cddmex).
* Fixed type conversion bugs in SCSB.
* Added interface to SVM.
* Updated procedures to get rid of the second pass of compute_mapping.

*******************************************************************
3.5 Release: 06/04/2003
*******************************************************************

This version is compatible with Matlab R13. To solve the type 
conversion issues we changed the following:

* The PTHB has as output type 'boolean'
* We introduced a new start event block for continuous systems. This block 
has output type boolean.
* For sample data models matters remain a bit more complicated. To avoid 
problems do the following
    - Use the sample data start event block (output type double)
    - Use proper types in the fsm block. This means that all input condition 
    are of type 'boolean' and the output type is 'double'.
    - Open the preferences of the statflow model (Tools>Explore>Edit>Properties) 
    and select strong data typing.
* Other minor changes to in the code solved a few other type conversion issues.
* We fixed a problem in the bounding box routine.
* CheckMate now facilitates the use of non-square transforamtion matrices.
* The distribution includes now documentation of the main data structure GLOBAL_PIHA.
* The distribution includes now documetation on the VCT demo.    
    
*******************************************************************
3.4 Release: 11/21/2002
*******************************************************************

_ A problem with unconnected inputs, that appeared incidentally when 
a model as opened has been resolved. The related problem of additional 
input ports remains. This is not really a problem, since it does affect 
neither simulation, exploration nor verification.

- This version does support the use of conditions in the FSMBs of the 
model rather than events. Note that due to the semantics of Stateflow, 
either all transition of a FSMB must be triggered by events, or all 
conditions must be guarded by conditions. The boing demo includes 
an example of a model that uses conditions.

*******************************************************************
3.4.13 Release: 01/19/2003
*******************************************************************

This release contains a few fixes of type conversion errors in Matlab R13.

------------------Previous Releases--------------------------------------


*******************************************************************
3.01 Release: 3/6/2002
*******************************************************************

Changes in this release:

-Bugs fixed in the refinement procedure.  Thanks to Howard Wong-Toi
for reporting the bug.

-State space partitioning procedure updated.  A hard-coded parameter
that was used to test which vertices correspond to which hyperplanes
was removed.  The parameter is now taken from the 'paramters.m' file.
Also, a bug relating to the bookkeeping of hyperplanes was fixed.

-Another demo example was added, the electronic throttle control (ETC)
example.  This is a 5th order version of the ETC example from the 
MoBIES project.  The example is meant for simulation/exploration
purposes.  Verification should not be attempted on this model.

-The documentation from the previous release was fixed.  The documentation
should now work in any browser.  Also, new documentation was added for 
the ETC example.

-The switched continuous system block (SCSB) in the CheckMate library
was fixed.  The blocks should no longer cause a warning when a CheckMate
model is simulated.  The user should be aware that the 'Apply' button
must be hit after properties in the SCSB are changed in order for them
to take effect.

*******************************************************************
3.01a Release: 3/7/2002
*******************************************************************

Changes in this release:

-A bug was fixed which involved the way that the reachability routine
dealt with non-determinism in the finite state machine. 

*******************************************************************
3.01b Release: 3/12/2002  
*******************************************************************

Changes in this release:

-A bug was fixed (in compute_mapping_no_SD.m) that incorrectly dealt with
assigned multiple terminal state mappings.  (Thanks to Howard Wong-Toi for
reporting this).

-Documentation for the ETC examples was added and previous documentation has
been updated.

-ETC regulation example was added that verifies an ETC system.  Also the 5d ETC
model was updated.

-A new splash page was added.

-Change was made (in check_overall_dynamics.m) to allow equality constraints 
for parameters.

-Changed optimization warning (in seg_approx_ode.m) so that the user knows that
the optimization did not improve on the original convex hull of the simulation points
during reachability analysis.

-Changed the flowpipe 'shrink wrapping' procedure (in seg_approx_ode.m) to accomodate
lower dimensional polyhedral regions.  This was introduced specifically to accomodate
lower dimensional paramter regions.

*******************************************************************
3.01c Release: 3/21/2002  
*******************************************************************

-Changed "apply_reset.m" to handle the case where one SCSB is reset while the others
are not.  Also, "apply_reset.m" now calls "grow_polytope.m".

-"seg_approx_ode.m" was changed to accomodate the case when it is passed an
empty parameter constraint set.

-SCSB block changed.  The block is now implemented with a mex function.
"trace_pthb_input.m" and "trace_scsb_input.m" was changed to accomodate the fact
that the SCSB block is now an s-function instead of a subsystem.

-SCSB's in demo's were updated to point to the new SCSB in the CheckMate/Simulink
library.

*******************************************************************
3.01c Release: 3/22/2002  
*******************************************************************

-New SCSB functions incorporated.  This one does not cause Matlab to crash
when the user debugs a Stateflow diagram.

-Note: users must manually update the SCSB's in their old CheckMate models with
the new SCSB. 

*******************************************************************
3.01d Release: 4/4/2002  
*******************************************************************

-Minor bugs with the Switched Continuous System Block were fixed.

-A user-setable flag was added that tells the verification procedure whether
to perform initial reachability or not. 

*******************************************************************
3.01e Release: 4/12/2002  
*******************************************************************

-Minor documentation changes

-Installation instructions added to root directory

-A bug was fixed in our convex hull routine (convex_hull.m).  The program now
returns the correct solution for the case where it is given less unique points
than there are dimensions.  Thanks to Howard Wong-Toi for pointing this out to us.

-A bug was fixed in the Ph-Plant demo.  The model was opening and assigning illegal
values to the initial condition field of the SCSB.  This has been rectified.

*******************************************************************
3.01f Release: 5/9/2002  
*******************************************************************

-Apply_reset was changed.  It no linger explicitly performs a 'grow polytope' operation.
It relies on the convex hull routine to grow the polytope if it is 'flat'.  The idea being
that if a reset was applied that was degenerate, the convex hull routine would have been called
to construct the reset region.

*******************************************************************
3.01g Release: 5/17/2002  
*******************************************************************

-A minor bug in iauto_part was fixed.  

*******************************************************************
3.01h Release: 6/7/2002
*******************************************************************

-Bug was fixed in partition_ss.m.  the clean_up procedure at the end was not correctly
 testing each of the pthb's to see which one was satisfied for each SSTREE region.  
This was corrected.  

-Convex hull routine updated.

*******************************************************************
3.01i Release: 6/17/2002
*******************************************************************

-CheckMate no longer attempts to allow PTHB names in ACTL expressions.
The change was made to 'build_ap.m'.

-Bug was fixed in partition_ss.  Program was not always associating the inside of the
PTHB with the correct side of a hyperplane in 'split_region' routine.  This has been
fixed.

-A new global variable has been introduced, GLOBAL_APPROX_PARAM.  This variable
holds all of the numerical parameters used for the verification.  Using this global
variable is much more efficient than the function calls that were used before.  Hence
significant increase in the speed of verifications has been achieved.

*******************************************************************
3.01j Release: 7/3/2002
*******************************************************************

-There was a bug in Piha.m.  The 'is_repeat' routine was testing to see if a newly
created cell was a copy of an existing cell by only testing if the boundary HP's were
identical.  This is not enough; the 'side' of each of the HP's is also important 
(iformation that is contained in hpflags).  This has been fixed.

-Several unused 'bouding_box' routines were removed.  Some of these existed as functions 
inside m-files and some of them were unused stand alone m-files.

-A new routine has been introduced which provides an alternative to the convex_hull 
routine used previously, performing a rectangular hull instead.  The function, 'rect_hull', 
produces a set of 2*n hyperplanes which are either parallel or orthogonal to each other 
and which bound a given set of points.  The hyperplanes are oriented in directions such 
that the total volume of the object returned is relatively small.  This provides a more 
conservative hull of the points given (in the sense that the polyhedral object returned 
contains more points than the convex hull would), but results in a smaller number of faces 
and takes much less time.  Note that this rectangular hull is now the default option (set 
by specifying the '.hull_flag' in the user-defined parameter file as either 'hyperrectangle' 
or 'convexhull'). 

*******************************************************************
3.01k Release: 7/23/2002
*******************************************************************

-CheckMate has been changed to be more verbose, when verifying non-linear systems. This 
should help the user to determine whether CheckMate got stuck, or whether there is any progress.

All 'clc' commands that remove feedback as soon as the next stage of the verification starts. 
This change affect all verifications. In addtition to this a approx_param.verbosity flag was 
introduced (default 0), with values from 0 (standard) to 2 (very verbose). This change will 
only effect the feedback for the verification of nonlinear systems. It is also possible to 
use the commandline option "verify -verbose". This sets verbosity to 1.

-The function fs_nonlin-map was changed, and will now detect certain null events. If a flowpipe 
segment lies completely inside the initial set, it is assumed that some states may stay in that 
location forever. 

-The private routine polyhedron.m was changed, to accmodate the change between rectangular hull 
and convex hull also for the case that the polyhedron is derived from a matrix of vertices. All 
other ways to create polyhedra already took care of this.

-The routine seg_aprox_ode has been changed such that, in case that the flowpipe approximation 
uses rectangular hull approximation of polyhedra, it adds the normals of the invariants to the 
set of normals. this gives a tighter approximation.

*******************************************************************
3.01L Release: 8/12/2002
*******************************************************************

-Line 548 of piha.m was changed.  'n' loop began with NAR where as it should begin with
NAR+1

-'number' field in the transition structure that is in the GLOBAL_PIHA was changed
to 'id'.  This is to reflect the fact that the transition number was given by Stateflow and
is not a sequential numbering of the transitions.

-'find_cond_expr' routine in piha.m was changed.  It should correctly parse the Stateflow
condition expressions now.

-'load_parameters.m' was added.  Running this function loads the default parameters into
a global variable.  This allows the user to use CheckMate functions that require parameters
without having defined a specific set of parameters. 

-Significant changes were made to 'partition_ss.m'.  The method used to partition the state
space was replaced with a new method that uses 'linprog' to discover when a cell region should
be divided.  The new method is much more efficient. 

*******************************************************************
3.01m Release: 8/28/2002
*******************************************************************

-Preliminary work on a sampled data difference equation analysis reachability
technique, called discrete-time flow analysis (DTFA) has been included in this 
release.  This type of analysis is not currently supported and documentation 
for it has yet to be written.  Its presence, however, should not affect the 
normal operation of CheckMate.  Several functions in CheckMate 
have been altered/added to accomodate the new capability, and three demos have been
added to illustrate the capability of DTFA.  For a description of DTFA, 
see J. Kapinski and B. Krogh, "Verifying Switched Mode Computer
 Controlled Systems", In Proceedings of the 2002 Conference on Computer
Aided Control System Design, to appear.   

-An unused function, transform.m, has been removed from the 'approximation'
folder.  The function that this file was to perform is already implemented
as a linearcon object method by the same name.

-Line 81 in apply_reset.m was uncommented.  This line 'bloats' the result
of the reset operation.  In some cases, the result is flattened and needs
to be restored to full dimension.

-The unused parameter Tsim was removed from the release.

-The method in which the user specifies the reset inside the user defined
dynamics file has been changed.  Now the user specifies an A and a B matrix
for the transformation.  See the boing example file boingfunc.m for an
example of the new reset method.

*******************************************************************
3.2 Release: 9/12/2002
*******************************************************************

- The function fs_lin_map was revised. It now computes the first segment
of the flowpipe, and translates this to obtain the other segments. The
function now only test for the timelimit if neither the system has an
attractive equilibrium, nor the system is unstable. Some unused sub-functions 
have been removed.

- The new way to define the reset may cause backward compatibility
problems. We now test whether the user uses an old type of reset or a new 
type of reset. If the reset is defined in the old fashion, CheckMate
produces a warning.

- To ensure backward compatibility, we include the obsolete field "np"
in the mask. This field is not used anywhere. It is just kept to
maintain backwards compatibility.

- Several unused function have been removed, as well as inconsistencies
in file names have been resolved.

*******************************************************************
3.3 Release: 10/17/2002
*******************************************************************

- The function piha.m was revised. Some flaws in the construction of the
composition of the FSM have been straightened out. Also some obsolete code 
has been removed.

- An obsolete function in flow_reach has been removed.

- The distinction between 'face' and 'init' in the standard case was no 
longer needed if the model is linear or nonlinear. This has been fixed.

- the function grow_polytope had a minor bug that was caused by an 
superfluous input.

