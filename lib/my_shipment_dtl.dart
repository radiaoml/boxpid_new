import 'package:flutter/material.dart';

class MyShipmentDtl extends StatefulWidget {
  final Map<String, dynamic> shipment;

  const MyShipmentDtl({super.key, required this.shipment});

  @override
  State<MyShipmentDtl> createState() => _MyShipmentDtlState();
}

class _MyShipmentDtlState extends State<MyShipmentDtl> {
  @override
  Widget build(BuildContext context) {
    final shipment = widget.shipment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Details'),
        leading: const BackButton(),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
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
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(shipment['icon'], color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Shipment Info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('From:', shipment['from']),
              _buildDetailRow('To:', shipment['to']),
              _buildDetailRow('Departure:', shipment['fromDate']),
              _buildDetailRow('Arrival:', shipment['toDate']),
              const SizedBox(height: 10),
              const Divider(),
              const Text(
                'More information coming soon...',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
