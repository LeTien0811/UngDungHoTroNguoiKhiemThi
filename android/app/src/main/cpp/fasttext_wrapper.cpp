#include "fasttext/src/fasttext.h"
#include <string>
#include <cstring>
#include <vector>
#include <sstream>

#if defined(_WIN32)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

extern "C" {
EXPORT void* create_fasttext() {
    return new fasttext::FastText();
}

EXPORT void load_model(void* handle, const char* path) {
    auto ft = static_cast<fasttext::FastText*>(handle);
    ft->loadModel(std::string(path));
}

EXPORT const char* predict_intent(void* handle, const char* text) {
    auto ft = static_cast<fasttext::FastText*>(handle);
    std::vector<std::pair<fasttext::real, std::string>> predictions;

    std::stringstream ss(text);

    ft->predictLine(ss, predictions, 1, 0.0);

    if (predictions.empty()) {
        return strdup("UNKNOWN");
    }

    std::string result = predictions[0].second;
    return strdup(result.c_str());
}

EXPORT void free_string(const char* str) {
    if (str != nullptr) {
        free((void*)str);
    }
}

EXPORT void destroy_fasttext(void* handle) {
    if (handle != nullptr) {
        auto ft = static_cast<fasttext::FastText*>(handle);
        delete ft;
    }
}
}