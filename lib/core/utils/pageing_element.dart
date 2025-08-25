class PaginationHandler<T> {
  int currentPage;
  final int pageSize;
  bool isLoading;
  bool isFirstLoad;
  int totalItems;
  List<T> items;

  PaginationHandler({
    this.currentPage = 0,
    this.pageSize = 10,
    this.isLoading = false,
    this.isFirstLoad = true,
    this.totalItems = 0,
    List<T>? items,
  }) : items = items ?? [];

  bool get hasMore => items.length < totalItems;

  void reset() {
    currentPage = 0;
    totalItems = 0;
    items.clear();
    isFirstLoad = true;
    isLoading = false;
  }

  void addItems(List<T> newItems, int total) {
    if (newItems.isNotEmpty) {
      items.addAll(newItems);
      currentPage++;
      totalItems = total;
      isFirstLoad = false;
    }
  }
}
