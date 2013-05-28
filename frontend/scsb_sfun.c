/* File: scsb_sfun.c
 * Abstract:
 *   C-MEX S-function for the Switched Continuous System Block (SCSB)
 *   in the CheckMate library. To compile the S-function, type "mex
 *   scsb_sfun.c" in the MATLAB command window.
 * Author: Alongkrit Chutinan
 * Date: March 21, 2002
 * Altered by Jim Kapinski
 * April, 2002
 * Altered by Ansgar Fehnker
 * July, 2003
 * Note:
 *   This function has been adapted for the template provided by The
 *   MathWorks.  For more details about S-functions, see
 *   simulink/src/sfuntmpl_doc.c.
 */

#define S_FUNCTION_NAME  scsb_sfun
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

/* Data indices for S-Function parameter. */
#define NPARAM          12
#define PARAM_NX        0
#define PARAM_NUP       1
#define PARAM_NZ        2
#define PARAM_NU        3
#define PARAM_X0        4
#define PARAM_SWFUNC    5
#define PARAM_P0        6
#define PARAM_USE_RESET 7
#define PARAM_USE_PARAM 8
#define PARAM_USE_SD    9
#define PARAM_AR_CI     10
#define PARAM_AR_DI     11

/* Data indices for pointer work vector. */
#define NPWORK             4
#define PWORK_X_DOT        0
#define PWORK_X_RESET      1
#define PWORK_Z            2
#define PWORK_U_OUT        3

/* Data indices for integer work vector. */
#define NIWORK              8
#define IWORK_U_PORT        0
#define IWORK_RESET_PORT    1
#define IWORK_USE_RESET     2
#define IWORK_LAST_RESET    3
#define IWORK_USE_PARAM     4
#define IWORK_SD_PORT       5
#define IWORK_USE_SD        6
#define IWORK_LAST_SD       7


void computeDerivativeAndReset(SimStruct *S);

/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS   /* Change to #undef to remove function */
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlCheckParameters =============================================
 * Abstract:
 *    mdlCheckParameters verifies new parameter settings whenever parameter
 *    change or are re-evaluated during a simulation. When a simulation is
 *    running, changes to S-function parameters can occur at any time during
 *    the simulation loop.
 *
 *    This method can be called at any point after mdlInitializeSizes.
 *    You should add a call to this method from mdlInitalizeSizes
 *    to check the parameters. After setting the number of parameters
 *    you expect in your S-function via ssSetNumSFcnParams(S,n), you should:
 *     #if defined(MATLAB_MEX_FILE)
 *       if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
 *           mdlCheckParameters(S);
 *           if (ssGetErrorStatus(S) != NULL) return;
 *       } else {
 *           return;     Simulink will report a parameter mismatch error
 *       }
 *     #endif
 *
 *     When a Simulation is running, changes to S-function parameters can
 *     occur either at the start of a simulation step, or during a
 *     simulation step. When changes to S-function parameters occur during
 *     a simulation step, this method is called twice, for the same
 *     parameter changes. The first call during the simulation step is
 *     used to verify that the parameters are correct. After verifying the
 *     new parameters, the simulation continues using the original
 *     parameter values until the next simulation step at which time the
 *     new parameter values will be used. Redundant calls are needed to
 *     maintain simulation consistency.  Note that you cannot access the
 *     work, state, input, output, etc. vectors in this method. This
 *     method should only be used to validate the parameters. Processing
 *     of the parameters should be done in mdlProcessParameters.
 *
 *     See matlabroot/simulink/src/sfun_errhdl.c for an example. 
 */
static void mdlCheckParameters(SimStruct *S)
{
  mxArray *mxTemp;
  int_T nx,nup,nz,nu,nAR,use_sd,use_param;
  real_T temp;

  use_sd = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_USE_SD));
  use_param = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_USE_PARAM));
  
  /* nx must be scalar integer. */
  mxTemp = ssGetSFcnParam(S,PARAM_NX);
  if (!mxIsNumeric(mxTemp)) {
    ssSetErrorStatus(S,"Number of continuous states must be numeric. ");
    return;
  }
  if ((mxGetM(mxTemp) != 1) || (mxGetN(mxTemp) != 1)) {
    ssSetErrorStatus(S,"Number of continuous states must be scalar. ");
    return;
  }
  temp = mxGetScalar(mxTemp);
  nx = (int_T) temp;
  if (temp != (real_T) nx) {
    ssSetErrorStatus(S,"Number of continuous states must be integer. ");
    return;
  }
  if (nx < 0) {
     ssSetErrorStatus(S,"Number of continuous states must be non-negative. ");
     return;
  }
  if (use_sd) {

    /* nup must be scalar integer. */
    mxTemp = ssGetSFcnParam(S,PARAM_NUP);
    if (!mxIsNumeric(mxTemp)) {
        ssSetErrorStatus(S,"Number of discrete-time controller outputs must be numeric. ");
        return;
    }
    if ((mxGetM(mxTemp) != 1) || (mxGetN(mxTemp) != 1)) {
        ssSetErrorStatus(S,"Number of discrete-time controller outputs must be scalar. ");
        return;
    }
    temp = mxGetScalar(mxTemp);
    nup = (int_T) temp;
    if (temp != (real_T) nup) {
        ssSetErrorStatus(S,"Number of discrete-time controller outputs must be integer. ");
        return;
    }
    if (nup < 0) {
        ssSetErrorStatus(S,"Number of discrete-time controller outputs must be non-negative. ");
        return;
    }
  
    /* nz must be scalar integer. */
    mxTemp = ssGetSFcnParam(S,PARAM_NZ);
    if (!mxIsNumeric(mxTemp)) {
        ssSetErrorStatus(S,"Number of discrete-time controller states must be numeric. ");
        return;
    }
    if ((mxGetM(mxTemp) != 1) || (mxGetN(mxTemp) != 1)) {
        ssSetErrorStatus(S,"Number of discrete-time controller states must be scalar. ");
        return;
    }
    temp = mxGetScalar(mxTemp);
    nz = (int_T) temp;
    if (temp != (real_T) nz) {
        ssSetErrorStatus(S,"Number of discrete-time controller states must be integer. ");
        return;
    }
    if (nz < 0) {
        ssSetErrorStatus(S,"Number of discrete-time controller states must be non-negative. ");
        return;
    }
  }
  /* nu must be scalar integer. */
  mxTemp = ssGetSFcnParam(S,PARAM_NU);
  if (!mxIsNumeric(mxTemp)) {
    ssSetErrorStatus(S,"Number of discrete inputs must be numeric. ");
    return;
  }
  if ((mxGetM(mxTemp) != 1) || (mxGetN(mxTemp) != 1)) {
    ssSetErrorStatus(S,"Number of discrete inputs must be scalar. ");
    return;
  }
  temp = mxGetScalar(mxTemp);
  nu = (int_T) temp;
  if (temp != (real_T) nu) {
    ssSetErrorStatus(S,"Number of discrete inputs must be integer. ");
    return;
  }
  if (nu < 0) {
    ssSetErrorStatus(S,"Number of discrete inputs must be non-negative. ");
    return;
  }
/* x0 must be a column vector of length nx. */
  mxTemp = ssGetSFcnParam(S,PARAM_X0);
  if (!mxIsNumeric(mxTemp)) {
    ssSetErrorStatus(S,"Initial conditions must be numeric. ");
    return;
  }
  
  /*Check Initial conditions.  If Sampled-Data Analysis is used, then the initial
  conditions should be in the form [x0;z0]*/
  if (!use_sd) {
    if ((nx == 0 && !mxIsEmpty(mxTemp)) || 
          (nx !=0 && (mxGetM(mxTemp) != nx || mxGetN(mxTemp) != 1))) {
        ssSetErrorStatus(S,"Initial condition and number of continuous states must be consistent. ");
        return;
    }
  }
  
  if (use_sd) {
     if (((nx == 0 && nz == 0 )&& !mxIsEmpty(mxTemp)) || 
          (nx !=0 && (mxGetM(mxTemp) != nx +nz || mxGetN(mxTemp) != 1))) {
        ssSetErrorStatus(S,"Initial condition and number of continuous states must be consistent. ");
        return;
     }
  }
  
  
  /* swfunc must be a string */
  mxTemp = ssGetSFcnParam(S,PARAM_SWFUNC);
  if (!mxIsChar(mxTemp)) {
    ssSetErrorStatus(S,"Switching Function must be a string. ");
    return;
  }
  
  if (use_param) {
      /* p0 must be numeric. */
    mxTemp = ssGetSFcnParam(S,PARAM_P0);
    if (!mxIsNumeric(mxTemp)) {
        ssSetErrorStatus(S,"Default parameter must be numeric. ");
        return;
    }
  }

  /* reset flag must be scalar and real. */
  mxTemp = ssGetSFcnParam(S,PARAM_USE_RESET);
  if (!mxIsNumeric(mxTemp)) {
    ssSetErrorStatus(S,"Reset flag must be numeric. ");
    return;
  }
  if ((mxGetM(mxTemp) != 1) || (mxGetN(mxTemp) != 1)) {
    ssSetErrorStatus(S,"Reset flag must be scalar. ");
    return;
  }

  
  /* AR CI must be a double matrix with nx columns. */
  mxTemp = ssGetSFcnParam(S,PARAM_AR_CI);
  if (!mxIsDouble(mxTemp)) {
    ssSetErrorStatus(S,"Matrix CI for analysis region must be of class 'double'. ");
    return;
  }
  if (use_sd) {
    if (!mxIsEmpty(mxTemp) && mxGetN(mxTemp) != (nx+nz)) {
        ssSetErrorStatus(S,"Matrix CI for analysis region must have same number of columns as number of plant and controller states. ");
        return;
    }
  }
  if (!use_sd) {
    if (!mxIsEmpty(mxTemp) && mxGetN(mxTemp) != nx) {
        ssSetErrorStatus(S,"Matrix CI for analysis region must have same number of columns as number of continuous states. ");
        return;
    }
  }
  if (mxIsEmpty(mxTemp)) {
    nAR = 0;
  }
  else {
    nAR = mxGetM(mxTemp);
  }

  /* AR dI must be a double column vector with nAR rows. */
  mxTemp = ssGetSFcnParam(S,PARAM_AR_DI);
  if (!mxIsDouble(mxTemp)) {
    ssSetErrorStatus(S,"Vector dI for analysis region must be of class 'double'. ");
    return;
  }
  if ((nAR == 0 && !mxIsEmpty(mxTemp)) || 
      (nAR != 0 && (mxGetM(mxTemp) != nAR || mxGetN(mxTemp) != 1))) {
    ssSetErrorStatus(S,"Vector dI for analysis region must be consistent with matrix CI. ");
    return;
  }

  
}
#endif /* MDL_CHECK_PARAMETERS */

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 *
 *    The direct feedthrough flag can be either 1=yes or 0=no. It should be
 *    set to 1 if the input, "u", is used in the mdlOutput function. Setting
 *    this to 0 is akin to making a promise that "u" will not be used in the
 *    mdlOutput function. If you break the promise, then unpredictable results
 *    will occur.
 *
 *    The NumContStates, NumDiscStates, NumInputs, NumOutputs, NumRWork,
 *    NumIWork, NumPWork NumModes, and NumNonsampledZCs widths can be set to:
 *       DYNAMICALLY_SIZED    - In this case, they will be set to the actual
 *                              input width, unless you are have a
 *                              mdlSetWorkWidths to set the widths.
 *       0 or positive number - This explicitly sets item to the specified
 *                              value.
 */
static void mdlInitializeSizes(SimStruct *S)
{
  int_T nx,nup,nz,nu,use_reset,use_sd;
  int_T ninput,noutput;
  int_T u_port,reset_port,x_port,sd_port;
  int_T zero_crossings;

  
  ssSetNumSFcnParams(S,NPARAM);  /* Number of expected parameters */
  if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
    return; /* Parameter mismatch will be reported by Simulink */
  }
  else {
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
  }



  /* Assume that all parameters have been checked above. */
  nx = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NX));
  nu = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NU));
  use_reset = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_USE_RESET));
  use_sd = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_USE_SD));
  if (use_sd) {
    nup = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NUP));
    nz = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NZ));
  }
    
  /* Initialize number of continuous and discrete states.  There are only
  discrete states if sampled-data analysis is used.*/
  if (use_sd) {
    ssSetNumContStates(S,nx+1);
    ssSetNumDiscStates(S,nz+nup);
  }
  else {
  ssSetNumContStates(S,nx+1);
  ssSetNumDiscStates(S,0);
  }
  
  /* Compute port index for the input u. Port index is -1 if there is
     no input signal u. */
  if (nu > 0)
    u_port = 0;
  else
    u_port = -1;
  
  /* Compute port index for the SD clock input.*/  
  if (use_sd)
    sd_port = u_port + 1;
  else
    sd_port = u_port;  
    
  /* Compute port index for the reset signal. Port index is -1 if
     there is no reset signal.  Note that the sampled-data clock input is now the first
     input port after the discrete-location inputs. */
  if (use_reset)
    reset_port = sd_port + 1;
  else
    reset_port = -1;
  
  ninput = (nu > 0) + use_sd + use_reset;
   
  if (!ssSetNumInputPorts(S,ninput)) return;

  /* Initialize size and direct feedthrough status for u port. */
  if (u_port != -1) {
    ssSetInputPortWidth(S,u_port,nu);
    ssSetInputPortDirectFeedThrough(S,u_port,0);
  }

  /* Initialize size and direct feedthrough status for sampled-data clock input port. */
  if (use_sd) {
    ssSetInputPortWidth(S,sd_port,1);
    ssSetInputPortDirectFeedThrough(S,sd_port,0);
  }

  /* Initialize size, type, and direct feedthrough status for reset port. */
  if (reset_port != -1) {
    ssSetInputPortWidth(S,reset_port,1);
    ssSetInputPortDirectFeedThrough(S,reset_port,0);
   
    ssSetInputPortDataType(S,reset_port,DYNAMICALLY_TYPED);
  }

  /* Compute port index for the state output port x. Port index is -1
     if the output x is not available. */
  if ((nx > 0)||(nz>0))
    x_port = 0;
  else
    x_port = -1;

  noutput = (nx > 0)||(nz > 0);

  if (!ssSetNumOutputPorts(S,noutput)) return;
  
  /* Initialize the size for the x port.  If sampled-data analysis is used,
  then make the output the continuous-time state, the controller output, and 
  the discrete-time controller state.*/
  if (x_port != -1) {
    if (use_sd)
        ssSetOutputPortWidth(S,x_port,nx+nz);
    else
        ssSetOutputPortWidth(S,x_port,nx);
   }
        
  ssSetNumSampleTimes(S,1);
  ssSetNumRWork(S,0);
  ssSetNumDWork(S,0);
  ssSetNumIWork(S,NIWORK);
  ssSetNumPWork(S,NPWORK);

  
  zero_crossings = 0;
  if (use_reset) {
    /* Declare that we will track one zero crossing signal, namely the
       reset signal. */
    zero_crossings = 1;   
  }
  if (use_sd) {
    zero_crossings++;
  }
  ssSetNumNonsampledZCs(S,zero_crossings);  
  
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *
 *    This function is used to specify the sample time(s) for your S-function.
 *    You must register the same number of sample times as specified in
 *    ssSetNumSampleTimes. If you specify that you have no sample times, then
 *    the S-function is assumed to have one inherited sample time.
 *
 *    The sample times are specified as pairs "[sample_time, offset_time]"
 *    via the following macros:
 *      ssSetSampleTime(S, sampleTimePairIndex, sample_time)
 *      ssSetOffsetTime(S, offsetTimePairIndex, offset_time)
 *    Where sampleTimePairIndex starts at 0.
 *
 *    The valid sample time pairs are (upper case values are macros defined
 *    in simstruc.h):
 *
 *      [CONTINUOUS_SAMPLE_TIME,  0.0                       ]
 *      [CONTINUOUS_SAMPLE_TIME,  FIXED_IN_MINOR_STEP_OFFSET]
 *      [discrete_sample_period,  offset                    ]
 *      [VARIABLE_SAMPLE_TIME  ,  0.0                       ]
 *
 *    Alternatively, you can specify that the sample time is inherited from the
 *    driving block in which case the S-function can have only one sample time
 *    pair:
 *
 *      [INHERITED_SAMPLE_TIME,  0.0                       ]
 *    or
 *      [INHERITED_SAMPLE_TIME,  FIXED_IN_MINOR_STEP_OFFSET]
 *
 *    The following guidelines may help aid in specifying sample times:
 *
 *      o A continuous function that changes during minor integration steps
 *        should register the [CONTINUOUS_SAMPLE_TIME, 0.0] sample time.
 *      o A continuous function that does not change during minor integration
 *        steps should register the
 *              [CONTINUOUS_SAMPLE_TIME, FIXED_IN_MINOR_STEP_OFFSET]
 *        sample time.
 *      o A discrete function that changes at a specified rate should register
 *        the discrete sample time pair
 *              [discrete_sample_period, offset]
 *        where
 *              discrete_sample_period > 0.0 and
 *              0.0 <= offset < discrete_sample_period
 *      o A discrete function that changes at a variable rate should
 *        register the variable step discrete [VARIABLE_SAMPLE_TIME, 0.0]
 *        sample time. The mdlGetTimeOfNextVarHit function is called to get
 *        the time of the next sample hit for the variable step discrete task.
 *        Note, the VARIABLE_SAMPLE_TIME can be used with variable step
 *        solvers only.
 *      o Discrete blocks which can operate in triggered subsystems.  For your 
 *        block to operate correctly in a triggered subsystem or a periodic 
 *        system it must register [INHERITED_SAMPLE_TIME, 0.0]. In a triggered
 *        subsystem after sample times have been propagated throughout the
 *        block diagram, the assigned sample time to the block will be 
 *        [INHERITED_SAMPLE_TIME, INHERITED_SAMPLE_TIME]. Typically discrete
 *        blocks which can be periodic or reside within triggered subsystems
 *        need to register the inherited sample time and the option
 *        SS_DISALLOW_CONSTANT_SAMPLE_TIME. Then in mdlSetWorkWidths, they
 *        need to verify that they were assigned a discrete or triggered
 *        sample time. To do this:
 *          mdlSetWorkWidths:
 *            if (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME) {
 *              ssSetErrorStatus(S, "This block cannot be assigned a "
 *                               "continuous sample time");
 *            }
 *
 *    If your function has no intrinsic sample time, then you should indicate
 *    that your sample time is inherited according to the following guidelines:
 *
 *      o A function that changes as its input changes, even during minor
 *        integration steps should register the [INHERITED_SAMPLE_TIME, 0.0]
 *        sample time.
 *      o A function that changes as its input changes, but doesn't change
 *        during minor integration steps (i.e., held during minor steps) should
 *        register the [INHERITED_SAMPLE_TIME, FIXED_IN_MINOR_STEP_OFFSET]
 *        sample time.
 *
 *    To check for a sample hit during execution (in mdlOutputs or mdlUpdate),
 *    you should use the ssIsSampleHit or ssIsContinuousTask macros.
 *    For example, if your first sample time is continuous, then you
 *    used the following code-fragment to check for a sample hit. Note,
 *    you would get incorrect results if you used ssIsSampleHit(S,0,tid).
 *        if (ssIsContinuousTask(S,tid)) {
 *        }
 *    If say, you wanted to determine if the third (discrete) task has a hit,
 *    then you would use the following code-fragment:
 *        if (ssIsSampleHit(S,2,tid) {
 *        }
 *
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
  /* Specify that we have a continuous sample time. */
  ssSetSampleTime(S,0,CONTINUOUS_SAMPLE_TIME);
  ssSetOffsetTime(S,0,0.0);
}


#define MDL_START  /* Change to #undef to remove function */
/* Function: mdlStart =======================================================
 * Abstract:
 *    This function is called once at start of model execution. If you
 *    have states that should be initialized once, this is the place
 *    to do it.
 */
static void mdlStart(SimStruct *S)
{
  int_T nx,nu,nz,nup,use_reset,u_port,reset_port,use_param,use_sd,sd_port;
  real_T *z_and_u,*temp,zero,*cont_states;  
  
  /* Assume that all parameters have been checked previously. */
  use_reset = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_USE_RESET));
  use_param = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_USE_PARAM));
  use_sd = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_USE_SD)); 
  nx = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NX));
  if (use_sd) {
    nup = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NUP));
    nz = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NZ));
  }
  nu = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NU));
  
  
  /* Compute port index for the input u. Port index is -1 if there is
     no input signal u. */
  if ((nu > 0))
    u_port = 0;
  else
    u_port = -1;
  
  /* Compute port index for the SD clock input.*/  
  if (use_sd)
    sd_port = u_port + 1;
  else
    sd_port = u_port;  
    
  /* Compute port index for the reset signal. Port index is -1 if
     there is no reset signal.  Note that the sampled-data clock input is now the first
     input port after the discrete-location inputs. */
  if (use_reset)
    reset_port = sd_port + 1;
  else
    reset_port = -1;
  
  /* Store port indices in the integer work vector so that we don't
     have to compute them again. */
  ssSetIWorkValue(S,IWORK_U_PORT,u_port);
  ssSetIWorkValue(S,IWORK_RESET_PORT,reset_port);
  ssSetIWorkValue(S,IWORK_USE_RESET,use_reset);
  ssSetIWorkValue(S,IWORK_USE_PARAM,use_param);
  ssSetIWorkValue(S,IWORK_USE_SD,use_sd);
  ssSetIWorkValue(S,IWORK_SD_PORT,sd_port);
  
  
  /* Initialize pointer work vector and allocate some mxArrays to
     store arguments for the SCSB wrapper function. */
  ssSetPWorkValue(S,PWORK_X_DOT,calloc((nx+1),sizeof(real_T)));
  ssSetPWorkValue(S,PWORK_X_RESET,calloc(nx,sizeof(real_T)));
  if (use_sd){
    ssSetPWorkValue(S,PWORK_Z,calloc(nz,sizeof(real_T)));
    ssSetPWorkValue(S,PWORK_U_OUT,calloc(nup,sizeof(real_T)));
  }
    
  /* Initialize the continuous state vector to initial values
     specified in S-function parameter. */
  if (nx>0){
  nx = ssGetNumContStates(S);
  memcpy(ssGetContStates(S),mxGetPr(ssGetSFcnParam(S,PARAM_X0)),
         (nx-1)*sizeof(real_T));
  zero=0;
  cont_states = ssGetContStates(S);
  memcpy(&cont_states[nx-1],&zero,
         sizeof(real_T));
         }
 
  /* If sampled-data analysis is used, put the initial controller
     states in the first part of the discrete-state vector.  Then 
     compute the output of the controller and put those values in the
     second part of the discrete-state vector.*/
  if (use_sd) {
    temp = mxGetPr(ssGetSFcnParam(S,PARAM_X0));
    if (nx>0){
    memcpy(ssGetDiscStates(S),&temp[nx-1],
         (nz)*sizeof(real_T));
    } else {
    memcpy(ssGetDiscStates(S),temp,
         (nz)*sizeof(real_T));
    }
    computeDerivativeAndReset(S);
    z_and_u = ssGetDiscStates(S);

    if (nup>0){
    memcpy(&z_and_u[nz],ssGetPWorkValue(S,PWORK_U_OUT),nup*sizeof(real_T)); 
    } 
  }
  
  
}


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector(s),
 *    ssGetOutputPortSignal.
 */
static void mdlOutputs(SimStruct *S,int_T tid)
{
  
  real_T *cont_out,*disc_out,use_sd;
  int_T nx,nz;  
  
  use_sd = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_USE_SD)); 
  
  nx = ssGetNumContStates(S);
  if (use_sd){
      nz = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NZ));
  }
  
  /* y = x, copy state vector x to output vector y. */
  cont_out = ssGetOutputPortRealSignal(S,0);
  memcpy(cont_out,ssGetContStates(S),
         (ssGetNumContStates(S)-1)*sizeof(real_T));
  if (use_sd){
    disc_out = &cont_out[nx-1];
    memcpy(disc_out,ssGetDiscStates(S),
             nz*sizeof(real_T));
  }
}

#define MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
/* Function: mdlUpdate ======================================================
 * Abstract:
 *    This function is called once for every major integration time step.
 *    Discrete states are typically updated here, but this function is useful
 *    for performing any tasks that should only take place once per
 *    integration step.
 */
static void mdlUpdate(SimStruct *S,int_T tid)
{
  int_T i,j,nx,nz,nup,use_reset,reset_value,use_sd,sd_port,reset_port,clock_value,nAR;
  real_T prod_i;
  real_T *x,*CI,*dI,*z_and_u;
  mxArray *mxCI;
  InputPtrsType      u;
  DTypeId test;



  nx = ssGetNumContStates(S);
  x = ssGetContStates(S);

  /* Check if state reset should be applied. */

  use_reset = ssGetIWorkValue(S,IWORK_USE_RESET);
  if (use_reset) {
    reset_port = ssGetIWorkValue(S,IWORK_RESET_PORT);
    
    /* This code was added by JPK 2/2004.  The purpose is to 
     * determine what the data type of the reset input is and 
     * to handle it accordingly.*/
    test= ssGetInputPortDataType(S,reset_port);
    if (test==8) {
        /* Boolean data type case */
        u     = ssGetInputPortSignalPtrs(S,reset_port);
        if((**(InputBooleanPtrsType) u)==1){        
            reset_value=1;
        }else{
            reset_value=0;
        }      
    } else {
       /* Double data type case */
        if(**ssGetInputPortRealSignalPtrs(S,reset_port)==1){        
            reset_value=1;
        }else{
            reset_value=0;
        } 
    }    
    
    if (ssGetIWorkValue(S,IWORK_LAST_RESET) != reset_value) {
      /* If the reset signal changes, record the new reset signal value. */
      ssSetIWorkValue(S,IWORK_LAST_RESET,reset_value);
      /* Apply state reset. */
      computeDerivativeAndReset(S);
      memcpy(x,ssGetPWorkValue(S,PWORK_X_RESET),(nx-1)*sizeof(real_T));
      /* Update block output since state has changed. */
      mdlOutputs(S,tid);
    }
  }
  
  /* If there is a clock pulse, update controller state and output. */

  z_and_u = ssGetDiscStates(S);
  use_sd = ssGetIWorkValue(S,IWORK_USE_SD);
  
  
  if (use_sd) {
    nz = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NZ));
    nup = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NUP));
    sd_port = ssGetIWorkValue(S,IWORK_SD_PORT);
    clock_value = (int_T) **ssGetInputPortRealSignalPtrs(S,sd_port);
    if ((ssGetIWorkValue(S,IWORK_LAST_SD) < .5)&&(clock_value > .5)) {
      /* If the clock signal goes hi, update the controller. */
      ssSetIWorkValue(S,IWORK_LAST_SD,clock_value);
      computeDerivativeAndReset(S);
      memcpy(z_and_u,ssGetPWorkValue(S,PWORK_Z),nz*sizeof(real_T));
      memcpy(&z_and_u[nz],ssGetPWorkValue(S,PWORK_U_OUT),nup*sizeof(real_T));      
      /* Update block output since state has changed. */
      mdlOutputs(S,tid);
    }
    else if ((ssGetIWorkValue(S,IWORK_LAST_SD) > .5)&&(clock_value < .5)) {
        ssSetIWorkValue(S,IWORK_LAST_SD,clock_value);
    }
  }
  

  /* Check if simulation should be stopped. */
  
  mxCI = ssGetSFcnParam(S,PARAM_AR_CI);
  if (!mxIsEmpty(mxCI)) {
    nAR = mxGetM(mxCI);
    CI = mxGetPr(mxCI);
    dI = mxGetPr(ssGetSFcnParam(S,PARAM_AR_DI));
    /* Compute product CI*x for analysis region. */
    for (i = 0; i < nAR; i++) {
      /* Multiply ith row of CI with x */
      prod_i = 0;
      
      /* If sampled-data analysis is to be performed, analysis
         region includes controller state dimensions. */
      if (use_sd) {
        for (j = 0; j < nx-1; j++) {
            prod_i += CI[j*nAR+i]*x[j];
        }
        for (j = nx-1; j < nx-1+nz;j++) {
            prod_i += CI[j*nAR+i]*z_and_u[j-(nx-1)];
        }
      }  
      else {
        for (j = 0; j < nx-1; j++) {
            prod_i += CI[j*nAR+i]*x[j];      
        }
      }
      
      /* if CIi*x > dIi, then state is out of analysis region. */
      if (prod_i > dI[i]) {
        /* Stop simulation if state is outside of analysis region. */
        ssSetStopRequested(S,1);
        ssWarning(S,"System has left the user-defined Analysis Region. Simulation halted.");
        ssSetErrorStatus(S,"System has left the user-defined Analysis Region. Simulation halted. ");
      }
    }
  }

}
#endif /* MDL_UPDATE */

#define MDL_DERIVATIVES
/* Function: mdlDerivatives =================================================
 * Abstract:
 *    In this function, you compute the S-function block's derivatives.
 *    The derivatives are placed in the derivative vector, ssGetdX(S).
 */
static void mdlDerivatives(SimStruct *S)
{
  /* Call the SCSB wrapper function to compute state derivative and
     state reset vectors. */
 int_T nx;

 nx = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NX));


  computeDerivativeAndReset(S);
 
  /* Copy the derivative computed above from pointer work vector. */
  memcpy(ssGetdX(S),ssGetPWorkValue(S,PWORK_X_DOT),
         (nx+1)*sizeof(real_T));
}


#define MDL_ZERO_CROSSINGS
/* Function: mdlZeroCrossings ===============================================
 * Abstract:
 *    If your S-function has registered CONTINUOUS_SAMPLE_TIME and there
 *    are signals entering the S-function or internally generated signals
 *    which have discontinuities, you can use this method to locate the
 *    discontinuities. When called, this method must update the
 *    ssGetNonsampleZCs(S) vector.
 */
static void mdlZeroCrossings(SimStruct *S)
{
  real_T *zcSignals;
  int_T use_reset,use_sd,reset_value,reset_port,sd_port,sd_value;

  use_reset = ssGetIWorkValue(S,IWORK_USE_RESET);
  use_sd = ssGetIWorkValue(S,IWORK_USE_SD);
  if (use_reset) {
    reset_port = ssGetIWorkValue(S,IWORK_RESET_PORT);
    /* Assume that the reset signal changes between discrete values of 0
       and 1. Thus, we set the zero crossing detection at 0.5 */
    reset_value = (int_T) **ssGetInputPortRealSignalPtrs(S,reset_port);
    zcSignals = ssGetNonsampledZCs(S);
    zcSignals[0] = (real_T) reset_value - 0.5;
    
    if (use_sd) {
        sd_port = ssGetIWorkValue(S,IWORK_SD_PORT);
        /* Assume that the SD signal changes between discrete values of 0
            and 1. Thus, we set the zero crossing detection at 0.5 */
        sd_value = (int_T) **ssGetInputPortRealSignalPtrs(S,sd_port);
        zcSignals = ssGetNonsampledZCs(S);
        zcSignals[1] = (real_T) sd_value - 0.5;
    } 
  }
  else if (use_sd) {
        sd_port = ssGetIWorkValue(S,IWORK_SD_PORT);
        /* Assume that the SD signal changes between discrete values of 0
            and 1. Thus, we set the zero crossing detection at 0.5 */
        sd_value = (int_T) **ssGetInputPortRealSignalPtrs(S,sd_port);
        zcSignals = ssGetNonsampledZCs(S);
        zcSignals[0] = (real_T) sd_value - 0.5;
  }
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was allocated
 *    in mdlStart, this is the place to free it.
 *
 *    Suppose your S-function allocates a few few chunks of memory in mdlStart
 *    and saves them in PWork. The following code fragment would free this
 *    memory.
 *        {
 *            int i;
 *            for (i = 0; i<ssGetNumPWork(S); i++) {
 *                if (ssGetPWorkValue(S,i) != NULL) {
 *                    free(ssGetPWorkValue(S,i));
 *                }
 *            }
 *        }
 */
static void mdlTerminate(SimStruct *S)
{
  /* Free mxArrays and other arrays that we allocated in mdlStart. */
  free(ssGetPWorkValue(S,PWORK_X_DOT)); 
  free(ssGetPWorkValue(S,PWORK_X_RESET)); 
  free(ssGetPWorkValue(S,PWORK_Z)); 
  free(ssGetPWorkValue(S,PWORK_U_OUT));
}


/*========================*
 * Other helper functions *
 *========================*/

/* Function: mxIsVector =======================================================
 * Abstract:
 *    Return 1 if the given mxArray is a vector of length L, i.e. the
 *    mxArray has the size of 1 in one dimension and the size L in the
 *    other dimension. Return 0 otherwise.
 */
int_T myMxIsVector(mxArray *A,int_T L)
{
  int_T m,n,st;

  m = mxGetM(A);
  n = mxGetN(A);
  st = ((m == 1) && (n == L)) || ((m == L) && (n == 1));
  return st;
}

/* Function: controller_state_update ==========================================
   Abstract:
        Use the difference equations specified in the user-defined m-file to
        update the state of the discrete-time controller.
*/      

/* Function: computeDerivativeAndReset ========================================
 * Abstract:
 *    Call the SCSB wrapper function, which, in turn, calls the
 *    use-defined switching function to compute the state derivative
 *    and reset vectors given the current state x and discrete input
 *    u. The results are stored in memory allocated inside the pointer
 *    work vector.
 */
void computeDerivativeAndReset(SimStruct *S)
{
  
  mxArray *ArgIn[9];
  mxArray *ArgOut[2];
  mxArray *x_dot_temp;
  int_T i,nx,nz,nu,nup,u_port,use_sd,use_reset,buflen;
  real_T *mxUPr,*z_and_u,*u,*z_idx,one,*u_idx,*x_in,*timer,*x_dot;
  InputRealPtrsType uPtrs;

  use_reset = ssGetIWorkValue(S,IWORK_USE_RESET);
  use_sd = ssGetIWorkValue(S,IWORK_USE_SD);
  
  ArgIn[0] = ssGetSFcnParam(S,PARAM_SWFUNC);

  /* Copy x vector to mxArray to be used as an argument to the wrapper
     function. */
  nx = ssGetNumContStates(S);
  if (use_sd) {
    nz = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NZ));
    ArgIn[1] = mxCreateDoubleMatrix(nx-1+nz,1,mxREAL);
    x_in = mxGetPr(ArgIn[1]);    
    memcpy(x_in,ssGetContStates(S),(nx-1)*sizeof(real_T));     
    memcpy(&x_in[nx-1],ssGetDiscStates(S),nz*sizeof(real_T));
  }
  else {
    nz = 0;    
    ArgIn[1] = mxCreateDoubleMatrix(nx-1,1,mxREAL);    
    x_in = mxGetPr(ArgIn[1]);
    memcpy(x_in,ssGetContStates(S),(nx-1)*sizeof(real_T));
  
  }

  /* Copy u vector to mxArray to be used as an argument to the wrapper
     function. */
  nu = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NU));
  ArgIn[2] = mxCreateDoubleMatrix(nu,1,mxREAL);
  if (nu > 0) {
    u_port = ssGetIWorkValue(S,IWORK_U_PORT);
    uPtrs = ssGetInputPortRealSignalPtrs(S,u_port);
    mxUPr = mxGetPr(ArgIn[2]);
    for (i = 0; i < nu; i++) {
      mxUPr[i] = *uPtrs[i];
    }
  }

  ArgIn[3] = ssGetSFcnParam(S,PARAM_P0);
  ArgIn[4] = ssGetSFcnParam(S,PARAM_USE_RESET);
  ArgIn[5] = ssGetSFcnParam(S,PARAM_USE_PARAM);
  ArgIn[6] = ssGetSFcnParam(S,PARAM_USE_SD);
  if (use_sd) {
     nup = (int_T) *mxGetPr(ssGetSFcnParam(S,PARAM_NUP)); 
     z_and_u = ssGetDiscStates(S); 
     u = &z_and_u[nz];
     ArgIn[7] = mxCreateDoubleMatrix(nup,1,mxREAL);
     memcpy(mxGetPr(ArgIn[7]),u,nup*sizeof(real_T));
  }   
  else {
    ArgIn[7] = mxCreateDoubleMatrix(1,1,mxREAL);
  }
  
  /* Pass the simulation time to the user-defined m-file.
     This will allow the simulation of time varying systems.*/
  ArgIn[8] = mxCreateDoubleMatrix(1,1,mxREAL);
  timer = mxGetPr(ArgIn[8]);     
  memcpy(timer,&ssGetContStates(S)[nx-1],(1)*sizeof(real_T));   
  
  
  /* Call the SCSB wrapper function, which calls the switching
     function to return the derivative and the reset vectors.
       [msg,x_dot,x_reset] = swfunc_wrapper(swfunc,x,u,p0,use_reset,use_param)
   */
   
  mexCallMATLAB(2,ArgOut,8,ArgIn,"scsb_wrapper");   

  mxDestroyArray(ArgIn[1]);
  mxDestroyArray(ArgIn[2]);
  mxDestroyArray(ArgIn[7]);
  mxDestroyArray(ArgIn[8]);
  
  /* Perform error checking to check data integrity and prevent
     possible segmentation fault error. */

  /* Check if derivative is a vector of class 'double' and of
     appropriate length. */
  if (!mxIsDouble(ArgOut[0])) {
    ssSetErrorStatus(S,"Switching function must return derivative vector of class 'double'. ");
    mxDestroyArray(ArgOut[0]);
    mxDestroyArray(ArgOut[1]);
    return;
  }   
  if (use_sd) {
    if (!myMxIsVector(ArgOut[0],nx-1+nz+nup)) {
        ssSetErrorStatus(S,"Switching function must return derivative vector with appropriate length. ");
        mxDestroyArray(ArgOut[0]);
        mxDestroyArray(ArgOut[1]);
        return;
    }
  }   
  if (!use_sd) {
    if (!myMxIsVector(ArgOut[0],nx-1)) {
        ssSetErrorStatus(S,"Switching function must return derivative vector with appropriate length. ");
        mxDestroyArray(ArgOut[0]);
        mxDestroyArray(ArgOut[1]);
        return;
    }
  }
  if (use_reset) {
    /* Check if reset is a vector of class 'double' and of appropriate
       length. */
    if (!mxIsDouble(ArgOut[1])) {
      ssSetErrorStatus(S,"Switching function must return reset vector of class 'double'. ");
      mxDestroyArray(ArgOut[0]);
      mxDestroyArray(ArgOut[1]);
      return;
    }
    if (!myMxIsVector(ArgOut[1],nx-1)) {
      ssSetErrorStatus(S,"Switching function must return reset vector with appropriate length. ");
      mxDestroyArray(ArgOut[0]);
      mxDestroyArray(ArgOut[1]);
      return;
    }
  }
    
  /* If everything checks out, copy output arguments into memory
     allocated in the pointer work vector. */   
  buflen = nx*sizeof(real_T);
  x_dot_temp = mxCreateDoubleMatrix(nx,1,mxREAL);
  x_dot = mxGetPr(x_dot_temp);
  memcpy(x_dot,mxGetPr(ArgOut[0]),(nx-1)*sizeof(real_T));
  one = 1;
  memcpy(&x_dot[nx-1],&one,sizeof(real_T));
  memcpy(ssGetPWorkValue(S,PWORK_X_DOT),mxGetPr(x_dot_temp),buflen);
  if (use_reset) {
    memcpy(ssGetPWorkValue(S,PWORK_X_RESET),mxGetPr(ArgOut[1]),(nx-1)*sizeof(real_T));
  }

  mxDestroyArray(x_dot_temp);   
  
  if (use_sd) {
    z_idx = mxGetPr(ArgOut[0]);
    z_idx = &z_idx[nx-1];
    u_idx = mxGetPr(ArgOut[0]);
    u_idx = &u_idx[nx-1+nz];
    memcpy(ssGetPWorkValue(S,PWORK_Z),z_idx,nz*sizeof(real_T));
    memcpy(ssGetPWorkValue(S,PWORK_U_OUT),u_idx,nup*sizeof(real_T));
  }

  /* Free the mxArrays returned by the above MATLAB function call. */
  mxDestroyArray(ArgOut[0]);
  mxDestroyArray(ArgOut[1]);
  return;
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
