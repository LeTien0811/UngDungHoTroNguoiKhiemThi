cmake_minimum_required(VERSION 3.22.1)

# 1. Khai báo Project (Giúp IDE nhận diện tốt hơn)
project(ImageOptimizer)

# 2. Bật chuẩn C++17 - BẮT BUỘC cho OpenCV 4.x và PaddleOCR sau này
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 3. Chỉ đường tới thư mục OpenCV (Đảm bảo folder 'opencv' nằm cùng cấp với file này)
set(OpenCV_DIR ${CMAKE_SOURCE_DIR}/opencv/sdk/native/jni)
find_package(OpenCV REQUIRED)

# 4. Gom nhóm các file source (Sau này ông có thêm ocr_engine.cpp thì cứ nhét vào đây)
set(SOURCE_FILES image_optimizer.cpp)

# 5. Tạo thư viện động .so
add_library(image_optimizer SHARED ${SOURCE_FILES})

# 6. Chỉ định các thư mục chứa header (.h)
target_include_directories(image_optimizer PRIVATE ${OpenCV_INCLUDE_DIRS})

# 7. Kết nối thư viện (OpenCV + Log Android)
target_link_libraries(image_optimizer
        ${OpenCV_LIBS}
        log     # Thư viện để ông dùng __android_log_print trong C++
)