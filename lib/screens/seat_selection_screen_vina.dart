import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/booking_controller_nadif.dart';
import '../widgets/seat_item_vina.dart';
import '../screens/profile_screen_nadif.dart';
import '../utils/constants.dart';

class SeatSelectionScreenVina extends StatefulWidget {
  final String movieId;
  final String movieTitle;
  final int basePrice;

  const SeatSelectionScreenVina({
    super.key,
    required this.movieId,
    required this.movieTitle,
    required this.basePrice,
  });

  @override
  State<SeatSelectionScreenVina> createState() => _SeatSelectionScreenVinaState();
}

class _SeatSelectionScreenVinaState extends State<SeatSelectionScreenVina> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<BookingControllerNadif>(context, listen: false);
      controller.loadBookedSeats(widget.movieId);
    });
  }

  List<String> _generateSeatMatrix() {
    List<String> seats = [];
    
    for (int i = 1; i <= 48; i++) {
      seats.add('$i');
    }
    
    return seats;
  }

  Widget _buildScreenDisplay() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.netflixGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.netflixRed, width: 2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.netflixGrey,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'SCREEN',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.netflixRed,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 200,
            color: AppColors.netflixRed,
          ),
          const SizedBox(height: 12),
          Text(
            widget.movieTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All eyes forward please',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid(BookingControllerNadif controller) {
    final seats = _generateSeatMatrix();
    
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: seats.length,
        itemBuilder: (context, index) {
          final seatId = seats[index];
          final isBooked = !controller.isSeatAvailable(seatId);
          final isSelected = controller.isSeatSelected(seatId);
          
          return Tooltip(
            message: isBooked ? 'Already booked' : 
                    isSelected ? 'Selected - Tap to deselect' : 
                    'Available - Tap to select',
            child: SeatItemVina(
              seatId: seatId,
              isSold: isBooked,
              isSelected: isSelected,
              onTap: isBooked
                  ? null
                  : () => controller.toggleSeat(seatId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingSection(BookingControllerNadif controller) {
    final totalPrice = controller.calculateTotalPrice(widget.movieTitle, widget.basePrice);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.netflixBlack,
        border: Border(top: BorderSide(color: AppColors.netflixGrey)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.netflixGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_seat, color: AppColors.netflixRed),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Seats',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        controller.selectedSeats.isEmpty
                            ? 'No seats selected'
                            : controller.selectedSeats.join(', '),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: controller.hasSelectedSeats
                        ? AppColors.netflixRed
                        : AppColors.netflixGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.selectedSeats.length} seats',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.netflixGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Price',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp $totalPrice',
                      style: const TextStyle(
                        color: AppColors.netflixRed,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (controller.selectedSeats.isNotEmpty)
                      Text(
                        '${controller.selectedSeats.length} × Rp ${widget.basePrice}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (controller.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[900]!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => controller.clearError(),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.selectedSeats.isEmpty
                      ? null
                      : controller.clearSelectedSeats,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.selectedSeats.isEmpty || controller.isLoading
                      ? null
                      : () => _showConfirmationDialog(controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.netflixRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BookingControllerNadif controller) {
    final totalPrice = controller.calculateTotalPrice(widget.movieTitle, widget.basePrice);
    final breakdown = controller.getPriceBreakdown(widget.movieTitle, widget.basePrice);
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.netflixBlack,
        title: const Text(
          '⚠️ PERMANENT BOOKING CONFIRMATION',
          style: TextStyle(color: AppColors.netflixRed),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This booking is PERMANENT and CANNOT be cancelled or refunded.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Movie: ${widget.movieTitle}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Seats: ${controller.selectedSeats.join(', ')}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: Rp $totalPrice',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.netflixGrey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price Breakdown:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...breakdown.split('\n').map((line) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          line,
                          style: TextStyle(
                            color: line.contains('Total:') 
                                ? AppColors.netflixRed 
                                : line.contains('===')
                                ? Colors.grey[300]
                                : Colors.grey,
                            fontSize: 12,
                            fontWeight: line.contains('Total:') ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      )
                    ).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _processBooking(controller);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.netflixRed,
            ),
            child: const Text('CONFIRM PERMANENT BOOKING'),
          ),
        ],
      ),
    );
  }

  Future<void> _processBooking(BookingControllerNadif controller) async {
    try {
      final bookingId = await controller.createBooking(
        movieId: widget.movieId,
        movieTitle: widget.movieTitle,
        basePrice: widget.basePrice,
      );

      if (mounted && bookingId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.netflixRed,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Booking successful! Check your profile for QR code.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreenNadif(
                          highlightBookingId: bookingId,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'VIEW',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.netflixDark,
      appBar: AppBar(
        backgroundColor: AppColors.netflixBlack,
        title: const Text('Select Seats'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BookingControllerNadif>(
        builder: (context, controller, _) {
          return Column(
            children: [
              _buildScreenDisplay(),
              const SizedBox(height: 20),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _LegendItem(color: AppColors.seatAvailable, label: 'Available'),
                    _LegendItem(color: AppColors.seatSelected, label: 'Selected'),
                    _LegendItem(color: AppColors.seatSold, label: 'Booked'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              _buildSeatGrid(controller),
              
              _buildBookingSection(controller),
            ],
          );
        },
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}