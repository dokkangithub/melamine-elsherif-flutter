import 'package:flutter/material.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../domain/wishlist/entities/wishlist_details.dart';
import '../../../domain/wishlist/usecases/add_wishlist_usecases.dart';
import '../../../domain/wishlist/usecases/check_wishlist_usecases.dart';
import '../../../domain/wishlist/usecases/get_wishlist_usecases.dart';
import '../../../domain/wishlist/usecases/remove_wishlist_usecases.dart';

class WishlistProvider extends ChangeNotifier {
  final GetWishlistUseCase getWishlistUseCase;
  final CheckWishlistUseCase checkWishlistUseCase;
  final AddToWishlistUseCase addToWishlistUseCase;
  final RemoveFromWishlistUseCase removeFromWishlistUseCase;

  WishlistProvider({
    required this.getWishlistUseCase,
    required this.checkWishlistUseCase,
    required this.addToWishlistUseCase,
    required this.removeFromWishlistUseCase,
  });

  LoadingState wishlistState = LoadingState.loading;
  List<WishlistItem> wishlistItems = [];
  String wishlistError = '';

  // Map for tracking wishlist status - product slug to boolean (in wishlist or not)
  Map<String, bool> wishlistStatus = {};

  // Alternative approach: Set of product slugs in wishlist for quick lookup
  Set<String> _wishlistSlugs = {};

  String? lastActionMessage;

  // Check if a product is in wishlist using the Set
  bool isProductInWishlist(String slug) {
    return _wishlistSlugs.contains(slug);
  }

  Future<void> fetchWishlist() async {
    try {
      wishlistState = LoadingState.loading;
      notifyListeners();

      wishlistItems = await getWishlistUseCase();

      // Update both tracking systems
      _updateWishlistTracking();

      wishlistState = LoadingState.loaded;
    } catch (e) {
      wishlistState = LoadingState.error;
      wishlistError = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Helper method to update tracking data structures
  void _updateWishlistTracking() {
    // Clear and repopulate tracking structures
    wishlistStatus.clear();
    _wishlistSlugs.clear();

    // Update based on current wishlist items
    for (var item in wishlistItems) {
      wishlistStatus[item.slug] = true;
      _wishlistSlugs.add(item.slug);
    }
  }

  Future<bool> isInWishlist(String slug) async {
    // First check local tracking for quick response
    if (wishlistStatus.containsKey(slug)) {
      return wishlistStatus[slug] ?? false;
    }

    if (_wishlistSlugs.contains(slug)) {
      return true;
    }

    // If not in local tracking, check with backend
    try {
      final check = await checkWishlistUseCase(slug);

      // Update both tracking systems
      wishlistStatus[slug] = check.isInWishlist;
      if (check.isInWishlist) {
        _wishlistSlugs.add(slug);
      }

      notifyListeners();
      return check.isInWishlist;
    } catch (e) {
      wishlistError = e.toString();
      return false;
    }
  }

  Future<void> addToWishlist(String slug) async {
    try {
      final result = await addToWishlistUseCase(slug);

      // Update both tracking systems
      wishlistStatus[slug] = result.isInWishlist;
      if (result.isInWishlist) {
        _wishlistSlugs.add(slug);
      }

      lastActionMessage = result.message;

      // Optional: fetch all items to ensure consistency
      await fetchWishlist();

      notifyListeners();
    } catch (e) {
      wishlistError = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String slug) async {
    try {
      final result = await removeFromWishlistUseCase(slug);

      // Update both tracking systems
      wishlistStatus[slug] = result.isInWishlist;
      _wishlistSlugs.remove(slug);

      lastActionMessage = result.message;

      // Optional: fetch all items to ensure consistency
      await fetchWishlist();

      notifyListeners();
    } catch (e) {
      wishlistError = e.toString();
      notifyListeners();
    }
  }

  // Method to clear the entire wishlist
  Future<void> clearWishlist() async {
    try {
      // Create a copy to avoid modifying during iteration
      final itemsToRemove = List<WishlistItem>.from(wishlistItems);

      for (var item in itemsToRemove) {
        await removeFromWishlist(item.slug);
      }

      // Clear tracking structures
      wishlistStatus.clear();
      _wishlistSlugs.clear();

      lastActionMessage = "Wishlist cleared successfully";
      notifyListeners();
    } catch (e) {
      wishlistError = e.toString();
      notifyListeners();
    }
  }

  // Toggle wishlist status - convenience method
  Future<void> toggleWishlistStatus(BuildContext context, String slug) async {
    // Check current status and toggle
    bool currentStatus = _wishlistSlugs.contains(slug);

    if (currentStatus) {
      await removeFromWishlist(slug);
    } else {
      await addToWishlist(slug);
    }
  }
}