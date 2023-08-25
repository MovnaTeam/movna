import 'package:meta/meta.dart';
import 'package:movna/data/exceptions.dart';

/// Abstract class to convert a model to a domain entity and vice-versa.
abstract class BaseAdapter<Entity, Model> {
  /// Converts model class [m] to its entity equivalent.
  ///
  /// Throws a [ConversionException] if the conversion fails
  @nonVirtual
  Entity convertModel(Model m) {
    try {
      return modelToEntity(m);
    } catch (e, s) {
      throw ConversionException<Entity, Model>(e, s);
    }
  }

  /// Converts entity class [e] to its model equivalent.
  ///
  /// Throws a [ConversionException] if the conversion fails
  @nonVirtual
  Model convertEntity(Entity e) {
    try {
      return entityToModel(e);
    } catch (e, s) {
      throw ConversionException<Model, Entity>(e, s);
    }
  }

  /// Converts model class [m] to its entity equivalent.
  ///
  /// Subclasses that want to handle model to entity conversion should implement
  /// this.
  @protected
  Entity modelToEntity(Model m) {
    // Method is defined so that subclasses don't have to implement it
    // if they don't need it.
    throw UnimplementedError();
  }

  /// Converts domain entity class [e] to its model equivalent.
  ///
  /// Subclasses that want to handle entity to model conversion should implement
  /// this.
  @protected
  Model entityToModel(Entity e) {
    // Method is defined so that subclasses don't have to implement it
    // if they don't need it.
    throw UnimplementedError();
  }

  /// Converts a model to an entity and returns null if given model is null.
  /// Can still throw exception if conversion fails.
  Entity? modelToEntityOrNull(Model? model) {
    return model == null ? null : modelToEntity(model);
  }

  /// Converts an entity to a model and returns null if given entity is null.
  /// Can still throw exception if conversion fails.
  Model? entityToModelOrNull(Entity? entity) {
    return entity == null ? null : entityToModel(entity);
  }

  /// Converts a model to an entity and returns null if the conversion failed.
  Entity? tryModelToEntity(Model? model) {
    try {
      return model == null ? null : modelToEntity(model);
    } catch (e) {
      return null;
    }
  }

  /// Converts an Entity to a model and returns null if the conversion failed.
  Model? tryEntityToModel(Entity? entity) {
    try {
      return entity == null ? null : entityToModel(entity);
    } catch (e) {
      return null;
    }
  }

  /// Converts a list of [Model]s to a list of non nullable [Entity]s.
  ///
  /// If [ignoreErrors] is `false`, this method will throw on conversion error.
  /// Otherwise it will ignore the faulty models and return only the list of
  /// successful conversions.
  List<Entity> modelsToEntities(
    Iterable<Model>? models, {
    bool ignoreErrors = true,
  }) {
    final converter = ignoreErrors ? tryModelToEntity : modelToEntity;
    return models
            ?.map((model) => converter(model))
            .whereType<Entity>()
            .toList(growable: true) ??
        [];
  }

  /// Converts a list of [Entity]s to a list of [Model]s,
  List<Model> entitiesToModels(Iterable<Entity>? entities) {
    return entities
            ?.map((entity) => entityToModel(entity))
            .whereType<Model>()
            .toList(growable: true) ??
        [];
  }
}
