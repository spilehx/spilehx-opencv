#include "core.h"
#include <opencv2/imgproc.hpp>
#include <vector>

DEFINE_KIND(k_Mat);

cv::Mat& hx_cv_core_mat(value handle) {
    val_check_kind(handle, k_Mat);
    return *static_cast<cv::Mat*>(val_data(handle));
}

value hx_cv_core_toMat(cv::Mat* matrix) {
    value handle = alloc_abstract(k_Mat, matrix);
    val_gc(handle, finaliser<cv::Mat>);
    return handle;
}

value hx_cv_core_createMat(value rows, value cols, value type) {
    try {
        int rowCount = val_get_int(rows);
        int columnCount = val_get_int(cols);
        CV_Assert(rowCount >= 0 && columnCount >= 0);
        return hx_cv_core_toMat(new cv::Mat(rowCount, columnCount, val_get_int(type)));
    } CV_CATCH_ERROR
}
DEFINE_PRIM(hx_cv_core_createMat, 3);

value hx_cv_core_cloneMat(value handle) {
    try {
        return hx_cv_core_toMat(new cv::Mat(hx_cv_core_mat(handle).clone()));
    } CV_CATCH_ERROR
}
DEFINE_PRIM(hx_cv_core_cloneMat, 1);

// Scalar access initially supports single-channel floating-point matrices.
value hx_cv_core_mGet(value handle, value row, value col) {
    try {
        cv::Mat& matrix = hx_cv_core_mat(handle);
        int r = val_get_int(row);
        int c = val_get_int(col);
        CV_Assert(matrix.channels() == 1 && r >= 0 && r < matrix.rows && c >= 0 && c < matrix.cols);
        CV_Assert(matrix.depth() == CV_32F || matrix.depth() == CV_64F);
        return alloc_float(matrix.depth() == CV_32F ? matrix.at<float>(r, c) : matrix.at<double>(r, c));
    } CV_CATCH_ERROR
}
DEFINE_PRIM(hx_cv_core_mGet, 3);

value hx_cv_core_mSet(value handle, value row, value col, value number) {
    try {
        cv::Mat& matrix = hx_cv_core_mat(handle);
        int r = val_get_int(row);
        int c = val_get_int(col);
        CV_Assert(matrix.channels() == 1 && r >= 0 && r < matrix.rows && c >= 0 && c < matrix.cols);
        CV_Assert(matrix.depth() == CV_32F || matrix.depth() == CV_64F);
        if (matrix.depth() == CV_32F) matrix.at<float>(r, c) = val_get_double(number);
        else matrix.at<double>(r, c) = val_get_double(number);
        return number;
    } CV_CATCH_ERROR
}
DEFINE_PRIM(hx_cv_core_mSet, 4);

#define MAT_PROPERTY(name, expression) \
    value hx_cv_core_Mat_get_##name(value handle) { \
        try { \
            cv::Mat& matrix = hx_cv_core_mat(handle); \
            return alloc_int(expression); \
        } CV_CATCH_ERROR \
    } \
    DEFINE_PRIM(hx_cv_core_Mat_get_##name, 1)

MAT_PROPERTY(rows, matrix.rows);
MAT_PROPERTY(cols, matrix.cols);
MAT_PROPERTY(type, matrix.type());
MAT_PROPERTY(step, static_cast<int>(matrix.step[0]));
MAT_PROPERTY(depth, matrix.depth());
MAT_PROPERTY(channels, matrix.channels());


cv::Mat hx_cv_core_optionalMat(value handle) {
    return val_is_null(handle) ? cv::Mat() : hx_cv_core_mat(handle);
}

#define CORE_DEFINE_TYPE(name, type) \
    DEFINE_KIND(k_##name); \
    type& hx_cv_core_as##name(value handle) { \
        val_check_kind(handle, k_##name); \
        return *static_cast<type*>(val_data(handle)); \
    } \
    value hx_cv_core_to##name(type* object) { \
        value handle = alloc_abstract(k_##name, object); \
        val_gc(handle, finaliser<type>); \
        return handle; \
    }

#define CORE_PROPERTY(name, field, getter, setter) \
    CV_PRIM(core, name##_get_##field, 1, (value handle), \
        return getter(hx_cv_core_as##name(handle).field); \
    ); \
    CV_PRIM(core, name##_set_##field, 2, (value handle, value number), \
        return getter(hx_cv_core_as##name(handle).field = setter(number)); \
    )

CORE_DEFINE_TYPE(Point, cv::Point);
CV_PRIM(core, Point, 2, (value x, value y),
    return hx_cv_core_toPoint(new cv::Point(val_get_int(x), val_get_int(y)));
);
CORE_PROPERTY(Point, x, alloc_int, val_get_int);
CORE_PROPERTY(Point, y, alloc_int, val_get_int);

CORE_DEFINE_TYPE(Point2D32f, cv::Point2f);
CV_PRIM(core, Point2D32f, 2, (value x, value y),
    return hx_cv_core_toPoint2D32f(new cv::Point2f(val_get_double(x), val_get_double(y)));
);
CORE_PROPERTY(Point2D32f, x, alloc_float, val_get_double);
CORE_PROPERTY(Point2D32f, y, alloc_float, val_get_double);

CORE_DEFINE_TYPE(Point2D64f, cv::Point2d);
CV_PRIM(core, Point2D64f, 2, (value x, value y),
    return hx_cv_core_toPoint2D64f(new cv::Point2d(val_get_double(x), val_get_double(y)));
);
CORE_PROPERTY(Point2D64f, x, alloc_float, val_get_double);
CORE_PROPERTY(Point2D64f, y, alloc_float, val_get_double);

CORE_DEFINE_TYPE(Point3D32f, cv::Point3f);
CV_PRIM(core, Point3D32f, 3, (value x, value y, value z),
    return hx_cv_core_toPoint3D32f(new cv::Point3f(val_get_double(x), val_get_double(y), val_get_double(z)));
);
CORE_PROPERTY(Point3D32f, x, alloc_float, val_get_double);
CORE_PROPERTY(Point3D32f, y, alloc_float, val_get_double);
CORE_PROPERTY(Point3D32f, z, alloc_float, val_get_double);

CORE_DEFINE_TYPE(Point3D64f, cv::Point3d);
CV_PRIM(core, Point3D64f, 3, (value x, value y, value z),
    return hx_cv_core_toPoint3D64f(new cv::Point3d(val_get_double(x), val_get_double(y), val_get_double(z)));
);
CORE_PROPERTY(Point3D64f, x, alloc_float, val_get_double);
CORE_PROPERTY(Point3D64f, y, alloc_float, val_get_double);
CORE_PROPERTY(Point3D64f, z, alloc_float, val_get_double);

CORE_DEFINE_TYPE(Size, cv::Size);
CV_PRIM(core, Size, 2, (value width, value height),
    return hx_cv_core_toSize(new cv::Size(val_get_int(width), val_get_int(height)));
);
CORE_PROPERTY(Size, width, alloc_int, val_get_int);
CORE_PROPERTY(Size, height, alloc_int, val_get_int);

CORE_DEFINE_TYPE(Size2D32f, cv::Size2f);
CV_PRIM(core, Size2D32f, 2, (value width, value height),
    return hx_cv_core_toSize2D32f(new cv::Size2f(val_get_double(width), val_get_double(height)));
);
CORE_PROPERTY(Size2D32f, width, alloc_float, val_get_double);
CORE_PROPERTY(Size2D32f, height, alloc_float, val_get_double);

CORE_DEFINE_TYPE(Rect, cv::Rect);
CV_PRIM(core, Rect, 4, (value x, value y, value width, value height),
    return hx_cv_core_toRect(new cv::Rect(val_get_int(x), val_get_int(y), val_get_int(width), val_get_int(height)));
);
CORE_PROPERTY(Rect, x, alloc_int, val_get_int);
CORE_PROPERTY(Rect, y, alloc_int, val_get_int);
CORE_PROPERTY(Rect, width, alloc_int, val_get_int);
CORE_PROPERTY(Rect, height, alloc_int, val_get_int);

CORE_DEFINE_TYPE(Scalar, cv::Scalar);

CORE_DEFINE_TYPE(TermCriteria, cv::TermCriteria);

CV_PRIM(core, Scalar, 4, (value x, value y, value z, value w),
    return hx_cv_core_toScalar(new cv::Scalar(val_get_double(x), val_get_double(y), val_get_double(z), val_get_double(w)));
);
CV_PRIM(core, Scalar_get_i, 2, (value handle, value index),
    int i = val_get_int(index);
    CV_Assert(i >= 0 && i < 4);
    return alloc_float(hx_cv_core_asScalar(handle)[i]);
);
CV_PRIM(core, Scalar_set_i, 3, (value handle, value index, value number),
    int i = val_get_int(index);
    CV_Assert(i >= 0 && i < 4);
    return alloc_float(hx_cv_core_asScalar(handle)[i] = val_get_double(number));
);
CV_PRIM(core, TermCriteria, 3, (value type, value maxCount, value epsilon),
    return hx_cv_core_toTermCriteria(new cv::TermCriteria(val_get_int(type), val_get_int(maxCount), val_get_double(epsilon)));
);
CORE_PROPERTY(TermCriteria, type, alloc_int, val_get_int);
CORE_PROPERTY(TermCriteria, maxCount, alloc_int, val_get_int);
CORE_PROPERTY(TermCriteria, epsilon, alloc_float, val_get_double);

// Linear component indices address logical rows, including for non-contiguous views.
template <typename T>
static T& matrixComponent(cv::Mat& matrix, int index, int depth) {
    CV_Assert(matrix.dims == 2 && matrix.depth() == depth);
    CV_Assert(index >= 0 && static_cast<size_t>(index) < matrix.total() * matrix.channels());
    size_t rowWidth = static_cast<size_t>(matrix.cols) * matrix.channels();
    return matrix.ptr<T>(index / rowWidth)[index % rowWidth];
}

#define MAT_ACCESS(name, type, depth, getter, setter) \
    CV_PRIM(core, mat_##name##_get, 2, (value handle, value index), \
        return getter(matrixComponent<type>(hx_cv_core_mat(handle), val_get_int(index), depth)); \
    ); \
    CV_PRIM(core, mat_##name##_set, 3, (value handle, value index, value number), \
        return getter(matrixComponent<type>(hx_cv_core_mat(handle), val_get_int(index), depth) = static_cast<type>(setter(number))); \
    )

MAT_ACCESS(uchar, uchar, CV_8U, alloc_int, val_get_int);
MAT_ACCESS(char, signed char, CV_8S, alloc_int, val_get_int);
MAT_ACCESS(ushort, unsigned short, CV_16U, alloc_int, val_get_int);
MAT_ACCESS(short, short, CV_16S, alloc_int, val_get_int);
MAT_ACCESS(int, int, CV_32S, alloc_int, val_get_int);
MAT_ACCESS(float, float, CV_32F, alloc_float, val_get_double);
MAT_ACCESS(double, double, CV_64F, alloc_float, val_get_double);

// Indexing converts the retained numeric depths to doubles without assuming continuity.
static cv::Scalar matrixElement(cv::Mat& matrix, const std::vector<int>& indices) {
    CV_Assert(static_cast<int>(indices.size()) == matrix.dims && matrix.channels() <= 4);
    for (int d = 0; d < matrix.dims; ++d) CV_Assert(indices[d] >= 0 && indices[d] < matrix.size[d]);
    const uchar* data = matrix.ptr(indices.data());
    cv::Scalar result;
    for (int channel = 0; channel < matrix.channels(); ++channel) {
        switch (matrix.depth()) {
            case CV_8U: result[channel] = data[channel]; break;
            case CV_8S: result[channel] = reinterpret_cast<const signed char*>(data)[channel]; break;
            case CV_16U: result[channel] = reinterpret_cast<const unsigned short*>(data)[channel]; break;
            case CV_16S: result[channel] = reinterpret_cast<const short*>(data)[channel]; break;
            case CV_32S: result[channel] = reinterpret_cast<const int*>(data)[channel]; break;
            case CV_32F: result[channel] = reinterpret_cast<const float*>(data)[channel]; break;
            case CV_64F: result[channel] = reinterpret_cast<const double*>(data)[channel]; break;
            default: CV_Error(cv::Error::StsUnsupportedFormat, "Unsupported matrix indexing depth");
        }
    }
    return result;
}

static std::vector<int> linearIndices(cv::Mat& matrix, int index) {
    CV_Assert(index >= 0 && static_cast<size_t>(index) < matrix.total());
    std::vector<int> indices(matrix.dims);
    for (int d = matrix.dims - 1; d >= 0; --d) {
        indices[d] = index % matrix.size[d];
        index /= matrix.size[d];
    }
    return indices;
}

static std::vector<int> arrayIndices(value indices) {
    val_check(indices, array);
    std::vector<int> result(val_array_size(indices));
    for (int i = 0; i < static_cast<int>(result.size()); ++i) result[i] = val_get_int(val_array_i(indices, i));
    return result;
}

CV_PRIM(core, get1D, 2, (value handle, value index),
    cv::Mat& matrix = hx_cv_core_mat(handle);
    cv::Scalar element = matrixElement(matrix, linearIndices(matrix, val_get_int(index)));
    return hx_cv_core_toScalar(new cv::Scalar(element));
);
CV_PRIM(core, getReal1D, 2, (value handle, value index),
    cv::Mat& matrix = hx_cv_core_mat(handle);
    CV_Assert(matrix.channels() == 1);
    cv::Scalar element = matrixElement(matrix, linearIndices(matrix, val_get_int(index)));
    return alloc_float(element[0]);
);
CV_PRIM(core, get2D, 3, (value handle, value row, value col),
    cv::Mat& matrix = hx_cv_core_mat(handle);
    cv::Scalar element = matrixElement(matrix, {val_get_int(row), val_get_int(col)});
    return hx_cv_core_toScalar(new cv::Scalar(element));
);
CV_PRIM(core, getReal2D, 3, (value handle, value row, value col),
    cv::Mat& matrix = hx_cv_core_mat(handle);
    CV_Assert(matrix.channels() == 1);
    cv::Scalar element = matrixElement(matrix, {val_get_int(row), val_get_int(col)});
    return alloc_float(element[0]);
);
CV_PRIM(core, get3D, 4, (value handle, value i, value j, value k),
    cv::Mat& matrix = hx_cv_core_mat(handle);
    cv::Scalar element = matrixElement(matrix, {val_get_int(i), val_get_int(j), val_get_int(k)});
    return hx_cv_core_toScalar(new cv::Scalar(element));
);
CV_PRIM(core, getReal3D, 4, (value handle, value i, value j, value k),
    cv::Mat& matrix = hx_cv_core_mat(handle);
    CV_Assert(matrix.channels() == 1);
    cv::Scalar element = matrixElement(matrix, {val_get_int(i), val_get_int(j), val_get_int(k)});
    return alloc_float(element[0]);
);
CV_PRIM(core, getND, 2, (value handle, value indices),
    cv::Mat& matrix = hx_cv_core_mat(handle);
    cv::Scalar element = matrixElement(matrix, arrayIndices(indices));
    return hx_cv_core_toScalar(new cv::Scalar(element));
);
CV_PRIM(core, getRealND, 2, (value handle, value indices),
    cv::Mat& matrix = hx_cv_core_mat(handle);
    CV_Assert(matrix.channels() == 1);
    cv::Scalar element = matrixElement(matrix, arrayIndices(indices));
    return alloc_float(element[0]);
);

CV_PRIM(core, absDiff, 3, (value src1, value src2, value dst),
    cv::absdiff(hx_cv_core_mat(src1), hx_cv_core_mat(src2), hx_cv_core_mat(dst));
    return val_null;
);
CV_PRIM(core, absDiffS, 3, (value src, value number, value dst),
    cv::absdiff(hx_cv_core_mat(src), hx_cv_core_asScalar(number), hx_cv_core_mat(dst));
    return val_null;
);
CV_PRIM(core, add, 4, (value src1, value src2, value dst, value mask),
    cv::add(hx_cv_core_mat(src1), hx_cv_core_mat(src2), hx_cv_core_mat(dst), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM(core, addS, 4, (value src, value number, value dst, value mask),
    cv::add(hx_cv_core_mat(src), hx_cv_core_asScalar(number), hx_cv_core_mat(dst), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM(core, sub, 4, (value src1, value src2, value dst, value mask),
    cv::subtract(hx_cv_core_mat(src1), hx_cv_core_mat(src2), hx_cv_core_mat(dst), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM(core, scaleAdd, 4, (value src1, value scale, value src2, value dst),
    cv::scaleAdd(hx_cv_core_mat(src1), val_get_double(scale), hx_cv_core_mat(src2), hx_cv_core_mat(dst));
    return val_null;
);
CV_PRIM(core, mul, 4, (value src1, value src2, value dst, value scale),
    cv::multiply(hx_cv_core_mat(src1), hx_cv_core_mat(src2), hx_cv_core_mat(dst), val_get_double(scale));
    return val_null;
);
CV_PRIM(core, div, 4, (value src1, value src2, value dst, value scale),
    cv::divide(hx_cv_core_mat(src1), hx_cv_core_mat(src2), hx_cv_core_mat(dst), val_get_double(scale));
    return val_null;
);
CV_PRIM(core, and, 4, (value src1, value src2, value dst, value mask),
    cv::bitwise_and(hx_cv_core_mat(src1), hx_cv_core_mat(src2), hx_cv_core_mat(dst), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM(core, andS, 4, (value src, value number, value dst, value mask),
    cv::bitwise_and(hx_cv_core_mat(src), hx_cv_core_asScalar(number), hx_cv_core_mat(dst), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM(core, avg, 2, (value src, value mask),
    return hx_cv_core_toScalar(new cv::Scalar(cv::mean(hx_cv_core_mat(src), hx_cv_core_optionalMat(mask))));
);
CV_PRIM(core, avgSdv, 4, (value src, value mean, value stdDev, value mask),
    cv::meanStdDev(hx_cv_core_mat(src), hx_cv_core_asScalar(mean), hx_cv_core_asScalar(stdDev), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM(core, cmp, 4, (value src1, value src2, value dst, value operation),
    cv::compare(hx_cv_core_mat(src1), hx_cv_core_mat(src2), hx_cv_core_mat(dst), val_get_int(operation));
    return val_null;
);
CV_PRIM(core, cmpS, 4, (value src, value number, value dst, value operation),
    cv::compare(hx_cv_core_mat(src), val_get_double(number), hx_cv_core_mat(dst), val_get_int(operation));
    return val_null;
);
CV_PRIM(core, convertScale, 5, (value src, value dst, value depth, value scale, value shift),
    hx_cv_core_mat(src).convertTo(hx_cv_core_mat(dst), val_get_int(depth), val_get_double(scale), val_get_double(shift));
    return val_null;
);
CV_PRIM(core, convertScaleAbs, 4, (value src, value dst, value scale, value shift),
    cv::convertScaleAbs(hx_cv_core_mat(src), hx_cv_core_mat(dst), val_get_double(scale), val_get_double(shift));
    return val_null;
);
CV_PRIM(core, copy, 3, (value src, value dst, value mask),
    hx_cv_core_mat(src).copyTo(hx_cv_core_mat(dst), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM(core, set, 3, (value dst, value number, value mask),
    hx_cv_core_mat(dst).setTo(hx_cv_core_asScalar(number), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM(core, countNonZero, 1, (value src),
    return alloc_int(cv::countNonZero(hx_cv_core_mat(src)));
);
CV_PRIM(core, DCT, 3, (value src, value dst, value flags),
    cv::dct(hx_cv_core_mat(src), hx_cv_core_mat(dst), val_get_int(flags));
    return val_null;
);
CV_PRIM(core, DFT, 4, (value src, value dst, value flags, value nonzeroRows),
    cv::dft(hx_cv_core_mat(src), hx_cv_core_mat(dst), val_get_int(flags), val_get_int(nonzeroRows));
    return val_null;
);
CV_PRIM(core, det, 1, (value src),
    return alloc_float(cv::determinant(hx_cv_core_mat(src)));
);
CV_PRIM(core, dotProduct, 2, (value src1, value src2),
    return alloc_float(hx_cv_core_mat(src1).dot(hx_cv_core_mat(src2)));
);
CV_PRIM(core, magnitude, 3, (value x, value y, value dst),
    cv::magnitude(hx_cv_core_mat(x), hx_cv_core_mat(y), hx_cv_core_mat(dst));
    return val_null;
);
CV_PRIM(core, phase, 4, (value x, value y, value angle, value degrees),
    cv::phase(hx_cv_core_mat(x), hx_cv_core_mat(y), hx_cv_core_mat(angle), val_get_bool(degrees));
    return val_null;
);
CV_PRIM(core, cartToPolar, 5, (value x, value y, value magnitude, value angle, value degrees),
    cv::cartToPolar(hx_cv_core_mat(x), hx_cv_core_mat(y), hx_cv_core_mat(magnitude), hx_cv_core_mat(angle), val_get_bool(degrees));
    return val_null;
);
CV_PRIM(core, polarToCart, 5, (value magnitude, value angle, value x, value y, value degrees),
    cv::polarToCart(hx_cv_core_mat(magnitude), hx_cv_core_mat(angle), hx_cv_core_mat(x), hx_cv_core_mat(y), val_get_bool(degrees));
    return val_null;
);
CV_PRIM(core, getCols, 3, (value src, value start, value end),
    return hx_cv_core_toMat(new cv::Mat(hx_cv_core_mat(src).colRange(val_get_int(start), val_get_int(end))));
);
CV_PRIM(core, getRows, 3, (value src, value start, value end),
    return hx_cv_core_toMat(new cv::Mat(hx_cv_core_mat(src).rowRange(val_get_int(start), val_get_int(end))));
);
CV_PRIM(core, getDiag, 2, (value src, value diagonal),
    return hx_cv_core_toMat(new cv::Mat(hx_cv_core_mat(src).diag(val_get_int(diagonal))));
);
CV_PRIM(core, getSubRect, 2, (value src, value rectangle),
    return hx_cv_core_toMat(new cv::Mat(hx_cv_core_mat(src)(hx_cv_core_asRect(rectangle))));
);
CV_PRIM(core, getElemType, 1, (value src),
    return alloc_int(hx_cv_core_mat(src).type());
);
CV_PRIM(core, getSize, 1, (value src),
    return hx_cv_core_toSize(new cv::Size(hx_cv_core_mat(src).size()));
);

CV_PRIM_MULT(core, addWeighted, 6,
    cv::addWeighted(hx_cv_core_mat(args[0]), val_get_double(args[1]), hx_cv_core_mat(args[2]),
        val_get_double(args[3]), val_get_double(args[4]), hx_cv_core_mat(args[5]));
    return val_null;
);

CV_PRIM(core, merge, 2, (value sources, value dst),
    val_check(sources, array);
    std::vector<cv::Mat> matrices;
    for (int i = 0; i < val_array_size(sources); ++i) matrices.push_back(hx_cv_core_mat(val_array_i(sources, i)));
    cv::merge(matrices, hx_cv_core_mat(dst));
    return val_null;
);
CV_PRIM(core, split, 1, (value src),
    std::vector<cv::Mat> channels;
    cv::split(hx_cv_core_mat(src), channels);
    value result = alloc_array(channels.size());
    for (int i = 0; i < static_cast<int>(channels.size()); ++i)
        val_array_set_i(result, i, hx_cv_core_toMat(new cv::Mat(channels[i])));
    return result;
);

CV_PRIM_MULT(core, circle, 7,
    cv::circle(hx_cv_core_mat(args[0]), hx_cv_core_asPoint(args[1]), val_get_int(args[2]),
        hx_cv_core_asScalar(args[3]), val_get_int(args[4]), val_get_int(args[5]), val_get_int(args[6]));
    return val_null;
);
CV_PRIM_MULT(core, line, 7,
    cv::line(hx_cv_core_mat(args[0]), hx_cv_core_asPoint(args[1]), hx_cv_core_asPoint(args[2]),
        hx_cv_core_asScalar(args[3]), val_get_int(args[4]), val_get_int(args[5]), val_get_int(args[6]));
    return val_null;
);
CV_PRIM_MULT(core, rectangle, 7,
    cv::rectangle(hx_cv_core_mat(args[0]), hx_cv_core_asPoint(args[1]), hx_cv_core_asPoint(args[2]),
        hx_cv_core_asScalar(args[3]), val_get_int(args[4]), val_get_int(args[5]), val_get_int(args[6]));
    return val_null;
);
CV_PRIM_MULT(core, putText, 9,
    cv::putText(hx_cv_core_mat(args[0]), val_get_string(args[1]), hx_cv_core_asPoint(args[2]),
        val_get_int(args[3]), val_get_double(args[4]), hx_cv_core_asScalar(args[5]),
        val_get_int(args[6]), val_get_int(args[7]), val_get_bool(args[8]));
    return val_null;
);

extern "C" void core_allocateKinds() {
    k_Mat = alloc_kind();
    k_Point = alloc_kind();
    k_Point2D32f = alloc_kind();
    k_Point2D64f = alloc_kind();
    k_Point3D32f = alloc_kind();
    k_Point3D64f = alloc_kind();
    k_Size = alloc_kind();
    k_Size2D32f = alloc_kind();
    k_Rect = alloc_kind();
    k_Scalar = alloc_kind();
    k_TermCriteria = alloc_kind();
}
