#pragma once

#include <hx/CFFI.h>
#include <opencv2/core.hpp>

// Translate OpenCV failures before they can cross the CFFI boundary.
#define CV_CATCH_ERROR \
    catch (const cv::Exception& error) { \
        val_throw(alloc_string(error.what())); \
        return val_null; \
    }

template <typename T>
void finaliser(value handle) {
    delete static_cast<T*>(val_data(handle));
}

#define CV_PRIM(module, name, count, parameters, ...) \
    value hx_cv_##module##_##name parameters { \
        try { __VA_ARGS__ } CV_CATCH_ERROR \
    } \
    DEFINE_PRIM(hx_cv_##module##_##name, count)

#define CV_PRIM_MULT(module, name, count, ...) \
    value hx_cv_##module##_##name(value* args, int nargs) { \
        try { \
            CV_Assert(nargs == count); \
            __VA_ARGS__ \
        } CV_CATCH_ERROR \
    } \
    DEFINE_PRIM_MULT(hx_cv_##module##_##name)
