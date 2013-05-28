/* Include files */

#include <stddef.h>
#include "blas.h"
#include "CheckMate_clipboard_sfun.h"
#include "c1_CheckMate_clipboard.h"
#define CHARTINSTANCE_CHARTNUMBER      (chartInstance->chartNumber)
#define CHARTINSTANCE_INSTANCENUMBER   (chartInstance->instanceNumber)
#include "CheckMate_clipboard_sfun_debug_macros.h"
#define _SF_MEX_LISTEN_FOR_CTRL_C(S)   sf_mex_listen_for_ctrl_c(sfGlobalDebugInstanceStruct,S);

/* Type Definitions */

/* Named Constants */
#define c1_event_gear1to2              (0)
#define c1_event_gear2to1              (1)
#define c1_event_gear2to3              (2)
#define c1_event_gear3to2              (3)
#define c1_event_gear3to4              (4)
#define c1_event_gear4to3              (5)
#define c1_event_cc_to_acc             (6)
#define c1_event_acc_to_cc             (7)
#define c1_event_collide               (8)
#define c1_event_start                 (9)
#define CALL_EVENT                     (-1)
#define c1_IN_NO_ACTIVE_CHILD          ((uint8_T)0U)
#define c1_IN_ACC_1                    ((uint8_T)1U)
#define c1_IN_ACC_2                    ((uint8_T)2U)
#define c1_IN_ACC_3                    ((uint8_T)3U)
#define c1_IN_ACC_4                    ((uint8_T)4U)
#define c1_IN_CC_1                     ((uint8_T)5U)
#define c1_IN_CC_2                     ((uint8_T)6U)
#define c1_IN_CC_3                     ((uint8_T)7U)
#define c1_IN_CC_4                     ((uint8_T)8U)
#define c1_IN_avoid_error              ((uint8_T)9U)

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
static void initialize_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void initialize_params_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void enable_c1_CheckMate_clipboard(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance);
static void disable_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void c1_update_debugger_state_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static const mxArray *get_sim_state_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void set_sim_state_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance, const mxArray *c1_st);
static void c1_set_sim_state_side_effects_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void finalize_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void sf_c1_CheckMate_clipboard(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance);
static void c1_chartstep_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void initSimStructsc1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void registerMessagesc1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void c1_ACC_1(SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void c1_ACC_2(SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void c1_ACC_3(SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void c1_ACC_4(SFc1_CheckMate_clipboardInstanceStruct *chartInstance);
static void init_script_number_translation(uint32_T c1_machineNumber, uint32_T
  c1_chartNumber);
static const mxArray *c1_sf_marshallOut(void *chartInstanceVoid, void *c1_inData);
static real_T c1_emlrt_marshallIn(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance, const mxArray *c1_gear1to2, const char_T *c1_identifier);
static real_T c1_b_emlrt_marshallIn(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void c1_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static const mxArray *c1_b_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static int32_T c1_c_emlrt_marshallIn(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void c1_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static const mxArray *c1_c_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static uint8_T c1_d_emlrt_marshallIn(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance, const mxArray *c1_b_tp_ACC_1, const char_T *c1_identifier);
static uint8_T c1_e_emlrt_marshallIn(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void c1_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static const mxArray *c1_f_emlrt_marshallIn
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance, const mxArray
   *c1_b_setSimStateSideEffectsInfo, const char_T *c1_identifier);
static const mxArray *c1_g_emlrt_marshallIn
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance, const mxArray *c1_u,
   const emlrtMsgIdentifier *c1_parentId);
static void init_dsm_address_info(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance);

/* Function Definitions */
static void initialize_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
  real_T *c1_q;
  c1_q = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  chartInstance->c1_doSetSimStateSideEffects = 0U;
  chartInstance->c1_setSimStateSideEffectsInfo = NULL;
  chartInstance->c1_tp_ACC_1 = 0U;
  chartInstance->c1_tp_ACC_2 = 0U;
  chartInstance->c1_tp_ACC_3 = 0U;
  chartInstance->c1_tp_ACC_4 = 0U;
  chartInstance->c1_tp_CC_1 = 0U;
  chartInstance->c1_tp_CC_2 = 0U;
  chartInstance->c1_tp_CC_3 = 0U;
  chartInstance->c1_tp_CC_4 = 0U;
  chartInstance->c1_tp_avoid_error = 0U;
  chartInstance->c1_is_active_c1_CheckMate_clipboard = 0U;
  chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_NO_ACTIVE_CHILD;
  if (!(cdrGetOutputPortReusable(chartInstance->S, 1) != 0)) {
    *c1_q = 0.0;
  }
}

static void initialize_params_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
}

static void enable_c1_CheckMate_clipboard(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void disable_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void c1_update_debugger_state_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
  uint32_T c1_prevAniVal;
  c1_prevAniVal = _SFD_GET_ANIMATION();
  _SFD_SET_ANIMATION(0U);
  _SFD_SET_HONOR_BREAKPOINTS(0U);
  if (chartInstance->c1_is_active_c1_CheckMate_clipboard == 1U) {
    _SFD_CC_CALL(CHART_ACTIVE_TAG, 0U, chartInstance->c1_sfEvent);
  }

  if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_ACC_1) {
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 0U, chartInstance->c1_sfEvent);
  } else {
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 0U, chartInstance->c1_sfEvent);
  }

  if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_CC_1) {
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 4U, chartInstance->c1_sfEvent);
  } else {
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 4U, chartInstance->c1_sfEvent);
  }

  if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_CC_2) {
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 5U, chartInstance->c1_sfEvent);
  } else {
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 5U, chartInstance->c1_sfEvent);
  }

  if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_ACC_2) {
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 1U, chartInstance->c1_sfEvent);
  } else {
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 1U, chartInstance->c1_sfEvent);
  }

  if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_avoid_error) {
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 8U, chartInstance->c1_sfEvent);
  } else {
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 8U, chartInstance->c1_sfEvent);
  }

  if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_CC_3) {
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 6U, chartInstance->c1_sfEvent);
  } else {
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 6U, chartInstance->c1_sfEvent);
  }

  if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_ACC_3) {
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 2U, chartInstance->c1_sfEvent);
  } else {
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 2U, chartInstance->c1_sfEvent);
  }

  if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_ACC_4) {
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 3U, chartInstance->c1_sfEvent);
  } else {
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 3U, chartInstance->c1_sfEvent);
  }

  if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_CC_4) {
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 7U, chartInstance->c1_sfEvent);
  } else {
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 7U, chartInstance->c1_sfEvent);
  }

  _SFD_SET_ANIMATION(c1_prevAniVal);
  _SFD_SET_HONOR_BREAKPOINTS(1U);
  _SFD_ANIMATE();
}

static const mxArray *get_sim_state_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
  const mxArray *c1_st;
  const mxArray *c1_y = NULL;
  real_T c1_hoistedGlobal;
  real_T c1_u;
  const mxArray *c1_b_y = NULL;
  uint8_T c1_b_hoistedGlobal;
  uint8_T c1_b_u;
  const mxArray *c1_c_y = NULL;
  uint8_T c1_c_hoistedGlobal;
  uint8_T c1_c_u;
  const mxArray *c1_d_y = NULL;
  real_T *c1_q;
  c1_q = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  c1_st = NULL;
  c1_st = NULL;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_createcellarray(3), FALSE);
  c1_hoistedGlobal = *c1_q;
  c1_u = c1_hoistedGlobal;
  c1_b_y = NULL;
  sf_mex_assign(&c1_b_y, sf_mex_create("y", &c1_u, 0, 0U, 0U, 0U, 0), FALSE);
  sf_mex_setcell(c1_y, 0, c1_b_y);
  c1_b_hoistedGlobal = chartInstance->c1_is_active_c1_CheckMate_clipboard;
  c1_b_u = c1_b_hoistedGlobal;
  c1_c_y = NULL;
  sf_mex_assign(&c1_c_y, sf_mex_create("y", &c1_b_u, 3, 0U, 0U, 0U, 0), FALSE);
  sf_mex_setcell(c1_y, 1, c1_c_y);
  c1_c_hoistedGlobal = chartInstance->c1_is_c1_CheckMate_clipboard;
  c1_c_u = c1_c_hoistedGlobal;
  c1_d_y = NULL;
  sf_mex_assign(&c1_d_y, sf_mex_create("y", &c1_c_u, 3, 0U, 0U, 0U, 0), FALSE);
  sf_mex_setcell(c1_y, 2, c1_d_y);
  sf_mex_assign(&c1_st, c1_y, FALSE);
  return c1_st;
}

static void set_sim_state_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance, const mxArray *c1_st)
{
  const mxArray *c1_u;
  real_T *c1_q;
  c1_q = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  c1_u = sf_mex_dup(c1_st);
  *c1_q = c1_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 0)),
    "q");
  chartInstance->c1_is_active_c1_CheckMate_clipboard = c1_d_emlrt_marshallIn
    (chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 1)),
     "is_active_c1_CheckMate_clipboard");
  chartInstance->c1_is_c1_CheckMate_clipboard = c1_d_emlrt_marshallIn
    (chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 2)),
     "is_c1_CheckMate_clipboard");
  sf_mex_assign(&chartInstance->c1_setSimStateSideEffectsInfo,
                c1_f_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell
    (c1_u, 3)), "setSimStateSideEffectsInfo"), TRUE);
  sf_mex_destroy(&c1_u);
  chartInstance->c1_doSetSimStateSideEffects = 1U;
  c1_update_debugger_state_c1_CheckMate_clipboard(chartInstance);
  sf_mex_destroy(&c1_st);
}

static void c1_set_sim_state_side_effects_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
  if (chartInstance->c1_doSetSimStateSideEffects != 0) {
    if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_ACC_1) {
      chartInstance->c1_tp_ACC_1 = 1U;
    } else {
      chartInstance->c1_tp_ACC_1 = 0U;
    }

    if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_ACC_2) {
      chartInstance->c1_tp_ACC_2 = 1U;
    } else {
      chartInstance->c1_tp_ACC_2 = 0U;
    }

    if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_ACC_3) {
      chartInstance->c1_tp_ACC_3 = 1U;
    } else {
      chartInstance->c1_tp_ACC_3 = 0U;
    }

    if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_ACC_4) {
      chartInstance->c1_tp_ACC_4 = 1U;
    } else {
      chartInstance->c1_tp_ACC_4 = 0U;
    }

    if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_CC_1) {
      chartInstance->c1_tp_CC_1 = 1U;
    } else {
      chartInstance->c1_tp_CC_1 = 0U;
    }

    if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_CC_2) {
      chartInstance->c1_tp_CC_2 = 1U;
    } else {
      chartInstance->c1_tp_CC_2 = 0U;
    }

    if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_CC_3) {
      chartInstance->c1_tp_CC_3 = 1U;
    } else {
      chartInstance->c1_tp_CC_3 = 0U;
    }

    if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_CC_4) {
      chartInstance->c1_tp_CC_4 = 1U;
    } else {
      chartInstance->c1_tp_CC_4 = 0U;
    }

    if (chartInstance->c1_is_c1_CheckMate_clipboard == c1_IN_avoid_error) {
      chartInstance->c1_tp_avoid_error = 1U;
    } else {
      chartInstance->c1_tp_avoid_error = 0U;
    }

    chartInstance->c1_doSetSimStateSideEffects = 0U;
  }
}

static void finalize_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
  sf_mex_destroy(&chartInstance->c1_setSimStateSideEffectsInfo);
}

static void sf_c1_CheckMate_clipboard(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance)
{
  real_T *c1_q;
  real_T *c1_gear1to2;
  real_T *c1_gear2to1;
  real_T *c1_gear2to3;
  real_T *c1_gear3to2;
  real_T *c1_gear3to4;
  real_T *c1_gear4to3;
  real_T *c1_cc_to_acc;
  real_T *c1_acc_to_cc;
  real_T *c1_collide;
  real_T *c1_start;
  c1_start = (real_T *)*(ssGetInputPortSignalPtrs(chartInstance->S, 0) + 9);
  c1_collide = (real_T *)*(ssGetInputPortSignalPtrs(chartInstance->S, 0) + 8);
  c1_acc_to_cc = (real_T *)*(ssGetInputPortSignalPtrs(chartInstance->S, 0) + 7);
  c1_cc_to_acc = (real_T *)*(ssGetInputPortSignalPtrs(chartInstance->S, 0) + 6);
  c1_gear4to3 = (real_T *)*(ssGetInputPortSignalPtrs(chartInstance->S, 0) + 5);
  c1_gear3to4 = (real_T *)*(ssGetInputPortSignalPtrs(chartInstance->S, 0) + 4);
  c1_gear3to2 = (real_T *)*(ssGetInputPortSignalPtrs(chartInstance->S, 0) + 3);
  c1_gear2to3 = (real_T *)*(ssGetInputPortSignalPtrs(chartInstance->S, 0) + 2);
  c1_gear2to1 = (real_T *)*(ssGetInputPortSignalPtrs(chartInstance->S, 0) + 1);
  c1_gear1to2 = (real_T *)*(ssGetInputPortSignalPtrs(chartInstance->S, 0) + 0);
  c1_q = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  c1_set_sim_state_side_effects_c1_CheckMate_clipboard(chartInstance);
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
  _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
  if (*c1_gear1to2 == 1.0) {
    chartInstance->c1_sfEvent = c1_event_gear1to2;
    _SFD_CE_CALL(EVENT_BEFORE_BROADCAST_TAG, c1_event_gear1to2,
                 chartInstance->c1_sfEvent);
    c1_chartstep_c1_CheckMate_clipboard(chartInstance);
    _SFD_CE_CALL(EVENT_AFTER_BROADCAST_TAG, c1_event_gear1to2,
                 chartInstance->c1_sfEvent);
  }

  if (*c1_gear2to1 == 1.0) {
    chartInstance->c1_sfEvent = c1_event_gear2to1;
    _SFD_CE_CALL(EVENT_BEFORE_BROADCAST_TAG, c1_event_gear2to1,
                 chartInstance->c1_sfEvent);
    c1_chartstep_c1_CheckMate_clipboard(chartInstance);
    _SFD_CE_CALL(EVENT_AFTER_BROADCAST_TAG, c1_event_gear2to1,
                 chartInstance->c1_sfEvent);
  }

  if (*c1_gear2to3 == 1.0) {
    chartInstance->c1_sfEvent = c1_event_gear2to3;
    _SFD_CE_CALL(EVENT_BEFORE_BROADCAST_TAG, c1_event_gear2to3,
                 chartInstance->c1_sfEvent);
    c1_chartstep_c1_CheckMate_clipboard(chartInstance);
    _SFD_CE_CALL(EVENT_AFTER_BROADCAST_TAG, c1_event_gear2to3,
                 chartInstance->c1_sfEvent);
  }

  if (*c1_gear3to2 == 1.0) {
    chartInstance->c1_sfEvent = c1_event_gear3to2;
    _SFD_CE_CALL(EVENT_BEFORE_BROADCAST_TAG, c1_event_gear3to2,
                 chartInstance->c1_sfEvent);
    c1_chartstep_c1_CheckMate_clipboard(chartInstance);
    _SFD_CE_CALL(EVENT_AFTER_BROADCAST_TAG, c1_event_gear3to2,
                 chartInstance->c1_sfEvent);
  }

  if (*c1_gear3to4 == 1.0) {
    chartInstance->c1_sfEvent = c1_event_gear3to4;
    _SFD_CE_CALL(EVENT_BEFORE_BROADCAST_TAG, c1_event_gear3to4,
                 chartInstance->c1_sfEvent);
    c1_chartstep_c1_CheckMate_clipboard(chartInstance);
    _SFD_CE_CALL(EVENT_AFTER_BROADCAST_TAG, c1_event_gear3to4,
                 chartInstance->c1_sfEvent);
  }

  if (*c1_gear4to3 == 1.0) {
    chartInstance->c1_sfEvent = c1_event_gear4to3;
    _SFD_CE_CALL(EVENT_BEFORE_BROADCAST_TAG, c1_event_gear4to3,
                 chartInstance->c1_sfEvent);
    c1_chartstep_c1_CheckMate_clipboard(chartInstance);
    _SFD_CE_CALL(EVENT_AFTER_BROADCAST_TAG, c1_event_gear4to3,
                 chartInstance->c1_sfEvent);
  }

  if (*c1_cc_to_acc == 1.0) {
    chartInstance->c1_sfEvent = c1_event_cc_to_acc;
    _SFD_CE_CALL(EVENT_BEFORE_BROADCAST_TAG, c1_event_cc_to_acc,
                 chartInstance->c1_sfEvent);
    c1_chartstep_c1_CheckMate_clipboard(chartInstance);
    _SFD_CE_CALL(EVENT_AFTER_BROADCAST_TAG, c1_event_cc_to_acc,
                 chartInstance->c1_sfEvent);
  }

  if (*c1_acc_to_cc == 1.0) {
    chartInstance->c1_sfEvent = c1_event_acc_to_cc;
    _SFD_CE_CALL(EVENT_BEFORE_BROADCAST_TAG, c1_event_acc_to_cc,
                 chartInstance->c1_sfEvent);
    c1_chartstep_c1_CheckMate_clipboard(chartInstance);
    _SFD_CE_CALL(EVENT_AFTER_BROADCAST_TAG, c1_event_acc_to_cc,
                 chartInstance->c1_sfEvent);
  }

  if (*c1_collide == 1.0) {
    chartInstance->c1_sfEvent = c1_event_collide;
    _SFD_CE_CALL(EVENT_BEFORE_BROADCAST_TAG, c1_event_collide,
                 chartInstance->c1_sfEvent);
    c1_chartstep_c1_CheckMate_clipboard(chartInstance);
    _SFD_CE_CALL(EVENT_AFTER_BROADCAST_TAG, c1_event_collide,
                 chartInstance->c1_sfEvent);
  }

  if (*c1_start == 1.0) {
    chartInstance->c1_sfEvent = c1_event_start;
    _SFD_CE_CALL(EVENT_BEFORE_BROADCAST_TAG, c1_event_start,
                 chartInstance->c1_sfEvent);
    c1_chartstep_c1_CheckMate_clipboard(chartInstance);
    _SFD_CE_CALL(EVENT_AFTER_BROADCAST_TAG, c1_event_start,
                 chartInstance->c1_sfEvent);
  }

  _SFD_CHECK_FOR_STATE_INCONSISTENCY(_CheckMate_clipboardMachineNumber_,
    chartInstance->chartNumber, chartInstance->instanceNumber);
}

static void c1_chartstep_c1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
  boolean_T c1_out;
  boolean_T c1_b_out;
  boolean_T c1_c_out;
  boolean_T c1_d_out;
  boolean_T c1_e_out;
  boolean_T c1_f_out;
  boolean_T c1_g_out;
  boolean_T c1_h_out;
  boolean_T c1_i_out;
  boolean_T c1_j_out;
  boolean_T c1_k_out;
  boolean_T c1_l_out;
  boolean_T c1_m_out;
  boolean_T c1_n_out;
  boolean_T c1_o_out;
  boolean_T c1_p_out;
  boolean_T c1_q_out;
  boolean_T c1_r_out;
  boolean_T c1_s_out;
  real_T *c1_q;
  c1_q = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
  if (chartInstance->c1_is_active_c1_CheckMate_clipboard == 0U) {
    _SFD_CC_CALL(CHART_ENTER_ENTRY_FUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
    chartInstance->c1_is_active_c1_CheckMate_clipboard = 1U;
    _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
    _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 20U,
                 chartInstance->c1_sfEvent);
    c1_out = (CV_TRANSITION_EVAL(20U, (int32_T)_SFD_CCP_CALL(20U, 0,
                chartInstance->c1_sfEvent == c1_event_start != 0U,
                chartInstance->c1_sfEvent)) != 0);
    if (c1_out) {
      _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 20U, chartInstance->c1_sfEvent);
      chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_CC_1;
      _SFD_CS_CALL(STATE_ACTIVE_TAG, 4U, chartInstance->c1_sfEvent);
      chartInstance->c1_tp_CC_1 = 1U;
      *c1_q = 1.0;
      _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
    }
  } else {
    switch (chartInstance->c1_is_c1_CheckMate_clipboard) {
     case c1_IN_ACC_1:
      CV_CHART_EVAL(0, 0, 1);
      c1_ACC_1(chartInstance);
      break;

     case c1_IN_ACC_2:
      CV_CHART_EVAL(0, 0, 2);
      c1_ACC_2(chartInstance);
      break;

     case c1_IN_ACC_3:
      CV_CHART_EVAL(0, 0, 3);
      c1_ACC_3(chartInstance);
      break;

     case c1_IN_ACC_4:
      CV_CHART_EVAL(0, 0, 4);
      c1_ACC_4(chartInstance);
      break;

     case c1_IN_CC_1:
      CV_CHART_EVAL(0, 0, 5);
      _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 12U,
                   chartInstance->c1_sfEvent);
      c1_b_out = (CV_TRANSITION_EVAL(12U, (int32_T)_SFD_CCP_CALL(12U, 0,
        chartInstance->c1_sfEvent == c1_event_cc_to_acc != 0U,
        chartInstance->c1_sfEvent)) != 0);
      if (c1_b_out) {
        if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
          unsigned int transitionList[2];
          unsigned int numTransitions = 1;
          transitionList[0] = 12;
          _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
          c1_c_out = (chartInstance->c1_sfEvent == c1_event_gear1to2);
          if (c1_c_out) {
            transitionList[numTransitions] = 0;
            numTransitions++;
          }

          _SFD_TRANSITION_CONFLICT_CHECK_END();
          if (numTransitions > 1) {
            _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
          }
        }

        _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 12U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_CC_1 = 0U;
        _SFD_CS_CALL(STATE_INACTIVE_TAG, 4U, chartInstance->c1_sfEvent);
        chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_ACC_1;
        _SFD_CS_CALL(STATE_ACTIVE_TAG, 0U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_ACC_1 = 1U;
        *c1_q = 5.0;
        _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
      } else {
        _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 0U,
                     chartInstance->c1_sfEvent);
        c1_d_out = (CV_TRANSITION_EVAL(0U, (int32_T)_SFD_CCP_CALL(0U, 0,
          chartInstance->c1_sfEvent == c1_event_gear1to2 != 0U,
          chartInstance->c1_sfEvent)) != 0);
        if (c1_d_out) {
          _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 0U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_CC_1 = 0U;
          _SFD_CS_CALL(STATE_INACTIVE_TAG, 4U, chartInstance->c1_sfEvent);
          chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_CC_2;
          _SFD_CS_CALL(STATE_ACTIVE_TAG, 5U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_CC_2 = 1U;
          *c1_q = 2.0;
          _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
        } else {
          _SFD_CS_CALL(STATE_ENTER_DURING_FUNCTION_TAG, 4U,
                       chartInstance->c1_sfEvent);
        }
      }

      _SFD_CS_CALL(EXIT_OUT_OF_FUNCTION_TAG, 4U, chartInstance->c1_sfEvent);
      break;

     case c1_IN_CC_2:
      CV_CHART_EVAL(0, 0, 6);
      _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 1U,
                   chartInstance->c1_sfEvent);
      c1_e_out = (CV_TRANSITION_EVAL(1U, (int32_T)_SFD_CCP_CALL(1U, 0,
        chartInstance->c1_sfEvent == c1_event_gear2to1 != 0U,
        chartInstance->c1_sfEvent)) != 0);
      if (c1_e_out) {
        if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
          unsigned int transitionList[3];
          unsigned int numTransitions = 1;
          transitionList[0] = 1;
          _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
          c1_f_out = (chartInstance->c1_sfEvent == c1_event_cc_to_acc);
          if (c1_f_out) {
            transitionList[numTransitions] = 13;
            numTransitions++;
          }

          c1_g_out = (chartInstance->c1_sfEvent == c1_event_gear2to3);
          if (c1_g_out) {
            transitionList[numTransitions] = 4;
            numTransitions++;
          }

          _SFD_TRANSITION_CONFLICT_CHECK_END();
          if (numTransitions > 1) {
            _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
          }
        }

        _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 1U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_CC_2 = 0U;
        _SFD_CS_CALL(STATE_INACTIVE_TAG, 5U, chartInstance->c1_sfEvent);
        chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_CC_1;
        _SFD_CS_CALL(STATE_ACTIVE_TAG, 4U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_CC_1 = 1U;
        *c1_q = 1.0;
        _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
      } else {
        _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 13U,
                     chartInstance->c1_sfEvent);
        c1_h_out = (CV_TRANSITION_EVAL(13U, (int32_T)_SFD_CCP_CALL(13U, 0,
          chartInstance->c1_sfEvent == c1_event_cc_to_acc != 0U,
          chartInstance->c1_sfEvent)) != 0);
        if (c1_h_out) {
          if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
            unsigned int transitionList[2];
            unsigned int numTransitions = 1;
            transitionList[0] = 13;
            _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
            c1_i_out = (chartInstance->c1_sfEvent == c1_event_gear2to3);
            if (c1_i_out) {
              transitionList[numTransitions] = 4;
              numTransitions++;
            }

            _SFD_TRANSITION_CONFLICT_CHECK_END();
            if (numTransitions > 1) {
              _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
            }
          }

          _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 13U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_CC_2 = 0U;
          _SFD_CS_CALL(STATE_INACTIVE_TAG, 5U, chartInstance->c1_sfEvent);
          chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_ACC_2;
          _SFD_CS_CALL(STATE_ACTIVE_TAG, 1U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_ACC_2 = 1U;
          *c1_q = 6.0;
          _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
        } else {
          _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 4U,
                       chartInstance->c1_sfEvent);
          c1_j_out = (CV_TRANSITION_EVAL(4U, (int32_T)_SFD_CCP_CALL(4U, 0,
            chartInstance->c1_sfEvent == c1_event_gear2to3 != 0U,
            chartInstance->c1_sfEvent)) != 0);
          if (c1_j_out) {
            _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 4U, chartInstance->c1_sfEvent);
            chartInstance->c1_tp_CC_2 = 0U;
            _SFD_CS_CALL(STATE_INACTIVE_TAG, 5U, chartInstance->c1_sfEvent);
            chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_CC_3;
            _SFD_CS_CALL(STATE_ACTIVE_TAG, 6U, chartInstance->c1_sfEvent);
            chartInstance->c1_tp_CC_3 = 1U;
            *c1_q = 3.0;
            _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
          } else {
            _SFD_CS_CALL(STATE_ENTER_DURING_FUNCTION_TAG, 5U,
                         chartInstance->c1_sfEvent);
          }
        }
      }

      _SFD_CS_CALL(EXIT_OUT_OF_FUNCTION_TAG, 5U, chartInstance->c1_sfEvent);
      break;

     case c1_IN_CC_3:
      CV_CHART_EVAL(0, 0, 7);
      _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 5U,
                   chartInstance->c1_sfEvent);
      c1_k_out = (CV_TRANSITION_EVAL(5U, (int32_T)_SFD_CCP_CALL(5U, 0,
        chartInstance->c1_sfEvent == c1_event_gear3to2 != 0U,
        chartInstance->c1_sfEvent)) != 0);
      if (c1_k_out) {
        if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
          unsigned int transitionList[3];
          unsigned int numTransitions = 1;
          transitionList[0] = 5;
          _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
          c1_l_out = (chartInstance->c1_sfEvent == c1_event_cc_to_acc);
          if (c1_l_out) {
            transitionList[numTransitions] = 14;
            numTransitions++;
          }

          c1_m_out = (chartInstance->c1_sfEvent == c1_event_gear3to4);
          if (c1_m_out) {
            transitionList[numTransitions] = 6;
            numTransitions++;
          }

          _SFD_TRANSITION_CONFLICT_CHECK_END();
          if (numTransitions > 1) {
            _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
          }
        }

        _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 5U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_CC_3 = 0U;
        _SFD_CS_CALL(STATE_INACTIVE_TAG, 6U, chartInstance->c1_sfEvent);
        chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_CC_2;
        _SFD_CS_CALL(STATE_ACTIVE_TAG, 5U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_CC_2 = 1U;
        *c1_q = 2.0;
        _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
      } else {
        _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 14U,
                     chartInstance->c1_sfEvent);
        c1_n_out = (CV_TRANSITION_EVAL(14U, (int32_T)_SFD_CCP_CALL(14U, 0,
          chartInstance->c1_sfEvent == c1_event_cc_to_acc != 0U,
          chartInstance->c1_sfEvent)) != 0);
        if (c1_n_out) {
          if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
            unsigned int transitionList[2];
            unsigned int numTransitions = 1;
            transitionList[0] = 14;
            _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
            c1_o_out = (chartInstance->c1_sfEvent == c1_event_gear3to4);
            if (c1_o_out) {
              transitionList[numTransitions] = 6;
              numTransitions++;
            }

            _SFD_TRANSITION_CONFLICT_CHECK_END();
            if (numTransitions > 1) {
              _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
            }
          }

          _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 14U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_CC_3 = 0U;
          _SFD_CS_CALL(STATE_INACTIVE_TAG, 6U, chartInstance->c1_sfEvent);
          chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_ACC_3;
          _SFD_CS_CALL(STATE_ACTIVE_TAG, 2U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_ACC_3 = 1U;
          *c1_q = 7.0;
          _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
        } else {
          _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 6U,
                       chartInstance->c1_sfEvent);
          c1_p_out = (CV_TRANSITION_EVAL(6U, (int32_T)_SFD_CCP_CALL(6U, 0,
            chartInstance->c1_sfEvent == c1_event_gear3to4 != 0U,
            chartInstance->c1_sfEvent)) != 0);
          if (c1_p_out) {
            _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 6U, chartInstance->c1_sfEvent);
            chartInstance->c1_tp_CC_3 = 0U;
            _SFD_CS_CALL(STATE_INACTIVE_TAG, 6U, chartInstance->c1_sfEvent);
            chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_CC_4;
            _SFD_CS_CALL(STATE_ACTIVE_TAG, 7U, chartInstance->c1_sfEvent);
            chartInstance->c1_tp_CC_4 = 1U;
            *c1_q = 4.0;
            _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
          } else {
            _SFD_CS_CALL(STATE_ENTER_DURING_FUNCTION_TAG, 6U,
                         chartInstance->c1_sfEvent);
          }
        }
      }

      _SFD_CS_CALL(EXIT_OUT_OF_FUNCTION_TAG, 6U, chartInstance->c1_sfEvent);
      break;

     case c1_IN_CC_4:
      CV_CHART_EVAL(0, 0, 8);
      _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 7U,
                   chartInstance->c1_sfEvent);
      c1_q_out = (CV_TRANSITION_EVAL(7U, (int32_T)_SFD_CCP_CALL(7U, 0,
        chartInstance->c1_sfEvent == c1_event_gear4to3 != 0U,
        chartInstance->c1_sfEvent)) != 0);
      if (c1_q_out) {
        if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
          unsigned int transitionList[2];
          unsigned int numTransitions = 1;
          transitionList[0] = 7;
          _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
          c1_r_out = (chartInstance->c1_sfEvent == c1_event_cc_to_acc);
          if (c1_r_out) {
            transitionList[numTransitions] = 15;
            numTransitions++;
          }

          _SFD_TRANSITION_CONFLICT_CHECK_END();
          if (numTransitions > 1) {
            _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
          }
        }

        _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 7U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_CC_4 = 0U;
        _SFD_CS_CALL(STATE_INACTIVE_TAG, 7U, chartInstance->c1_sfEvent);
        chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_CC_3;
        _SFD_CS_CALL(STATE_ACTIVE_TAG, 6U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_CC_3 = 1U;
        *c1_q = 3.0;
        _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
      } else {
        _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 15U,
                     chartInstance->c1_sfEvent);
        c1_s_out = (CV_TRANSITION_EVAL(15U, (int32_T)_SFD_CCP_CALL(15U, 0,
          chartInstance->c1_sfEvent == c1_event_cc_to_acc != 0U,
          chartInstance->c1_sfEvent)) != 0);
        if (c1_s_out) {
          _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 15U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_CC_4 = 0U;
          _SFD_CS_CALL(STATE_INACTIVE_TAG, 7U, chartInstance->c1_sfEvent);
          chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_ACC_4;
          _SFD_CS_CALL(STATE_ACTIVE_TAG, 3U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_ACC_4 = 1U;
          *c1_q = 8.0;
          _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
        } else {
          _SFD_CS_CALL(STATE_ENTER_DURING_FUNCTION_TAG, 7U,
                       chartInstance->c1_sfEvent);
        }
      }

      _SFD_CS_CALL(EXIT_OUT_OF_FUNCTION_TAG, 7U, chartInstance->c1_sfEvent);
      break;

     case c1_IN_avoid_error:
      CV_CHART_EVAL(0, 0, 9);
      _SFD_CS_CALL(STATE_ENTER_DURING_FUNCTION_TAG, 8U,
                   chartInstance->c1_sfEvent);
      _SFD_CS_CALL(EXIT_OUT_OF_FUNCTION_TAG, 8U, chartInstance->c1_sfEvent);
      break;

     default:
      CV_CHART_EVAL(0, 0, 0);
      chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_NO_ACTIVE_CHILD;
      _SFD_CS_CALL(STATE_INACTIVE_TAG, 0U, chartInstance->c1_sfEvent);
      break;
    }
  }

  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
}

static void initSimStructsc1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
}

static void registerMessagesc1_CheckMate_clipboard
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
}

static void c1_ACC_1(SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
  boolean_T c1_out;
  boolean_T c1_b_out;
  boolean_T c1_c_out;
  boolean_T c1_d_out;
  boolean_T c1_e_out;
  boolean_T c1_f_out;
  real_T *c1_q;
  c1_q = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 16U, chartInstance->c1_sfEvent);
  c1_out = (CV_TRANSITION_EVAL(16U, (int32_T)_SFD_CCP_CALL(16U, 0,
              chartInstance->c1_sfEvent == c1_event_collide != 0U,
              chartInstance->c1_sfEvent)) != 0);
  if (c1_out) {
    if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
      unsigned int transitionList[3];
      unsigned int numTransitions = 1;
      transitionList[0] = 16;
      _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
      c1_b_out = (chartInstance->c1_sfEvent == c1_event_gear1to2);
      if (c1_b_out) {
        transitionList[numTransitions] = 2;
        numTransitions++;
      }

      c1_c_out = (chartInstance->c1_sfEvent == c1_event_acc_to_cc);
      if (c1_c_out) {
        transitionList[numTransitions] = 21;
        numTransitions++;
      }

      _SFD_TRANSITION_CONFLICT_CHECK_END();
      if (numTransitions > 1) {
        _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
      }
    }

    _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 16U, chartInstance->c1_sfEvent);
    chartInstance->c1_tp_ACC_1 = 0U;
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 0U, chartInstance->c1_sfEvent);
    chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_avoid_error;
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 8U, chartInstance->c1_sfEvent);
    chartInstance->c1_tp_avoid_error = 1U;
    *c1_q = 9.0;
    _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
  } else {
    _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 2U, chartInstance->c1_sfEvent);
    c1_d_out = (CV_TRANSITION_EVAL(2U, (int32_T)_SFD_CCP_CALL(2U, 0,
      chartInstance->c1_sfEvent == c1_event_gear1to2 != 0U,
      chartInstance->c1_sfEvent)) != 0);
    if (c1_d_out) {
      if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
        unsigned int transitionList[2];
        unsigned int numTransitions = 1;
        transitionList[0] = 2;
        _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
        c1_e_out = (chartInstance->c1_sfEvent == c1_event_acc_to_cc);
        if (c1_e_out) {
          transitionList[numTransitions] = 21;
          numTransitions++;
        }

        _SFD_TRANSITION_CONFLICT_CHECK_END();
        if (numTransitions > 1) {
          _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
        }
      }

      _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 2U, chartInstance->c1_sfEvent);
      chartInstance->c1_tp_ACC_1 = 0U;
      _SFD_CS_CALL(STATE_INACTIVE_TAG, 0U, chartInstance->c1_sfEvent);
      chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_ACC_2;
      _SFD_CS_CALL(STATE_ACTIVE_TAG, 1U, chartInstance->c1_sfEvent);
      chartInstance->c1_tp_ACC_2 = 1U;
      *c1_q = 6.0;
      _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
    } else {
      _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 21U,
                   chartInstance->c1_sfEvent);
      c1_f_out = (CV_TRANSITION_EVAL(21U, (int32_T)_SFD_CCP_CALL(21U, 0,
        chartInstance->c1_sfEvent == c1_event_acc_to_cc != 0U,
        chartInstance->c1_sfEvent)) != 0);
      if (c1_f_out) {
        _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 21U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_ACC_1 = 0U;
        _SFD_CS_CALL(STATE_INACTIVE_TAG, 0U, chartInstance->c1_sfEvent);
        chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_CC_1;
        _SFD_CS_CALL(STATE_ACTIVE_TAG, 4U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_CC_1 = 1U;
        *c1_q = 1.0;
        _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
      } else {
        _SFD_CS_CALL(STATE_ENTER_DURING_FUNCTION_TAG, 0U,
                     chartInstance->c1_sfEvent);
      }
    }
  }

  _SFD_CS_CALL(EXIT_OUT_OF_FUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
}

static void c1_ACC_2(SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
  boolean_T c1_out;
  boolean_T c1_b_out;
  boolean_T c1_c_out;
  boolean_T c1_d_out;
  boolean_T c1_e_out;
  boolean_T c1_f_out;
  boolean_T c1_g_out;
  boolean_T c1_h_out;
  boolean_T c1_i_out;
  boolean_T c1_j_out;
  real_T *c1_q;
  c1_q = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 3U, chartInstance->c1_sfEvent);
  c1_out = (CV_TRANSITION_EVAL(3U, (int32_T)_SFD_CCP_CALL(3U, 0,
              chartInstance->c1_sfEvent == c1_event_gear2to1 != 0U,
              chartInstance->c1_sfEvent)) != 0);
  if (c1_out) {
    if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
      unsigned int transitionList[4];
      unsigned int numTransitions = 1;
      transitionList[0] = 3;
      _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
      c1_b_out = (chartInstance->c1_sfEvent == c1_event_collide);
      if (c1_b_out) {
        transitionList[numTransitions] = 17;
        numTransitions++;
      }

      c1_c_out = (chartInstance->c1_sfEvent == c1_event_gear2to3);
      if (c1_c_out) {
        transitionList[numTransitions] = 8;
        numTransitions++;
      }

      c1_d_out = (chartInstance->c1_sfEvent == c1_event_acc_to_cc);
      if (c1_d_out) {
        transitionList[numTransitions] = 22;
        numTransitions++;
      }

      _SFD_TRANSITION_CONFLICT_CHECK_END();
      if (numTransitions > 1) {
        _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
      }
    }

    _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 3U, chartInstance->c1_sfEvent);
    chartInstance->c1_tp_ACC_2 = 0U;
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 1U, chartInstance->c1_sfEvent);
    chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_ACC_1;
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 0U, chartInstance->c1_sfEvent);
    chartInstance->c1_tp_ACC_1 = 1U;
    *c1_q = 5.0;
    _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
  } else {
    _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 17U,
                 chartInstance->c1_sfEvent);
    c1_e_out = (CV_TRANSITION_EVAL(17U, (int32_T)_SFD_CCP_CALL(17U, 0,
      chartInstance->c1_sfEvent == c1_event_collide != 0U,
      chartInstance->c1_sfEvent)) != 0);
    if (c1_e_out) {
      if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
        unsigned int transitionList[3];
        unsigned int numTransitions = 1;
        transitionList[0] = 17;
        _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
        c1_f_out = (chartInstance->c1_sfEvent == c1_event_gear2to3);
        if (c1_f_out) {
          transitionList[numTransitions] = 8;
          numTransitions++;
        }

        c1_g_out = (chartInstance->c1_sfEvent == c1_event_acc_to_cc);
        if (c1_g_out) {
          transitionList[numTransitions] = 22;
          numTransitions++;
        }

        _SFD_TRANSITION_CONFLICT_CHECK_END();
        if (numTransitions > 1) {
          _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
        }
      }

      _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 17U, chartInstance->c1_sfEvent);
      chartInstance->c1_tp_ACC_2 = 0U;
      _SFD_CS_CALL(STATE_INACTIVE_TAG, 1U, chartInstance->c1_sfEvent);
      chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_avoid_error;
      _SFD_CS_CALL(STATE_ACTIVE_TAG, 8U, chartInstance->c1_sfEvent);
      chartInstance->c1_tp_avoid_error = 1U;
      *c1_q = 9.0;
      _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
    } else {
      _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 8U,
                   chartInstance->c1_sfEvent);
      c1_h_out = (CV_TRANSITION_EVAL(8U, (int32_T)_SFD_CCP_CALL(8U, 0,
        chartInstance->c1_sfEvent == c1_event_gear2to3 != 0U,
        chartInstance->c1_sfEvent)) != 0);
      if (c1_h_out) {
        if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
          unsigned int transitionList[2];
          unsigned int numTransitions = 1;
          transitionList[0] = 8;
          _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
          c1_i_out = (chartInstance->c1_sfEvent == c1_event_acc_to_cc);
          if (c1_i_out) {
            transitionList[numTransitions] = 22;
            numTransitions++;
          }

          _SFD_TRANSITION_CONFLICT_CHECK_END();
          if (numTransitions > 1) {
            _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
          }
        }

        _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 8U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_ACC_2 = 0U;
        _SFD_CS_CALL(STATE_INACTIVE_TAG, 1U, chartInstance->c1_sfEvent);
        chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_ACC_3;
        _SFD_CS_CALL(STATE_ACTIVE_TAG, 2U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_ACC_3 = 1U;
        *c1_q = 7.0;
        _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
      } else {
        _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 22U,
                     chartInstance->c1_sfEvent);
        c1_j_out = (CV_TRANSITION_EVAL(22U, (int32_T)_SFD_CCP_CALL(22U, 0,
          chartInstance->c1_sfEvent == c1_event_acc_to_cc != 0U,
          chartInstance->c1_sfEvent)) != 0);
        if (c1_j_out) {
          _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 22U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_ACC_2 = 0U;
          _SFD_CS_CALL(STATE_INACTIVE_TAG, 1U, chartInstance->c1_sfEvent);
          chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_CC_2;
          _SFD_CS_CALL(STATE_ACTIVE_TAG, 5U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_CC_2 = 1U;
          *c1_q = 2.0;
          _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
        } else {
          _SFD_CS_CALL(STATE_ENTER_DURING_FUNCTION_TAG, 1U,
                       chartInstance->c1_sfEvent);
        }
      }
    }
  }

  _SFD_CS_CALL(EXIT_OUT_OF_FUNCTION_TAG, 1U, chartInstance->c1_sfEvent);
}

static void c1_ACC_3(SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
  boolean_T c1_out;
  boolean_T c1_b_out;
  boolean_T c1_c_out;
  boolean_T c1_d_out;
  boolean_T c1_e_out;
  boolean_T c1_f_out;
  boolean_T c1_g_out;
  boolean_T c1_h_out;
  boolean_T c1_i_out;
  boolean_T c1_j_out;
  real_T *c1_q;
  c1_q = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 9U, chartInstance->c1_sfEvent);
  c1_out = (CV_TRANSITION_EVAL(9U, (int32_T)_SFD_CCP_CALL(9U, 0,
              chartInstance->c1_sfEvent == c1_event_gear3to2 != 0U,
              chartInstance->c1_sfEvent)) != 0);
  if (c1_out) {
    if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
      unsigned int transitionList[4];
      unsigned int numTransitions = 1;
      transitionList[0] = 9;
      _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
      c1_b_out = (chartInstance->c1_sfEvent == c1_event_collide);
      if (c1_b_out) {
        transitionList[numTransitions] = 18;
        numTransitions++;
      }

      c1_c_out = (chartInstance->c1_sfEvent == c1_event_gear3to4);
      if (c1_c_out) {
        transitionList[numTransitions] = 10;
        numTransitions++;
      }

      c1_d_out = (chartInstance->c1_sfEvent == c1_event_acc_to_cc);
      if (c1_d_out) {
        transitionList[numTransitions] = 23;
        numTransitions++;
      }

      _SFD_TRANSITION_CONFLICT_CHECK_END();
      if (numTransitions > 1) {
        _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
      }
    }

    _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 9U, chartInstance->c1_sfEvent);
    chartInstance->c1_tp_ACC_3 = 0U;
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 2U, chartInstance->c1_sfEvent);
    chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_ACC_2;
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 1U, chartInstance->c1_sfEvent);
    chartInstance->c1_tp_ACC_2 = 1U;
    *c1_q = 6.0;
    _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
  } else {
    _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 18U,
                 chartInstance->c1_sfEvent);
    c1_e_out = (CV_TRANSITION_EVAL(18U, (int32_T)_SFD_CCP_CALL(18U, 0,
      chartInstance->c1_sfEvent == c1_event_collide != 0U,
      chartInstance->c1_sfEvent)) != 0);
    if (c1_e_out) {
      if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
        unsigned int transitionList[3];
        unsigned int numTransitions = 1;
        transitionList[0] = 18;
        _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
        c1_f_out = (chartInstance->c1_sfEvent == c1_event_gear3to4);
        if (c1_f_out) {
          transitionList[numTransitions] = 10;
          numTransitions++;
        }

        c1_g_out = (chartInstance->c1_sfEvent == c1_event_acc_to_cc);
        if (c1_g_out) {
          transitionList[numTransitions] = 23;
          numTransitions++;
        }

        _SFD_TRANSITION_CONFLICT_CHECK_END();
        if (numTransitions > 1) {
          _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
        }
      }

      _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 18U, chartInstance->c1_sfEvent);
      chartInstance->c1_tp_ACC_3 = 0U;
      _SFD_CS_CALL(STATE_INACTIVE_TAG, 2U, chartInstance->c1_sfEvent);
      chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_avoid_error;
      _SFD_CS_CALL(STATE_ACTIVE_TAG, 8U, chartInstance->c1_sfEvent);
      chartInstance->c1_tp_avoid_error = 1U;
      *c1_q = 9.0;
      _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
    } else {
      _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 10U,
                   chartInstance->c1_sfEvent);
      c1_h_out = (CV_TRANSITION_EVAL(10U, (int32_T)_SFD_CCP_CALL(10U, 0,
        chartInstance->c1_sfEvent == c1_event_gear3to4 != 0U,
        chartInstance->c1_sfEvent)) != 0);
      if (c1_h_out) {
        if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
          unsigned int transitionList[2];
          unsigned int numTransitions = 1;
          transitionList[0] = 10;
          _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
          c1_i_out = (chartInstance->c1_sfEvent == c1_event_acc_to_cc);
          if (c1_i_out) {
            transitionList[numTransitions] = 23;
            numTransitions++;
          }

          _SFD_TRANSITION_CONFLICT_CHECK_END();
          if (numTransitions > 1) {
            _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
          }
        }

        _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 10U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_ACC_3 = 0U;
        _SFD_CS_CALL(STATE_INACTIVE_TAG, 2U, chartInstance->c1_sfEvent);
        chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_ACC_4;
        _SFD_CS_CALL(STATE_ACTIVE_TAG, 3U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_ACC_4 = 1U;
        *c1_q = 8.0;
        _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
      } else {
        _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 23U,
                     chartInstance->c1_sfEvent);
        c1_j_out = (CV_TRANSITION_EVAL(23U, (int32_T)_SFD_CCP_CALL(23U, 0,
          chartInstance->c1_sfEvent == c1_event_acc_to_cc != 0U,
          chartInstance->c1_sfEvent)) != 0);
        if (c1_j_out) {
          _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 23U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_ACC_3 = 0U;
          _SFD_CS_CALL(STATE_INACTIVE_TAG, 2U, chartInstance->c1_sfEvent);
          chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_CC_3;
          _SFD_CS_CALL(STATE_ACTIVE_TAG, 6U, chartInstance->c1_sfEvent);
          chartInstance->c1_tp_CC_3 = 1U;
          *c1_q = 3.0;
          _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
        } else {
          _SFD_CS_CALL(STATE_ENTER_DURING_FUNCTION_TAG, 2U,
                       chartInstance->c1_sfEvent);
        }
      }
    }
  }

  _SFD_CS_CALL(EXIT_OUT_OF_FUNCTION_TAG, 2U, chartInstance->c1_sfEvent);
}

static void c1_ACC_4(SFc1_CheckMate_clipboardInstanceStruct *chartInstance)
{
  boolean_T c1_out;
  boolean_T c1_b_out;
  boolean_T c1_c_out;
  boolean_T c1_d_out;
  boolean_T c1_e_out;
  boolean_T c1_f_out;
  real_T *c1_q;
  c1_q = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 11U, chartInstance->c1_sfEvent);
  c1_out = (CV_TRANSITION_EVAL(11U, (int32_T)_SFD_CCP_CALL(11U, 0,
              chartInstance->c1_sfEvent == c1_event_gear4to3 != 0U,
              chartInstance->c1_sfEvent)) != 0);
  if (c1_out) {
    if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
      unsigned int transitionList[3];
      unsigned int numTransitions = 1;
      transitionList[0] = 11;
      _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
      c1_b_out = (chartInstance->c1_sfEvent == c1_event_collide);
      if (c1_b_out) {
        transitionList[numTransitions] = 19;
        numTransitions++;
      }

      c1_c_out = (chartInstance->c1_sfEvent == c1_event_acc_to_cc);
      if (c1_c_out) {
        transitionList[numTransitions] = 24;
        numTransitions++;
      }

      _SFD_TRANSITION_CONFLICT_CHECK_END();
      if (numTransitions > 1) {
        _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
      }
    }

    _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 11U, chartInstance->c1_sfEvent);
    chartInstance->c1_tp_ACC_4 = 0U;
    _SFD_CS_CALL(STATE_INACTIVE_TAG, 3U, chartInstance->c1_sfEvent);
    chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_ACC_3;
    _SFD_CS_CALL(STATE_ACTIVE_TAG, 2U, chartInstance->c1_sfEvent);
    chartInstance->c1_tp_ACC_3 = 1U;
    *c1_q = 7.0;
    _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
  } else {
    _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 19U,
                 chartInstance->c1_sfEvent);
    c1_d_out = (CV_TRANSITION_EVAL(19U, (int32_T)_SFD_CCP_CALL(19U, 0,
      chartInstance->c1_sfEvent == c1_event_collide != 0U,
      chartInstance->c1_sfEvent)) != 0);
    if (c1_d_out) {
      if (_SFD_TRANSITION_CONFLICT_CHECK_ENABLED()) {
        unsigned int transitionList[2];
        unsigned int numTransitions = 1;
        transitionList[0] = 19;
        _SFD_TRANSITION_CONFLICT_CHECK_BEGIN();
        c1_e_out = (chartInstance->c1_sfEvent == c1_event_acc_to_cc);
        if (c1_e_out) {
          transitionList[numTransitions] = 24;
          numTransitions++;
        }

        _SFD_TRANSITION_CONFLICT_CHECK_END();
        if (numTransitions > 1) {
          _SFD_TRANSITION_CONFLICT(&(transitionList[0]),numTransitions);
        }
      }

      _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 19U, chartInstance->c1_sfEvent);
      chartInstance->c1_tp_ACC_4 = 0U;
      _SFD_CS_CALL(STATE_INACTIVE_TAG, 3U, chartInstance->c1_sfEvent);
      chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_avoid_error;
      _SFD_CS_CALL(STATE_ACTIVE_TAG, 8U, chartInstance->c1_sfEvent);
      chartInstance->c1_tp_avoid_error = 1U;
      *c1_q = 9.0;
      _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
    } else {
      _SFD_CT_CALL(TRANSITION_BEFORE_PROCESSING_TAG, 24U,
                   chartInstance->c1_sfEvent);
      c1_f_out = (CV_TRANSITION_EVAL(24U, (int32_T)_SFD_CCP_CALL(24U, 0,
        chartInstance->c1_sfEvent == c1_event_acc_to_cc != 0U,
        chartInstance->c1_sfEvent)) != 0);
      if (c1_f_out) {
        _SFD_CT_CALL(TRANSITION_ACTIVE_TAG, 24U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_ACC_4 = 0U;
        _SFD_CS_CALL(STATE_INACTIVE_TAG, 3U, chartInstance->c1_sfEvent);
        chartInstance->c1_is_c1_CheckMate_clipboard = c1_IN_CC_4;
        _SFD_CS_CALL(STATE_ACTIVE_TAG, 7U, chartInstance->c1_sfEvent);
        chartInstance->c1_tp_CC_4 = 1U;
        *c1_q = 4.0;
        _SFD_DATA_RANGE_CHECK(*c1_q, 0U);
      } else {
        _SFD_CS_CALL(STATE_ENTER_DURING_FUNCTION_TAG, 3U,
                     chartInstance->c1_sfEvent);
      }
    }
  }

  _SFD_CS_CALL(EXIT_OUT_OF_FUNCTION_TAG, 3U, chartInstance->c1_sfEvent);
}

static void init_script_number_translation(uint32_T c1_machineNumber, uint32_T
  c1_chartNumber)
{
}

const mxArray *sf_c1_CheckMate_clipboard_get_eml_resolved_functions_info(void)
{
  const mxArray *c1_nameCaptureInfo = NULL;
  c1_nameCaptureInfo = NULL;
  sf_mex_assign(&c1_nameCaptureInfo, sf_mex_create("nameCaptureInfo", NULL, 0,
    0U, 1U, 0U, 2, 0, 1), FALSE);
  return c1_nameCaptureInfo;
}

static const mxArray *c1_sf_marshallOut(void *chartInstanceVoid, void *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  real_T c1_u;
  const mxArray *c1_y = NULL;
  SFc1_CheckMate_clipboardInstanceStruct *chartInstance;
  chartInstance = (SFc1_CheckMate_clipboardInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_u = *(real_T *)c1_inData;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", &c1_u, 0, 0U, 0U, 0U, 0), FALSE);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, FALSE);
  return c1_mxArrayOutData;
}

static real_T c1_emlrt_marshallIn(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance, const mxArray *c1_gear1to2, const char_T *c1_identifier)
{
  real_T c1_y;
  emlrtMsgIdentifier c1_thisId;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_y = c1_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_gear1to2),
    &c1_thisId);
  sf_mex_destroy(&c1_gear1to2);
  return c1_y;
}

static real_T c1_b_emlrt_marshallIn(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  real_T c1_y;
  real_T c1_d0;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_d0, 1, 0, 0U, 0, 0U, 0);
  c1_y = c1_d0;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void c1_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_gear1to2;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y;
  SFc1_CheckMate_clipboardInstanceStruct *chartInstance;
  chartInstance = (SFc1_CheckMate_clipboardInstanceStruct *)chartInstanceVoid;
  c1_gear1to2 = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_y = c1_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_gear1to2),
    &c1_thisId);
  sf_mex_destroy(&c1_gear1to2);
  *(real_T *)c1_outData = c1_y;
  sf_mex_destroy(&c1_mxArrayInData);
}

static const mxArray *c1_b_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  int32_T c1_u;
  const mxArray *c1_y = NULL;
  SFc1_CheckMate_clipboardInstanceStruct *chartInstance;
  chartInstance = (SFc1_CheckMate_clipboardInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_u = *(int32_T *)c1_inData;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", &c1_u, 6, 0U, 0U, 0U, 0), FALSE);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, FALSE);
  return c1_mxArrayOutData;
}

static int32_T c1_c_emlrt_marshallIn(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  int32_T c1_y;
  int32_T c1_i0;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_i0, 1, 6, 0U, 0, 0U, 0);
  c1_y = c1_i0;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void c1_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_b_sfEvent;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  int32_T c1_y;
  SFc1_CheckMate_clipboardInstanceStruct *chartInstance;
  chartInstance = (SFc1_CheckMate_clipboardInstanceStruct *)chartInstanceVoid;
  c1_b_sfEvent = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_y = c1_c_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_sfEvent),
    &c1_thisId);
  sf_mex_destroy(&c1_b_sfEvent);
  *(int32_T *)c1_outData = c1_y;
  sf_mex_destroy(&c1_mxArrayInData);
}

static const mxArray *c1_c_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  uint8_T c1_u;
  const mxArray *c1_y = NULL;
  SFc1_CheckMate_clipboardInstanceStruct *chartInstance;
  chartInstance = (SFc1_CheckMate_clipboardInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_u = *(uint8_T *)c1_inData;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", &c1_u, 3, 0U, 0U, 0U, 0), FALSE);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, FALSE);
  return c1_mxArrayOutData;
}

static uint8_T c1_d_emlrt_marshallIn(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance, const mxArray *c1_b_tp_ACC_1, const char_T *c1_identifier)
{
  uint8_T c1_y;
  emlrtMsgIdentifier c1_thisId;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_y = c1_e_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_tp_ACC_1),
    &c1_thisId);
  sf_mex_destroy(&c1_b_tp_ACC_1);
  return c1_y;
}

static uint8_T c1_e_emlrt_marshallIn(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  uint8_T c1_y;
  uint8_T c1_u0;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_u0, 1, 3, 0U, 0, 0U, 0);
  c1_y = c1_u0;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void c1_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_b_tp_ACC_1;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  uint8_T c1_y;
  SFc1_CheckMate_clipboardInstanceStruct *chartInstance;
  chartInstance = (SFc1_CheckMate_clipboardInstanceStruct *)chartInstanceVoid;
  c1_b_tp_ACC_1 = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_y = c1_e_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_tp_ACC_1),
    &c1_thisId);
  sf_mex_destroy(&c1_b_tp_ACC_1);
  *(uint8_T *)c1_outData = c1_y;
  sf_mex_destroy(&c1_mxArrayInData);
}

static const mxArray *c1_f_emlrt_marshallIn
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance, const mxArray
   *c1_b_setSimStateSideEffectsInfo, const char_T *c1_identifier)
{
  const mxArray *c1_y = NULL;
  emlrtMsgIdentifier c1_thisId;
  c1_y = NULL;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  sf_mex_assign(&c1_y, c1_g_emlrt_marshallIn(chartInstance, sf_mex_dup
    (c1_b_setSimStateSideEffectsInfo), &c1_thisId), FALSE);
  sf_mex_destroy(&c1_b_setSimStateSideEffectsInfo);
  return c1_y;
}

static const mxArray *c1_g_emlrt_marshallIn
  (SFc1_CheckMate_clipboardInstanceStruct *chartInstance, const mxArray *c1_u,
   const emlrtMsgIdentifier *c1_parentId)
{
  const mxArray *c1_y = NULL;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_duplicatearraysafe(&c1_u), FALSE);
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void init_dsm_address_info(SFc1_CheckMate_clipboardInstanceStruct
  *chartInstance)
{
}

/* SFunction Glue Code */
#ifdef utFree
#undef utFree
#endif

#ifdef utMalloc
#undef utMalloc
#endif

#ifdef __cplusplus

extern "C" void *utMalloc(size_t size);
extern "C" void utFree(void*);

#else

extern void *utMalloc(size_t size);
extern void utFree(void*);

#endif

void sf_c1_CheckMate_clipboard_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(3410143203U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(67649858U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(4007106882U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(928850502U);
}

mxArray *sf_c1_CheckMate_clipboard_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs", "locals" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1,1,5,
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateString("goUbELse0fT4WPqIM166oH");
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"inputs",mxCreateDoubleMatrix(0,0,mxREAL));
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"parameters",mxCreateDoubleMatrix(0,0,
                mxREAL));
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,1,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(4));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"outputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"locals",mxCreateDoubleMatrix(0,0,mxREAL));
  }

  return(mxAutoinheritanceInfo);
}

mxArray *sf_c1_CheckMate_clipboard_third_party_uses_info(void)
{
  mxArray * mxcell3p = mxCreateCellMatrix(1,0);
  return(mxcell3p);
}

static const mxArray *sf_get_sim_state_info_c1_CheckMate_clipboard(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x3'type','srcId','name','auxInfo'{{M[1],M[35],T\"q\",},{M[8],M[0],T\"is_active_c1_CheckMate_clipboard\",},{M[9],M[0],T\"is_c1_CheckMate_clipboard\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 3, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c1_CheckMate_clipboard_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc1_CheckMate_clipboardInstanceStruct *chartInstance;
    chartInstance = (SFc1_CheckMate_clipboardInstanceStruct *) ((ChartInfoStruct
      *)(ssGetUserData(S)))->chartInstance;
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (sfGlobalDebugInstanceStruct,
           _CheckMate_clipboardMachineNumber_,
           1,
           9,
           25,
           1,
           10,
           0,
           0,
           0,
           0,
           &(chartInstance->chartNumber),
           &(chartInstance->instanceNumber),
           ssGetPath(S),
           (void *)S);
        if (chartAlreadyPresent==0) {
          /* this is the first instance */
          init_script_number_translation(_CheckMate_clipboardMachineNumber_,
            chartInstance->chartNumber);
          sf_debug_set_chart_disable_implicit_casting
            (sfGlobalDebugInstanceStruct,_CheckMate_clipboardMachineNumber_,
             chartInstance->chartNumber,0);
          sf_debug_set_chart_event_thresholds(sfGlobalDebugInstanceStruct,
            _CheckMate_clipboardMachineNumber_,
            chartInstance->chartNumber,
            10,
            10,
            10);
          _SFD_SET_DATA_PROPS(0,2,0,1,"q");
          _SFD_EVENT_SCOPE(0,1);
          _SFD_EVENT_SCOPE(1,1);
          _SFD_EVENT_SCOPE(2,1);
          _SFD_EVENT_SCOPE(3,1);
          _SFD_EVENT_SCOPE(4,1);
          _SFD_EVENT_SCOPE(5,1);
          _SFD_EVENT_SCOPE(6,1);
          _SFD_EVENT_SCOPE(7,1);
          _SFD_EVENT_SCOPE(8,1);
          _SFD_EVENT_SCOPE(9,1);
          _SFD_STATE_INFO(0,0,0);
          _SFD_STATE_INFO(1,0,0);
          _SFD_STATE_INFO(2,0,0);
          _SFD_STATE_INFO(3,0,0);
          _SFD_STATE_INFO(4,0,0);
          _SFD_STATE_INFO(5,0,0);
          _SFD_STATE_INFO(6,0,0);
          _SFD_STATE_INFO(7,0,0);
          _SFD_STATE_INFO(8,0,0);
          _SFD_CH_SUBSTATE_COUNT(9);
          _SFD_CH_SUBSTATE_DECOMP(0);
          _SFD_CH_SUBSTATE_INDEX(0,0);
          _SFD_CH_SUBSTATE_INDEX(1,1);
          _SFD_CH_SUBSTATE_INDEX(2,2);
          _SFD_CH_SUBSTATE_INDEX(3,3);
          _SFD_CH_SUBSTATE_INDEX(4,4);
          _SFD_CH_SUBSTATE_INDEX(5,5);
          _SFD_CH_SUBSTATE_INDEX(6,6);
          _SFD_CH_SUBSTATE_INDEX(7,7);
          _SFD_CH_SUBSTATE_INDEX(8,8);
          _SFD_ST_SUBSTATE_COUNT(0,0);
          _SFD_ST_SUBSTATE_COUNT(1,0);
          _SFD_ST_SUBSTATE_COUNT(2,0);
          _SFD_ST_SUBSTATE_COUNT(3,0);
          _SFD_ST_SUBSTATE_COUNT(4,0);
          _SFD_ST_SUBSTATE_COUNT(5,0);
          _SFD_ST_SUBSTATE_COUNT(6,0);
          _SFD_ST_SUBSTATE_COUNT(7,0);
          _SFD_ST_SUBSTATE_COUNT(8,0);
        }

        _SFD_CV_INIT_CHART(9,1,0,0);

        {
          _SFD_CV_INIT_STATE(0,0,0,0,0,0,NULL,NULL);
        }

        {
          _SFD_CV_INIT_STATE(1,0,0,0,0,0,NULL,NULL);
        }

        {
          _SFD_CV_INIT_STATE(2,0,0,0,0,0,NULL,NULL);
        }

        {
          _SFD_CV_INIT_STATE(3,0,0,0,0,0,NULL,NULL);
        }

        {
          _SFD_CV_INIT_STATE(4,0,0,0,0,0,NULL,NULL);
        }

        {
          _SFD_CV_INIT_STATE(5,0,0,0,0,0,NULL,NULL);
        }

        {
          _SFD_CV_INIT_STATE(6,0,0,0,0,0,NULL,NULL);
        }

        {
          _SFD_CV_INIT_STATE(7,0,0,0,0,0,NULL,NULL);
        }

        {
          _SFD_CV_INIT_STATE(8,0,0,0,0,0,NULL,NULL);
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(12,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 7 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(16,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 5 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(20,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(21,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(3,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(2,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(1,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(0,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(13,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 7 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(17,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(22,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(5,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(4,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(9,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(8,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 7 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(18,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 7 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(19,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(14,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(23,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(7,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(6,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(11,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(10,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(15,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          static int sPostFixPredicateTree[] = { 0 };

          _SFD_CV_INIT_TRANS(24,1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),1,
                             &(sPostFixPredicateTree[0]));
        }

        _SFD_TRANS_COV_WTS(12,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          _SFD_TRANS_COV_MAPS(12,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(16,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 7 };

          _SFD_TRANS_COV_MAPS(16,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(20,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 5 };

          _SFD_TRANS_COV_MAPS(20,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(21,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          _SFD_TRANS_COV_MAPS(21,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(3,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(3,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(2,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(2,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(1,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(1,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(0,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(0,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(13,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          _SFD_TRANS_COV_MAPS(13,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(17,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 7 };

          _SFD_TRANS_COV_MAPS(17,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(22,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          _SFD_TRANS_COV_MAPS(22,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(5,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(5,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(4,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(4,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(9,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(9,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(8,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(8,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(18,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 7 };

          _SFD_TRANS_COV_MAPS(18,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(19,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 7 };

          _SFD_TRANS_COV_MAPS(19,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(14,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          _SFD_TRANS_COV_MAPS(14,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(23,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          _SFD_TRANS_COV_MAPS(23,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(7,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(7,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(6,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(6,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(11,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(11,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(10,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 8 };

          _SFD_TRANS_COV_MAPS(10,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(15,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          _SFD_TRANS_COV_MAPS(15,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_TRANS_COV_WTS(24,0,1,0,0);
        if (chartAlreadyPresent==0) {
          static unsigned int sStartGuardMap[] = { 0 };

          static unsigned int sEndGuardMap[] = { 9 };

          _SFD_TRANS_COV_MAPS(24,
                              0,NULL,NULL,
                              1,&(sStartGuardMap[0]),&(sEndGuardMap[0]),
                              0,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_SET_DATA_COMPILED_PROPS(0,SF_INT8,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)c1_sf_marshallIn);

        {
          real_T *c1_q;
          c1_q = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
          _SFD_SET_DATA_VALUE_PTR(0U, c1_q);
        }
      }
    } else {
      sf_debug_reset_current_state_configuration(sfGlobalDebugInstanceStruct,
        _CheckMate_clipboardMachineNumber_,chartInstance->chartNumber,
        chartInstance->instanceNumber);
    }
  }
}

static const char* sf_get_instance_specialization(void)
{
  return "U6qlNAzQPrUIYB6jkWzGHC";
}

static void sf_opaque_initialize_c1_CheckMate_clipboard(void *chartInstanceVar)
{
  chart_debug_initialization(((SFc1_CheckMate_clipboardInstanceStruct*)
    chartInstanceVar)->S,0);
  initialize_params_c1_CheckMate_clipboard
    ((SFc1_CheckMate_clipboardInstanceStruct*) chartInstanceVar);
  initialize_c1_CheckMate_clipboard((SFc1_CheckMate_clipboardInstanceStruct*)
    chartInstanceVar);
}

static void sf_opaque_enable_c1_CheckMate_clipboard(void *chartInstanceVar)
{
  enable_c1_CheckMate_clipboard((SFc1_CheckMate_clipboardInstanceStruct*)
    chartInstanceVar);
}

static void sf_opaque_disable_c1_CheckMate_clipboard(void *chartInstanceVar)
{
  disable_c1_CheckMate_clipboard((SFc1_CheckMate_clipboardInstanceStruct*)
    chartInstanceVar);
}

static void sf_opaque_gateway_c1_CheckMate_clipboard(void *chartInstanceVar)
{
  sf_c1_CheckMate_clipboard((SFc1_CheckMate_clipboardInstanceStruct*)
    chartInstanceVar);
}

extern const mxArray* sf_internal_get_sim_state_c1_CheckMate_clipboard(SimStruct*
  S)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_raw2high");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = (mxArray*) get_sim_state_c1_CheckMate_clipboard
    ((SFc1_CheckMate_clipboardInstanceStruct*)chartInfo->chartInstance);/* raw sim ctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c1_CheckMate_clipboard();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_raw2high'.\n");
  }

  return plhs[0];
}

extern void sf_internal_set_sim_state_c1_CheckMate_clipboard(SimStruct* S, const
  mxArray *st)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_high2raw");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = mxDuplicateArray(st);      /* high level simctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c1_CheckMate_clipboard();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_high2raw'.\n");
  }

  set_sim_state_c1_CheckMate_clipboard((SFc1_CheckMate_clipboardInstanceStruct*)
    chartInfo->chartInstance, mxDuplicateArray(plhs[0]));
  mxDestroyArray(plhs[0]);
}

static const mxArray* sf_opaque_get_sim_state_c1_CheckMate_clipboard(SimStruct*
  S)
{
  return sf_internal_get_sim_state_c1_CheckMate_clipboard(S);
}

static void sf_opaque_set_sim_state_c1_CheckMate_clipboard(SimStruct* S, const
  mxArray *st)
{
  sf_internal_set_sim_state_c1_CheckMate_clipboard(S, st);
}

static void sf_opaque_terminate_c1_CheckMate_clipboard(void *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc1_CheckMate_clipboardInstanceStruct*) chartInstanceVar
      )->S;
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
      unload_CheckMate_clipboard_optimization_info();
    }

    finalize_c1_CheckMate_clipboard((SFc1_CheckMate_clipboardInstanceStruct*)
      chartInstanceVar);
    utFree((void *)chartInstanceVar);
    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  initSimStructsc1_CheckMate_clipboard((SFc1_CheckMate_clipboardInstanceStruct*)
    chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c1_CheckMate_clipboard(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    initialize_params_c1_CheckMate_clipboard
      ((SFc1_CheckMate_clipboardInstanceStruct*)(((ChartInfoStruct *)
         ssGetUserData(S))->chartInstance));
  }
}

static void mdlSetWorkWidths_c1_CheckMate_clipboard(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    mxArray *infoStruct = load_CheckMate_clipboard_optimization_info();
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(S,sf_get_instance_specialization(),infoStruct,
      1);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,sf_rtw_info_uint_prop(S,sf_get_instance_specialization(),
                infoStruct,1,"RTWCG"));
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop(S,
      sf_get_instance_specialization(),infoStruct,1,
      "gatewayCannotBeInlinedMultipleTimes"));
    sf_update_buildInfo(S,sf_get_instance_specialization(),infoStruct,1);
    if (chartIsInlinable) {
      sf_mark_chart_reusable_outputs(S,sf_get_instance_specialization(),
        infoStruct,1,1);
    }

    ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);

    {
      unsigned int outPortIdx;
      for (outPortIdx=1; outPortIdx<=1; ++outPortIdx) {
        ssSetOutputPortOptimizeInIR(S, outPortIdx, 1U);
      }
    }

    sf_set_rtw_dwork_info(S,sf_get_instance_specialization(),infoStruct,1);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(3250235025U));
  ssSetChecksum1(S,(2813640334U));
  ssSetChecksum2(S,(176295478U));
  ssSetChecksum3(S,(86622612U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
  ssSupportsMultipleExecInstances(S,1);
}

static void mdlRTW_c1_CheckMate_clipboard(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    ssWriteRTWStrParam(S, "StateflowChartType", "Stateflow");
  }
}

static void mdlStart_c1_CheckMate_clipboard(SimStruct *S)
{
  SFc1_CheckMate_clipboardInstanceStruct *chartInstance;
  chartInstance = (SFc1_CheckMate_clipboardInstanceStruct *)utMalloc(sizeof
    (SFc1_CheckMate_clipboardInstanceStruct));
  memset(chartInstance, 0, sizeof(SFc1_CheckMate_clipboardInstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 0;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway =
    sf_opaque_gateway_c1_CheckMate_clipboard;
  chartInstance->chartInfo.initializeChart =
    sf_opaque_initialize_c1_CheckMate_clipboard;
  chartInstance->chartInfo.terminateChart =
    sf_opaque_terminate_c1_CheckMate_clipboard;
  chartInstance->chartInfo.enableChart = sf_opaque_enable_c1_CheckMate_clipboard;
  chartInstance->chartInfo.disableChart =
    sf_opaque_disable_c1_CheckMate_clipboard;
  chartInstance->chartInfo.getSimState =
    sf_opaque_get_sim_state_c1_CheckMate_clipboard;
  chartInstance->chartInfo.setSimState =
    sf_opaque_set_sim_state_c1_CheckMate_clipboard;
  chartInstance->chartInfo.getSimStateInfo =
    sf_get_sim_state_info_c1_CheckMate_clipboard;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c1_CheckMate_clipboard;
  chartInstance->chartInfo.mdlStart = mdlStart_c1_CheckMate_clipboard;
  chartInstance->chartInfo.mdlSetWorkWidths =
    mdlSetWorkWidths_c1_CheckMate_clipboard;
  chartInstance->chartInfo.extModeExec = NULL;
  chartInstance->chartInfo.restoreLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.restoreBeforeLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.storeCurrentConfiguration = NULL;
  chartInstance->S = S;
  ssSetUserData(S,(void *)(&(chartInstance->chartInfo)));/* register the chart instance with simstruct */
  init_dsm_address_info(chartInstance);
  if (!sim_mode_is_rtw_gen(S)) {
  }

  sf_opaque_init_subchart_simstructs(chartInstance->chartInfo.chartInstance);
  chart_debug_initialization(S,1);
}

void c1_CheckMate_clipboard_method_dispatcher(SimStruct *S, int_T method, void
  *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c1_CheckMate_clipboard(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c1_CheckMate_clipboard(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c1_CheckMate_clipboard(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c1_CheckMate_clipboard_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}
