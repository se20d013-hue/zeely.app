import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../utils/utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final n = await SupabaseService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = n;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'payment_due':
        return Icons.alarm_rounded;
      case 'payment_received':
        return Icons.check_circle_rounded;
      case 'loan_approved':
        return Icons.thumb_up_rounded;
      case 'loan_rejected':
        return Icons.cancel_rounded;
      case 'overdue':
        return Icons.warning_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColor(String? type) {
    switch (type) {
      case 'payment_due':
        return AppColors.warning;
      case 'payment_received':
        return AppColors.success;
      case 'loan_approved':
        return AppColors.success;
      case 'loan_rejected':
        return AppColors.error;
      case 'overdue':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Мэдэгдлүүд'),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight),
            )
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Мэдэгдэл байхгүй',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _notifications.length,
                  itemBuilder: (context, i) {
                    final n = _notifications[i];
                    final isRead = n['is_read'] == true;
                    final color = _getColor(n['type']);
                    return GestureDetector(
                      onTap: () {
                        SupabaseService.markNotificationRead(n['id']);
                        setState(() => _notifications[i]['is_read'] = true);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isRead
                              ? AppColors.surface
                              : color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isRead
                                ? AppColors.border
                                : color.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIcon(n['type']),
                                color: color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n['title'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n['body'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppUtils.formatDateTime(
                                      DateTime.parse(n['created_at']),
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 11,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
