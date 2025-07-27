import 'package:objectbox/objectbox.dart';
import '../../../../core/database/objectbox_store.dart';
import '../../../../core/database/timestamp_service.dart';
import '../../../../objectbox.g.dart';
import '../models/set_products_model.dart';

abstract class SetProductsLocalDataSource {
  Future<bool> isCollectionCacheValid(String collectionType, int page);
  Future<List<DatumModel>?> getCollectionFromCache(String collectionType, int page);
  Future<void> saveCollection(String collectionType, int page, List<DatumModel> products, int totalPages);
  Future<void> clearCache();
}

class SetProductsLocalDataSourceImpl implements SetProductsLocalDataSource {
  final ObjectBox objectBox;
  final TimestampService timestampService;

  SetProductsLocalDataSourceImpl({
    required this.objectBox,
    required this.timestampService,
  });

  @override
  Future<bool> isCollectionCacheValid(String collectionType, int page) async {
    final query = objectBox.setProductCollectionBox.query(
      SetProductCollectionEntity_.collectionType.equals(collectionType) &
      SetProductCollectionEntity_.page.equals(page)
    ).build();
    final collection = query.findFirst();
    query.close();
    if (collection == null) return false;
    return timestampService.isCacheValid(collection.timestamp);
  }

  @override
  Future<List<DatumModel>?> getCollectionFromCache(String collectionType, int page) async {
    final query = objectBox.setProductCollectionBox.query(
      SetProductCollectionEntity_.collectionType.equals(collectionType) &
      SetProductCollectionEntity_.page.equals(page)
    ).build();
    final collection = query.findFirst();
    query.close();
    if (collection == null) return null;
    return collection.setProducts.map((e) => e.toModel()).toList();
  }

  @override
  Future<void> saveCollection(String collectionType, int page, List<DatumModel> products, int totalPages) async {
    objectBox.store.runInTransaction(TxMode.write, () {
      final timestamp = timestampService.getCurrentTimestamp();
      final existingQuery = objectBox.setProductCollectionBox.query(
        SetProductCollectionEntity_.collectionType.equals(collectionType) &
        SetProductCollectionEntity_.page.equals(page)
      ).build();
      final existingCollection = existingQuery.findFirst();
      existingQuery.close();
      final collection = existingCollection ?? SetProductCollectionEntity(
        collectionType: collectionType,
        page: page,
        totalPages: totalPages,
        timestamp: timestamp,
      );
      if (existingCollection != null) {
        collection.timestamp = timestamp;
        collection.totalPages = totalPages;
        collection.setProducts.clear();
      }
      for (final model in products) {
        final entity = SetProductEntity.fromModel(model, timestamp);
        objectBox.setProductBox.put(entity);
        collection.setProducts.add(entity);
      }
      objectBox.setProductCollectionBox.put(collection);
    });
  }

  @override
  Future<void> clearCache() async {
    objectBox.setProductBox.removeAll();
    objectBox.setProductCollectionBox.removeAll();
  }
} 