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
          : buildShipmentDetail(selectedShipment!),
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

  Widget buildShipmentDetail(Map<String, dynamic> shipment) {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/world_map.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.green, BlendMode.hue),
            ),
          ),
          child: Center(
            child: Icon(Icons.flight, size: 40, color: Colors.white),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                        child: Text(
                          shipment['from'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.flight, color: const Color(0xFF92B61B)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          shipment['to'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Sender:', shipment['shipperName']),
                  _buildDetailRow('Recipient:', shipment['receiverName']),
                  const SizedBox(height: 10),
                  ...shipment['events'].map<Widget>((event) => _buildStatusRow(
                    event['description'],
                    '${event['date']} ${event['time']}',
                  )),
                  const SizedBox(height: 20),
                  _buildDetailRow('Token:', 'BP#${DateTime.now().millisecondsSinceEpoch}'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDownloadButton('Download document', Icons.description),
                      _buildDownloadButton('Download facture', Icons.receipt),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 10, color: Color(0xFF92B61B)),
          const SizedBox(width: 8),
          Expanded(child: Text(status, style: const TextStyle(fontSize: 14))),
          Text(date, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(String text, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF92B61B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF92B61B)),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Color(0xFF92B61B))),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF92B61B)),
          ],
        ),
      ),
    );
  }
}