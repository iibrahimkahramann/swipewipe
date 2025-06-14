import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

final albumListProvider = FutureProvider<List<AssetPathEntity>>((ref) async {
  final permission = await PhotoManager.requestPermissionExtend();
  if (!permission.isAuth) return [];

  final albums = await PhotoManager.getAssetPathList(
    type: RequestType.all,
    filterOption: FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
    ),
  );

  return albums;
});
