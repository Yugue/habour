#!/bin/bash

# Create fonts directory if it doesn't exist
mkdir -p assets/fonts

# Download Libre Baskerville fonts
curl -L "https://fonts.gstatic.com/s/librebaskerville/v14/kmKnZrc3Hgbbcjq75U4uslyuy4kn0qNZaxM.ttf" -o "assets/fonts/LibreBaskerville-Regular.ttf"
curl -L "https://fonts.gstatic.com/s/librebaskerville/v14/kmKiZrc3Hgbbcjq75U4uslyuy4kn0qviTjY5KcY.ttf" -o "assets/fonts/LibreBaskerville-Bold.ttf"
curl -L "https://fonts.gstatic.com/s/librebaskerville/v14/kmKhZrc3Hgbbcjq75U4uslyuy4kn0qNcaxZW-Ew.ttf" -o "assets/fonts/LibreBaskerville-Italic.ttf"

# Download Montserrat fonts
curl -L "https://fonts.gstatic.com/s/montserrat/v25/JTUHjIg1_i6t8kCHKm4532VJOt5-QNFgpCtr6Hw5aX8.ttf" -o "assets/fonts/Montserrat-Regular.ttf"
curl -L "https://fonts.gstatic.com/s/montserrat/v25/JTUHjIg1_i6t8kCHKm4532VJOt5-QNFgpCu173w5aX8.ttf" -o "assets/fonts/Montserrat-Medium.ttf"
curl -L "https://fonts.gstatic.com/s/montserrat/v25/JTUHjIg1_i6t8kCHKm4532VJOt5-QNFgpCu173w5aX8.ttf" -o "assets/fonts/Montserrat-SemiBold.ttf"
curl -L "https://fonts.gstatic.com/s/montserrat/v25/JTUHjIg1_i6t8kCHKm4532VJOt5-QNFgpCtZ6Hw5aX8.ttf" -o "assets/fonts/Montserrat-Bold.ttf"

echo "Font files downloaded successfully." 