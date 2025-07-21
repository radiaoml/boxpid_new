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
          // National shipment
          'icon': Icons.location_on,

          'direction': Icons.arrow_downward,
          'shipperName': 'Ayoub ELKEBBAR',
          'shipperPhone': '06xxxx8456',
          'shipperCity': 'Casablanca',
          'receiverName': 'Amine IRAQI',
          'receiverPhone': '07xxxx6538',
          'receiverCity': 'Marrakech',
          'company': 'Boxpid Logistics',
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
          // International shipment
          'icon': Icons.public,

          'direction': Icons.arrow_upward,
          'shipperName': 'Radia Omalek',
          'shipperPhone': '06xxxx1234',
          'shipperCity': 'Fes',
          'receiverName': 'Hamza El Mersly',
          'receiverPhone': '07xxxx4321',
          'receiverCity': 'Tanger',
          'company': 'Boxpid Express',
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
      backgroundColor: Colors.white,
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

  String generateTrackingCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(12, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final trackingCode = generateTrackingCode();

    return Center(
      child: Column(
        children: [
          ClipPath(
            clipper: DolDurmaClipper(right: 40, holeRadius: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF91B51B),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              width: 300,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: Center(
                child: Text(
                  trackingCode,
                  style: const TextStyle(
                    fontSize: 18,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          /// 📦 WHITE SHIPPING TICKET
          Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
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
            child: Row(
              children: [
                Chip(
                  label: const Text("Standard Delivery"),
                  backgroundColor: const Color(0xFFC7D8C6),

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
          ),


          const SizedBox(height: 16),
          Container(
            width: 320,
            padding: const EdgeInsets.only(top: 16, bottom: 16),  // no side padding
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 30),         // light side margin + bottom margin
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Sender", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Receiver", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(shipment['shipperName']),
                    Text(shipment['receiverName']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(shipment['shipperPhone']),
                    Text(shipment['receiverPhone']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(shipment['shipperCity']),
                    Text(shipment['receiverCity']),
                  ],
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                const Text("Pickup & Delivery", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Pickup", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Delivery", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(shipment['fromDate']),
                    Text(shipment['toDate']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(shipment['events'][0]['time']), // assuming time is the same for pickup/delivery
                    Text(shipment['events'][0]['time']),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                const Text("Package Details", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _infoRow("Dimensions", "16x16x4"), // hardcoded for now
                _infoRow("Weight", "${shipment['totalWeight']} Kg"),
                _infoRow("Description", "Lorem ipsum dolor sit amet."),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
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


class DolDurmaClipper extends CustomClipper<Path> {
  DolDurmaClipper({required this.right, required this.holeRadius});

  final double right;
  final double holeRadius;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - right - holeRadius, 0.0)
      ..arcToPoint(
        Offset(size.width - right, 0),
        clockwise: false,
        radius: const Radius.circular(1),
      )
      ..lineTo(size.width, 0.0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - right, size.height)
      ..arcToPoint(
        Offset(size.width - right - holeRadius, size.height),
        clockwise: false,
        radius: const Radius.circular(1),
      )
      ..lineTo(0.0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(DolDurmaClipper oldClipper) => true;
}
