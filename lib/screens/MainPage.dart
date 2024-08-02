import 'package:flutter/material.dart';
import 'package:mill_project/widgets/mills.dart';
import 'package:mill_project/widgets/home.dart';
import 'package:mill_project/widgets/settings.dart';
import 'userlist.dart';
import 'package:mill_project/services/get_mill_service.dart'; // Import the MillService

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedMillIndex = 0;
  String appBarTitle = "Loading...";
  List<Mill> mills = [];
  int _selectedIndex = 1; // Add the missing _selectedIndex variable
  final MillService millService = MillService(); // Instantiate MillService

  // Initialize _widgetOptions with placeholder widgets
  List<Widget> _widgetOptions = <Widget>[
    const UserList(), // Placeholder for UserList
    HomeWidget(millID: ''), // Placeholder for HomeWidget
    const Settings(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchMills();
  }

  Future<void> _fetchMills() async {
    try {
      final data = await millService.fetchMills();

      setState(() {
        mills = data;
        if (mills.isNotEmpty) {
          _onMillSelected(0); // Set the first mill as the default selected mill
        } else {
          appBarTitle = "No Mills Available";
        }
      });
    } catch (e) {
      print('Error fetching mills: $e');
      setState(() {
        appBarTitle = "Error Loading Mills";
      });
    }
  }

  void _onMillSelected(int index) {
    setState(() {
      selectedMillIndex = index;
      _setAppBarTitle(mills[index].label, mills[index].raspberrypi_id);

      // Update the UserList and HomeWidget with the selected mill's ID
      _widgetOptions[0] = UserList(millID: mills[index].raspberrypi_id);
      _widgetOptions[1] = HomeWidget(millID: mills[index].raspberrypi_id);

      // Debug statement
      print('Selected millID: ${mills[index].raspberrypi_id}');
    });
  }

  void _setAppBarTitle(String title, String millID) {
    setState(() {
      appBarTitle = title.isEmpty ? millID : title;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _widgetOptions[_selectedIndex],
                      const SizedBox(height: 20),
                      Flexible(
                        flex: 2,
                        fit: FlexFit.loose,
                        child: SizedBox(
                          height: 90,
                          child: mills.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: mills.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        _onMillSelected(index);
                                      },
                                      child: Mills(
                                        raspberrypiId:
                                            mills[index].raspberrypi_id,
                                        label: mills[index].label,
                                        isSelected: selectedMillIndex == index,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: 'Userlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
