import 'package:cardiocare/signal_app/model/signal_enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cardiocare/signal_app/widgets/signal_renderers.dart';
import 'package:cardiocare/services/db_helper.dart';
import 'package:cardiocare/signal_app/model/signal_model.dart';
import 'package:cardiocare/utils/format_datetime.dart';

class ListItem extends StatelessWidget {
  final Signal signal;

  const ListItem({
    super.key,
    required this.signal,
  });

  void Function() _showPeakDrawer(BuildContext context) {
    return () {
      showModalBottomSheet(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return PeakItemDrawer(signal: signal);
        },
      );
    };
  }

  String _getSignalHighlight(dynamic signal) {
    switch (signal.signalType) {
      case SignalType.ecg:
        return '${signal.hbpm} bpm';
      case SignalType.bp:
        return '${signal.systolic}/${signal.diastolic} mmHg';
      case SignalType.btemp:
        return '${signal.avgTemp.toStringAsFixed(1)} °C';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper dbhelper = Provider.of<DatabaseHelper>(context);

    return Dismissible(
      key: Key(signal.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: signal.signalType.color,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child:
            Icon(Icons.delete, color: Theme.of(context).colorScheme.secondary),
      ),
      onDismissed: (direction) async {
        int success = await dbhelper.deleteSignal(signal);
        if (success == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${signal.name} deleted successfully"),
            ),
          );
        }
      },
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              title: Text("Delete ${signal.name}?"),
              content: const Text("Are you sure you want to delete this item?"),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("DELETE"),
                ),
              ],
            );
          },
        );
      },
      child: ListTile(
        tileColor: Theme.of(context).colorScheme.secondary,
        iconColor: signal.signalType.color,
        splashColor: signal.signalType.color.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: signal.signalType.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(child: signal.signalType.icon),
        ),
        onTap: _showPeakDrawer(context),
        title: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                signal.name,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 1.0,
                ),
                decoration: BoxDecoration(
                  color: signal.signalType.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getSignalHighlight(signal),
                  style: TextStyle(
                    fontSize: 12,
                    color: signal.signalType.color,
                  ),
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                formatDuration(
                  signal.startTime.toIso8601String(),
                  signal.stopTime.toIso8601String(),
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            Text(
              formatDateTime(signal.startTime.toIso8601String()),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PeakItemDrawer extends StatefulWidget {
  final dynamic signal;

  const PeakItemDrawer({super.key, required this.signal});

  @override
  State<PeakItemDrawer> createState() => _PeakItemDrawerState();
}

class _PeakItemDrawerState extends State<PeakItemDrawer> {
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;
  final DatabaseHelper dbhelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _init() {
    _isEditing = false;
    _controller.text = widget.signal.name;
  }

  Future<void> _updateSignalName(DatabaseHelper dbhelper) async {
    String prevSignalName = widget.signal.name;
    widget.signal.name = _controller.text;
    final success = await dbhelper.updateSignal(widget.signal);
    if (success == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "$prevSignalName updated to ${widget.signal.name} successfully"),
        ),
      );
    }
    setState(() {
      _init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper dbhelper = Provider.of<DatabaseHelper>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _isEditing
                          ? Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  labelText: "Signal Name",
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(4),
                                ),
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                autofocus: true,
                              ),
                            )
                          : Expanded(
                              child: Text(
                                widget.signal.name,
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      IconButton(
                        icon: Icon(_isEditing ? Icons.done : Icons.edit),
                        onPressed: () {
                          if (_isEditing) {
                            _updateSignalName(dbhelper);
                          } else {
                            setState(() {
                              _isEditing = true;
                            });
                          }
                        },
                      ),
                      if (_isEditing)
                        IconButton(
                          icon: const Icon(Icons.close_sharp),
                          onPressed: () {
                            if (_isEditing) {
                              setState(() {
                                _init();
                              });
                            }
                          },
                        ),
                    ],
                  ),
                  Text(
                    widget.signal.signalType.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            _buildSignalContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalContent() {
    switch (widget.signal.signalType) {
      case SignalType.ecg:
        return ECGRenderer(
          isActive: true,
          ecgSignal: widget.signal,
        );
      case SignalType.bp:
        return BPRenderer(
          isActive: true,
          bpSignal: widget.signal,
        );
      case SignalType.btemp:
        return BtempRenderer(
          isActive: true,
          btempSignal: widget.signal,
        );
      default:
        return const Center(
          child: Text("Unable to render signal data"),
        );
    }
  }
}