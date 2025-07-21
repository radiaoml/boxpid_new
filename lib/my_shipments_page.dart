import 'dart:math';
import 'package:flutter/material.dart';

class MyShipmentsPage extends StatefulWidget {
  const MyShipmentsPage({super.key});

  @override
  State<MyShipmentsPage> createState() => _MyShipmentsPageState();
}

class _MyShipmentsPageState extends State<MyShipmentsPage> {
  List<Map<String, dynamic>> shipments = [];
  Map<String, dynamic>? selectedShipment;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShipments();
  }

  Future<void> fetchShipments() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      shipments = [
        {
          'from': 'Casablanca',
          'to': 'Marrakech',
          'fromDate': '17/07/2025',
          'toDate': '17/07/2025',
          'icon': Icons.local_shipping,
          'direction': Icons.arrow_downward,
          'shipperName': 'Ayoub ELKEBBAR',
          'receiverName': 'Amine IRAQI',
          'totalWeight': '2',
          'events': [
            {'description': 'Order created', 'date': '17/07/2025', 'time': '14:30'}
          ]
        },
        {
          'from': 'Fes',
          'to': 'Tanger',
          'fromDate': '15/07/2025',
          'toDate': '15/07/2025',
          'icon': Icons.mail,
          'direction': Icons.arrow_upward,
          'shipperName': 'Radia Omalek',
          'receiverName': 'Hamza El Mersly',
          'totalWeight': '5',
          'events': [
            {'description': 'Shipped', 'date': '15/07/2025', 'time': '12:00'}
          ]
        },
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedShipment == null ? "My shipments" : "Track shipment"),
        leading: selectedShipment != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedShipment = null;
            });
          },
        )
            : null,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : selectedShipment == null
          ? buildShipmentList()
          : SingleChildScrollView(
        child: ShipmentTicket(shipment: selectedShipment!),
      ),
    );
  }

  Widget buildShipmentList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Text(
            "Recent shipments",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: shipments.length,
            itemBuilder: (context, index) {
              final shipment = shipments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      selectedShipment = shipment;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF92B61B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(shipment['icon'], color: const Color(0xFF92B61B)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(shipment['from'],
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(shipment['fromDate'],
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(shipment['to'],
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(shipment['toDate'],
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Icon(shipment['direction'], color: const Color(0xFF92B61B)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// DashedLine widget for horizontal dashed separator
class DashedLine extends StatelessWidget {
  final double height;
  final Color color;

  const DashedLine({this.height = 1, this.color = Colors.grey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 5.0;
          const dashSpace = 3.0;
          final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class ShipmentTicket extends StatelessWidget {
  final Map<String, dynamic> shipment;

  const ShipmentTicket({super.key, required this.shipment});

  // Random 12-char alphanumeric tracking code generator
  String generateTrackingCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(12, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: const Text("Standard Delivery"),
                  backgroundColor: Colors.green.shade100,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      shipment['from'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.local_shipping, size: 16),
                    Text(
                      shipment['to'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Shipping Ticket",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ticketDetail("Sender", shipment['shipperName']),
            _ticketDetail("Receiver", shipment['receiverName']),
            _ticketDetail("From Date", shipment['fromDate']),
            _ticketDetail("To Date", shipment['toDate']),
            _ticketDetail("Weight", "${shipment['totalWeight']} Kg"),
            const SizedBox(height: 20),

            // Dashed line separator
            const DashedLine(height: 1, color: Colors.grey),

            const SizedBox(height: 20),

            Container(
              height: 50,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: Text(
                generateTrackingCode(),
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Tracking: 0000 ${shipment['shipperName'].hashCode.toString().substring(0, 4)} ${shipment['receiverName'].hashCode.toString().substring(0, 4)}",
                style: const TextStyle(fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _ticketDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
