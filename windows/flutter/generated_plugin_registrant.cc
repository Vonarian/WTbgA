//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audioplayers_windows/audioplayers_windows_plugin.h>
#include <dynamic_color/dynamic_color_plugin_c_api.h>
#include <flutter_acrylic/flutter_acrylic_plugin.h>
#include <hotkey_manager/hotkey_manager_plugin.h>
#include <screen_retriever/screen_retriever_plugin.h>
#include <system_theme/system_theme_plugin.h>
#include <tray_manager/tray_manager_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <win_toast/win_toast_plugin.h>
#include <window_manager/window_manager_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AudioplayersWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AudioplayersWindowsPlugin"));
  DynamicColorPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DynamicColorPluginCApi"));
  FlutterAcrylicPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterAcrylicPlugin"));
  HotkeyManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("HotkeyManagerPlugin"));
  ScreenRetrieverPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverPlugin"));
  SystemThemePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SystemThemePlugin"));
  TrayManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("TrayManagerPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WinToastPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WinToastPlugin"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
}
