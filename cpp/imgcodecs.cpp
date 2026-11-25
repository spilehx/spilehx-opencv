#include "imgcodecs.h"
#include <cstring>
#include <limits>
#include <vector>

CV_PRIM(imgcodecs, loadImage, 2, (value filename, value flags),
    cv::Mat image = cv::imread(val_get_string(filename), val_get_int(flags));
    if (image.empty()) return val_null;
    return hx_cv_core_toMat(new cv::Mat(image));
);
CV_PRIM(imgcodecs, saveImage, 2, (value filename, value image),
    return alloc_bool(cv::imwrite(val_get_string(filename), hx_cv_core_mat(image)));
);
CV_PRIM(imgcodecs, encodeJpeg, 2, (value image, value quality),
    int jpegQuality = val_get_int(quality);
    CV_Assert(jpegQuality >= 0 && jpegQuality <= 100);
    std::vector<unsigned char> encoded;
    CV_Assert(cv::imencode(".jpg", hx_cv_core_mat(image), encoded,
        std::vector<int>{cv::IMWRITE_JPEG_QUALITY, jpegQuality}));
    CV_Assert(encoded.size() <= static_cast<size_t>(std::numeric_limits<int>::max()));
    buffer bytes = alloc_buffer_len(static_cast<int>(encoded.size()));
    std::memcpy(buffer_data(bytes), encoded.data(), encoded.size());
    return buffer_val(bytes);
);
