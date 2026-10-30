import 'package:flutter/material.dart';

import 'app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Giao diện'),
                  subtitle: const Text('Màu chủ đạo và cỡ chữ'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AppearanceScreen(),
                    ),
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.animation_outlined),
                  title: const Text('Giảm chuyển động'),
                  subtitle: const Text('Hạn chế hiệu ứng chuyển cảnh'),
                  value: settings.reduceMotion,
                  onChanged: (value) => settings.update(lessMotion: value),
                ),
              ],
            ),
          ),
          if (settings.storageError != null) Text(settings.storageError!),
        ],
      ),
    );
  }
}

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Giao diện')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Chọn màu của bạn', style: text.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Áp dụng ngay và ghi nhớ trên thiết bị này cho tài khoản của bạn.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final entry in AppSettings.colors.entries)
                ChoiceChip(
                  avatar: CircleAvatar(
                    backgroundColor: entry.value,
                    radius: 10,
                  ),
                  label: Text(entry.key),
                  selected: settings.colorName == entry.key,
                  onSelected: (_) => settings.update(color: entry.key),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Text('Cỡ chữ', style: text.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in AppSettings.textSizes.entries)
                ChoiceChip(
                  label: Text(entry.key),
                  selected: settings.textScale == entry.value,
                  onSelected: (_) => settings.update(scale: entry.value),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text('Căn phòng của bạn', style: text.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Chữ rõ ràng, màu sắc nhẹ nhàng. Bạn có thể đổi lại bất cứ lúc nào.',
                  ),
                ],
              ),
            ),
          ),
          if (settings.storageError != null) ...[
            Text(settings.storageError!),
            TextButton(
              onPressed: () => settings.update(),
              child: const Text('Lưu lại'),
            ),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: settings.reset,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Về mặc định'),
          ),
        ],
      ),
    );
  }
}
