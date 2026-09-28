import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avm_global_web/services/notification_service.dart';

class JobAlertBanner extends StatefulWidget {
  final String? searchKeyword;
  final VoidCallback? onDismissed;
  final VoidCallback? onSubscribed;

  const JobAlertBanner({
    super.key,
    this.searchKeyword,
    this.onDismissed,
    this.onSubscribed,
  });

  /// Static helper to display the banner in an Overlay
  static OverlayEntry? show(
    BuildContext context, {
    String? searchKeyword,
    VoidCallback? onSubscribed,
  }) {
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;

        return Positioned(
          top: isMobile ? 16 : 24,
          right: isMobile ? 16 : 24,
          left: isMobile ? 16 : null,
          child: Material(
            color: Colors.transparent,
            child: JobAlertBanner(
              searchKeyword: searchKeyword,
              onDismissed: () => entry.remove(),
              onSubscribed: () {
                entry.remove();
                onSubscribed?.call();
              },
            ),
          ),
        );
      },
    );

    overlayState.insert(entry);
    return entry;
  }

  @override
  State<JobAlertBanner> createState() => _JobAlertBannerState();
}

class _JobAlertBannerState extends State<JobAlertBanner> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleAllowAlerts() async {
    setState(() => _isLoading = true);
    final keyword = widget.searchKeyword?.trim() ?? 'all';
    await NotificationService.instance.subscribeToSearchTopic(keyword);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        widget.onSubscribed?.call();
      }
    }
  }

  void _handleDismiss() {
    _animController.reverse().then((_) {
      if (mounted) {
        widget.onDismissed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final bannerWidth = isMobile ? screenWidth - 32 : 380.0;

    final hasKeyword = widget.searchKeyword != null && widget.searchKeyword!.trim().isNotEmpty;
    final keywordLabel = widget.searchKeyword?.trim() ?? '';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: isMobile ? Alignment.topCenter : Alignment.topRight,
        child: Container(
          width: bannerWidth,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A192F), // Dark Navy
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF146EB8).withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF146EB8).withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bell Icon with glowing backdrop
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF146EB8), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF146EB8).withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title & Dismiss
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSuccess
                              ? 'Job Alerts Activated!'
                              : (hasKeyword ? 'Get Alerts for "$keywordLabel"' : 'Turn on Job Alerts'),
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: hasKeyword ? TextOverflow.ellipsis : TextOverflow.clip,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _isSuccess
                              ? 'You will receive instant notifications for new openings.'
                              : (hasKeyword
                                  ? 'Get notified instantly when new "$keywordLabel" jobs are posted.'
                                  : 'Get notified immediately about newly posted international openings.'),
                          style: GoogleFonts.notoSans(
                            fontSize: 12.5,
                            color: const Color(0xFF94A3B8),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Dismiss',
                    onPressed: _handleDismiss,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Action Buttons
              if (!_isSuccess)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _handleDismiss,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Not Now',
                        style: GoogleFonts.notoSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleAllowAlerts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF146EB8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  'Allow Alerts',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Subscribed successfully',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
