import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/common/responsive_layout.dart';
import 'package:anet_merchants/core/localization/app_language.dart';

class SearchableDropdownField extends StatefulWidget {
  final List<String> values;
  final String? selectedValue;
  final String Function(String value) labelOf;
  final ValueChanged<String?>? onChanged;
  final IconData icon;
  final bool isLoading;
  final bool enabled;
  final String? searchHint;
  final String? emptyLabel;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const SearchableDropdownField({
    super.key,
    required this.values,
    required this.selectedValue,
    required this.labelOf,
    required this.onChanged,
    this.icon = Icons.storefront_rounded,
    this.isLoading = false,
    this.enabled = true,
    this.searchHint,
    this.emptyLabel,
    this.height = 48,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
  });

  @override
  State<SearchableDropdownField> createState() =>
      _SearchableDropdownFieldState();
}

class _SearchableDropdownFieldState extends State<SearchableDropdownField> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  double _menuWidth = 320;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_rebuildOverlay);
  }

  @override
  void didUpdateWidget(covariant SearchableDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isOpen && oldWidget.selectedValue != widget.selectedValue) {
      _close();
    }
  }

  @override
  void deactivate() {
    _removeOverlay();
    _isOpen = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _searchController.removeListener(_rebuildOverlay);
    _removeOverlay();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  AppTextStyle get _style => AppTextStyle(
        kIsWeb && AppBreakpoints.isTabletOrLarger(context)
            ? AppPlatform.web
            : AppPlatform.mobile,
      );

  String get _selectedLabel {
    final selected = widget.selectedValue;
    if (selected == null || selected.isEmpty) {
      return '';
    }
    if (!widget.values.contains(selected)) {
      return widget.labelOf(widget.values.isEmpty ? selected : widget.values.first);
    }
    return widget.labelOf(selected);
  }

  List<String> get _filteredValues {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.values;
    }

    return widget.values.where((value) {
      final label = widget.labelOf(value).toLowerCase();
      return label.contains(query) || value.toLowerCase().contains(query);
    }).toList();
  }

  void _rebuildOverlay() {
    if (!mounted || _overlayEntry == null) {
      return;
    }
    _overlayEntry!.markNeedsBuild();
  }

  void _toggle() {
    if (widget.isLoading || !widget.enabled || widget.onChanged == null) {
      return;
    }
    if (_isOpen) {
      _close();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    if (!mounted || _overlayEntry != null) {
      return;
    }
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      _menuWidth = renderObject.size.width;
    }
    _searchController.clear();
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocus.requestFocus();
      }
    });
  }

  void _close() {
    _removeOverlay();
    if (_isOpen && mounted) {
      setState(() => _isOpen = false);
    } else {
      _isOpen = false;
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _select(String value) {
    _close();
    widget.onChanged?.call(value);
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    if (!mounted) {
      return const SizedBox.shrink();
    }
    final media = MediaQuery.of(overlayContext);
    final maxMenuHeight = (media.size.height * 0.45).clamp(180.0, 420.0);
    final width = _menuWidth;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 6),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): _close,
            },
            child: Material(
              color: context.appSurface,
              elevation: 10,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        autofocus: kIsWeb,
                        textInputAction: TextInputAction.search,
                        style: _style.h5.copyWith(
                          color: context.appTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText:
                              widget.searchHint ?? context.tr('search_terminal'),
                          hintStyle: _style.h5.copyWith(
                            color: context.appTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: context.appSurfaceAlt,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: context.appBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: context.appBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: _filteredValues.isEmpty
                          ? 72
                          : (_filteredValues.length * 44.0)
                              .clamp(44.0, maxMenuHeight),
                      child: _filteredValues.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                              child: Text(
                                widget.emptyLabel ??
                                    context.tr('no_matching_terminals'),
                                textAlign: TextAlign.center,
                                style: _style.h5.copyWith(
                                  color: context.appTextSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 8),
                              itemCount: _filteredValues.length,
                              itemBuilder: (context, index) {
                                final value = _filteredValues[index];
                                final selected = value == widget.selectedValue;
                                return InkWell(
                                  onTap: () => _select(value),
                                  child: Container(
                                    color: selected
                                        ? AppColors.primaryPurple
                                            .withValues(alpha: 0.08)
                                        : null,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 11,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          widget.icon,
                                          color: AppColors.primaryPurple,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            widget.labelOf(value),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: _style.h5.copyWith(
                                              color: context.appTextPrimary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(color: context.appBorder),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: AppColors.primaryPurple,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.isLoading
                        ? context.tr('loading')
                        : _selectedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _style.h5.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  _isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primaryPurple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
