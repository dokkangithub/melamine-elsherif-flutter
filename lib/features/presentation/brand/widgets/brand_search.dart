import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_form_field.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../../core/config/themes.dart/theme.dart';

class BrandSearch extends StatefulWidget {
  final Function(String) onSearch;

  const BrandSearch({super.key, required this.onSearch});

  @override
  State<BrandSearch> createState() => _BrandSearchState();
}

class _BrandSearchState extends State<BrandSearch> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: _searchController,
      hint: 'search_brands'.tr(context),
      prefixIcon: Image.asset(
        AppImages.search,
        color: AppTheme.primaryColor,
        width: 20,
        height: 20,
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (value) {
        widget.onSearch(value);
      },
    );
  }
}
