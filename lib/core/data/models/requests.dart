abstract interface class Request<T> {
  Map<String, dynamic> toJson();
}

abstract interface class CreateRequest implements Request {}

abstract interface class DeleteRequest implements Request {}
