# MatchMatter Project

MatchMatter is a Flutter project designed to manage and organize sports matches efficiently.

## Getting Started Guide

### 1. 环境设置

要运行MatchMatter Flutter项目，请按照以下步骤设置您的开发环境。

#### 1.1 安装 Flutter SDK

1. 前往 [Flutter 官方网站](https://flutter.dev/docs/get-started/install)。
2. 下载适用于您操作系统的Flutter SDK并解压。
3. 将Flutter添加到您的环境变量中。
   - 对于macOS和Linux用户：
     ```sh
     export PATH="$PATH:`pwd`/flutter/bin"
     ```
   - 对于Windows用户：
     - 将Flutter SDK的`bin`目录路径添加到环境变量中。

#### 1.2 安装依赖工具

1. 安装Dart SDK（Flutter已经包含Dart SDK）。
2. 确保安装了以下工具：
   - Git
   - Android Studio（用于Android模拟器）
   - Visual Studio Code（VS Code）

#### 1.3 安装 VS Code

1. 前往 [VS Code 官方网站](https://code.visualstudio.com/) 并下载最新版本的VS Code。
2. 按照安装向导安装VS Code。

#### 1.4 配置 VS Code 插件

1. 打开VS Code。
2. 转到左侧活动栏中的扩展视图图标或按下 `Ctrl+Shift+X`。
3. 在搜索栏中输入 `Flutter` 并安装 `Flutter` 插件，它将自动安装Dart插件。

#### 1.5 配置 Android 虚拟设备（AVD）

1. 打开Android Studio（仅用于配置AVD）。
2. 选择 `AVD Manager`，然后点击 `Create Virtual Device`。
3. 选择一个设备模型，然后点击 `Next`。
4. 选择一个系统镜像，然后点击 `Next`。
5. 按照提示完成AVD的创建。

#### 1.6 安装 Flutter 依赖包

在项目根目录下运行以下命令来安装所需的依赖包：
```sh
flutter pub get

## 2.2 使用 VS Code 运行和调试

打开VS Code并打开MatchMatter项目文件夹。在左侧活动栏中点击 Run 图标或按 `Ctrl+Shift+D` 打开调试面板。点击 Run and Debug 按钮，选择 Flutter 模板。选择连接的设备或模拟器，然后点击运行按钮开始调试。

## 2.3 热重载和热重启

在开发过程中，可以使用以下命令进行热重载和热重启：

- 热重载：按 `r` 键
- 热重启：按 `R` 键
