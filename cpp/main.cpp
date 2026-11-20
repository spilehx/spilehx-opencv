#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif
#include <hx/CFFI.h>

#include "core.h"
#include "features2d.h"
#include "objdetect.h"
#include "highgui.h"

extern "C" void hx_opencv_entry() {
    core_allocateKinds();
    features2d_allocateKinds();
    objdetect_allocateKinds();
    highgui_allocateKinds();
}
DEFINE_ENTRY_POINT(hx_opencv_entry);

