import 'package:flame/components.dart';

class ObjectPool<T extends Component> {
  final List<T> _pool = [];
  final T Function() create;

  List<T> get pool => _pool;

  ObjectPool({required this.create});

  T obtain() {
    if (_pool.isNotEmpty) 
    {
      return _pool.removeLast();
    } 
    else 
    {
      return create();
    }
  }

  void release(T object) 
  {
    _pool.add(object);
  }

  void preload(int count) 
  {
    for (int i = 0; i < count; i++) 
    {
      _pool.add(create());
    }
  }
}
