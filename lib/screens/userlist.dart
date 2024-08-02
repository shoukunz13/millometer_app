import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mill_project/widgets/adduser.dart';

class UserList extends StatefulWidget {
  final String? millID; // Parameter to filter users by Mill ID

  const UserList({super.key, this.millID});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<UserData> users = [];
  final String baseUrl =
      'http://10.0.2.2:3004/api/userList'; // Update to your API URL

  @override
  void didUpdateWidget(covariant UserList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.millID != oldWidget.millID) {
      _fetchUsers(); // Fetch users when millID changes
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'PiID': widget.millID, // Use PiID in query parameters
      });
      final response = await http.get(
        uri,
        headers: {
          'api-key':
              '1b50e01f728f56b50a66c92261b746c0aa8277251de247df713d72f5a8a65b04', // Adjust API key
        },
      );
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        print(
            'Users fetched successfully: ${jsonResponse.length} users received');
        setState(() {
          users = jsonResponse.map((user) => UserData.fromJson(user)).toList();
        });
      } else {
        print('Failed to load users. Status code: ${response.statusCode}');
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 5,
      fit: FlexFit.loose,
      child: SizedBox(
        height: 490,
        child: Stack(
          children: [
            Positioned.fill(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  print('Building user widget: ${user.name}, ${user.phoneNum}');
                  return User(
                    name: user.name,
                    phoneNum: user.phoneNum,
                    status: user.status,
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    _showAddUserScreen(context);
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddUser();
        },
      ),
    );
  }
}

class UserData {
  final String name;
  final String phoneNum;
  final int status;

  UserData({required this.name, required this.phoneNum, this.status = -1});

  factory UserData.fromJson(Map<String, dynamic> json) {
    print('Parsing UserData from JSON: $json');
    return UserData(
      name: json['name'] ?? 'Unknown',
      phoneNum: json['phoneNum'] ?? 'Unknown',
      status: json['status'] ?? -1,
    );
  }
}

class User extends StatelessWidget {
  final String name;
  final String phoneNum;
  final int status;

  const User({
    super.key,
    required this.name,
    required this.phoneNum,
    this.status = -1,
  });

  @override
  Widget build(BuildContext context) {
    print('Building User widget: $name, $phoneNum, status: $status');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: 400,
        height: 90,
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
                  child: _statusIcon(status),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      name,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      phoneNum,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon _statusIcon(int value) {
    if (value == 0) {
      return Icon(Icons.circle,
          color: Color.fromARGB(255, 169, 169, 169), size: 10);
    } else if (value == 1) {
      return Icon(Icons.circle,
          color: const Color.fromARGB(255, 101, 224, 105), size: 10);
    } else {
      return Icon(Icons.circle, color: Colors.amber, size: 10);
    }
  }
}
