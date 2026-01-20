//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <amwal_pay_sdk/amwal_s_d_k_linux.h>
#include <url_launcher_linux/url_launcher_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) amwal_pay_sdk_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AmwalSDKLinux");
  amwal_s_d_k_linux_register_with_registrar(amwal_pay_sdk_registrar);
  g_autoptr(FlPluginRegistrar) url_launcher_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UrlLauncherPlugin");
  url_launcher_plugin_register_with_registrar(url_launcher_linux_registrar);
}
