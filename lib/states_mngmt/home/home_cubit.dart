import 'package:bloc/bloc.dart';
import 'package:chat/chat.dart';
import 'package:chatapp/cache/local_cache.dart';
import 'package:chatapp/states_mngmt/home/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  IUserService _userService;
  ILocalCache _localCache;

  HomeCubit(this._userService, this._localCache) : super(HomeInitial());

  Future<User> connect() async {
    final userJson = _localCache.fetch('USER');
    userJson['last_seen'] = DateTime.now();
    userJson['active'] = true;

    final user = User.fromJson(userJson);
    await _userService.connect(user);
    return user;
  }

  Future<void> activeUsers(User currentUser) async {
    emit(HomeLoading());
    final users = await _userService.online();
    users.removeWhere((ele) => ele.id == currentUser.id);
    emit(HomeSuccess(users));
  }
}
