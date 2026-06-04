import 'package:flutter/material.dart';

import '../models/printer_device.dart';

class PrintersTab extends StatelessWidget {
  const PrintersTab({
    super.key,
    required this.permissionsGranted,
    required this.loading,
    required this.printers,
    required this.connectedPrinter,
    required this.onRefresh,
    required this.onConnect,
    required this.onDisconnect,
  });

  final bool permissionsGranted;
  final bool loading;
  final List<PrinterDevice> printers;
  final PrinterDevice? connectedPrinter;
  final VoidCallback onRefresh;
  final ValueChanged<PrinterDevice> onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PrinterGuideCard(
          connectedPrinter: connectedPrinter,
          loading: loading,
          onRefresh: onRefresh,
          onDisconnect: onDisconnect,
        ),
        if (!permissionsGranted) ...[
          const SizedBox(height: 12),
          Text(
            'Bluetooth permission is required.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        if (printers.isEmpty && permissionsGranted)
          const _EmptyPrinterCard()
        else
          for (final device in printers) ...[
            _PrinterDeviceCard(
              device: device,
              loading: loading,
              connected: connectedPrinter?.address == device.address,
              onConnect: () => onConnect(device),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _PrinterGuideCard extends StatelessWidget {
  const _PrinterGuideCard({
    required this.connectedPrinter,
    required this.loading,
    required this.onRefresh,
    required this.onDisconnect,
  });

  final PrinterDevice? connectedPrinter;
  final bool loading;
  final VoidCallback onRefresh;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final isConnected = connectedPrinter != null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paired Bluetooth printers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Turn on the printer, pair it in Android Bluetooth settings first, then come back here and connect.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                const Chip(label: Text('80mm mode')),
                Chip(
                  label: Text(isConnected ? 'Connected' : 'Disconnected'),
                ),
              ],
            ),
            if (isConnected) ...[
              const SizedBox(height: 8),
              Text(
                'Connected device: ${connectedPrinter!.name}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(connectedPrinter!.address),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: loading ? null : onRefresh,
                    child: Text(loading ? 'Loading...' : 'Refresh list'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: loading || !isConnected ? null : onDisconnect,
                    icon: const Icon(Icons.bluetooth_disabled),
                    label: const Text('Disconnect'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrinterDeviceCard extends StatelessWidget {
  const _PrinterDeviceCard({
    required this.device,
    required this.loading,
    required this.connected,
    required this.onConnect,
  });

  final PrinterDevice device;
  final bool loading;
  final bool connected;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(device.address),
        trailing: FilledButton(
          onPressed: loading || connected ? null : onConnect,
          child: Text(connected ? 'Connected' : 'Connect'),
        ),
      ),
    );
  }
}

class _EmptyPrinterCard extends StatelessWidget {
  const _EmptyPrinterCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No paired printer found'),
            Text('Pair the printer from Android settings first.'),
          ],
        ),
      ),
    );
  }
}
