#ifndef __c3_CheckMate_clipboard_h__
#define __c3_CheckMate_clipboard_h__

/* Include files */
#include "sfc_sf.h"
#include "sfc_mex.h"
#include "rtwtypes.h"

/* Type Definitions */
#ifndef typedef_SFc3_CheckMate_clipboardInstanceStruct
#define typedef_SFc3_CheckMate_clipboardInstanceStruct

typedef struct {
  SimStruct *S;
  ChartInfoStruct chartInfo;
  uint32_T chartNumber;
  uint32_T instanceNumber;
  int32_T c3_sfEvent;
  uint8_T c3_tp_left;
  uint8_T c3_tp_neither;
  uint8_T c3_tp_right;
  boolean_T c3_isStable;
  uint8_T c3_is_active_c3_CheckMate_clipboard;
  uint8_T c3_is_c3_CheckMate_clipboard;
  uint8_T c3_doSetSimStateSideEffects;
  const mxArray *c3_setSimStateSideEffectsInfo;
} SFc3_CheckMate_clipboardInstanceStruct;

#endif                                 /*typedef_SFc3_CheckMate_clipboardInstanceStruct*/

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern const mxArray *sf_c3_CheckMate_clipboard_get_eml_resolved_functions_info
  (void);

/* Function Definitions */
extern void sf_c3_CheckMate_clipboard_get_check_sum(mxArray *plhs[]);
extern void c3_CheckMate_clipboard_method_dispatcher(SimStruct *S, int_T method,
  void *data);

#endif
