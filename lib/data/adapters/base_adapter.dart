/// Abstract class to convert a model to a domain entity and vice-versa.
abstract class BaseAdapter<Entity, Model> {
  /// Converts model class [m] to its entity equivalent.
  Entity modelToEntity(Model m) {
    // Method is defined so that subclasses don't have to implement it
    // if they don't need it.
    throw UnimplementedError();
  }

  /// Converts domain entity class [m] to its model equivalent.
  Model entityToModel(Entity e) {
    // Method is defined so that subclasses don't have to implement it
    // if they don't need it.
    throw UnimplementedError();
  }
}