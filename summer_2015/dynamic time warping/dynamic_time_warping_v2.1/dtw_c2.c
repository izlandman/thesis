/**
 * Copyright (C) 2013 Quan Wang <wangq10@rpi.edu>,
 * Signal Analysis and Machine Perception Laboratory,
 * Department of Electrical, Computer, and Systems Engineering,
 * Rensselaer Polytechnic Institute, Troy, NY 12180, USA
 */

/** 
 * This is the C/MEX code of dynamic time warping of two signals
 *
 * compile: 
 *     mex dtw_c2.c
 *
 * usage:
 *     d=dtw_c(s,t)  or  d=dtw_c(s,t,w)
 *     where s is signal 1, t is signal 2, w is window parameter 
 */

#include "mex.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

double vectorDistance(double *s, double *t, int ns, int nt, int k, int i, int j)
{
    double result=0;
    double ss,tt;
    int x;
    for(x=0;x<k;x++)
    {
        ss=s[i+ns*x];
        tt=t[j+nt*x];
        result+=((ss-tt)*(ss-tt));
    }
    result=sqrt(result);
    return result;
}

void dtw_c2(double *s, double *t, int w, int ns, int nt, int k, double **D)
{
    double d=0;
    int sizediff=ns-nt>0 ? ns-nt : nt-ns;
    // double ** D;
    int i,j;
    int j1,j2;
    double cost,temp;   
    
    if(w!=-1 && w<sizediff) w=sizediff; // adapt window size
       
    // dynamic programming
    for(i=1;i<=ns;i++)
    {
        if(w==-1)
        {
            j1=1;
            j2=nt;
        }
        else
        {
            j1= i-w>1 ? i-w : 1;
            j2= i+w<nt ? i+w : nt;
        }
        for(j=j1;j<=j2;j++)
        {
            cost=vectorDistance(s,t,ns,nt,k,i-1,j-1);
            
            temp=D[i-1][j];
            if(D[i][j-1]!=-1) 
            {
                if(temp==-1 || D[i][j-1]<temp) temp=D[i][j-1];
            }
            if(D[i-1][j-1]!=-1) 
            {
                if(temp==-1 || D[i-1][j-1]<temp) temp=D[i-1][j-1];
            }
            
            D[i][j]=cost+temp;
        }
    }
    
    
    d=D[ns][nt];
    
    /* view matrix D */
/*
    for(i=0;i<ns+1;i++)
    {
        for(j=0;j<nt+1;j++)
        {
            printf("%f  ",D[i][j]);
        }
        printf("\n");
    }
    printf("\n");
*/
    
    // free D
/*
    for(i=0;i<ns+1;i++)
    {
        free(D[i]);
    }
    free(D);
*/
    // return D;
}

/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    double *s,*t, *pOut, **D;
    int w,i,j;
    int ns,nt,k;
    
    /*  check for proper number of arguments */
    if(nrhs!=2&&nrhs!=3)
    {
        mexErrMsgIdAndTxt( "MATLAB:dtw_c:invalidNumInputs",
                "Two or three inputs required.");
    }
    if(nlhs>1)
    {
        mexErrMsgIdAndTxt( "MATLAB:dtw_c:invalidNumOutputs",
                "dtw_c: One output required.");
    }
    
    /* check to make sure w is a scalar */
    if(nrhs==2)
    {
        w=-1;
    }
    else if(nrhs==3)
    {
        if( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) ||
                mxGetN(prhs[2])*mxGetM(prhs[2])!=1 )
        {
            mexErrMsgIdAndTxt( "MATLAB:dtw_c2:wNotScalar",
                    "dtw_c2: Input w must be a scalar.");
        }
        
        /*  get the scalar input w */
        w = (int) mxGetScalar(prhs[2]);
    }
    
    
    /*  create a pointer to the input matrix s */
    s = mxGetPr(prhs[0]);
    
    /*  create a pointer to the input matrix t */
    t = mxGetPr(prhs[1]);
    
    /*  get the dimensions of the matrix input s */
    ns = mxGetM(prhs[0]);
    k = mxGetN(prhs[0]);
    
    /*  get the dimensions of the matrix input t */
    nt = mxGetM(prhs[1]);
    if(mxGetN(prhs[1])!=k)
    {
        mexErrMsgIdAndTxt( "MATLAB:dtw_c2:dimNotMatch",
                    "dtw_c2: Dimensions of input s and t must match.");
    }  
    
    /*  set the output pointer to the output matrix */
    plhs[0] = mxCreateDoubleMatrix( ns+1, nt+1, mxREAL);
    pOut = (double*)mxGetData(plhs[0]);
    
    // build result matrix, pass it to function
    D = (double **)malloc((ns+1)*sizeof(double *));
    for(i=0;i<ns+1;i++)
    {
        D[i]=(double *)malloc((nt+1)*sizeof(double));
    }

    // initialization
    for(i=0;i<ns+1;i++)
    {
        for(j=0;j<nt+1;j++)
        {
            D[i][j]=-1;
        }
    }
    D[0][0]=0;
    
    /*  call the C subroutine */
    dtw_c2(s,t,w,ns,nt,k,D);
    
    for( i=0; i < ns+1; i++){
        for( j=0; j < nt+1; j++){
            pOut[i+(ns+1)*j] = D[i][j];
        }
    }
    
    for(i=0;i<ns+1;i++)
    {
        free(D[i]);
    }
    free(D);
    
    return;
    
}
