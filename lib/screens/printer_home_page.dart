import 'package:flutter/material.dart';

import '../controllers/printer_controller.dart';
import 'history_tab.dart';
import 'home_tab.dart';
import 'printers_tab.dart';

class PrinterHomePage extends StatefulWidget {
  const PrinterHomePage({super.key});

  @override
  State<PrinterHomePage> createState() => _PrinterHomePageState();
}

class _PrinterHomePageState extends State<PrinterHomePage> {
  final PrinterController controller = PrinterController();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAction(controller.setup);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _runAction(Future<String?> Function() action) async {
    final message = await action();

    if (!mounted || message == null || message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final pages = [
          HomeTab(
            permissionsGranted: controller.permissionsGranted,
            selectedImage: controller.selectedImage,
            connectedPrinter: controller.connectedPrinter,
            lastError: controller.lastError,
            busy: controller.busy,
            onPickImage: () => _runAction(controller.pickImage),
            onPrintImage: () => _runAction(controller.printSelectedImage),
            onPrintTest: () => _runAction(controller.printTestPage),
          ),
          PrintersTab(
            permissionsGranted: controller.permissionsGranted,
            loading: controller.loadingPrinters || controller.busy,
            printers: controller.printers,
            connectedPrinter: controller.connectedPrinter,
            onRefresh: () => _runAction(controller.refreshPrinters),
            onConnect: (device) => _runAction(() => controller.connect(device)),
            onDisconnect: () => _runAction(controller.disconnectDevice),
          ),
          HistoryTab(items: controller.history),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Woosim Printer'),
            actions: [
              if (controller.busy)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
          body: pages[currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.bluetooth_outlined),
                selectedIcon: Icon(Icons.bluetooth),
                label: 'Printers',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'History',
              ),
            ],
          ),
        );
      },
    );
  }
}
