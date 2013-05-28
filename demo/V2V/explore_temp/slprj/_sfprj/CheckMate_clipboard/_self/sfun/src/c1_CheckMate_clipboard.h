#ifndef __c1_CheckMate_clipboard_h__
#define __c1_CheckMate_clipboard_h__

/* Include files */
#include "sfc_sf.h"
#include "sfc_mex.h"
#include "rtwtypes.h"

/* Type Definitions */
#ifndef typedef_SFc1_CheckMate_clipboardInstanceStruct
#define typedef_SFc1_CheckMate_clipboardInstanceStruct

typedef struct {
  SimStruct *S;
  ChartInfoStruct chartInfo;
  uint32_T chartNumber;
  uint32_T instanceNumber;
  int32_T c1_sfEvent;
  uint8_T c1_tp_ACC_1;
  uint8_T c1_tp_CC_1;
  uint8_T c1_tp_CC_2;
  uint8_T c1_tp_ACC_2;
  uint8_T c1_tp_avoid_error;
  uint8_T c1_tp_CC_3;
  uint8_T c1_tp_ACC_3;
  uint8_T c1_tp_ACC_4;
  uint8_T c1_tp_CC_4;
  boolean_T c1_isStable;
  uint8_T c1_is_active_c1_CheckMate_clipboard;
  uint8_T c1_is_c1_CheckMate_clipboard;
  uint8_T c1_doSetSimStateSideEffects;
  const mxArray *c1_setSimStateSideEffectsInfo;
} SFc1_CheckMate_clipboardInstanceStruct;

#endif                                 /*typedef_SFc1_CheckMate_clipboardInstanceStruct*/

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern const mxArray *sf_c1_CheckMate_clipboard_get_eml_resolved_functions_info
  (void);

/* Function Definitions */
extern void sf_c1_CheckMate_clipboard_get_check_sum(mxArray *plhs[]);
extern void c1_CheckMate_clipboard_method_dispatcher(SimStruct *S, int_T method,
  void *data);

#endif
