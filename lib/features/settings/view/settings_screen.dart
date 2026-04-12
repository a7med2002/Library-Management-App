import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_profile_card.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _SettingsHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Profile Card ──────────────────────
                  Obx(() => SettingsProfileCard(
                        name: controller.employeeName.value,
                        email: controller.employeeEmail.value,
                        onSignOut: controller.signOut,
                      )),
                  const SizedBox(height: 20),

                  // ── App Section ───────────────────────
                  SettingsSection(
                    title: 'التطبيق',
                    children: [
                      Obx(() => SettingsTile(
                            icon: Icons.storefront_rounded,
                            label: 'اسم المتجر',
                            value: controller.storeName.value,
                            onTap: controller.goToStoreName,
                          )),
                      Obx(() => SettingsTile(
                            icon: Icons.attach_money_rounded,
                            label: 'العملة الافتراضية',
                            value: controller.defaultCurrency.value,
                            onTap: controller.goToCurrency,
                            showDivider: false,
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Employees Section ─────────────────
                  SettingsSection(
                    title: 'الموظفون',
                    children: [
                      Obx(() => SettingsTile(
                            icon: Icons.group_rounded,
                            label: 'إدارة الموظفين',
                            value:
                                '${controller.employeesCount.value} موظفين',
                            onTap: controller.goToEmployees,
                            showDivider: false,
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── About Section ─────────────────────
                  SettingsSection(
                    title: 'حول التطبيق',
                    children: [
                      Obx(() => SettingsTile(
                            icon: Icons.info_outline_rounded,
                            label: 'الإصدار',
                            value: controller.appVersion.value,
                            showArrow: false,
                          )),
                      SettingsTile(
                        icon: Icons.mail_outline_rounded,
                        label: 'تواصل معنا',
                        onTap: controller.goToContactUs,
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────
class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        right: 16,
        left: 16,
      ),
      color: kBackgroundColor,
      child: Text('الإعدادات', style: AppTextStyles.titleMedium),
    );
  }
}