#include <opencv2/opencv.hpp>
#include <stdint.h>
#include <cstdlib>
#include <cstring>

extern "C" {
__attribute__((visibility("default"))) __attribute__((used))
uint8_t* preprocess_frame(uint8_t* raw_bytes, int width, int height, int* out_size) {
    if (raw_bytes == nullptr || width <= 0 || height <= 0) {
        *out_size = 0;
        return nullptr;
    }

    cv::Mat img(height, width, CV_8UC4, raw_bytes);
    cv::Mat gray, blurred, binarized;

    cv::cvtColor(img, gray, cv::COLOR_RGBA2GRAY);
    cv::GaussianBlur(gray, blurred, cv::Size(3, 3), 0);
    cv::adaptiveThreshold(blurred, binarized, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 11, 2);

    size_t size = binarized.total() * binarized.elemSize();
    *out_size = (int)size;

    uint8_t* result = (uint8_t*)malloc(size);
    if (result == nullptr) return nullptr;

    memcpy(result, binarized.data, size);
    return result;
}

__attribute__((visibility("default"))) __attribute__((used))
uint8_t* crop_and_enhance(uint8_t* raw_bytes, int img_w, int img_h, int x, int y, int w, int h, int* out_size) {
    if (raw_bytes == nullptr || img_w <= 0 || img_h <= 0) {
        *out_size = 0;
        return nullptr;
    }

    cv::Mat full_img(img_h, img_w, CV_8UC4, raw_bytes);
    cv::Rect roi(x, y, w, h);
    roi &= cv::Rect(0, 0, img_w, img_h);

    if (roi.width <= 0 || roi.height <= 0) {
        *out_size = 0;
        return nullptr;
    }

    cv::Mat cropped = full_img(roi).clone();
    cv::Mat gray, blurred, binarized;

    cv::cvtColor(cropped, gray, cv::COLOR_RGBA2GRAY);
    cv::GaussianBlur(gray, blurred, cv::Size(3, 3), 0);
    cv::adaptiveThreshold(blurred, binarized, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 11, 2);

    size_t size = binarized.total() * binarized.elemSize();
    *out_size = (int)size;

    uint8_t* result = (uint8_t*)malloc(size);
    if (result == nullptr) return nullptr;

    memcpy(result, binarized.data, size);
    return result;
}

__attribute__((visibility("default"))) __attribute__((used))
void free_memory(void* ptr) {
    if (ptr != nullptr) {
        free(ptr);
    }
}
}