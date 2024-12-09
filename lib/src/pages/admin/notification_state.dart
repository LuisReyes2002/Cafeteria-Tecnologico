// notification_state.dart
abstract class NotificationBaseState {}

class NotificationInitial extends NotificationBaseState {}

class NotificationLoading extends NotificationBaseState {}

class NotificationSuccess extends NotificationBaseState {
  final String message;

  NotificationSuccess(this.message);
}

class NotificationFailure extends NotificationBaseState {
  final String error;

  NotificationFailure(this.error);
}
