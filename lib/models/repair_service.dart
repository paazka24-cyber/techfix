class RepairService {
  final String id;
  final String category; // Phone, Laptop, Tablet, Console
  final String title;
  final String description;
  final int price; // "from" price in dollars
  final String duration;

  const RepairService({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
  });
}

const serviceCategories = ['All', 'Phone', 'Laptop', 'Tablet', 'Console'];

const expressSurcharge = 20;

const repairServices = <RepairService>[
  // Phone
  RepairService(
    id: 'phone_screen',
    category: 'Phone',
    title: 'Screen & display replacement',
    description: 'Cracked or dead display swapped for a quality panel.',
    price: 149,
    duration: '60-90 min',
  ),
  RepairService(
    id: 'phone_battery',
    category: 'Phone',
    title: 'Battery replacement',
    description: 'New battery with a full health report.',
    price: 69,
    duration: '30 min',
  ),
  RepairService(
    id: 'phone_port',
    category: 'Phone',
    title: 'Charging port repair',
    description: 'Port cleaned or replaced, then tested for fast-charge.',
    price: 59,
    duration: '45 min',
  ),
  RepairService(
    id: 'phone_liquid',
    category: 'Phone',
    title: 'Liquid damage assessment',
    description:
        'Board-level clean, corrosion treatment and a condition report.',
    price: 89,
    duration: '24 hours',
  ),
  RepairService(
    id: 'phone_camera',
    category: 'Phone',
    title: 'Camera repair',
    description: 'Blurry, cracked or non-working camera module replaced.',
    price: 79,
    duration: '45 min',
  ),
  // Laptop
  RepairService(
    id: 'laptop_keyboard',
    category: 'Laptop',
    title: 'Keyboard & hinge service',
    description: 'Keyboard deck or hinge assembly replaced and stress-tested.',
    price: 129,
    duration: '2 hours',
  ),
  RepairService(
    id: 'laptop_screen',
    category: 'Laptop',
    title: 'Screen replacement',
    description: 'Broken or flickering laptop display replaced.',
    price: 179,
    duration: '2 hours',
  ),
  RepairService(
    id: 'laptop_battery',
    category: 'Laptop',
    title: 'Battery replacement',
    description: 'New battery and charging circuit check.',
    price: 89,
    duration: '1 hour',
  ),
  RepairService(
    id: 'laptop_tuneup',
    category: 'Laptop',
    title: 'Slow performance tune-up',
    description: 'Cleaning, malware check, SSD and RAM health review.',
    price: 49,
    duration: '1 hour',
  ),
  // Tablet
  RepairService(
    id: 'tablet_screen',
    category: 'Tablet',
    title: 'Screen replacement',
    description: 'Cracked glass or unresponsive touch fixed.',
    price: 119,
    duration: '90 min',
  ),
  RepairService(
    id: 'tablet_battery',
    category: 'Tablet',
    title: 'Battery replacement',
    description: 'New battery with a full health check.',
    price: 79,
    duration: '45 min',
  ),
  RepairService(
    id: 'tablet_port',
    category: 'Tablet',
    title: 'Charging port repair',
    description: 'Port cleaned or replaced, then tested.',
    price: 59,
    duration: '45 min',
  ),
  // Console
  RepairService(
    id: 'console_hdmi',
    category: 'Console',
    title: 'HDMI port reflow',
    description: 'Display output repaired at board level, then load-tested.',
    price: 99,
    duration: '2 hours',
  ),
  RepairService(
    id: 'console_heat',
    category: 'Console',
    title: 'Overheating & fan clean',
    description: 'Deep clean, new thermal paste and fan check.',
    price: 59,
    duration: '1 hour',
  ),
  RepairService(
    id: 'console_drive',
    category: 'Console',
    title: 'Disc drive repair',
    description: 'Drive that will not read or eject discs repaired.',
    price: 89,
    duration: '2 hours',
  ),
];
