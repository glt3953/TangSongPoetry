#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
from PIL import Image

def generate_app_icons(source_image_path, output_dir):
    """
    从源图像生成iOS应用所需的所有AppIcon尺寸
    
    :param source_image_path: 源图像文件路径（建议至少1024x1024像素）
    :param output_dir: 输出目录路径
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # 打开源图像
    try:
        source_image = Image.open(source_image_path)
    except Exception as e:
        print(f"无法打开源图像: {e}")
        return
    
    # 检查图像尺寸
    width, height = source_image.size
    if width < 1024 or height < 1024:
        print("警告: 源图像小于1024x1024像素，可能会导致较小尺寸的图标质量不佳")
    
    # iOS AppIcon尺寸列表 (尺寸, 文件名)
    icon_sizes = [
        (20, "icon-20.png"),
        (29, "icon-29.png"),
        (40, "icon-40.png"),
        (58, "icon-29@2x.png"),
        (60, "icon-60.png"),
        (76, "icon-76.png"),
        (80, "icon-40@2x.png"),
        (87, "icon-29@3x.png"),
        (120, "icon-40@3x.png"),
        (120, "icon-60@2x.png"),
        (152, "icon-76@2x.png"),
        (167, "icon-83.5@2x.png"),
        (180, "icon-60@3x.png"),
        (1024, "icon-1024.png")
    ]
    
    # 生成各种尺寸的图标
    for size, filename in icon_sizes:
        resized_image = source_image.resize((size, size), Image.LANCZOS)
        output_path = os.path.join(output_dir, filename)
        resized_image.save(output_path)
        print(f"已生成: {filename} ({size}x{size})")
    
    print(f"\n所有AppIcon已生成到: {output_dir}")
    print("请将这些图标添加到您的Xcode项目的Assets.xcassets中的AppIcon集合")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("用法: python generate_app_icons.py <源图像路径> <输出目录>")
        sys.exit(1)
    
    source_image_path = sys.argv[1]
    output_dir = sys.argv[2]
    
    generate_app_icons(source_image_path, output_dir)