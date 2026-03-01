import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/local_storage_service.dart';

part 'server_settings_provider.g.dart';

@Riverpod(keepAlive: true)
class ServerUrl extends _$ServerUrl {
  @override
  String build() {
    final storage = ref.watch(localStorageServiceProvider);

    // Non possiamo usare async qui direttamente in build per Dio,
    // quindi usiamo un valore iniziale e carichiamo asincronamente
    _loadFromStorage(storage);

    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';
  }

  Future<void> _loadFromStorage(LocalStorageService storage) async {
    final savedUrl = await storage.loadServerUrl();
    if (savedUrl != null && savedUrl.isNotEmpty) {
      state = savedUrl;
    }
  }

  Future<void> setUrl(String url) async {
    state = url;
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveServerUrl(url);
  }
}
