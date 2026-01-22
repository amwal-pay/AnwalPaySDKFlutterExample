import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A singleton class to manage logs across the application
class LogsManager {
  static final LogsManager _instance = LogsManager._internal();
  factory LogsManager() => _instance;
  LogsManager._internal();

  final List<LogEntry> _logs = [];
  final ValueNotifier<List<LogEntry>> logsNotifier = ValueNotifier([]);

  void addLog(String message, LogType type) {
    final entry = LogEntry(
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );
    _logs.add(entry);
    logsNotifier.value = List.from(_logs);
  }

  void clearLogs() {
    _logs.clear();
    logsNotifier.value = [];
  }

  List<LogEntry> get logs => List.from(_logs);
}

/// Represents different types of logs
enum LogType {
  response,
  cancelled,
  customerId,
  error,
  info,
  debug,
}

/// Represents a single log entry
class LogEntry {
  final String message;
  final LogType type;
  final DateTime timestamp;

  LogEntry({
    required this.message,
    required this.type,
    required this.timestamp,
  });

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}

/// A widget that displays all logs in a modal bottom sheet
class LogsViewer extends StatelessWidget {
  const LogsViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'SDK Logs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => LogsManager().clearLogs(),
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Clear all logs',
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Logs list
          Expanded(
            child: ValueListenableBuilder<List<LogEntry>>(
              valueListenable: LogsManager().logsNotifier,
              builder: (context, logs, child) {
                if (logs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No logs yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'SDK interactions will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return LogEntryWidget(log: log);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays a single log entry
class LogEntryWidget extends StatelessWidget {
  final LogEntry log;

  const LogEntryWidget({Key? key, required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _showLogDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getLogIcon(),
                  const SizedBox(width: 8),
                  Text(
                    _getLogTypeText(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getLogColor(),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    log.formattedTimestamp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                log.message.length > 100
                    ? '${log.message.substring(0, 100)}...'
                    : log.message,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getLogIcon() {
    switch (log.type) {
      case LogType.response:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case LogType.cancelled:
        return const Icon(Icons.cancel, color: Colors.orange, size: 20);
      case LogType.customerId:
        return const Icon(Icons.person, color: Colors.blue, size: 20);
      case LogType.error:
        return const Icon(Icons.error, color: Colors.red, size: 20);
      case LogType.info:
        return const Icon(Icons.info, color: Colors.blue, size: 20);
      case LogType.debug:
        return const Icon(Icons.bug_report, color: Colors.grey, size: 20);
    }
  }

  String _getLogTypeText() {
    switch (log.type) {
      case LogType.response:
        return 'Response';
      case LogType.cancelled:
        return 'Cancelled';
      case LogType.customerId:
        return 'Customer ID';
      case LogType.error:
        return 'Error';
      case LogType.info:
        return 'Info';
      case LogType.debug:
        return 'Debug';
    }
  }

  Color _getLogColor() {
    switch (log.type) {
      case LogType.response:
        return Colors.green;
      case LogType.cancelled:
        return Colors.orange;
      case LogType.customerId:
        return Colors.blue;
      case LogType.error:
        return Colors.red;
      case LogType.info:
        return Colors.blue;
      case LogType.debug:
        return Colors.grey;
    }
  }

  void _showLogDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _getLogIcon(),
            const SizedBox(width: 8),
            Text(_getLogTypeText()),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Time: ${log.formattedTimestamp}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                log.message,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: log.message));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Extension to easily show logs viewer
extension LogsViewerExtension on BuildContext {
  void showLogsViewer() {
    showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LogsViewer(),
    );
  }
}