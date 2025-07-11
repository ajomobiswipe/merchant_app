import 'dart:io';
import 'package:anet_merchant_app/presentation/widgets/widget.dart';
import 'package:dio/dio.dart';

void handleDioError(DioException e) {
  String message;

  // Extra safety in case e.response is null
  final statusCode = e.response?.statusCode;

  switch (e.type) {
    case DioExceptionType.cancel:
      message = "Request to API server was cancelled";
      break;

    case DioExceptionType.connectionTimeout:
      message =
          "Connection timed out. Server took too long to respond. Try again.";
      break;

    case DioExceptionType.sendTimeout:
      message = "Send timeout while sending request to server.";
      break;

    case DioExceptionType.receiveTimeout:
      message = "Receive timeout. Server did not respond in time.";
      break;

    case DioExceptionType.badResponse:
      message = _handleHttpStatus(statusCode, e);
      break;

    case DioExceptionType.connectionError:
      if (e.error is SocketException) {
        message = "No internet connection or server unreachable.";
      } else if (e.error.toString().contains("Connection reset by peer")) {
        message = "Server forcibly closed the connection.";
      } else {
        message = "Unexpected connection error: ${e.error}";
      }
      break;

    case DioExceptionType.badCertificate:
      message = "SSL Certificate verification failed.";
      break;

    case DioExceptionType.unknown:
      if (e.error is SocketException) {
        message = "No internet or DNS issue.";
      } else if (e.error.toString().contains("TimeoutException")) {
        message = "Request timed out. Please try again later.";
      } else if (e.error.toString().contains("Connection reset by peer")) {
        message = "Connection reset by server.";
      } else {
        message = "Unexpected error occurred: ${e.message ?? e.error}";
      }
      break;
  }

  AlertService().error(message);
}

String _handleHttpStatus(int? statusCode, DioException e) {
  switch (statusCode) {
    case 400:
      return "Bad Request - Invalid input";
    case 401:
      return "Unauthorized - Please check your credentials";
    case 403:
      return "Access Denied - You don't have permission";
    case 404:
      return "Not Found - Endpoint does not exist";
    case 500:
      return "Internal Server Error - Please try later";
    case 502:
      return "Bad Gateway - Invalid response from upstream server";
    case 503:
      return "Service Unavailable - Server overloaded or under maintenance";
    case 504:
      return "Gateway Timeout - Server didn't respond in time";
    default:
      return "Unexpected server error: HTTP $statusCode";
  }
}
