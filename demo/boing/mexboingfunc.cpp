#include "mex.h"

void mexFunction(int nlhs, mxArray*  plhs[],
            int nrhs, const mxArray* prhs[])
{
   if (nrhs != 2)
   {
       mexErrMsgIdAndTxt("boingfunc:wrongInput", "Wrong number of input");
   }
   double* pu = mxGetPr(prhs[1]);
   
   mxArray* retType = mxCreateString("linear");
   const char* fieldNames[] = {"A", "b"};
   mxArray* retSys = mxCreateStructMatrix(1,1,2, fieldNames);
    const char* fieldNames2[] = {"A", "B"};
   mxArray* retReset = mxCreateStructMatrix(1,1,2, fieldNames2);
   
   if (*pu == 1.0)  {
       mxArray* A=mxCreateDoubleMatrix(3,3, mxREAL);
       double* ar = mxGetPr(A);
       ar[0] = 0.0; ar[1] = 0.0; ar[2] = 0.0;
       ar[3] = 0.0; ar[4] = 0.0; ar[5] = 0.0;
       ar[6] = 0.0; ar[7] = 1.0; ar[8] = 0.0;
       mxSetField(retSys, 0, "A", A);
       
       mxArray* b=mxCreateDoubleMatrix(3,1, mxREAL);
       double* br = mxGetPr(b);
       br[0] = 1.0; br[1] = 0.0; br[2] = -1.0;
       mxSetField(retSys, 0, "b", b);
       
       A=mxCreateDoubleMatrix(3,3, mxREAL);
       ar = mxGetPr(A);
       ar[0] = 1.0; ar[1] = 0.0; ar[2] = 0.0;
       ar[3] = 0.0; ar[4] = 1.0; ar[5] = 0.0;
       ar[6] = 0.0; ar[7] = 0.0; ar[8] = -0.9;
       mxSetField(retReset, 0, "A", A);
       
       b=mxCreateDoubleMatrix(3,1, mxREAL);
       br = mxGetPr(b);
       br[0] = 0.0; br[1] = 0.0; br[2] = 0.0;
       mxSetField(retReset, 0, "B", b);
   } else {
       mxArray* A=mxCreateDoubleMatrix(3,3, mxREAL);
       double* ar = mxGetPr(A);
       ar[0] = 0.0; ar[1] = 0.0; ar[2] = 0.0;
       ar[3] = 0.0; ar[4] = 0.0; ar[5] = 0.0;
       ar[6] = 0.0; ar[7] = 0.0; ar[8] = 0.0;
       mxSetField(retSys, 0, "A", A);
       
       mxArray* b=mxCreateDoubleMatrix(3,1, mxREAL);
       double* br = mxGetPr(b);
       br[0] = 0.0; br[1] = 0.0; br[2] = 0.0;
       mxSetField(retSys, 0, "b", b);
       
       A=mxCreateDoubleMatrix(3,3, mxREAL);
       ar = mxGetPr(A);
       ar[0] = 1.0; ar[1] = 0.0; ar[2] = 0.0;
       ar[3] = 0.0; ar[4] = 1.0; ar[5] = 0.0;
       ar[6] = 0.0; ar[7] = 0.0; ar[8] = 1.0;
       mxSetField(retReset, 0, "A", A);
       
       b=mxCreateDoubleMatrix(3,1, mxREAL);
       br = mxGetPr(b);
       br[0] = 0.0; br[1] = 0.0; br[2] = 0.0;
       mxSetField(retReset, 0, "B", b);
       
   }
   nlhs = 3;
   plhs[0] = retSys;
   plhs[2] = retReset;
   plhs[1] = retType;
}