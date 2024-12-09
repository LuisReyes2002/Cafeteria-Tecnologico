// notification_event.dart
abstract class NotificationEvent {}

class NewOrderEvent extends NotificationEvent {
  final String orderId;

  NewOrderEvent(this.orderId);
}

// notification_state.dart
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final String message;

  NotificationSuccess(this.message);
}

class NotificationFailure extends NotificationState {
  final String error;

  NotificationFailure(this.error);
}
